import 'package:flutter/material.dart';
import 'package:pdm_flutter_app/User/userListPage.dart';

void main() {
  runApp(UserManagementApp());
}

class UserManagementApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'User Management',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: UserListPage(),
    );
  }
}
