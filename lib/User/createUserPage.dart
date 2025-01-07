import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateUserPage extends StatefulWidget {
  final Function onUserCreated;

  const CreateUserPage({super.key, required this.onUserCreated});

  @override
  _CreateUserPageState createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final String apiUrl = 'http://10.0.2.2:3000/users';
  final _formKey = GlobalKey<FormState>();
  String? username;
  String? email;
  String? role;
  final roles = ['PROJECT_MANAGER', 'MEMBER'];

  Future<void> createUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'username': username,
            'email': email,
            'role': role,
          }),
        );
        if (response.statusCode == 201) {
          widget.onUserCreated();
          Navigator.pop(context);
        } else {
          showError('Failed to create user');
        }
      } catch (error) {
        showError('Error creating user: $error');
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
                onChanged: (value) => role = value,
                validator: (value) =>
                    value == null ? 'Please select a role' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
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
