import 'package:client/core/presentation/widgets/my_appbar_widget.dart';
import 'package:client/core/presentation/widgets/my_scaffold.dart';
import 'package:client/features/chat/presentation/widgets/logout_button_widget.dart';
import 'package:client/main.dart';
import 'package:flutter/material.dart';

class RealtimeConversationsScreen extends StatefulWidget {
  static const String route = '/conversations';

  const RealtimeConversationsScreen({super.key});

  @override
  State<RealtimeConversationsScreen> createState() =>
      _RealtimeConversationsScreenState();
}

class _RealtimeConversationsScreenState
    extends State<RealtimeConversationsScreen> {
  @override
  Widget build(BuildContext context) {
    final double contentHeight = MediaQuery.of(context).size.height - 105;

    return MyScaffold(
      background: background2Colors,
      appBar: MyAppbarWidget(
        context: context,
        withBackground: true,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kPageContentWidth),
          child: Row(
            children: [
              Expanded(
                child: Placeholder(),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: SignOutButtonWidget(),
              )
            ],
          ),
        ),
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            height: contentHeight,
            width: MediaQuery.of(context).size.width,
          ),
          SingleChildScrollView(
            clipBehavior: Clip.none,
            child: Column(
              children: [],
            ),
          ),
        ],
      ),
    );
  }
}
