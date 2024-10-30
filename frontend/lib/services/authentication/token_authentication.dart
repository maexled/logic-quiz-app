import 'dart:convert';
import 'dart:io';

import 'package:formal_logic_quiz_app/constants.dart';
import 'package:formal_logic_quiz_app/main.dart';
import 'package:formal_logic_quiz_app/services/authentication/token_storage.dart';
import 'package:http/http.dart' as http;

/// Check if the token is valid by sending a request to the server
/// with the token in the Authorization header.
/// Returns true if the token is valid, false otherwise.
/// If the token is 'offline', it is always considered valid.
/// Throws an error if the request fails.
Future<bool> isTokenValid(String token) async {
  if (token == 'offline') {
    return true;
  }
  try {
    final response = await http.post(
      Uri.parse(CHECK_TOKEN_URL),
      headers: {'Authorization': "Bearer $token"},
    ).timeout(const Duration(seconds: 2));

    if (response.statusCode == 200) {
      return true;
    }
  } catch (e) {
    logger.i('Error validating token: $e');
    rethrow;
  }
  return false;
}

Future<(bool, String)> login(String username, String password) async {
  // Special case: offline login with hardcoded credentials
  if (username == 'asdfgh' && password == 'asdfgh') {
    logger.i("Offline login with hardcoded credentials");
    TokenStorage.saveToken('offline');
    return (true, 'offline');
  }
  String errorMessage = "";
  try {
    final Map<String, dynamic> requestBody = {
      'username': username,
      'password': password,
    };

    final response = await http
        .post(
          Uri.parse(LOGIN_URL),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        )
        .timeout(const Duration(seconds: 2));

    final data = jsonDecode(response.body);
    final token = data['token'];
    if (response.statusCode == 200) {
      TokenStorage.saveToken(token);
      logger.d('Login success, token saved: $token');
      return (true, errorMessage);
    } else {
      errorMessage = data['error'];
    }
  } catch (e) {
    if (e is SocketException) {
      errorMessage = 'Server not reachable';
    } else {
      errorMessage = e.toString();
    }
  }
  logger.e('Login failed: $errorMessage');
  return (false, errorMessage);
}

Future<(bool, String)> register(
    String email, String username, String password) async {
  String errorMessage = "";
  try {
    final Map<String, dynamic> requestBody = {
      'email': email,
      'username': username,
      'password': password,
    };

    final response = await http
        .post(
          Uri.parse(REGISTER_URL),
          body: json.encode(requestBody),
        )
        .timeout(const Duration(seconds: 2));

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      logger.d('Register success');
      return (true, errorMessage);
    } else {
      errorMessage = data['error'];
    }
  } catch (e) {
    if (e is SocketException) {
      errorMessage = 'Server not reachable';
    } else {
      errorMessage = e.toString();
    }
  }
  logger.e('Register failed: $errorMessage');
  return (false, errorMessage);
}
