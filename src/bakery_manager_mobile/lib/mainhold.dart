import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


/* 
  * Runs the app 
  * Currently only works in Debug mode
*/

//This is the entry point of the application. It calls runApp(), which takes a widget (in this case, MyApp) 
//and makes it the root of the widget tree. 
void main() {
  runApp(const MyApp()); 
} 

//MyApp is a StatelessWidget that uses ChangeNotifierProvider to manage the app's state. 
//The create method initializes MyAppState, a class that extends ChangeNotifier, 
//meaning it can notify listeners when its state changes.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      // Sets the theme of the app - currently using material

      //The MaterialApp defines the main structure of the app:
      //title: The app's name, shown in task switchers.
      //theme: Uses Material 3 (M3) and creates a color scheme based on a seed color.
      //home: The home screen of the app, which is MyHomePage.
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
//but it's structured to allow state changes in the future (for example, it could hold bakery data, recipes, etc.).
class MyAppState extends ChangeNotifier {

}

// ...

/*
 * Home page for the app
 * Children: 
 *  Title() - Title Text for home page
 *  OptionsBar() - Option Buttons
*/
//MyHomePage is the main screen. It uses a Scaffold to provide the basic material design layout.
//SafeArea ensures that the content does not overlap with system UI (like the notch or status bar).
//It includes a Column containing two main widgets: Title and OptionsBar.
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
//OptionsBar contains a vertical list of buttons. Each ElevatedButton represents a different option 
//for the bakery management app (e.g., "All Recipes", "Ingredient Inventory", etc.).
//Align aligns the buttons to the top-left corner.
//SizedBox is used to create vertical gaps between the buttons.
class OptionsBar extends StatelessWidget {
  const OptionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {}, // Do nothing for now - Should route to the Recipies page
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  fixedSize: const Size(130, 130), // Square size (130x130)
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Makes the button square-shaped
                  ),
                ),
                child: const Text('All Recipes', style: TextStyle(color: Colors.white)),
              ),

              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {}, // Do nothing for now - Should route to the Ingredient Inventory page
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  fixedSize: const Size(130, 130), // Square size (130x130)
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Square corners
                  ),
                ),
                child: const Text('Ingredient Inventory', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {}, // Do nothing for now - Should route to the Product Inventory page
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  fixedSize: const Size(130, 130), // Square size (130x130)
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Square shape
                  ),
                ),
                child: const Text('Product Inventory', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {}, // Do nothing for now - Should route to the Tasks page
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  fixedSize: const Size(130, 130), // Square size (130x130)
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Square corners
                  ),
                ),
                child: const Text('Daily Tasks', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {}, // Do nothing for now - Should route to My Account page - May be removed
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              fixedSize: const Size(130, 130), // Square size (130x130)
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // Square shape
              ),
            ),
            child: const Text('My Account', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

//A custom widget to display a vertical list of buttons. It takes a list of strings (options), 
//and for each string, it creates a button.
class VerticalButtonList extends StatelessWidget {
  final List<String> options;

  const VerticalButtonList({required this.options, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: options
            .map((option) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text(option),
                  ),
                ))
            .toList(),
      ),
    );
  }
}


/*  
 * Title widget:
 * Contains text of the homepage title 
*/
//This widget displays the title at the center of the screen. 
//It uses the app's theme to style the text (specifically displaySmall from the textTheme with a bold font weight).
class Title extends StatelessWidget {
  const Title({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Adjust the size of the "Hi Benjamin Burchfield!" text 
    final style = theme.textTheme.displaySmall!.copyWith(
      //fixedSize: const Size(130, 130), // Square size (130x130)
      
      height: 5, // Set the height of the square
      fontWeight: FontWeight.bold,
      fontSize: theme.textTheme.displaySmall!.fontSize! - 10, // Reduce the font size slightly
      color: Colors.white,
      backgroundColor: Colors.orange,
    );
    final subtitleStyle = theme.textTheme.bodyMedium!.copyWith(
      height: -5,
      color: Colors.white,
      fontWeight: FontWeight.normal,
    );

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ensures the column takes minimal vertical space
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns the "Owner" text to the left
        children: [
          // Adjust the size of the "Hi Benjamin Burchfield!" text and color.
          Text('Hi Benjamin Burchfield!', style: style,), //First line of homepage title.

          /*const Text(
                'Hi Benjamin Burchfield!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),*/

          Padding(
            padding: const EdgeInsets.only(left: 0.0), // Adds a little left padding to align under "Hi"
            child: Text('Owner', style: subtitleStyle), // Second line "Owner" aligned to the left
          ),
        ],
      ),
    );
  }
}
