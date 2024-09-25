import 'dart:convert';
import 'package:flutter/material.dart'; //testing
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';

String genSessionId() {
  var uuid = const Uuid();
  return uuid.v4().replaceAll('-', ''); // Generates a UUID and removes the dashes
}


// API Service Class
class ApiService {
  static final baseApiUrl = dotenv.env['BASE_URL'];

  // Get Recipes Function
  static Future<Map<String, dynamic>> getRecipes() async {
    final url = Uri.parse('$baseApiUrl/recipes');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? sessionId = prefs.getString('session_id');

      if (sessionId == null) {
        return {'status': 'error', 'reason': 'No active session'};
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $sessionId', // Send session ID in header
      };

      final response = await http.get(url, headers: headers);

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
      int scalingFactor = 1}) async {
    final url = Uri.parse('$baseApiUrl/add_recipe');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "RecipeName": recipeName,
      "Instructions" : ingredients,
      "Servings": scalingFactor.toString(),
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      // Successful response

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return {'status': 'success',
                'recipeID': responseBody['recipeID']

                };
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

 static Future<Map<String, dynamic>> addRecipeIngredient({String recipeID = "", String ingredientDescription = "", double quantity = 0, String unit = "", int stockQuantity = 0, int reorderFlag = 0}) async {
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

  static Future<Map<String, dynamic>> getRecipeIngredients(String recipeID) async {
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
        'ingredients': ingredients,  // Only return the ingredients
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

  // Login Function
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseApiUrl/login');
    final headers = {
      'Content-Type': 'application/json',
      'username': username,
      'password': password
    };

    try {
      // Make the POST request to the server
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);

        // Check if the server provided a session_id, if not, generate one
        String sessionId = responseBody['session_id'] ?? genSessionId();

        // Post the generated session ID to the backend if needed
        if (responseBody['session_id'] == null) {
          final sessionPostUrl = Uri.parse('$baseApiUrl/post_login_success');
          await http.post(sessionPostUrl, body: jsonEncode({'session_id': sessionId}), headers: {'Content-Type': 'application/json'});

           //testing
          final sessionPostResponse = await http.post(sessionPostUrl, 
              body: jsonEncode({'session_id': sessionId}), 
              headers: {'Content-Type': 'application/json'}
          );
          if (sessionPostResponse.statusCode == 200) {
            debugPrint('Session ID successfully posted: $sessionId');
          } else {
            debugPrint('Failed to post Session ID. Status code: ${sessionPostResponse.statusCode}');
          }
        }

        // Store session ID in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('session_id', sessionId);

        return {
          'status': 'success',
          'session_id': sessionId,
        };
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'error',
          'reason': responseBody['reason'] ?? 'Invalid login credentials',
        };
      } else {
        return {
          'status': 'error',
          'reason': 'Unexpected error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  // Logout Function
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString('session_id'); // Retrieve session ID

    if (sessionId != null) {
      final url = Uri.parse('$baseApiUrl/logout');
      final headers = {
        'Content-Type': 'application/json',
        'session_id': sessionId // Send session_id in the headers
      };

      try {
        // Make the POST request to the backend to delete the session
        final response = await http.post(url, headers: headers);

        if (response.statusCode == 200) {
          // If successful, clear session data locally
          await prefs.clear();
          print('Successfully logged out');
        } else {
          print('Failed to log out. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error logging out: $e');
      }
    } else {
      print('No session found to log out.');
    }
  }

  static Future<Map<String, dynamic>> bumpSessionToken() async {
    final sessionId = await _getSessionId(); // Get session ID from local storage

    if (sessionId == null) {
      return {
        'status': 'error',
        'reason': 'No active session found',
      };
    }

    final url = Uri.parse('$baseApiUrl/token_bump');
    final headers = {
      'Content-Type': 'application/json',
      'session_id': sessionId, // Send session_id in the headers
    };

    try {
      // Make the POST request to bump the session token
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        // Token successfully bumped
        return {
          'status': 'success',
        };
      } else if (response.statusCode == 498) {
        // Invalid or expired token
        return {
          'status': 'error',
          'reason': 'Invalid or expired session',
        };
      } else {
        // Other server-side error
        return {
          'status': 'error',
          'reason': 'Unexpected error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<String?> _getSessionId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('session_id');
  }

}