import 'package:client/core/domain/services/auth_service.dart';
import 'package:client/injection_container.dart';
import 'package:collection/collection.dart';

class Message {
  final String messageId;
  final String conversationId;
  final String text;
  final DateTime sentAt;
  final bool hasPendingWrites;
  final String senderUid;
  final List<String> pendingReceivement;
  final List<String> pendingRead;
  final Map<String, DateTime> receivedAt;
  final Map<String, DateTime> readAt;

  // [participants] refers to the uids that can read this message
  final List<String> participants;

  Message({
    required this.messageId,
    required this.conversationId,
    required this.text,
    required this.senderUid,
    required this.participants,
    required this.sentAt,
    this.receivedAt = const {},
    this.readAt = const {},
    required this.hasPendingWrites,
    this.pendingRead = const [],
    this.pendingReceivement = const [],
  }) {
    assert(text.isNotEmpty == true);
  }

  bool get iAmNotTheSender => senderUid != getIt.get<AuthService>().loggedUid;

  bool get iAmTheSender => !iAmNotTheSender;

  bool get isGroup => conversationId.startsWith('group_');

  Map<String, DateTime> _notMeMap(Map<String, DateTime> map) {
    return Map<String, DateTime>.from(map)
      ..removeWhere((key, value) => key == getIt.get<AuthService>().loggedUid);
  }

  // Returns the [DateTime] of the last received time of the message
  // Returns null if there is no other participants except the sender
  // Returns null if none of the participants have received the message
  DateTime? get lastReceivedAt {
    if (_notMeMap(receivedAt).length < participants.length - 1) {
      return null;
    }
    return _notMeMap(receivedAt)
        .values
        .sorted((a, b) => a.compareTo(b))
        .lastOrNull;
  }

  DateTime? get lastReadAt {
    if (_notMeMap(readAt).length < participants.length - 1) {
      return null;
    }
    return _notMeMap(readAt).values.sorted((a, b) => a.compareTo(b)).lastOrNull;
  }

  bool get received {
    return lastReceivedAt != null;
  }

  bool get read {
    return lastReadAt != null;
  }

  // Returns if the logged user has received this message
  bool get iReceived {
    assert(senderUid != getIt.get<AuthService>().loggedUid,
        'This message was sent by the logged user');
    return receivedAt[getIt.get<AuthService>().loggedUid] != null;
  }

  // Returns if the logged user has read this mssage
  bool get iRead {
    assert(senderUid != getIt.get<AuthService>().loggedUid,
        'This message was sent by the logged user');
    return readAt[getIt.get<AuthService>().loggedUid] != null;
  }
}
