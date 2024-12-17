import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdm_flutter_app/User/UserDetailsPage.dart';
import 'package:pdm_flutter_app/User/createUserPage.dart';
import 'dart:convert';



class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final String apiUrl = 'http://10.0.2.2:3000/users';
  List users = [];
  String selectedRole = 'ALL';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          users = json.decode(response.body);
        });
      } else {
        showError('Failed to fetch users. Please try again later.');
      }
    } catch (error) {
      showError('Error fetching users: $error');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
    );
  }

  List getFilteredUsers() {
    if (selectedRole == 'ALL') return users;
    return users.where((user) => user['role'] == selectedRole).toList();
  }

  void navigateToCreateUser() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreateUserPage(onUserCreated: fetchUsers)),
    );
  }

  void navigateToUserDetail(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => UserDetailPage(userId: userId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  selectedRole = value;
                });
              },
              itemBuilder: (context) =>
                  ['ALL', 'PROJECT_MANAGER', 'MEMBER']
                      .map((role) => PopupMenuItem(
                    value: role,
                    child: Text(role),
                  ))
                      .toList(),
              child: Row(
                children: [
                  const Icon(Icons.filter_list),
                  const SizedBox(width: 4),
                  Text(selectedRole),
                ],
              ),
            ),
          ),
        ],
      ),
      body: users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: getFilteredUsers().length,
        itemBuilder: (context, index) {
          final user = getFilteredUsers()[index];
          final String username =
              user['username'] ?? 'Unknown'; // Default value for username
          final String id =
              user['id']?.toString() ?? ''; // Ensure id is not null

          return Card(
            margin:
            const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              title: Text(username),
              subtitle: Text(user['role'] ?? 'No role specified'),
              leading: CircleAvatar(
                child: Text(username.substring(0, 1)),
                backgroundColor: Colors.blueAccent,
              ),
              onTap: () => navigateToUserDetail(id), // Navigate to details
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToCreateUser,
        child: const Icon(Icons.add),
      ),
    );
  }
}
