import '../models/user.dart';

class UserRoleHelper {
  // Convert UserRole enum to string
  static String roleToString(UserRole role) {
    switch (role) {
      case UserRole.PROJECT_MANAGER:
        return 'PROJECT_MANAGER'; // Match backend string
      case UserRole.MEMBER:
        return 'MEMBER'; // Match backend string
      default:
        return 'UNKNOWN';
    }
  }

  // Convert raw role string from backend to UserRole enum
  static UserRole stringToRole(String role) {
    switch (role.toUpperCase()) { // Handle case sensitivity
      case 'PROJECT_MANAGER':
        return UserRole.PROJECT_MANAGER;
      case 'MEMBER':
        return UserRole.MEMBER;
      default:
        throw ArgumentError('Invalid role string: $role');
    }
  }
}
