import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'api_service.dart';
import 'api_constants.dart';
import '../helpers/user_role_helper.dart';

class UserService {
  final ApiService _apiService;

  UserService(this._apiService);

  /// Fetches the list of users from the API.
  /// Optionally filters users by role.
  Future<List<User>> fetchUsers({UserRole? role}) async {
    try {
      String endpoint = ApiConstants.usersEndpoint;
      if (role != null) {
        endpoint += '?role=${UserRoleHelper.roleToString(role)}';
      }
      print("Fetching users from endpoint: $endpoint");

      final response = await _apiService.get(endpoint);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load users. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching users: $e");
      throw Exception('Error fetching users: $e');
    }
  }

  /// Creates a new user with the provided signup data.
  Future<bool> createUser(Map<String, dynamic> userSignupData) async {
    try {
      final endpoint = '${ApiConstants.usersEndpoint}/auth/signup';
      print("Creating user at endpoint: $endpoint");

      final response = await _apiService.post(endpoint, userSignupData);

      if (response.statusCode == 201) {
        return true;
      } else {
        final errorMessage =
            'Failed to create user. Status code: ${response.statusCode}, Body: ${response.body}';
        print(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("Error creating user: $e");
      throw Exception('Error creating user: $e');
    }
  }

  /// Updates an existing user with the provided data.
  Future<bool> updateUser(String userId, Map<String, dynamic> updatedData) async {
    try {
      final endpoint = '${ApiConstants.usersEndpoint}/$userId';
      print("Updating user at endpoint: $endpoint");

      final response = await _apiService.put(endpoint, updatedData);

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorMessage =
            'Failed to update user. Status code: ${response.statusCode}, Body: ${response.body}';
        print(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("Error updating user: $e");
      throw Exception('Error updating user: $e');
    }
  }

  /// Deletes a user by their ID.
  Future<bool> deleteUser(String userId) async {
    try {
      final endpoint = '${ApiConstants.usersEndpoint}/$userId';
      print("Deleting user at endpoint: $endpoint");

      final response = await _apiService.delete(endpoint);

      if (response.statusCode == 204) {
        final successMessage = 'User Deleted Successfully';
        print("User deleted successfully. Response: ${response.body}");
        return true;
      } else {
        final errorMessage =
            'Failed to delete user. Status code: ${response.statusCode}, Body: ${response.body}';
        print(errorMessage);
        return false;
      }
    } catch (e) {
      print("Error deleting user: $e");
      return false;
    }
  }
}
