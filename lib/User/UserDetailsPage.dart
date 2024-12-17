import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserDetailPage extends StatefulWidget {
  final String userId;

  UserDetailPage({required this.userId});

  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  final String apiUrl = 'http://localhost:3000/users';
  Map user = {};
  List projects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/${widget.userId}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          user = data['user'];
          projects = data['projects'] ?? [];
          isLoading = false;
        });
      } else {
        showError('Failed to fetch user details.');
      }
    } catch (error) {
      showError('Error fetching user details: $error');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Information',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Divider(),
                    Text(
                      'Username: ${user['username'] ?? 'Unknown'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Role: ${user['role'] ?? 'Unknown'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Projects:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            projects.isEmpty
                ? const Text(
              'No projects assigned.',
              style: TextStyle(fontSize: 16),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return Card(
                  elevation: 2,
                  margin:
                  const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      project['name'] ?? 'Unnamed Project',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                        'Status: ${project['status'] ?? 'Unknown'}'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
