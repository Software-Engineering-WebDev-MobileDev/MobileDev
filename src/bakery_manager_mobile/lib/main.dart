import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        home: const MyHomePage(),
      ),
    );
  }
}

// Used to update the state of the app - current app is static so no state updates
class MyAppState extends ChangeNotifier {

}

// ...

/*
 * Home page for the app
 * Children: 
 *  Title() - Title Text for home page
 *  OptionsBar() - Option Buttons
*/
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // SafeArea prevents overlap for device function bars
      body: SafeArea(
        child: Column(
          children: [
            Title(),
            SizedBox(height: 10), // Used to create a gap
            OptionsBar(),
          ],
        ),
      ),
    );
  }
}

/* 
 * OptionsBar widget:
 * Contains five buttons on the home page that should route to a different page
*/
class OptionsBar extends StatelessWidget {
  const OptionsBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {}, // Do nothing for now - Should route to the Recipies page
              child: const Text('All Recipes'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {}, // Do nothing for now - Should route to the Ingredient Inventory page
              child: const Text('Ingredient Inventory'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {}, // Do nothing for now - Should route to the Product Inventory page
              child: const Text('Product Inventory'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {}, // Do nothing for now - Should route to the Tasks page
              child: const Text('Daily Tasks'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {}, // Do nothing for now - Should route to Sales History page - May be removed
              child: const Text('Sales History'),
            ),
          ],
        )
        );
  }
}

/*  
 * Title widget:
 * Contains text of the homepage title 
*/
class Title extends StatelessWidget {
  const Title({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!.copyWith(
      fontWeight: FontWeight.bold,
    );
    return Center(child: Text('Home', style: style));
  }
}
