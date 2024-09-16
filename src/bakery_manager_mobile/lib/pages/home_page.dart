import 'package:flutter/material.dart';
import 'package:bakery_manager_mobile/assets/constants.dart';

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
  void _logout() {
    Navigator.pushReplacementNamed(context, loginPageRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        leading: IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                height: 80,
                alignment: Alignment.center,
                child: const Text(
                  'The Rolling Scones',
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Hi Benjamin Burchfield!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const Text(
                'Owner',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 30),
              const Expanded(
                child: OptionsBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* 
 * OptionsBar widget:
 * Contains five buttons on the home page that should route to a different page
 * Using GridView with smaller buttons
*/
class OptionsBar extends StatelessWidget {
  const OptionsBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      children: [
        _buildMenuButton('All Recipes', Icons.menu_book, () {
          Navigator.pushNamed(context, recipePageRoute);
        }),
        _buildMenuButton('Ingredient Inventory', Icons.kitchen, () {
          Navigator.pushNamed(context, ingredientPageRoute);
        }),
        _buildMenuButton('Product Inventory', Icons.inventory, () {
          Navigator.pushNamed(context, productPageRoute);
        }),
        _buildMenuButton('Daily Tasks', Icons.task, () {
          Navigator.pushNamed(context, taskPageRoute);
        }),
        _buildMenuButton('Sales History', Icons.attach_money, () {
          Navigator.pushNamed(context, salesPageRoute);
        }),
        _buildMenuButton('My Account', Icons.account_box_rounded, () {
          Navigator.pushNamed(context, salesPageRoute);
        }),
      ],
    );
  }

  Widget _buildMenuButton(String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 227, 171, 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: Colors.white,
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
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
