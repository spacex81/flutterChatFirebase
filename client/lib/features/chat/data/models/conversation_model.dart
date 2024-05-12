import 'package:client/features/chat/domain/entities/conversation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel extends Conversation {
  static const kConversationId = "conversationId";
  static const kParticipants = "participants";
  static const kGroup = "group";

  ConversationModel(
      {required super.conversationId,
      required super.participants,
      required super.typingUids,
      super.group});

  static Conversation? fromDocument(
      DocumentSnapshot snapshot, List<String> typingUids) {
    final data = snapshot.data() as dynamic;
    if (data == null) {
      return null;
    }
    return fromData(snapshot, typingUids);
  }

  static Conversation? fromData(data, [List<String>? typingUids]) {
    return Conversation(
      conversationId: data[kConversationId],
      participants: List<String>.from(data[kParticipants]),
      group: data[kGroup] == null
          ? null
          : ConversationGroupModel.fromData(data[kGroup]),
      typingUids: typingUids ?? [],
    );
  }
}

class ConversationGroupModel extends ConversationGroup {
  static const kCreatedBy = "createdBy";
  static const kTitle = "title";
  static const kAdminUids = "adminUids";
  static const kJoinedAt = "joinedAt";

  ConversationGroupModel(
      {required super.title,
      required super.joinedAt,
      required super.adminUids,
      required super.createdBy});

  static fromData(data) {
    if (data == null) {
      return null;
    }
    return ConversationGroupModel(
      title: data[kTitle],
      adminUids: List<String>.from(data[kAdminUids]),
      createdBy: data[kCreatedBy],
      joinedAt: Map.fromEntries(Map.from(data[kJoinedAt]).entries.map((e) =>
          MapEntry(
              e.key,
              (e.value is Timestamp ? (e.value as Timestamp) : Timestamp.now())
                  .toDate()))),
    );
  }
}
