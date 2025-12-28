class Note {
  final int id;
  final String title;
  final String content;
  final int courseId;
  final String imageUrl;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.courseId,
    this.imageUrl = '',
  });

  String get fullImageUrl {
    if (imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http')) return imageUrl;
    return 'https://mindvault.atwebpages.com/api/$imageUrl';
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      courseId: int.parse(json['course_id'].toString()),
      imageUrl: json['image_url'] ?? '',
    );
  }
}