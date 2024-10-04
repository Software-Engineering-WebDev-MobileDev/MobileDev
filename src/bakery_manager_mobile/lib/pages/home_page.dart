import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String _firstName = '';
  String _lastName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstName = prefs.getString('first_name') ?? 'John';
      _lastName = prefs.getString('last_name') ?? 'Doe';
    });
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, loginPageRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 209, 125, 51),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10)
          ),
        ),
        // made the color scheme and design of the title more consistent
        title: Stack(
          children: <Widget>[
            // Stroked text as border.
            Text(
              'The Simple Bakery',
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 6
                  ..color = const Color.fromARGB(255, 140,72,27),
              ),
            ),
            // Solid text as fill.
            const Text(
              'The Simple Bakery',
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 246,235,216),
              ),
            ),
          ],
        ),
        //changed the color of the icon button
        leading: IconButton(
          color: const Color.fromARGB(255, 92,40,10),
          icon: const Icon(Icons.logout), 
          onPressed: _logout,
        ),
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

              // Dynamically displaying the first and last name
              Text(
                'Hi $_firstName $_lastName!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 209, 125, 51),
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
      crossAxisCount: 2,
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
        _buildMenuButton('Daily Tasks', Icons.task, () {
          Navigator.pushNamed(context, taskPageRoute);
        }),
        _buildMenuButton('My Account', Icons.account_box_rounded, () {
          Navigator.pushNamed(context, myAccountRoute);
        }),
      ],
    );
  }

  Widget _buildMenuButton(String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 209,126,51),
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
            color: const Color.fromARGB(255, 246,235,216),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color.fromARGB(255, 246,235,216),
            ),
          ),
        ],
      ),
    );
  }
}
