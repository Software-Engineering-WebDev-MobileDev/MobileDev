import 'package:bakery_manager_mobile/assets/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/routes.dart';
/* 
  * Runs the app 
  * Currently only works in Debug mode
*/ 
void main() {
  runApp(const MyApp()); 
} 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      // Sets the theme of the app - currently using material
      child: MaterialApp(
        title: 'Bakery Manager Mobile',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(0, 255, 0, 1)),
        ),
        initialRoute: loginPageRoute,
        routes: appRoutes,
      ),
    );
  }
}

// Used to update the state of the app - current app is static so no state updates
class MyAppState extends ChangeNotifier {

}

// ...