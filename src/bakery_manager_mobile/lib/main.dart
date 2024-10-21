import 'package:bakery_manager_mobile/assets/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/navigator_observer.dart';
import 'services/session_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    _sessionManager.onIdleTimeout = () => _handleIdleTimeout(context);
  }

  void _handleIdleTimeout(BuildContext context) {
    // Handle session timeout due to inactivity (e.g., navigate to login)
    navigatorKey.currentState?.pushReplacementNamed(loginPageRoute);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: GestureDetector(
        onTap: () => _sessionManager.resetIdleTimer, // Reset idle timer on tap
        onPanDown: (details) =>
            _sessionManager.resetIdleTimer(), // Reset idle timer on drag
        child: MaterialApp(
          title: 'Bakery Manager Mobile',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 209, 125, 51)),
          ),
          initialRoute: loginPageRoute,
          routes: appRoutes,
          navigatorObservers: [MyNavigatorObserver()],
        ),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {}