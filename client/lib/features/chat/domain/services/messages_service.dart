import 'package:client/core/domain/services/auth_service.dart';
import 'package:client/core/domain/services/users_service.dart';
import 'package:client/features/chat/data/data_sources/messages_ds.dart';
import 'package:client/features/chat/domain/entities/conversation.dart';
import 'package:client/features/chat/domain/entities/message.dart';

class MessagesService {
  final MessagesDS messagesDatasource;
  final UsersService usersService;
  final AuthService authService;

  MessagesService(
      {required this.messagesDatasource,
      required this.authService,
      required this.usersService});

  Stream<Conversation> conversationStream({required String conversationId}) {
    return messagesDatasource.conversationStream(
        conversationId: conversationId);
  }

  Stream<List<Conversation>> conversationListStream() {
    return messagesDatasource.conversationListStream();
  }

  Stream<List<Message>> messagesStream(
      {required String conversationId,
      int? limitToLast,
      void Function(List<Message> newReceivedMessageList)?
          onNewReceivedMessage}) {
    return messagesDatasource.messagesStream(
        conversationId: conversationId,
        limit: limitToLast,
        onNewReceivedMessage: onNewReceivedMessage);
  }

  Future<Conversation?> getConversationById({required String conversationId}) {
    return messagesDatasource.getConversationById(
        conversationId: conversationId);
  }
}
