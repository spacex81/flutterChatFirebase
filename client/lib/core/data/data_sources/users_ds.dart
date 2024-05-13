import 'package:client/core/data/data_sources/auth_ds.dart';
import 'package:client/core/data/models/user_full_model.dart';
import 'package:client/core/data/models/user_public_model.dart';
import 'package:client/core/domain/entities/user_public.dart';
import 'package:client/core/domain/services/auth_service.dart';
import 'package:client/features/login_and_registration/domain/entities/failures/email_already_exists_failure.dart';
import 'package:client/injection_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsersDS {
  final AuthDS authDS;

  CollectionReference get _publicUsersRef =>
      FirebaseFirestore.instance.collection('users');
  DocumentReference _fullUserDataRef(String uid) =>
      _publicUsersRef.doc(uid).collection("fullUser").doc("data");

  UsersDS({required this.authDS});

  Stream<List<UserPublicModel>> streamAllUsersExceptLogged() {
    return FirebaseFirestore.instance
        .collection('users')
        .where(UserPublicModel.kUid,
            isNotEqualTo: getIt.get<AuthService>().loggedUid)
        .snapshots()
        .map((snapshot) => UserPublicModel.fromList(
            snapshot.docs.map((e) => e.data()).toList()));
  }

  Future<void> createUser(
      {required String firstName,
      required String lastName,
      required String email,
      required String password}) async {
    try {
      final res = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await Future.wait([
        _publicUsersRef.doc(res.user!.uid).set(UserPublicModel(
                uid: res.user!.uid, firstName: firstName, lastName: lastName)
            .toMap()),
        _fullUserDataRef(res.user!.uid).set(UserFullModel(
                uid: res.user!.uid,
                firstName: firstName,
                lastName: lastName,
                fcmToken: null)
            .toMap())
      ]);
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        throw EmailAlreadyExistsFailure();
      }
      rethrow;
    }
  }

  Future<UserPublic?> getPublicUser({required String uid}) async {
    final user = await _publicUsersRef.doc(uid).get();
    if (!user.exists) {
      return null;
    }
    return UserPublicModel.fromMap(user.data());
  }

  Stream<UserPublic> streamPublicUser({required String uid}) {
    return _publicUsersRef
        .doc(uid)
        .snapshots()
        .map((data) => UserPublicModel.fromMap(data.data()));
  }
}
