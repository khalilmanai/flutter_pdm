import 'package:flutter/material.dart';
import 'package:pdm_flutter_app/User/UserDetailsPage.dart';
import 'package:pdm_flutter_app/User/createUserPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final String apiUrl = 'http://localhost:3000/users';
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
    return selectedRole == 'ALL'
        ? users
        : users.where((user) => user['role'] == selectedRole).toList();
  }

  void navigateToCreateUser() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreateUserPage(onUserCreated: fetchUsers)),
    );
  }

  void navigateToUserDetail(Map user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserDetailPage(user: user)),
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
              itemBuilder: (context) => ['ALL', 'PROJECT_MANAGER', 'MEMBER']
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final isWideScreen = constraints.maxWidth > 600;
          final filteredUsers = getFilteredUsers();

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWideScreen ? 3 : 1,
              childAspectRatio: isWideScreen ? 3 : 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              final String username = user['username'] ?? 'Unknown';

              return Card(
                elevation: 4,
                child: InkWell(
                  onTap: () => navigateToUserDetail(user), // Pass user object
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Text(
                            username.isNotEmpty
                                ? username.substring(0, 1).toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                username,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user['role'] ?? 'No role specified',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
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
