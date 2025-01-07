import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/service_locator.dart';
import 'project_detail_page.dart';

class ProjectListPage extends StatefulWidget {
  const ProjectListPage({Key? key}) : super(key: key);

  @override
  _ProjectListPageState createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  late Future<List<Project>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _refreshProjects();
  }

  void _refreshProjects() {
    setState(() {
      _projectsFuture = ServiceLocator.projectService.fetchProjects();
    });
  }

  void _navigateToProjectDetail(String projectId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailPage(projectId: projectId),
      ),
    ).then((_) => _refreshProjects());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProjects,
          ),
        ],
      ),
      body: FutureBuilder<List<Project>>(
        future: _projectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No projects available.'));
          } else {
            final projects = snapshot.data!;
            return ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(project.name[0]),
                      backgroundColor: Colors.blueAccent,
                    ),
                    title: Text(project.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      project.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () => _navigateToProjectDetail(project.projectId),
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
