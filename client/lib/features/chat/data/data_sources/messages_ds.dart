import 'dart:async';

import 'package:client/core/domain/services/auth_service.dart';
import 'package:client/features/chat/data/data_sources/typing_ds.dart';
import 'package:client/features/chat/data/models/conversation_model.dart';
import 'package:client/features/chat/data/models/message_firestore_model.dart';
import 'package:client/features/chat/domain/entities/conversation.dart';
import 'package:client/features/chat/domain/entities/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:stream_d/stream_d.dart';

class MessagesDS {
  final AuthService authService;
  final FirebaseFirestore firestore;
  final TypingDS typingDs;
  final List<String> _recentlyCreatedConversations = [];

  final Set<String> _updatedToReadMessages = {};
  // stores messages that have been received in local client but not marked as received on remote firebase
  final Set<Message> _updatedToReceivedMessages = {};

  MessagesDS(
      {required this.authService,
      required this.firestore,
      required this.typingDs}) {
    authService.addOnSignOutListener(() {
      _updatedToReadMessages.clear();
      _updatedToReceivedMessages.clear();
    });
  }

  DocumentReference<Map<String, dynamic>> _conversationRef(
      {required String conversationId}) {
    return firestore.collection("conversations").doc(conversationId);
  }

  Future<Conversation?> getConversationById(
      {required String conversationId}) async {
    final snapshot =
        await _conversationRef(conversationId: conversationId).get();
    if (!snapshot.exists) {
      return null;
    }
    Map<String, dynamic>? data = snapshot.data();
    data ??= (await _conversationRef(conversationId: conversationId)
            .get(const GetOptions(source: Source.server)))
        .data();
    return ConversationModel.fromData(data, []);
  }

  Stream<List<Conversation>> conversationListStream() {
    final Map<String, Conversation?> conversations = {};
    final StreamController<List<Conversation>> streamCtrl = StreamController();
    Map<String, RefreshTypingListener> typingListener = {};

    void addEvent() {
      print('addEvent: ');
      final event =
          conversations.values.where((e) => e != null).map((e) => e!).toList();
      print(event);
      streamCtrl.add(event);
    }

    void closeConversation(String conversationId) {
      if (typingListener[conversationId] != null) {
        typingDs.removeListener(listener: typingListener[conversationId]!);
      }
      typingListener.remove(conversationId);
      conversations.remove(conversationId);
    }

    final subscription = StreamD(firestore
            .collection("conversations")
            .where(ConversationModel.kParticipants,
                arrayContains: authService.loggedUid)
            .snapshots())
        .listenD((remoteConversations) async {
      for (final existingConversationId in List.from(conversations.keys)) {
        if (!remoteConversations.docs
            .any((doc) => doc.id == existingConversationId)) {
          closeConversation(existingConversationId);
        }
      }

      print("remoteConversations.docs -> ${remoteConversations.docs.length}");

      // handling typing events for each conversation
      for (final conversation in remoteConversations.docs) {
        final String conversationId = conversation.id;
        final snapshotData = conversation.data();

        if (typingListener[conversationId] == null) {
          typingListener[conversationId] = typingDs.addListener(
              conversationId: conversationId,
              listener: (typingUids) {
                conversations[conversationId] =
                    ConversationModel.fromData(snapshotData, typingUids);
                addEvent();
                if (conversations[conversationId] == null) {
                  print(
                      "looks like conversation \"$conversationId\" has been deleted");
                  closeConversation(conversationId);
                }
              });
        } else {
          conversations[conversationId] = ConversationModel.fromData(
              snapshotData, conversations[conversationId]?.typingUids ?? []);
        }
      }
      addEvent();
    });

    subscription.addOnDone(() {
      print("onDone subscription (messages)");
      streamCtrl.close();
    });
    streamCtrl.onCancel = () {
      print("streamCtrl.onCancel (messages)");
      for (final conversationId in List.from(conversations.keys)) {
        closeConversation(conversationId);
      }
      subscription.cancel();
    };

    return streamCtrl.stream;
  }

  Stream<Conversation> conversationStream({required String conversationId}) {
    final StreamController<Conversation> controller = StreamController();
    final conversationRef = _conversationRef(conversationId: conversationId);
    RefreshTypingListener? typingListener;
    Conversation? _conversation;

    final subscription =
        StreamD(conversationRef.snapshots()).listenD((snapshot) async {
      final snapshotData = snapshot.data();
      if (snapshotData == null) {
        // stream subscription from firebase is closed, so we also need to close our stream controller
        controller.close();
        return;
      }

      _conversation = ConversationModel.fromData(
          snapshotData, _conversation?.typingUids ?? []);

      typingListener ??= typingDs.addListener(
          conversationId: conversationId,
          listener: (typingUids) {
            print("refreshTypingListener: ${typingUids}");
            _conversation =
                ConversationModel.fromData(snapshotData, typingUids);
            if (_conversation != null) {
              controller.add(_conversation!);
            } else {
              print('conversationStream: ignoring event because is null #1');
            }
          });

      _conversation = ConversationModel.fromData(
          snapshotData, _conversation?.typingUids ?? []);
      if (_conversation != null) {
        controller.add(_conversation!);
      } else {
        print('conversationStream: ignoring event because is null #3');
      }
    });

    controller.onCancel = () {
      if (typingListener != null) {
        typingDs.removeListener(listener: typingListener!);
      }
      subscription.cancel();
    };
    subscription.addOnDone(controller.close);

    return controller.stream;
  }

  Stream<List<Message>> messagesStream(
      {required String conversationId,
      // this is limit is used in order to fetch only 1 message for home screen
      int? limit,
      void Function(List<Message> newReceivedMessageList)?
          onNewReceivedMessage}) {
    print('messagesStream called at ${DateTime.now().millisecondsSinceEpoch}');
    assert(authService.loggedUid != null, 'current user is not logged in');

    late final StreamSubscriptionD<QuerySnapshot<Map<String, dynamic>>> sub;
    late final StreamController<List<MessageFirestoreModel>> ctrl;

    Query<Map<String, dynamic>> query = firestore
        .collection("conversation")
        .doc(conversationId)
        .collection("messages")
        .where(MessageFirestoreModel.kParticipants,
            arrayContains: authService.loggedUid!)
        .orderBy(MessageFirestoreModel.kSentAt, descending: false);

    if (limit != null) {
      query = query.limitToLast(limit);
    }

    sub =
        StreamD(query.snapshots(includeMetadataChanges: true)).listenD((event) {
      // event is 'messages' collection
      Future.delayed(const Duration(seconds: 5), () {
        _updatedToReceivedMessages.removeWhere((element) =>
            element.received &&
            element.receivedAt[authService.loggedUid]!.millisecondsSinceEpoch +
                    (4 * 1000) <=
                DateTime.now().millisecondsSinceEpoch);
      });

      final List<Message> onNewReceivedMessageList = [];

      for (int i = 0; i < event.size; i++) {
        final message = MessageFirestoreModel.fromMap(
            event.docs[i].data(), event.docs[i].metadata.hasPendingWrites);

        if (message.senderUid != authService.loggedUid && !message.iReceived) {
          // set 'i received this message' in remote firestore
          if (_updatedToReceivedMessages
              .any((msg) => msg.messageId == message.messageId)) {
            continue;
          }

          _updatedToReceivedMessages.add(message);
          onNewReceivedMessageList.add(message);

          print(
              ">> new message has been received! message.iReceived: ${message.iReceived}");
          event.docs[i].reference.update({
            "${MessageFirestoreModel.kReceivedAt}.${authService.loggedUid}":
                FieldValue.serverTimestamp(),
            MessageFirestoreModel.kPendingReceivement:
                FieldValue.arrayRemove([authService.loggedUid]),
          });

          typingDs.cancelTypingForUid(
              conversationId: conversationId, uid: message.senderUid);
        }
      }

      ctrl.add(_fromMapList(event));
      if (onNewReceivedMessage != null) {
        onNewReceivedMessage(onNewReceivedMessageList
            .sorted((a, b) => a.sentAt.compareTo(b.sentAt))
            .toList());
      }
    });
    ctrl = StreamController<List<MessageFirestoreModel>>(onCancel: () {
      Future.delayed(const Duration(milliseconds: 30), () {
        sub.cancel();
      });
    });

    late void Function() onLoggedOutListener;
    onLoggedOutListener = () {
      print("--> onLoggedOutListener: ${ctrl.isClosed}");
      ctrl.close();
      authService.removeOnSignOutListener(onLoggedOutListener);
    };
    authService.addOnSignOutListener(onLoggedOutListener);

    sub.addOnDone(ctrl.close);

    return ctrl.stream;
  }

  List<MessageFirestoreModel> _fromMapList(
          QuerySnapshot<Map<String, dynamic>> event) =>
      List.from(event.docs)
          .map((e) => MessageFirestoreModel.fromMap(
              e.data(), e.metadata.hasPendingWrites))
          .toList();
}
