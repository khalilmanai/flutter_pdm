import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'api_service.dart';
import 'api_constants.dart';
import '../helpers/user_role_helper.dart';

class UserService {
  final ApiService _apiService;

  UserService(this._apiService);

  Future<List<User>> fetchUsers({UserRole? role}) async {
  try {
    String endpoint = ApiConstants.usersEndpoint;
    if (role != null) {
      endpoint += '?role=${UserRoleHelper.roleToString(role)}';
    }

    final response = await _apiService.get(endpoint);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  } catch (e) {
    throw Exception('Error fetching users: $e');
  }
}


  Future<bool> updateUser(String userId, Map<String, dynamic> updatedData) async {
    final response =
        await _apiService.put('${ApiConstants.usersEndpoint}/$userId', updatedData);
    return response.statusCode == 200;
  }
}
