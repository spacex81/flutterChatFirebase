import 'package:client/core/domain/services/auth_service.dart';
import 'package:client/features/chat/data/models/conversation_model.dart';
import 'package:client/features/chat/domain/entities/conversation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupsDS {
  final FirebaseFirestore firestore;
  final AuthService authService;

  GroupsDS({required this.firestore, required this.authService});

  // we need three parts to create a new group
  // 1) title of the group 2) list of participants 3) list of administrators
  // if list of administrators is null, we will set the logged user as a sole administrator
  Future<Conversation> createGroup(
      {required String groupTitle,
      required List<String> uids,
      List<String>? groupAdminUids}) async {
    assert(authService.loggedUid != null, "current user is not logged in");

    // '_' collection is used to generate random uid for the new conversation group
    final conversationId = "group_${firestore.collection("_").doc().id}";
    final ref = firestore.collection("conversations").doc(conversationId);
    final data = {
      ConversationModel.kConversationId: conversationId,
      ConversationModel.kParticipants: uids,
      ConversationModel.kGroup: {
        ConversationGroupModel.kTitle: groupTitle,
        ConversationGroupModel.kAdminUids:
            groupAdminUids ?? [authService.loggedUid!],
        ConversationGroupModel.kCreatedBy: authService.loggedUid!,
        ConversationGroupModel.kJoinedAt: {
          authService.loggedUid: FieldValue.serverTimestamp(),
        },
      },
    };
    await ref.set(data);
    return ConversationModel.fromData(data, [])!;
  }

  Future<void> addParticipant(
      {required String conversationId,
      required String uid,
      bool isAdmin = false}) async {
    final ref = firestore.collection("conversations").doc(conversationId);
    final data = {
      ConversationModel.kParticipants: FieldValue.arrayUnion([uid]),
      "${ConversationModel.kGroup}.${ConversationGroupModel.kJoinedAt}.$uid":
          FieldValue.serverTimestamp(),
    };
    if (isAdmin) {
      data['${ConversationModel.kGroup}.${ConversationGroupModel.kAdminUids}'] =
          FieldValue.arrayUnion([uid]);
    }
    await ref.update(data);
  }

  Future<void> removeParticipant(
      {required String conversationId, required String uid}) async {
    final group = conversationId.startsWith('group_')
        ? {
            '${ConversationModel.kGroup}.${ConversationGroupModel.kJoinedAt}.$uid':
                FieldValue.delete(),
            '${ConversationModel.kGroup}.${ConversationGroupModel.kAdminUids}.$uid':
                FieldValue.delete(),
          }
        : {};
    await firestore.collection("conversations").doc(conversationId).update({
      ConversationModel.kParticipants: FieldValue.arrayRemove([uid]),
      ...group
    });
  }
}
