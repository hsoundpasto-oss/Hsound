import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String artistId;
  final String artistName;
  final String title;
  final String? description;
  final String venue;
  final String address;
  final String? googleMapsUrl;
  final DateTime eventDate;
  final String price;
  final String status;
  final DateTime createdAt;
  final String? reviewMessage;

  Event({
    required this.id,
    required this.artistId,
    required this.artistName,
    required this.title,
    this.description,
    required this.venue,
    required this.address,
    this.googleMapsUrl,
    required this.eventDate,
    required this.price,
    this.status = 'pending',
    required this.createdAt,
    this.reviewMessage,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      artistId: data['artistId'] ?? '',
      artistName: data['artistName'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      venue: data['venue'] ?? '',
      address: data['address'] ?? '',
      googleMapsUrl: data['googleMapsUrl'],
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      price: data['price'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      reviewMessage: data['reviewMessage'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'artistId': artistId,
      'artistName': artistName,
      'title': title,
      'description': description,
      'venue': venue,
      'address': address,
      'googleMapsUrl': googleMapsUrl,
      'eventDate': Timestamp.fromDate(eventDate),
      'price': price,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'reviewMessage': reviewMessage,
    };
  }

  Event copyWith({String? id}) {
    return Event(
      id: id ?? this.id,
      artistId: artistId,
      artistName: artistName,
      title: title,
      description: description,
      venue: venue,
      address: address,
      googleMapsUrl: googleMapsUrl,
      eventDate: eventDate,
      price: price,
      status: status,
      createdAt: createdAt,
      reviewMessage: reviewMessage,
    );
  }
}
