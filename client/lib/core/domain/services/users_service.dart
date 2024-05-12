import 'package:client/core/data/data_sources/users_ds.dart';
import 'package:client/core/domain/entities/failures/failure.dart';
import 'package:client/core/domain/entities/user_public.dart';
import 'package:dartz/dartz.dart';

class UsersService {
  final UsersDS usersRemoteDataSource;

  UsersService({required this.usersRemoteDataSource});

  Future<Either<Failure, void>> createUser(
      {required String firstName,
      required String lastName,
      required String email,
      required String password}) async {
    try {
      await usersRemoteDataSource.createUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
      return right(null);
    } catch (e) {
      if (e is Failure) {
        return left(e);
      }
      print(e.toString());
      return left(Failure("An error occurred when trying to create the user"));
    }
  }

  Stream<List<UserPublic>> streamAllUsersExceptLogged() {
    return usersRemoteDataSource.streamAllUsersExceptLogged();
  }

  Future<UserPublic?> getUser({required String uid}) {
    return usersRemoteDataSource.getPublicUser(uid: uid);
  }
}
