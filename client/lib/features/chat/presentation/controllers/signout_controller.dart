import 'package:client/core/domain/services/auth_service.dart';
import 'package:client/injection_container.dart';
import 'package:client/screen_routes.dart';
import 'package:flutter/material.dart';

class SignOutController {
  void signOut(BuildContext context) {
    Future.delayed(
        const Duration(milliseconds: 200), getIt.get<AuthService>().signOut);
    Navigator.of(context)
        .pushNamedAndRemoveUntil(ScreenRoutes.login, (route) => false);
  }
}
