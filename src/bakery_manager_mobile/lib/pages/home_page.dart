import 'package:bakery_manager_mobile/services/api_service.dart';
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
  String _firstName = '';
  String _lastName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  String _capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  Future<void> _loadUserData() async {
    // Call the API to get user info
    Map<String, dynamic> userInfo = await ApiService.getUserInfo();

    // Check if the response was successful
    if (userInfo['status'] == 'success') {
      setState(() {
        // Assuming userInfo['content'] contains a map with first and last name
        _firstName = _capitalizeFirstLetter(userInfo['content']['FirstName'] ?? '');
        _lastName = _capitalizeFirstLetter(userInfo['content']['LastName'] ?? '');
      });
    } else {
      // Handle the error case, show only "Hi!"
      setState(() {
        _firstName = '';
        _lastName = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 209, 125, 51),
        shape: const RoundedRectangleBorder(),
        title: const Stack(
          children: <Widget>[
            Text(
              'Home',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
          ],
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
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'The Rolling Scones',
                    style: TextStyle(
                      fontFamily: 'Pacifico',
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 140, 72, 27),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Dynamically displaying the first and last name
              Text(
                'Hi $_firstName $_lastName!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 209, 125, 51),
                ),
              ),
              const SizedBox(height: 80),
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
        backgroundColor: const Color.fromARGB(255, 209, 126, 51),
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
            size: 36,
            color: Colors.white
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white
            ),
          ),
        ],
      ),
    );
  }
}

