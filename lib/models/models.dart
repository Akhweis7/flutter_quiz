class AuthResponse {
  final String? token;
  final UserResponse? user;

  AuthResponse({this.token, this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json['token'],
        user: json['user'] != null
            ? UserResponse.fromJson(json['user'] as Map<String, dynamic>)
            : null,
      );
}

class UserResponse {
  final String? id;
  final String? username;
  final String? email;
  final String? role;

  UserResponse({this.id, this.username, this.email, this.role});

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
        id: json['id'],
        username: json['username'],
        email: json['email'],
        role: json['role'],
      );
}

class TaskItem {
  final String? id;
  String title;
  List<Subtask> subtasks;

  TaskItem({this.id, required this.title, List<Subtask>? subtasks})
      : subtasks = subtasks ?? [];

  factory TaskItem.fromJson(Map<String, dynamic> json) => TaskItem(
        id: json['id'],
        title: json['title'] ?? '',
        subtasks: (json['subtasks'] as List<dynamic>?)
                ?.map((s) => Subtask.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'title': title,
        'subtasks': subtasks.map((s) => s.toJson()).toList(),
      };
}

class Subtask {
  final String? id;
  String title;
  String? username;
  String? description;
  String? goal;
  String? techstack;
  DateTime? duedate;

  Subtask({
    this.id,
    required this.title,
    this.username,
    this.description,
    this.goal,
    this.techstack,
    this.duedate,
  });

  factory Subtask.fromJson(Map<String, dynamic> json) => Subtask(
        id: json['id'],
        title: json['title'] ?? '',
        username: json['username'],
        description: json['description'],
        goal: json['goal'],
        techstack: json['techstack'],
        duedate: json['duedate'] != null
            ? DateTime.tryParse(json['duedate'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'title': title,
        'date': DateTime.now().toIso8601String(),
        if (username != null) 'username': username,
        if (description != null) 'description': description,
        if (goal != null) 'goal': goal,
        if (techstack != null) 'techstack': techstack,
        if (duedate != null) 'duedate': duedate!.toIso8601String(),
      };
}
