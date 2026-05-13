import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final bool isArtist;
  final String? photoUrl;
  final String? bio;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  // Campos adicionales que tienes en Firebase
  final String? contactEmail;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? spotifyUrl;
  final String? tiktokUrl;
  final String? whatsappUrl;
  final String? youtubeUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.isArtist,
    this.photoUrl,
    this.bio,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.contactEmail,
    this.facebookUrl,
    this.instagramUrl,
    this.spotifyUrl,
    this.tiktokUrl,
    this.whatsappUrl,
    this.youtubeUrl,
  });

  // Convertir de Firestore a UserModel
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      id: doc.id,
      name: data['name'] ?? 'Usuario',
      email: data['email'] ?? '',
      isArtist: data['isArtist'] ?? false,
      photoUrl: data['photoUrl'],
      bio: data['bio'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
      contactEmail: data['contactEmail'],
      facebookUrl: data['facebookUrl'],
      instagramUrl: data['instagramUrl'],
      spotifyUrl: data['spotifyUrl'],
      tiktokUrl: data['tiktokUrl'],
      whatsappUrl: data['whatsappUrl'],
      youtubeUrl: data['youtubeUrl'],
    );
  }

  // Para compatibilidad con el código existente
  String get role => isArtist ? 'musician' : 'user';

  // Convertir a JSON (para el provider existente)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'isArtist': isArtist,
      'photoUrl': photoUrl,
      'bio': bio,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Factory para compatibilidad con el código existente
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isArtist: json['isArtist'] ?? (json['role'] == 'musician'),
      photoUrl: json['photoUrl'],
      bio: json['bio'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isActive: json['isActive'] ?? true,
    );
  }

  // Crear copia con cambios
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    bool? isArtist,
    String? photoUrl,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isArtist: isArtist ?? this.isArtist,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}