import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class ApiResult<T> {
  final T? data;
  final String? error;
  final int? statusCode;
  final bool isSuccess;

  ApiResult.success(this.data, {this.statusCode = 200})
      : error = null,
        isSuccess = true;

  ApiResult.failure(this.error, {this.statusCode})
      : data = null,
        isSuccess = false;
}

class ApiClient {
  String _baseUrl;
  String _apiKey;
  final http.Client _client;

  ApiClient({
    String? baseUrl,
    String? apiKey,
    http.Client? client,
  })  : _baseUrl = baseUrl ?? AppConstants.defaultApiBaseUrl,
        _apiKey = apiKey ?? '',
        _client = client ?? http.Client();

  String get baseUrl => _baseUrl;
  String get apiKey => _apiKey;

  void updateConfig({String? baseUrl, String? apiKey}) {
    if (baseUrl != null) _baseUrl = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    if (apiKey != null) _apiKey = apiKey.trim();
  }

  Map<String, String> _buildHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_apiKey.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_apiKey';
      headers['X-API-Key'] = _apiKey;
    }
    return headers;
  }

  /// Ping the backend health/root endpoint
  Future<ApiResult<Map<String, dynamic>>> testConnection() async {
    try {
      final uri = Uri.parse('$_baseUrl/health');
      final response = await _client
          .get(uri, headers: _buildHeaders())
          .timeout(const Duration(seconds: 5));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResult.success(decoded, statusCode: response.statusCode);
      } else {
        return ApiResult.failure(
          'Backend returned HTTP ${response.statusCode}: ${response.reasonPhrase}',
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      return ApiResult.failure(
        'Cannot reach backend at $_baseUrl ($e). Ensure FastAPI server is running on the host machine.',
      );
    } on TimeoutException {
      return ApiResult.failure('Connection timed out while contacting $_baseUrl.');
    } catch (e) {
      return ApiResult.failure('Connection error: $e');
    }
  }

  /// Generic POST request
  Future<ApiResult<Map<String, dynamic>>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final normalizedPath = path.startsWith('/') ? path : '/$path';
      final uri = Uri.parse('$_baseUrl$normalizedPath');
      final response = await _client
          .post(
            uri,
            headers: _buildHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResult.success(decoded, statusCode: response.statusCode);
      } else {
        return ApiResult.failure(
          'HTTP ${response.statusCode}: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      return ApiResult.failure('Network unreachable: ${e.message}');
    } on TimeoutException {
      return ApiResult.failure('Request timed out after ${AppConstants.apiTimeout.inSeconds}s');
    } catch (e) {
      return ApiResult.failure('API error: $e');
    }
  }
}

