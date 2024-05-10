import '../../../features/chat/chat_utils.dart' as chatUtils;

class UserPublic {
  final String uid;
  final String firstName;
  final String lastName;

  UserPublic(
      {required this.uid, required this.firstName, required this.lastName});

  String get fullName => "$firstName $lastName";

  // String get
}
