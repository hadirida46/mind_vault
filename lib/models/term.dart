class Term {
  final int id;
  final String term;
  final String definition;
  final int? courseId;

  Term({required this.id, required this.term, required this.definition, this.courseId});

  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
      id: json['id'],
      term: json['term'],
      definition: json['definition'],
      courseId: json['course_id'],
    );
  }
}
