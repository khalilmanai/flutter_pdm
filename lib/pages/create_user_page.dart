// lib/pages/createUserPage.dart

import 'package:flutter/material.dart';
import '../services/service_locator.dart';

class CreateUserPage extends StatefulWidget {
  final Function onUserCreated;

  const CreateUserPage({Key? key, required this.onUserCreated}) : super(key: key);

  @override
  _CreateUserPageState createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  String? username;
  String? email;
  String? role;
  final roles = ['PROJECT_MANAGER', 'MEMBER'];

  bool _isSubmitting = false;

  Future<void> createUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSubmitting = true;
      });

      try {
        final userData = {
          'username': username,
          'email': email,
          'role': role,
        };

        // Use UserService to create user
        final success = await ServiceLocator.userService.createUser(userData);

        if (success) {
          widget.onUserCreated();
          Navigator.pop(context);
        } else {
          showError('Failed to create user');
        }
      } catch (error) {
        showError('Error creating user: $error');
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
                onSaved: (value) => username = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onSaved: (value) => email = value,
              ),
              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: 'Role'),
                items: roles
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (value) => role = value as String?,
                validator: (value) =>
                    value == null ? 'Please select a role' : null,
              ),
              const SizedBox(height: 20),
              _isSubmitting
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: createUser,
                      child: const Text('Create User'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
