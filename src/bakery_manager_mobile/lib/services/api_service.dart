import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
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

  // Add Email Function
  static Future<Map<String, dynamic>> addEmail(
      String email, String employeeID, String emailTypeID) async {
    final url = Uri.parse('$baseApiUrl/add_user_email');
    final headers = {
      'employee_id': employeeID,
      'email_address': email,
      'email_type_id': emailTypeID,
    };

    try {
      final response = await http.post(url, headers: headers);

      // Successful response
      if (response.statusCode == 201) {
        return {'status': 'success'};
      } else {
        return {
          'status': 'error',
          'reason': 'Failed to add email: ${response.statusCode}',
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

  // Add Phone Number Function
  static Future<Map<String, dynamic>> addPhoneNumber(
      String phoneNumber, String employeeID, String phoneTypeID) async {
    final url = Uri.parse('$baseApiUrl/add_user_phone');
    final headers = {
      'employee_id': employeeID,
      'phone_number': phoneNumber,
      'phone_type_id': phoneTypeID,
    };

    try {
      final response = await http.post(url, headers: headers);

      // Successful response
      if (response.statusCode == 201) {
        return {'status': 'success'};
      } else {
        return {
          'status': 'error',
          'reason': 'Failed to add phone number: ${response.statusCode}',
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
      }
      else {
        return false;
      }
    }
    catch(e){
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
      }
      else {
        return false;
      }
    }
    catch(e){
      return false;
    }

  }
}