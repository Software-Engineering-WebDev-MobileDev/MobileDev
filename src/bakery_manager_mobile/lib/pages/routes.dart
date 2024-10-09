import 'package:flutter/material.dart';
import 'package:bakery_manager_mobile/pages/home_page.dart';
import 'package:bakery_manager_mobile/pages/ingredient_page.dart';
import 'package:bakery_manager_mobile/pages/product_page.dart';
import 'package:bakery_manager_mobile/pages/recipe_page.dart';
import 'package:bakery_manager_mobile/pages/task_details_page.dart';
import 'package:bakery_manager_mobile/pages/task_page.dart';
import 'package:bakery_manager_mobile/pages/add_task_page.dart';
import 'package:bakery_manager_mobile/pages/edit_task_page.dart';
import 'package:bakery_manager_mobile/pages/login.dart';
import 'package:bakery_manager_mobile/pages/account_registration.dart';
import 'package:bakery_manager_mobile/pages/my_account.dart';
import 'package:bakery_manager_mobile/assets/constants.dart';
import 'package:bakery_manager_mobile/pages/add_recipe_page.dart';
import 'package:bakery_manager_mobile/pages/edit_recipe_page.dart';
import 'package:bakery_manager_mobile/pages/recipe_details_page.dart';
import 'package:bakery_manager_mobile/pages/ingredient_detail_page.dart';
import 'package:bakery_manager_mobile/pages/edit_account.dart';

Map<String, WidgetBuilder> appRoutes = {
  homePageRoute: (context) => const MyHomePage(),
  recipePageRoute: (context) => const AllRecipesPage(),
  ingredientPageRoute: (context) => const IngredientPage(),
  productPageRoute: (context) => const ProductPage(),
  taskPageRoute: (context) => const TaskPage(),
  taskDetailsPageRoute: (context) => const TaskDetailPage(),
  //addTaskPageRoute: (context) => const AddTaskPage(),
  //editTaskPageRoute: (context) => const EditTaskPage(),
  loginPageRoute: (context) => const LoginPage(),
  registrationPageRoute: (context) => const CreateAccountPage(),
  addRecipePageRoute: (context) => const AddRecipePage(),
  editRecipePageRoute: (context) => const EditRecipePage(),
  recipeDetailsPageRoute: (context) => const RecipeDetailPage(),
  myAccountRoute: (context) => const MyAccountPage(),
  ingredientDetailsPageRoute: (context) => const IngredientDetailPage(),
  editAccountPageRoute: (context) => const EditAccountPage(),
};


