import 'package:client/core/domain/services/auth_service.dart';
import 'package:client/core/presentation/widgets/my_scaffold.dart';
import 'package:client/core/presentation/widgets/waves_background/waves_background.dart';
import 'package:client/injection_container.dart';
import 'package:client/screen_routes.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  static const String route = '/';

  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _start(context);
    });

    return const MyScaffold(
        background: WavesBackground(),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
              ),
              SizedBox(height: 15),
              Text(
                "Loading...",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1),
              )
            ],
          ),
        ));
  }

  void _start(BuildContext context) {
    if (getIt.get<AuthService>().isAuthenticated) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(ScreenRoutes.conversations, (_) => false);
    } else {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(ScreenRoutes.login, (_) => false);
    }
  }
}
