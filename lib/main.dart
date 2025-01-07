import 'package:flutter/material.dart';
import 'User/userListPage.dart';
import 'pages/project_list_page.dart';
import 'pages/event_list_page.dart'; // Import the EventListPage

void main() {
  runApp(UserManagementApp());
}

class UserManagementApp extends StatefulWidget {
  @override
  _UserManagementAppState createState() => _UserManagementAppState();
}

class _UserManagementAppState extends State<UserManagementApp> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    UserListPage(),
    ProjectListPage(),
    EventListPage(), // Add Event List Page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Backoffice Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event),
              label: 'Events',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blueAccent,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

