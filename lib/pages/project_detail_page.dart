import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/service_locator.dart';


class ProjectDetailPage extends StatefulWidget {
  final String projectId;

  ProjectDetailPage({required this.projectId});

  @override
  _ProjectDetailPageState createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  late Future<Project> _projectFuture;

  @override
  void initState() {
    super.initState();
    _projectFuture = ServiceLocator.projectService.fetchProjectById(widget.projectId);
  }

  Future<void> _refreshProject() async {
    setState(() {
      _projectFuture = ServiceLocator.projectService.fetchProjectById(widget.projectId);
    });
  }

 

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProject,
          ),
        ],
      ),
      body: FutureBuilder<Project>(
        future: _projectFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            debugPrint('Error fetching project: ${snapshot.error}');
            return Center(
              child: Text('Error fetching project: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Project not found.'));
          } else {
            final project = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    project.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  _buildProjectDetails(project),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tasks',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildProjectDetails(Project project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Budget', project.budget),
        _buildDetailRow('Deadline', project.deadline),
        _buildDetailRow('Methodology', project.methodology),
        _buildDetailRow('Project Manager', project.projectManager.username),
        _buildDetailRow(
          'Team Members',
          project.teamMembers.map((member) => member.username).join(', '),
        ),
        if (project.cahierDeChargeFileUrl != null)
          _buildDetailRow('Cahier de Charge', project.cahierDeChargeFileUrl!),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  
}
