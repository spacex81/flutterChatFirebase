import 'package:client/core/data/data_sources/auth_ds.dart';
import 'package:client/core/data/data_sources/users_ds.dart';
import 'package:client/core/domain/services/auth_service.dart';
import 'package:client/core/domain/services/users_service.dart';
import 'package:client/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // FirebaseFirestore.instance.enablePersistence().catchError((err) {
  //   // for web
  //   print(
  //       "Could not enable offline mode, please, check if the App is opened in another Tab or try another browser");
  //   print(err.toString());
  // });

  // register AuthDS
  getIt
      .registerLazySingleton(() => AuthDS(firebaseAuth: FirebaseAuth.instance));
  // register UsersDS
  getIt.registerLazySingleton(() => UsersDS(authDS: getIt.get<AuthDS>()));

  // register AuthService
  getIt.registerLazySingleton(() => AuthService(
        authDS: getIt.get<AuthDS>(),
      ));
  // register UsersService
  getIt.registerLazySingleton(() => UsersService(
        usersRemoteDataSource: getIt.get<UsersDS>(),
      ));
}
