class Chapter {
  final String id;
  final String title;

  Chapter({
    required this.id,
    required this.title,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      title: json['attributes']['chapter'] ?? 'Unknown',
    );
  }
}