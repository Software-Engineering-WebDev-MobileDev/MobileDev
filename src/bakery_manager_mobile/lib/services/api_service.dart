import 'dart:convert';
import 'package:bakery_manager_mobile/models/account.dart';
import 'package:bakery_manager_mobile/models/ingredient.dart';
import 'package:bakery_manager_mobile/models/task.dart';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
//import '../models/account.dart';
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
    } catch (e) {
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
      String password,
      String email,
      String phoneNumber) async {
    final url = Uri.parse('$baseApiUrl/create_account');
    final headers = {
      'employee_id': employeeID,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'password': password,
      'email_address': email,
      'phone_number': phoneNumber
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

   static Future<Map<String, dynamic>> addTask({
    required String recipeID,
    required int amountToBake,
    required String assignedEmployeeID,
    required String dueDate,
    String? comments,
  }) async {
    final url = Uri.parse('$baseApiUrl/add_task');
    final sessionId = await SessionManager().getSessionToken(); // Assuming session manager gives you session token

    // Set headers, including session_id
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'session_id': sessionId!,
    };

    // Prepare the request body
    final Map<String, dynamic> body = {
      'RecipeID': recipeID,
      'AmountToBake': amountToBake,
      'AssignedEmployeeID': assignedEmployeeID,
      'DueDate': dueDate,
    };

    // Add comments if provided
    if (comments != null && comments.isNotEmpty) {
      body['Comments'] = comments;
    }

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        // Success response, parse response if needed
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'success',
          'taskID': responseBody['taskID'],
          if (responseBody['commentID'] != null) 'commentID': responseBody['commentID'],
        };
      } else {
        // Handle error responses
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'error',
          'reason': responseBody['reason'] ?? 'Failed to add task',
        };
      }
    } catch (e) {
      // Handle network or parsing errors
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> addUserEmail({
    required String emailAddress,
    required String type,
  }) async {
    final url = Uri.parse('$baseApiUrl/add_user_email');
    final sessionId = await SessionManager().getSessionToken();
    final headers = <String, String>{
      'session_id': sessionId!,
      'email_address': emailAddress,
      'type': type
    };

    try {
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 201) {
        return {'status': 'success'};
      } else {
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'error',
          'reason': responseBody['reason'] ?? 'Failed to add email',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteUserEmail({
    required String emailAddress,
  }) async {
    final url = Uri.parse('$baseApiUrl/user_email');
    final sessionId = await SessionManager().getSessionToken();
    final headers = <String, String>{
      'session_id': sessionId!,
      'email_address': emailAddress
    };

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        return {'status': 'success'};
      } else if (response.statusCode == 409) {
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'error',
          'reason': responseBody['reason'] ?? 'Email address does not exist',
        };
      } else {
        return {
          'status': 'error',
          'reason': 'Failed to delete email: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> addUserPhone({
    required String phoneNumber,
    required String type,
  }) async {
    final url = Uri.parse('$baseApiUrl/add_user_phone');
    final sessionId = await SessionManager().getSessionToken();
    final headers = <String, String>{
      'session_id': sessionId!,
      'phone_number': phoneNumber,
      'type': type,
    };

    try {
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 201) {
        return {'status': 'success'};
      } else {
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'error',
          'reason': responseBody['reason'] ?? 'Failed to add phone number',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteUserPhone({
    required String phoneNumber,
  }) async {
    final url = Uri.parse('$baseApiUrl/user_phone');
    final sessionId = await SessionManager().getSessionToken();
    final headers = <String, String>{
      'session_id': sessionId!,
      'phone_number': phoneNumber,
    };

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        return {'status': 'success'};
      } else if (response.statusCode == 409) {
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'error',
          'reason': responseBody['reason'] ?? 'Phone number does not exist',
        };
      } else {
        return {
          'status': 'error',
          'reason': 'Failed to delete phone number: ${response.statusCode}',
        };
      }
    } catch (e) {
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
  static Future<Map<String, dynamic>> getUserInfo() async {
    final url = Uri.parse('$baseApiUrl/my_info');
    String sessionId = await SessionManager().getSessionToken() ?? "";

    try {
      // Make the HTTP GET request
      final response = await http.get(
        url,
        headers: {
          'session_id': sessionId,
        },
      );

      // Successful response
      if (response.statusCode == 200) {
        Map<String, dynamic> body = json.decode(response.body);

        if (body['status'] == 'success') {
          return {
            'status': 'success',
            'content': body['content'], // Includes all user information
          };
        } else {
          return {
            'status': 'error',
            'reason': body['reason'],
          };
        }
      } else {
        return {
          'status': 'error',
          'reason': 'Failed to load user info: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getUserList(
      {int page = 1, int pageSize = 20}) async {
    final url = Uri.parse('$baseApiUrl/user_list');
    String sessionId = await SessionManager().getSessionToken() ?? "";

    try {
      // Make the HTTP GET request
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

        if (body['status'] == 'success') {
          return {
            'status': 'success',
            'page': body['page'],
            'page_count': body['page_count'],
            'content': (body['content'] as List<dynamic>).map((user) => Account.fromJson(user)).toList(),// Includes list of users
          };
        } else {
          return {
            'status': 'error',
            'reason': body['reason'],
          };
        }
      } else {
        return {
          'status': 'error',
          'reason': 'Failed to load user list: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }
}
