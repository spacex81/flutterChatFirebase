import 'package:client/core/domain/services/auth_service.dart';
import 'package:client/features/chat/data/data_sources/typing_ds.dart';
import 'package:client/features/chat/domain/entities/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessagesDS {
  final AuthService authService;
  final FirebaseFirestore firestore;
  final TypingDS typingDs;
  final List<String> _recentlyCreatedConversations = [];

  final Set<String> _updatedToReadMessages = {};
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
}
