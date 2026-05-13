class EventModel {
  final String id;
  final String title;
  final String description;
  final String musicianId;
  final String musicianName;
  final String? coverImage;
  final String? eventLink;
  final DateTime eventDate;
  final String location;
  final bool isApproved;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.musicianId,
    required this.musicianName,
    this.coverImage,
    this.eventLink,
    required this.eventDate,
    required this.location,
    this.isApproved = false,
    required this.createdAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      musicianId: json['musician_id'] ?? '',
      musicianName: json['musician_name'] ?? '',
      coverImage: json['cover_image'],
      eventLink: json['event_link'],
      eventDate: json['event_date'] != null
          ? DateTime.parse(json['event_date'])
          : DateTime.now(),
      location: json['location'] ?? '',
      isApproved: json['is_approved'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'musician_id': musicianId,
      'musician_name': musicianName,
      'cover_image': coverImage,
      'event_link': eventLink,
      'event_date': eventDate.toIso8601String(),
      'location': location,
      'is_approved': isApproved,
      'created_at': createdAt.toIso8601String(),
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? musicianId,
    String? musicianName,
    String? coverImage,
    String? eventLink,
    DateTime? eventDate,
    String? location,
    bool? isApproved,
    DateTime? createdAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      musicianId: musicianId ?? this.musicianId,
      musicianName: musicianName ?? this.musicianName,
      coverImage: coverImage ?? this.coverImage,
      eventLink: eventLink ?? this.eventLink,
      eventDate: eventDate ?? this.eventDate,
      location: location ?? this.location,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
