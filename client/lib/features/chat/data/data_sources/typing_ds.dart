import 'dart:async';

import 'package:client/core/domain/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const int kTypingDurationMs = 1000;

typedef RefreshTypingListener = void Function(List<String> typingUids);

class TypingDS {
  final FirebaseFirestore firestore;
  final AuthService authService;
  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
      _subscriptionByConversationId = {};
  final Map<String, List<void Function(List<String> typingUids)>>
      _listenersByConversationId = {};
  // TypingDS will defined active, when the listeners are added
  bool _active = false;

  /// for each conversation, store each user's timestamp of their latest type
  /// - Key: conversationId
  /// - Value: Map of:
  /// --- Key: uid
  /// --- Value: Timestamp the user typed at
  final Map<String, Map<String, Timestamp>> _cancelTyping = {};

  // for each conversation, stores the currently typing users
  final Map<String, List<String>> _typingUidsByConversationId = {};
  final List<void Function()> _onCloseListeners = [];

  TypingDS({required this.firestore, required this.authService});

  List<String> typingUids(String conversationUid) =>
      _typingUidsByConversationId[conversationUid] ?? [];

  /// if conversationId is not null, trigger all the listeners that is allocated to that conversationId
  /// it conversationId is null, trigger all the listeners for all the conversationIds
  _triggerListeners({String? conversationId}) {
    if (_active) {
      for (final cId in (conversationId != null
          ? [conversationId]
          : _listenersByConversationId.keys)) {
        for (final listener in (_listenersByConversationId[cId] ?? [])) {
          listener(_typingUidsByConversationId[cId]);
        }
      }
    } else {
      print("not calling listeners, because is active is false");
    }
  }

  RefreshTypingListener addListener(
      {required String conversationId,
      required RefreshTypingListener listener}) {
    _active = true;

    // add listener to certain conversation
    _listenersByConversationId[conversationId] ??= [];
    _listenersByConversationId[conversationId]!.add(listener);
    // trigger conversation listener if we are already subscribing to this conversation
    if (_subscriptionByConversationId[conversationId] != null) {
      _triggerListeners(conversationId: conversationId);
      return listener;
    }
    // subscribe to conversation using conversation id
    _subscriptionByConversationId[conversationId] =
        _ref(conversationId).snapshots().listen((event) {
      final List<String> typingUids = [];

      final typedAtUid = _convertDocsToTypedAtObject(event);
      print('typedAtUid');
      print(typedAtUid);
      for (final String uid
          in List<String>.from(typedAtUid.entries.map((e) => e.key))) {
        // last time certain user has typed
        final DateTime typedAt = typedAtUid[uid]!.toDate();
        typedAtUid.remove(uid);
        final cancelTypingByUid = _cancelTyping[conversationId] ??= {};
        // if last time certain user has typed is not past the deadline, keep that user's typing status active
        if (cancelTypingByUid[uid] != null &&
            cancelTypingByUid[uid]!.millisecondsSinceEpoch >
                typedAt.millisecondsSinceEpoch) {
          continue;
        }
        // if user's timestamp has past the deadline, remove that uid from the list
        cancelTypingByUid.remove(uid);
        const incorrectDevicesClock = 8 * 1000;
        if (DateTime.now().millisecondsSinceEpoch <=
            (kTypingDurationMs + incorrectDevicesClock)) {
          typingUids.add(uid);
        }
      }
      _typingUidsByConversationId[conversationId] = typingUids;

      _triggerListeners(conversationId: conversationId);
    });
    return listener;
  }

  void removeListener(
      {required void Function(List<String> typingUids) listener}) {
    for (final conversationId in _listenersByConversationId.keys) {
      final removed =
          (_listenersByConversationId[conversationId] ?? []).remove(listener);
      // if the last listener is removed and the list of listeners is empty, cancel everything
      if (removed && _listenersByConversationId[conversationId]!.isEmpty) {
        _subscriptionByConversationId[conversationId]!.cancel();
        _subscriptionByConversationId.remove(conversationId);
        _listenersByConversationId.remove(conversationId);
        _cancelTyping[conversationId]?.clear();
        _typingUidsByConversationId[conversationId]?.clear();
        break;
      }
    }
  }

  void cancelTypingForUid(
      {required String conversationId, required String uid}) {
    if (_active) {
      _cancelTyping[conversationId] ??= {};
      _cancelTyping[conversationId]![uid] = Timestamp.now();
      _typingUidsByConversationId[conversationId] =
          (_typingUidsByConversationId[conversationId] ?? [])
              .where((value) => value != uid)
              .toList();

      _triggerListeners(conversationId: conversationId);
    }
  }

  CollectionReference<Map<String, dynamic>> _ref(String conversationId) {
    return firestore
        .collection("conversations")
        .doc(conversationId)
        .collection("typing");
  }

  // returns the list of 'typedAt' information except the current user
  Map<String, Timestamp> _convertDocsToTypedAtObject(
      QuerySnapshot<Map<String, dynamic>> event) {
    final Map<String, Timestamp> res = {};
    for (final QueryDocumentSnapshot<Map<String, dynamic>> document
        in event.docs.where((element) => element.id != authService.loggedUid)) {
      res[document.id] = document.data()["typedAt"];
    }
    return res;
  }
}
