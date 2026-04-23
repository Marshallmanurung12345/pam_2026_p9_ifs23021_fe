import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';

class MotivationService {
  static Future<Map<String, dynamic>> getMotivations(int page) async {
    final uri = Uri.parse(
      ApiConstants.recommendations,
    ).replace(queryParameters: {'page': page.toString()});

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch recommendations: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception('Invalid recommendations response format');
  }

  static Future<void> generateMotivation(String theme, int total) async {
    final response = await http.post(
      Uri.parse(ApiConstants.generate),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'theme': theme, 'total': total}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to generate recommendations: ${response.statusCode}',
      );
    }
  }
}
