import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class ApiService {
  static Future<List<Recipe>> getRecipes() async {
    final baseApiUrl = dotenv.env['BASE_URL'];
    final response = await http.get(Uri.parse('$baseApiUrl/recipes'));
    if (response.statusCode == 200) {
      Map<String, dynamic> body = json.decode(response.body);
      List<dynamic> recipeList = body['recipes'];
      return recipeList.map((dynamic item) => Recipe.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }
}
