import 'package:uuid/uuid.dart';

class Issue {
  final String id;
  final String caption;
  final String imagePath;
  final String location;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final bool isMock;
  final String? userName;
  final String? userAvatar;

  Issue({
    String? id,
    required this.caption,
    required this.imagePath,
    required this.location,
    this.latitude = 0.0,
    this.longitude = 0.0,
    DateTime? timestamp,
    this.isMock = false,
    this.userName,
    this.userAvatar,
  }) : id = id ?? 'REP-${const Uuid().v4().substring(0, 8).toUpperCase()}',
       timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'caption': caption,
    'imagePath': imagePath,
    'location': location,
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      id: json['report_id'] ?? json['id'],
      caption: json['caption'] ?? json['description'] ?? '',
      imagePath: json['image_url'] ?? json['imagePath'] ?? '',
      location: json['address'] ?? json['location'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : (json['createdAt'] != null 
              ? DateTime.parse(json['createdAt']) 
              : (json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now())),
      userName: json['user_name'],
      userAvatar: json['user_avatar'],
    );
  }
}
