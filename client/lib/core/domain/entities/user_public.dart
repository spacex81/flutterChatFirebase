import 'package:client/core/domain/services/auth_service.dart';
import 'package:client/injection_container.dart';
import '../../../features/chat/domain/chat_utils.dart' as chatUtils;

class UserPublic {
  final String uid;
  final String firstName;
  final String lastName;

  UserPublic(
      {required this.uid, required this.firstName, required this.lastName});

  String get fullName => "$firstName $lastName";

  String get conversationId {
    return chatUtils
        .getDirectConversationId([uid, getIt.get<AuthService>().loggedUid!]);
  }

  static UserPublic empty() => UserPublic(uid: '', firstName: '', lastName: '');
}
