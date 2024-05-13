import 'package:client/features/chat/presentation/screens/realtime_chat_screen/realtime_chat_screen.dart';
import 'package:client/features/chat/presentation/screens/realtime_conversations_screen/realtime_conversations_screen.dart';
import 'package:client/features/groups/presentation/screens/add_participants_screen.dart';
import 'package:client/features/groups/presentation/screens/create_group_or_edit_title_screen.dart';
import 'package:client/features/loading/screens/loading_screen.dart';
import 'package:client/features/login_and_registration/presentation/screens/login_and_registration_screen.dart';
import 'package:flutter/material.dart';

class ScreenRoutes {
  static const loading = LoadingScreen.route;
  static const login = LoginAndRegistrationScreen.route;
  static const conversations = RealtimeConversationsScreen.route;
  static const chat = RealtimeChatScreen.route;
  static const createGroupOrEditTitle = CreateGroupOrEditTitleScreen.route;
  static const addGroupParticipants = AddGroupParticipantsScreen.route;
}

Map<String, Widget Function(BuildContext)> screenRoutes = {
  ScreenRoutes.loading: (context) => const LoadingScreen(),
  ScreenRoutes.login: (context) => const LoginAndRegistrationScreen(),
  ScreenRoutes.chat: (context) => const RealtimeChatScreen(),
  ScreenRoutes.conversations: (context) => const RealtimeConversationsScreen(),
  ScreenRoutes.createGroupOrEditTitle: (context) =>
      const CreateGroupOrEditTitleScreen(),
  ScreenRoutes.addGroupParticipants: (context) =>
      const AddGroupParticipantsScreen(),
};
