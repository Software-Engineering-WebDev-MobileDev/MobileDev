import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Bakery Manager Mobile',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(0, 255, 0, 1)),//(255, 0, 255, 1)
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            HomePageTitle(), // Renamed from Title to HomePageTitle
            SizedBox(height: 10),
            Expanded(child: OptionsBar()), // Ensure OptionsBar takes up the remaining space
          ],
        ),
      ),
    );
  }
}

class OptionsBar extends StatelessWidget {
  const OptionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3, // Number of tabs
      child: Column(
        children: [
          // Tab bar with horizontal tabs
          TabBar(
            labelColor: Colors.black,
            tabs: [
              Tab(text: 'Category 1'),
              Tab(text: 'Category 2'),
              Tab(text: 'Category 3'),
            ],
          ),
          // TabBarView contains different vertical lists for each tab
          Expanded(
            child: TabBarView(
              children: [
                // First tab: First vertical list of buttons
                VerticalButtonList(options: [
                  'All Recipes',
                  'Ingredient Inventory',
                  'Product Inventory',
                ]),
                // Second tab: Second vertical list of buttons
                VerticalButtonList(options: [
                  'Daily Tasks',
                  'Sales History',
                  'Orders',
                ]),
                // Third tab: Third vertical list of buttons
                VerticalButtonList(options: [
                  'Staff Management',
                  'Settings',
                  'Reports',
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

// Renamed custom title widget to avoid conflict
class HomePageTitle extends StatelessWidget {
  const HomePageTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!.copyWith(
      fontWeight: FontWeight.bold,
    );
    return Center(child: Text('HOME', style: style));
  }
}
