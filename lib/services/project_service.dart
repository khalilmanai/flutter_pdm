// lib/services/project_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project.dart';
import 'api_service.dart';
import 'api_constants.dart';

class ProjectService {
  final ApiService _apiService;

  ProjectService(this._apiService);

  Future<List<Project>> fetchProjects() async {
  final response = await _apiService.get(ApiConstants.projectsEndpoint);
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Project.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load projects: ${response.body}');
  }
}



  Future<Project> fetchProjectById(String projectId) async {
  final response = await _apiService.get('${ApiConstants.projectsEndpoint}/$projectId');
  if (response.statusCode == 200) {
    return Project.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load project: ${response.body}');
  }
}


  // Implement additional methods as needed (create, update, delete)
}
