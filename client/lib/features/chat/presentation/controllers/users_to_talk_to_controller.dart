import 'package:client/core/domain/entities/user_public.dart';
import 'package:client/core/domain/services/users_service.dart';
import 'package:client/injection_container.dart';

class UsersToTalkToController {
  Stream<List<UserPublic>> stream() {
    return getIt.get<UsersService>().streamAllUsersExceptLogged();
  }
}
