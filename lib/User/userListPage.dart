import 'dart:convert'; // Import this for base64 decoding
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/service_locator.dart';
import '../helpers/user_role_helper.dart';
import 'UserDetailPage.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  late Future<List<User>> _usersFuture;
  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  UserRole? _selectedRole;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() {
    _usersFuture = ServiceLocator.userService.fetchUsers();
    _usersFuture.then((users) {
      setState(() {
        _allUsers = users;
        _applyFilter();
      });
    });
  }

  void _applyFilter() {
    if (_selectedRole == null) {
      _filteredUsers = _allUsers;
    } else {
      _filteredUsers =
          _allUsers.where((user) => user.role == _selectedRole).toList();
    }
  }

  void _onRoleSelected(UserRole? role) {
    setState(() {
      _selectedRole = role;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<UserRole?>(
                value: _selectedRole,
                onChanged: _onRoleSelected,
                icon: const Icon(Icons.filter_list, color: Colors.white),
                dropdownColor: Colors.white,
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Roles')),
                  DropdownMenuItem(
                    value: UserRole.PROJECT_MANAGER,
                    child: const Text('Project Manager'),
                  ),
                  DropdownMenuItem(
                    value: UserRole.MEMBER,
                    child: const Text('Member'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error fetching users: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else if (_filteredUsers.isEmpty) {
            return const Center(
              child: Text('No users found.', style: TextStyle(fontSize: 18)),
            );
          } else {
            return ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      leading: user.image != null && user.image!.isNotEmpty
                          ? CircleAvatar(
                        radius: 24,
                        backgroundImage: MemoryImage(
                          base64Decode(user.image!),
                        ),
                      )
                          : CircleAvatar(
                        radius: 24,
                        child: Text(
                          user.username[0].toUpperCase(),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      title: Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            UserRoleHelper.roleToString(user.role),
                            style: TextStyle(
                              color: user.role == UserRole.PROJECT_MANAGER
                                  ? Colors.blue
                                  : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetailPage(user: user),
                          ),
                        ).then((_) => _fetchUsers());
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
