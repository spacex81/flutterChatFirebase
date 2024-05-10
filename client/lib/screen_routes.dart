import 'package:client/features/chat/presentation/screens/realtime_conversations_screen/realtime_conversations_screen.dart';
import 'package:client/features/loading/screens/loading_screen.dart';
import 'package:client/features/login_and_registration/presentation/screens/login_and_registration_screen.dart';
import 'package:flutter/material.dart';

class ScreenRoutes {
  static const loading = LoadingScreen.route;
  static const login = LoginAndRegistrationScreen.route;
  static const conversations = RealtimeConversationsScreen.route;
}

Map<String, Widget Function(BuildContext)> screenRoutes = {
  ScreenRoutes.loading: (context) => const LoadingScreen(),
  ScreenRoutes.login: (context) => const LoginAndRegistrationScreen(),
  ScreenRoutes.conversations: (context) => const RealtimeConversationsScreen(),
};
