import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class ApiService {
  static final baseApiUrl = dotenv.env['BASE_URL'];
    static Future<Map<String, dynamic>> getRecipes() async {
    final url = Uri.parse('$baseApiUrl/recipes');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> body = json.decode(response.body);
        List<dynamic> recipeList = body['recipes'];
        return {
          'status': 'success',
          'recipes': recipeList.map((dynamic item) => Recipe.fromJson(item)).toList(),
        };
      } else {
        return {
          'status': 'error',
          'reason': 'Failed to load recipes: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

    static Future<Map<String, dynamic>> addRecipe({String recipeName = "", String ingredients = "", double scalingFactor = 1.0}) async {
    final url = Uri.parse('$baseApiUrl/add_recipe');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'RecipeName': recipeName,
      'Instructions': ingredients,
      'ScalingFactor': scalingFactor.toString(),
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        return {'status': 'success'};
      } else {
        return {
          'status': 'error',
          'reason': 'Failed to add recipe: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> createAccount(String firstName, String lastName, String employeeID, String username, String password) async {
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

      if (response.statusCode == 201) {
        return {'status': 'success'};
      } else {
        return {
          'status': 'error',
          'reason': 'Failed to create account: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
  final url = Uri.parse('$baseApiUrl/login');
  final headers = <String, String>{
    'Content-Type': 'application/json',
  };
  final body = jsonEncode({
    'username': username,
    'password': password,
  });
try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 201) {
      // Successfully logged in
      final responseBody = jsonDecode(response.body);
      return {
        'status': 'success',
        'session_id': responseBody['session_id'],
      };
    } else if (response.statusCode == 400 || response.statusCode == 401) {
      // Handle client errors
      final responseBody = jsonDecode(response.body);
      return {
        'status': 'error',
        'reason': responseBody['reason'],
      };
    } else {
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
}
