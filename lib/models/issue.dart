import 'package:uuid/uuid.dart';

enum IssueCategory {
  road('Road'),
  garbage('Garbage'),
  water('Water'),
  safety('Safety');

  final String label;
  const IssueCategory(this.label);
}

class Issue {
  final String id;
  final IssueCategory category;
  final String caption;
  final String imagePath;
  final String location;
  final DateTime timestamp;
  final bool isMock;

  Issue({
    String? id,
    required this.category,
    required this.caption,
    required this.imagePath,
    required this.location,
    DateTime? timestamp,
    this.isMock = false,
  }) : id = id ?? 'REP-${const Uuid().v4().substring(0, 8).toUpperCase()}',
       timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category.name,
    'caption': caption,
    'imagePath': imagePath,
    'location': location,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Issue.fromJson(Map<String, dynamic> json) => Issue(
    id: json['id'],
    category: IssueCategory.values.byName(json['category']),
    caption: json['caption'],
    imagePath: json['imagePath'],
    location: json['location'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}
