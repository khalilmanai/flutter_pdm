import 'package:flutter/material.dart';
import '../models/user.dart';
import '../helpers/user_role_helper.dart';
import '../services/service_locator.dart';

class UserDetailPage extends StatefulWidget {
  final User user;

  const UserDetailPage({Key? key, required this.user}) : super(key: key);

  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late String _selectedRole;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    _selectedRole = UserRoleHelper.roleToString(widget.user.role);
  }

  Future<void> _saveChanges() async {
    final updatedUser = {
      'username': _usernameController.text,
      'email': _emailController.text,
      'role': _selectedRole,
    };

    await ServiceLocator.userService.updateUser(widget.user.id, updatedUser);
    Navigator.pop(context); // Return to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.user.username}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit User Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(labelText: 'Role'),
              items: [
                DropdownMenuItem(
                  value: UserRoleHelper.roleToString(UserRole.PROJECT_MANAGER),
                  child: const Text('Project Manager'),
                ),
                DropdownMenuItem(
                  value: UserRoleHelper.roleToString(UserRole.MEMBER),
                  child: const Text('Member'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
