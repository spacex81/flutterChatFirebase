// is typing... message will persist for 1 second
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
  bool _active = false;

  /// - Key: conversationId
  /// - Value: Map of:
  /// --- Key: uid
  /// --- Value: Timestamp the user typed at
  final Map<String, Map<String, Timestamp>> _cancelTyping = {};

  final Map<String, List<String>> _typingUidsByConversationId = {};
  final List<void Function()> _onCloseListeners = [];

  TypingDS({
    required this.firestore,
    required this.authService,
  });

  List<String> typingUids(String conversationId) =>
      _typingUidsByConversationId[conversationId] ?? [];
}
