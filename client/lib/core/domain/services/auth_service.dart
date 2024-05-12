import 'package:client/core/data/data_sources/auth_ds.dart';
import 'package:client/core/domain/entities/failures/failure.dart';
import 'package:dartz/dartz.dart';

class AuthService {
  final AuthDS authDS;

  AuthService({required this.authDS});

  bool get isAuthenticated {
    return authDS.isAuthenticated;
  }

  void addOnSignInListener(void Function() listener) =>
      authDS.addOnSignInListener(listener);

  void addOnSignOutListener(void Function() listener) =>
      authDS.addOnSignOutListener(listener);

  Future<void> signOut() async {
    return authDS.signOut();
  }

  Future<Either<Failure, void>> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await authDS.signInWithEmailAndPassword(email: email, password: password);
      return right(null);
    } catch (e) {
      if (e is Failure) {
        return left(e);
      }
      print(e);
      return left(Failure(
          'Ops! An unknown error occurred when trying to sign with with email and password'));
    }
  }

  String? get loggedUid => authDS.loggedUid;

  void removeOnSignOutListener(void Function() listener) {
    authDS.removeOnSignOutListener(listener);
  }
}
