import 'package:bakery_manager_mobile/pages/home_page.dart';
import 'package:bakery_manager_mobile/pages/ingredient_page.dart';
import 'package:bakery_manager_mobile/pages/product_page.dart';
import 'package:bakery_manager_mobile/pages/recipe_page.dart';
import 'package:bakery_manager_mobile/pages/sales_page.dart';
import 'package:bakery_manager_mobile/pages/task_page.dart';
import 'package:bakery_manager_mobile/pages/login.dart';
import 'package:bakery_manager_mobile/pages/account_registration.dart';
import 'package:bakery_manager_mobile/pages/my_account.dart';
import 'package:flutter/material.dart';
import 'package:bakery_manager_mobile/assets/constants.dart';
import 'package:bakery_manager_mobile/pages/add_recipe_page.dart';
import 'package:bakery_manager_mobile/pages/recipe_details_page.dart';

Map<String, WidgetBuilder> appRoutes = {
  homePageRoute: (context) => const MyHomePage(),
  recipePageRoute: (context) => const AllRecipesPage(),
  ingredientPageRoute: (context) => const IngredientPage(),
  productPageRoute: (context) => const ProductPage(),
  taskPageRoute: (context) => const TaskPage(),
  salesPageRoute: (context) => const SalesPage(),
  loginPageRoute: (context) => const LoginPage(),
  registrationPageRoute: (context) => const CreateAccountPage(),
  addRecipePageRoute: (context) => const AddRecipePage(),
  recipeDetailsPageRoute: (context) => const RecipeDetailPage(),
  myAccountRoute: (context) => const MyAccountPage(),
};