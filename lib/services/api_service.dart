import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class ApiService {
  static const String _base = 'https://185.140.181.252/kanban/api';

  static http.Client _client() {
    final httpClient = HttpClient()
      ..badCertificateCallback = (_, __, ___) => true;
    return IOClient(httpClient);
  }

  static Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String path, {String? token}) async {
    final client = _client();
    try {
      return await client.get(
        Uri.parse('$_base$path'),
        headers: _headers(token: token),
      );
    } finally {
      client.close();
    }
  }

  static Future<http.Response> post(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final client = _client();
    try {
      return await client.post(
        Uri.parse('$_base$path'),
        headers: _headers(token: token),
        body: jsonEncode(body),
      );
    } finally {
      client.close();
    }
  }

  static Future<http.Response> put(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final client = _client();
    try {
      return await client.put(
        Uri.parse('$_base$path'),
        headers: _headers(token: token),
        body: jsonEncode(body),
      );
    } finally {
      client.close();
    }
  }

  static Future<http.Response> delete(String path, {String? token}) async {
    final client = _client();
    try {
      return await client.delete(
        Uri.parse('$_base$path'),
        headers: _headers(token: token),
      );
    } finally {
      client.close();
    }
  }
}
