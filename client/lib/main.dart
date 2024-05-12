import 'package:client/screen_routes.dart';
import 'package:flutter/material.dart';
import 'injection_container.dart' as injection_container;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await injection_container.init();

  runApp(const MyApp());
}

const double kMargin = 16.0;
const double kPageContentWidth = 600;
const double kIconSize = 24.0;

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      color: Colors.white,
      debugShowCheckedModeBanner: false,
      builder: (context, widget) => Stack(
        children: [
          MaterialApp(
            title: 'Flutter Group Chat App with Firebase',
            debugShowCheckedModeBanner: false,
            initialRoute: ScreenRoutes.loading,
            routes: screenRoutes,
            navigatorKey: navigatorKey,
            theme: ThemeData(
              primarySwatch: Colors.indigo,
              fontFamily: 'RedHatDisplay',
            ),
          )
        ],
      ),
    );
  }
}
