import 'package:client/core/domain/entities/user_public.dart';
import 'package:client/features/chat/domain/entities/message.dart';

class ChatListItemEntity {}

class SeparatorDateForMessages extends ChatListItemEntity {
  DateTime date;

  SeparatorDateForMessages({required this.date});
}

class MessageChatListItemEntity extends ChatListItemEntity {
  final Message message;

  MessageChatListItemEntity({required this.message});
}

class TypingIndicatorChatListItemEntity extends ChatListItemEntity {
  UserPublic user;

  TypingIndicatorChatListItemEntity({required this.user});
}
