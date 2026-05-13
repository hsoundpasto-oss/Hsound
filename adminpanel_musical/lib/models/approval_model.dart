class ApprovalModel {
  final String id;
  final String type; // 'link', 'cover', 'event'
  final String title;
  final String description;
  final String submittedBy;
  final String submittedByName;
  final String? contentUrl;
  final String? imageUrl;
  final DateTime submittedAt;
  final bool isApproved;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  ApprovalModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.submittedBy,
    required this.submittedByName,
    this.contentUrl,
    this.imageUrl,
    required this.submittedAt,
    this.isApproved = false,
    this.reviewedBy,
    this.reviewedAt,
  });

  factory ApprovalModel.fromJson(Map<String, dynamic> json) {
    return ApprovalModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      submittedBy: json['submitted_by'] ?? '',
      submittedByName: json['submitted_by_name'] ?? '',
      contentUrl: json['content_url'],
      imageUrl: json['image_url'],
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'])
          : DateTime.now(),
      isApproved: json['is_approved'] ?? false,
      reviewedBy: json['reviewed_by'],
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'submitted_by': submittedBy,
      'submitted_by_name': submittedByName,
      'content_url': contentUrl,
      'image_url': imageUrl,
      'submitted_at': submittedAt.toIso8601String(),
      'is_approved': isApproved,
      'reviewed_by': reviewedBy,
      'reviewed_at': reviewedAt?.toIso8601String(),
    };
  }

  ApprovalModel copyWith({
    String? id,
    String? type,
    String? title,
    String? description,
    String? submittedBy,
    String? submittedByName,
    String? contentUrl,
    String? imageUrl,
    DateTime? submittedAt,
    bool? isApproved,
    String? reviewedBy,
    DateTime? reviewedAt,
  }) {
    return ApprovalModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      submittedBy: submittedBy ?? this.submittedBy,
      submittedByName: submittedByName ?? this.submittedByName,
      contentUrl: contentUrl ?? this.contentUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      submittedAt: submittedAt ?? this.submittedAt,
      isApproved: isApproved ?? this.isApproved,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}
