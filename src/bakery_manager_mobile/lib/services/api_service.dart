import 'dart:convert';
import 'package:bakery_manager_mobile/models/ingredient.dart';
import 'package:bakery_manager_mobile/models/task.dart';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../models/account.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'session_manager.dart';

// API Service Class
class ApiService {
  static final baseApiUrl = dotenv.env['BASE_URL'];

  // Get Recipes Function
  static Future<Map<String, dynamic>> getRecipes() async {
    final url = Uri.parse('$baseApiUrl/recipes');
    try {
      final response = await http.get(url);

      // Successful response
      if (response.statusCode == 200) {
        Map<String, dynamic> body = json.decode(response.body);
        List<dynamic> recipeList = body['recipes'];
        return {
          'status': 'success',
          'recipes':
              recipeList.map((dynamic item) => Recipe.fromJson(item)).toList(),
        };
      }
      // Failed response
      else {
        return {
          'status': 'error',
          'reason': 'Failed to load recipes: ${response.statusCode}',
        };
      }
    } catch (e) {
      // Network error
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  // Add Recipe Function
  static Future<Map<String, dynamic>> addRecipe(
      {String recipeName = "",
      String ingredients = "",
      int servings = 1,
      String description = "",
      String category = "",
      double prepTime = 0,
      double cookTime = 0}) async {
    final url = Uri.parse('$baseApiUrl/add_recipe');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "RecipeName": recipeName,
      "Instructions": ingredients,
      "Servings": servings.toString(),
      "Category": category,
      "PrepTime": prepTime,
      "CookTime": cookTime,
      "Description": description
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      // Successful response

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return {'status': 'success', 'recipeID': responseBody['recipeID']};
      }
      // Failed response
      else {
        return {
          'status': 'error',
          'reason': 'Failed to add recipe: ${response.statusCode}',
        };
      }
    } catch (e) {
      // Network error
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> updateRecipe({
    required String recipeId,
    required String recipeName,
    required String instructions,
    required int servings,
    required String category,
    required double prepTime,
    required double cookTime,
    required String description,
  }) async {
    final url = Uri.parse('$baseApiUrl/update_recipe/$recipeId');
    final headers = {'Content-Type': 'application/json'};
    final now = DateTime.now();
    final formattedDate =
        now.toIso8601String().split('T').join(' ').split('.').first;

    final body = jsonEncode({
      "RecipeName": recipeName,
      "Instructions": instructions,
      "Servings": servings.toString(),
      "Category": category,
      "PrepTime": prepTime,
      "CookTime": cookTime,
      "Description": description,
      "UpdatedAt": formattedDate,
    });

    try {
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'success',
          'updatedAt': responseBody['updatedAt'],
        };
      } else {
        return {
          'status': 'error',
          'reason': 'Failed to update recipe: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteRecipe({
    required String recipeId,
  }) async {
    final url = Uri.parse('$baseApiUrl/delete_recipe/$recipeId');
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'success',
          'message': responseBody['message'] ?? 'Recipe deleted successfully',
        };
      } else {
        return {
          'status': 'error',
          'reason': 'Failed to delete recipe: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> addRecipeIngredient(
      {String recipeID = "",
      String ingredientDescription = "",
      double quantity = 0,
      String unit = "",
      int stockQuantity = 0,
      int reorderFlag = 0}) async {
    final url = Uri.parse('$baseApiUrl/add_recipe_ingredient');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "RecipeID": recipeID,
      "IngredientDescription": ingredientDescription,
      "Quantity": quantity.toString(),
      "UnitOfMeasure": unit,
      "QuantityInStock": stockQuantity.toString(),
      "ReorderFlag": reorderFlag.toString(),
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      // Successful response
      if (response.statusCode == 200) {
        return {'status': 'success'};
      }
      // Failed response
      else {
        return {
          'status': 'error',
          'reason': 'Failed to add recipe ingredient: ${response.statusCode}',
        };
      }
    } catch (e) {
      // Network error
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getRecipeIngredients(
      String recipeID) async {
    final url = Uri.parse('$baseApiUrl/recipe/$recipeID');
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Filter ingredients from the full recipe response
        final ingredients = data['recipe']
            .map((item) => {
                  'RecipeIngredientID': item['RecipeIngredientID'],
                  'IngredientDescription': item['IngredientDescription'],
                  'Quantity': item['Quantity'],
                  'UnitOfMeasure': item['UnitOfMeasure'],
                  'QuantityInStock': item['QuantityInStock'],
                  'ReorderFlag': item['ReorderFlag'],
                  'ModifierID': item['ModifierID'],
                  'ScalingFactorID': item['ScalingFactorID'],
                })
            .toList();

        return {
          'status': 'success',
          'ingredients': ingredients, // Only return the ingredients
        };
      } else {
        return {
          'status': 'error',
          'reason': 'Failed to fetch recipe: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getRecipeName(String recipeID) async {
    final url = Uri.parse('$baseApiUrl/recipe/$recipeID');
    final headers = {'Content-Type': 'application/json'};

      try {
        final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract the recipe name from the response
        final String recipeName = data['recipe'][0]['RecipeName'];
        return {
          'status': 'success',
          'recipeName': recipeName,
        };
      } else {
        return {
          'status': 'error',
          'reason': 'Failed to fetch recipe name: ${response.statusCode}',
        };
      }
    }
    catch(e){
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }


  static Future<Map<String, dynamic>> getInventory(
      {int page = 1, int pageSize = 20}) async {
    final url = Uri.parse('$baseApiUrl/inventory');
    String sessionId = await SessionManager().getSessionToken() ?? "";
    try {
      final response = await http.get(
        url,
        headers: {
          'session_id': sessionId,
          'page': page.toString(),
          'page_size': pageSize.toString(),
        },
      );

      // Successful response
      if (response.statusCode == 200) {
        Map<String, dynamic> body = json.decode(response.body);
        List<dynamic> inventoryList = body['content'];
        return {
          'status': 'success',
          'inventory': inventoryList
              .map((dynamic item) => Ingredient.fromJson(item))
              .toList(),
          'page': body['page'],
          'page_count': body['page_count'],
        };
      }
      // Failed response
      else {
        return {
          'status': 'error',
          'reason': 'Failed to load inventory: ${response.statusCode}',
        };
      }
    } catch (e) {
      // Network error
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  // Create Account Function
  static Future<Map<String, dynamic>> createAccount(
      String firstName,
      String lastName,
      String employeeID,
      String username,
      String password) async {
    final url = Uri.parse('$baseApiUrl/create_account');
    final headers = {
      'employee_id': employeeID,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'password': password,
    };

    try {
      final response = await http.post(url, headers: headers);

      // Successful response
      if (response.statusCode == 201) {
        return {'status': 'success'};
      }
      // Failed response
      else {
        return {
          'status': 'error',
          'reason': 'Failed to create account: ${response.statusCode}',
        };
      }
    } catch (e) {
      // Network error
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getTasks() async {
    final url = Uri.parse('$baseApiUrl/tasks');
    String sessionId = await SessionManager().getSessionToken() ?? "";

    try {
      final response = await http.get(
        url,
        headers: {
          'session_id': sessionId,
        },
      );

      // Successful response
      if (response.statusCode == 200) {
        Map<String, dynamic> body = json.decode(response.body);
        List<dynamic> taskList = body['recipes']; // Assuming 'tasks' as key
        return {
          'status': 'success',
          'tasks': taskList.map((dynamic item) => Task.fromJson(item)).toList(),
        };
      }
      // Failed response
      else {
        return {
          'status': 'error',
          'reason': 'Failed to load tasks: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }
  
  // Add User Email Function
  static Future<Map<String, dynamic>> addUserEmail({
    required String sessionID,
    required String emailAddress,
    required String emailType,
  }) async {
    final url = Uri.parse('$baseApiUrl/api/add_user_email');  // API endpoint URL

    try {
      // Perform the POST request
      final response = await http.post(
        url,
        headers: {
          'session_id': sessionID,
          'email_address': emailAddress,
          'type': emailType,  // <personal|work|other>
        },
      );

      // If the response status is 200, parse the JSON response
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        return {
          'status': responseBody['status'],
        };
      } 
      // If the session is invalid or expired, handle 498 error
      else if (response.statusCode == 498) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        return {
          'status': 'error',
          'reason': responseBody['reason'],
        };
      } 
      // Other errors
      else {
        return {
          'status': 'error',
          'reason': 'Failed to add email: ${response.statusCode}',
        };
      }
    } catch (e) {
      // Catch network or parsing errors
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }
  // Login Function
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final url = Uri.parse('$baseApiUrl/login');
    final headers = <String, String>{
      'username': username,
      'password': password,
    };
    try {
      final response = await http.post(url, headers: headers);

      // Successful response
      if (response.statusCode == 201) {
        // Successfully logged in
        final responseBody = jsonDecode(response.body);
        final sessionManager = SessionManager();
        sessionManager.saveSession(responseBody['session_id']);
        //sessionManager.resetIdleTimer();
        return {
          'status': 'success',
        };
      }
      // Failed response
      else if (response.statusCode == 400 || response.statusCode == 401) {
        // Handle client errors
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'error',
          'reason': responseBody['reason'],
        };
      }
      // Failed response
      else {
        // Handle server errors
        return {
          'status': 'error',
          'reason': 'Unexpected error: ${response.statusCode}',
        };
      }
    } catch (e) {
      // Handle network errors
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<bool> sessionValidate(sessionID) async {
    final url = Uri.parse('$baseApiUrl/token_bump');
    final headers = <String, String>{
      'session_id': sessionID,
    };
    try {
      final response = await http.post(url, headers: headers);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> logout() async {
    final url = Uri.parse('$baseApiUrl/logout');
    final sessionManager = SessionManager();
    final sessionID = await sessionManager.getSessionToken();
    try {
      final headers = <String, String>{
        'session_id': sessionID!,
      };

      final response = await http.post(url, headers: headers);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
  // Get Account Function
  static Future<Map<String, dynamic>> getAccount(String userID) async {
    final url = Uri.parse('$baseApiUrl/account/$userID');
    try {
      final response = await http.get(url);

      // Successful response
      if (response.statusCode == 200) {
        Map<String, dynamic> body = json.decode(response.body);
        return {
          'status': 'success',
          'accountDetails': Account.fromJson(body),
        };
      }
      // Failed response
      else {
        return {
          'status': 'error',
          'reason': 'Failed to load account details: ${response.statusCode}',
        };
      }
    } catch (e) {
      // Network error
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> checkEmployeeIDExists(String employeeID) async {
    final url = Uri.parse('$baseApiUrl/check_employee_id');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = json.encode({'employee_id': employeeID});

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        return {
          'status': responseData['exists'] ? 'exists' : 'not_exists',
        };
      } else {
        return {'status': 'error', 'reason': 'Failed to check Employee ID'};
      }
    } catch (e) {
      return {'status': 'error', 'reason': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> checkEmailExists(String email) async {
    final url = Uri.parse('$baseApiUrl/check_email');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = json.encode({'email': email});

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        return {
          'status': responseData['exists'] ? 'exists' : 'not_exists',
        };
      } else {
        return {'status': 'error', 'reason': 'Failed to check Email'};
      }
    } catch (e) {
      return {'status': 'error', 'reason': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> checkUsernameExists(String username) async {
    final url = Uri.parse('$baseApiUrl/check_username');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = json.encode({'username': username});

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        return {
          'status': responseData['exists'] ? 'exists' : 'not_exists',
        };
      } else {
        return {'status': 'error', 'reason': 'Failed to check Username'};
      }
    } catch (e) {
      return {'status': 'error', 'reason': 'Network error: $e'};
    }
  }

}
