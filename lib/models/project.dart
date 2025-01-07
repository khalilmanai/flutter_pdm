import 'user.dart';

class Project {
  final String projectId;
  final String name;
  final String description;
  final String budget;
  final String deadline;
  final String methodology;
  final User projectManager;
  final List<User> teamMembers;
  final String? cahierDeChargeFileUrl;

  Project({
    required this.projectId,
    required this.name,
    required this.description,
    required this.budget,
    required this.deadline,
    required this.methodology,
    required this.projectManager,
    required this.teamMembers,
    this.cahierDeChargeFileUrl,
  });

factory Project.fromJson(Map<String, dynamic> json) {
  return Project(
    projectId: json['_id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    budget: json['budget'] ?? '',
    deadline: json['deadline'] ?? '',
    methodology: json['methodology'] ?? '',
    projectManager: json['projectManager'] is Map<String, dynamic>
        ? User.fromJson(json['projectManager'])
        : User(
            id: json['projectManager'] ?? '',
            username: 'Unknown',
            email: '',
            role: UserRole.MEMBER,
            status: '',
          ),
    teamMembers: (json['teamMembers'] as List<dynamic>?)
            ?.map((memberJson) => memberJson is Map<String, dynamic>
                ? User.fromJson(memberJson)
                : User(
                    id: memberJson ?? '',
                    username: 'Unknown',
                    email: '',
                    role: UserRole.MEMBER,
                    status: '',
                  ))
            .toList() ??
        [],
    cahierDeChargeFileUrl: json['cahierDeChargeFileUrl'],
  );
}



  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'budget': budget,
        'deadline': deadline,
        'methodology': methodology,
        'projectManager': projectManager.toJson(),
        'teamMembers': teamMembers.map((member) => member.toJson()).toList(),
        'cahierDeChargeFileUrl': cahierDeChargeFileUrl,
      };
}
