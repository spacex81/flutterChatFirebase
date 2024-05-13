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
  final String conversationId;
  final int? messagesLimit;
  StreamSubscription<List<Message>>? _msgSubscription;
  late final StreamController<DetailedConversation> _streamController;
  Conversation? _conversation;
  List<Message>? _messages;
  final List<UserPublic> _users = [];
  DetailedConversation? _last;
  void Function()? onLoad;
  StreamSubscription<Conversation>? _conversationsSubscription;

  DetailedConversation? get last => _last;

  void _emit() {
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
              'conversationsSubscription: controller was closed, not adding new event');
          _msgSubscription?.cancel();
        }
      }
    });
  }

  final _loadUsersLock = Lock();
  DetailedConversationController(
      {this.messagesLimit, required this.conversationId, this.onLoad}) {
    print('DetailedConversationController!');
    bool started = false;
    _streamController =
        StreamController<DetailedConversation>.broadcast(onListen: () {
      if (started) {
        return;
      }
      started = true;
      _conversationsSubscription = getIt
          .get<MessagesService>()
          .conversationStream(conversationId: conversationId)
          .listen((conversation) async {
        print('conversationStream!');
        _conversation = conversation;
        _loadUsersLock.synchronized(() async {
          for (final uid in conversation.participants) {
            if (!_users.any((element) => element.uid == uid)) {
              final user = await getIt.get<UsersService>().getUser(uid: uid);
              _users.add(user!);
            }
          }
          _emit();
        });
      });
    });

    _msgSubscription = getIt
        .get<MessagesService>()
        .messagesStream(
          conversationId: conversationId,
          limitToLast: messagesLimit,
        )
        .listen((messages) {
      _messages = messages;
      _emit();
    });
  }

  Stream<DetailedConversation> get stream {
    return _streamController.stream;
  }

  void dispose() {
    _streamController.close();
    _msgSubscription?.cancel();
    _conversationsSubscription?.cancel();
  }
}
