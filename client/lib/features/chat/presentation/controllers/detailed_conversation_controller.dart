import 'dart:async';

import 'package:client/core/domain/entities/user_public.dart';
import 'package:client/core/domain/services/users_service.dart';
import 'package:client/features/chat/domain/entities/conversation.dart';
import 'package:client/features/chat/domain/entities/detailed_conversation.dart';
import 'package:client/features/chat/domain/entities/message.dart';
import 'package:client/features/chat/domain/services/messages_service.dart';
import 'package:client/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:synchronized/synchronized.dart';

class DetailedConversationController {
  // this is needed to subscribe to certain conversation from the firestore
  final String conversationId;
  final int? messagesLimit;

  DetailedConversation? _last;
  // used to create 'DetailedConversation'
  Conversation? _conversation;
  List<Message>? _messages;
  final List<UserPublic> _users = [];

  // this function will run, right after new created 'DetailedConversation' is flushed down to stream controller
  void Function()? onLoad;

  StreamSubscription<List<Message>>? _msgSubscription;
  StreamSubscription<Conversation>? _conversationsSubscription;
  // this is the purpose of this class
  // whenever new 'List<Message>' or 'Conversation' arrives from firestore,
  // we create new instance of 'DetailedConversation' and send it to subscribers
  late final StreamController<DetailedConversation> _streamController;

  DetailedConversation? get last => _last;

  // '_loadUsersLock' is used to make sure that multiple 'addUser' calls is waited
  // if there are 3 'addUser' calls, '_loadUsersLock' makes sure all the remote network calls are finished
  // before moving on to the next line
  final _loadUsersLock = Lock();
  DetailedConversationController(
      {this.messagesLimit, required this.conversationId, this.onLoad}) {
    print('DetailedConversationController!');
    // construction of this class can happen multiple times
    // 'started' variable makes sure the firestore stream subscription process happens only once
    bool started = false;

    // setup stream controller
    _streamController =
        StreamController<DetailedConversation>.broadcast(onListen: () {
      if (started) {
        return;
      }
      started = true;
      // setup stream subscription for 'Conversation'
      _conversationsSubscription = getIt
          .get<MessagesService>()
          .conversationStream(conversationId: conversationId)
          .listen((conversation) async {
        print('conversationStream');
        _conversation = conversation;
        _loadUsersLock.synchronized(() async {
          for (final uid in conversation.participants) {
            // if conversation contains users that local conversation doesn't,
            // which means new user joins a conversation,
            // we need to add those new users to local conversation
            // which means updating the local conversation state
            if (!_users.any((element) => element.uid == uid)) {
              final user = await getIt.get<UsersService>().getUser(uid: uid);
              _users.add(user!);
            }
          }
          // since new 'Conversation' data has arrived, create new 'DetailedConversation' and send it
          _emit();
        });
      });
    });

    _msgSubscription = getIt
        .get<MessagesService>()
        .messagesStream(
            conversationId: conversationId, limitToLast: messagesLimit)
        .listen((messages) {
      _messages = messages;
      _emit();
    });
  }

  Stream<DetailedConversation> get stream {
    return _streamController.stream;
  }

  // whenever new 'List<Message>' or 'Conversation' arrives from firestore
  // emit newly created 'DetailedConversation'
  void _emit() {
    // this function uses shared resources such as '_conversation', '_users', '_messages' in order to send
    // 'DetailedConversation', so we need to lock those resources when adding it to stream controller
    _loadUsersLock.synchronized(() {
      if (_conversation != null && _messages != null && _users.isNotEmpty) {
        if (!_streamController.isClosed) {
          _streamController.add(_last = DetailedConversation(
              conversation: _conversation!,
              messages: _messages!,
              users: _users));
          if (onLoad != null) {
            onLoad!();
            onLoad = null;
          }
        } else {
          print(
              "conversationsSubscription: controller was closed, not adding new event");
          _msgSubscription?.cancel();
        }
      }
    });
  }

  void dispose() {
    _streamController.close();
    _msgSubscription?.cancel();
    _conversationsSubscription?.cancel();
  }
}
