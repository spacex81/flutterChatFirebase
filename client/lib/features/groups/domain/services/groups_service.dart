import 'package:client/core/domain/services/auth_service.dart';
import 'package:client/features/chat/domain/entities/conversation.dart';
import 'package:client/features/groups/data/datasources/groups_ds.dart';

class GroupsService {
  final GroupsDS groupsDS;
  final AuthService authService;

  GroupsService({required this.groupsDS, required this.authService});

  Future<Conversation> createGroup({required String groupTitle}) {
    // put goup creater as a default input value for the uids and groupAdminUids
    return groupsDS.createGroup(
        groupTitle: groupTitle,
        uids: [authService.loggedUid!],
        groupAdminUids: [authService.loggedUid!]);
  }

  Future<void> addParticipant(
      {required String conversationId,
      required String uid,
      bool isAdmin = false}) {
    return groupsDS.addParticipant(
        conversationId: conversationId, uid: uid, isAdmin: isAdmin);
  }

  Future<void> removeParticipant(
      {required String conversationId, required String uid}) {
    return groupsDS.removeParticipant(conversationId: conversationId, uid: uid);
  }
}
