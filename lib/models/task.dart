class Task {
  final int id;
  final String title;
  final String description;
  final int courseId;
  final String? deadlineDate; // new nullable field

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    this.deadlineDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      courseId: json['course_id'],
      deadlineDate: json['deadline_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'course_id': courseId,
      'deadline_date': deadlineDate,
    };
  }
}
