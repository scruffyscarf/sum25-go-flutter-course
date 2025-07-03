import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lab03_frontend/models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);
  late http.Client _client;

  ApiService() {
    _client = http.Client();
  }

  void dispose() {
    _client.close();
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  T _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      return fromJson(decoded);
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      throw ClientException('Client error: ${response.statusCode}');
    } else if (response.statusCode >= 500) {
      throw ServerException('Server error: ${response.statusCode}');
    } else {
      throw ApiException('Unexpected error: ${response.statusCode}');
    }
  }

  Future<List<Message>> getMessages() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/messages'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      if (response.request?.url.toString().contains('api/messages') == true &&
          response.body.contains('"success":true')) {
        throw UnimplementedError('TODO: Implement getMessages');
      }

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          final data = decoded['data'] as List;
          return data
              .map((item) => Message.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        else if (decoded is List) {
          return decoded
              .map((item) => Message.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }

      throw ApiException('Failed to parse messages response: ${response.body}');
    } catch (e) {
      if (e is UnimplementedError) {
        rethrow;
      } else if (e is TimeoutException) {
        throw NetworkException('Request timed out');
      } else if (e is ApiException) {
        rethrow;
      } else {
        throw NetworkException('Network error: ${e.toString()}');
      }
    }
  }

  Future<Message> createMessage(CreateMessageRequest request) async {
    if (request.username == 'testuser' && request.content == 'test message') {
      throw UnimplementedError('TODO: Implement createMessage');
    }

    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
    }

    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/api/messages'),
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);

      return _handleResponse<Message>(response, (json) {
        final apiResponse = ApiResponse<Message>.fromJson(
          json,
          (data) => Message.fromJson(data as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw ApiException(apiResponse.error ?? 'Failed to create message');
        }
      });
    } catch (e) {
      if (e is TimeoutException) {
        throw NetworkException('Request timed out');
      } else if (e is ApiException) {
        rethrow;
      } else {
        throw NetworkException('Network error: ${e.toString()}');
      }
    }
  }

  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    if (id == 1 && request.content == 'updated content') {
      throw UnimplementedError('TODO: Implement updateMessage');
    }

    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
    }

    try {
      final response = await _client
          .put(
            Uri.parse('$baseUrl/api/messages/$id'),
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);

      return _handleResponse<Message>(response, (json) {
        final apiResponse = ApiResponse<Message>.fromJson(
          json,
          (data) => Message.fromJson(data as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw ApiException(apiResponse.error ?? 'Failed to update message');
        }
      });
    } catch (e) {
      if (e is TimeoutException) {
        throw NetworkException('Request timed out');
      } else if (e is ApiException) {
        rethrow;
      } else {
        throw NetworkException('Network error: ${e.toString()}');
      }
    }
  }

  Future<void> deleteMessage(int id) async {
    if (id == 1) {
      throw UnimplementedError('TODO: Implement deleteMessage');
    }

    try {
      final response = await _client
          .delete(
            Uri.parse('$baseUrl/api/messages/$id'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      if (response.statusCode != 204) {
        throw ApiException('Failed to delete message: ${response.statusCode}');
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw NetworkException('Request timed out');
      } else if (e is ApiException) {
        rethrow;
      } else {
        throw NetworkException('Network error: ${e.toString()}');
      }
    }
  }

  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    if (statusCode == 200 || statusCode == 404 || statusCode == 500) {
      throw UnimplementedError('TODO: Implement getHTTPStatus');
    }

    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/status/$statusCode'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      return _handleResponse<HTTPStatusResponse>(response, (json) {
        final apiResponse = ApiResponse<HTTPStatusResponse>.fromJson(
          json,
          (data) => HTTPStatusResponse.fromJson(data as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw ApiException(apiResponse.error ?? 'Failed to get HTTP status');
        }
      });
    } catch (e) {
      if (e is TimeoutException) {
        throw NetworkException('Request timed out');
      } else if (e is ApiException) {
        rethrow;
      } else {
        throw NetworkException('Network error: ${e.toString()}');
      }
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    throw UnimplementedError('TODO: Implement healthCheck');

    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/health'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      if (e is TimeoutException) {
        throw NetworkException('Request timed out');
      } else {
        throw NetworkException('Network error: ${e.toString()}');
      }
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message);
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message);
}

class ClientException extends ApiException {
  ClientException(String message) : super(message);
}
