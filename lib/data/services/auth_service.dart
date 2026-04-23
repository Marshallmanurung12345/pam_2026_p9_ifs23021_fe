import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  static Future<String> login({
    required String username,
    required String password,
  }) async {
    late final http.Response response;
    try {
      response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
    } on http.ClientException {
      throw AuthException(_networkErrorMessage());
    } catch (_) {
      throw AuthException(_networkErrorMessage());
    }

    if (response.statusCode != 200) {
      throw AuthException('Login gagal: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    final token = _extractToken(decoded);

    if (token == null || token.isEmpty) {
      throw const AuthException('Token tidak ditemukan pada response login.');
    }

    return token;
  }

  static Future<Map<String, dynamic>> getCurrentUser(String token) async {
    late final http.Response response;
    try {
      response = await http.get(
        Uri.parse(ApiConstants.me),
        headers: {'Authorization': 'Bearer $token'},
      );
    } on http.ClientException {
      throw AuthException(_networkErrorMessage());
    } catch (_) {
      throw AuthException(_networkErrorMessage());
    }

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'data': decoded};
    }

    if (response.statusCode == 401) {
      throw const AuthException('Unauthorized');
    }

    throw AuthException('Validasi sesi gagal: ${response.statusCode}');
  }

  static String? _extractToken(dynamic decoded) {
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    final directToken = decoded['token']?.toString();
    if (directToken != null && directToken.isNotEmpty) {
      return directToken;
    }

    final data = decoded['data'];
    if (data is Map<String, dynamic>) {
      final nestedToken = data['token']?.toString();
      if (nestedToken != null && nestedToken.isNotEmpty) {
        return nestedToken;
      }
    }

    return null;
  }

  static String _networkErrorMessage() {
    if (kIsWeb) {
      return 'Gagal menghubungi server. Jika memakai Flutter Web, backend harus mengizinkan CORS untuk origin aplikasi ini.';
    }

    return 'Gagal menghubungi server. Periksa koneksi atau API base URL.';
  }
}
