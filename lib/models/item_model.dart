import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  String id;
  String title;
  String description;
  DateTime createdAt;

  Item({
    this.id = '',
    required this.title,
    required this.description,
    required this.createdAt,
  });

  // Convert Firestore ke Item app
  factory Item.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Item(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert Item untuk dimasukan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
