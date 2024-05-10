import 'dart:async';

import 'package:client/core/domain/entities/user_public.dart';
import 'package:client/features/chat/domain/entities/conversation.dart';
import 'package:client/features/chat/domain/entities/detailed_conversation.dart';
import 'package:client/features/chat/domain/entities/message.dart';
import 'package:synchronized/synchronized.dart';

class DetailedConversationController {
  final String conversationId;
  final int? messagesLimit;

  // need [List<Message>] and [Conversation]
  // in order to create [DetailedConversation]
  StreamSubscription<List<Message>>? _msgSubscription;
  List<Message>? _messages;
  StreamSubscription<Conversation>? _conversationSubscription;
  Conversation? _conversation;

  late final StreamController<DetailedConversation> _streamController;
  DetailedConversation? _last;

  final List<UserPublic> _users = [];

  void Function()? onLoad;
  DetailedConversation? get last => _last;

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
    });
  }
}
