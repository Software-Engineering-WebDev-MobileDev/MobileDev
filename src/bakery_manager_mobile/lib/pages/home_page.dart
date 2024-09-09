import 'package:bakery_manager_mobile/assets/constants.dart';
import 'package:flutter/material.dart';

/*
 * Home page for the app
 * Children: 
 *  Title() - Title Text for home page
 *  OptionsBar() - Option Buttons
*/
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
              onPressed: () {
                Navigator.pushNamed(context, recipePageRoute);
              }, // On press navigate to the Recipe page
              child: const Text('All Recipes'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, ingredientPageRoute);
              }, // On press navigate to the Ingredient page
              child: const Text('Ingredient Inventory'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, productPageRoute);
              }, // Do nothing for now - Should route to the Product Inventory page
              child: const Text('Product Inventory'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, taskPageRoute);
              }, // Do nothing for now - Should route to the Tasks page
              child: const Text('Daily Tasks'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, salesPageRoute);
              }, // Do nothing for now - Should route to Sales History page - May be removed
              child: const Text('Sales History'),
            ),
          ],
        ));
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
