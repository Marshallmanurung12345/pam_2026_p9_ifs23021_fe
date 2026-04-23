import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import 'auth_storage.dart';

class UnauthorizedException implements Exception {
  final String message;

  const UnauthorizedException([this.message = 'Unauthorized']);

  @override
  String toString() => message;
}

class MotivationService {
  static Future<Map<String, dynamic>> getMotivations(int page) async {
    final token = await AuthStorage.getToken();
    final uri = Uri.parse(
      ApiConstants.recommendations,
    ).replace(queryParameters: {'page': page.toString()});

    late final http.Response response;
    try {
      response = await http.get(uri, headers: _authorizedHeaders(token));
    } on http.ClientException {
      throw Exception(_networkErrorMessage());
    } catch (_) {
      throw Exception(_networkErrorMessage());
    }

    if (response.statusCode == 401) {
      throw const UnauthorizedException();
    }

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
    final token = await AuthStorage.getToken();
    final payload = {'theme': theme, 'total': total};
    late final http.Response response;
    try {
      response = await http.post(
        Uri.parse(ApiConstants.generate),
        headers: {
          ..._authorizedHeaders(token),
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
    } on http.ClientException {
      throw Exception(_networkErrorMessage());
    } catch (_) {
      throw Exception(_networkErrorMessage());
    }

    if (response.statusCode == 401) {
      throw const UnauthorizedException();
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to generate recommendations: '
        '${response.statusCode} '
        'url=${ApiConstants.generate} '
        'payload=${jsonEncode(payload)} '
        'response=${response.body}',
      );
    }
  }

  static Map<String, String> _authorizedHeaders(String? token) {
    if (token == null || token.isEmpty) {
      throw const UnauthorizedException('Token tidak tersedia.');
    }

    return {'Authorization': 'Bearer $token'};
  }

  static String _networkErrorMessage() {
    if (kIsWeb) {
      return 'Gagal menghubungi server. Jika memakai Flutter Web, backend harus mengizinkan CORS untuk origin aplikasi ini.';
    }

    return 'Gagal menghubungi server. Periksa koneksi atau API base URL.';
  }
}
