import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

class FirestoreService {
  final CollectionReference _itemsCollection =
      FirebaseFirestore.instance.collection('items');

  // CREATE
  Future<void> addItem(Item item) async {
    try {
      await _itemsCollection.add(item.toMap());
    } catch (e) {
      print('Error adding item: $e');
      rethrow;
    }
  }

  // READ (Stream untuk realtime updates)
  Stream<List<Item>> getItems() {
    return _itemsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Item.fromFirestore(doc)).toList();
    });
  }

  // UPDATE
  Future<void> updateItem(String id, Item item) async {
    try {
      await _itemsCollection.doc(id).update(item.toMap());
    } catch (e) {
      print('Error updating item: $e');
      rethrow;
    }
  }

  // DELETE
  Future<void> deleteItem(String id) async {
    try {
      await _itemsCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting item: $e');
      rethrow;
    }
  }
}
