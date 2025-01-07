import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<http.Response> get(String endpoint) {
    return http.get(Uri.parse('$baseUrl$endpoint'));
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) {
    return http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) {
    return http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
  }

  Future<http.Response> patch(String endpoint, Map<String, dynamic> body) {
    return http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
  }

  Future<http.Response> delete(String endpoint) {
    return http.delete(Uri.parse('$baseUrl$endpoint'));
  }
}
