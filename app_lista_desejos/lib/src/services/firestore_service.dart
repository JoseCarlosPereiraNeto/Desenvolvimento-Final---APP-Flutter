import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wish_item.dart';

class FirestoreService {
  static final CollectionReference<Map<String, dynamic>> _wishCollection =
      FirebaseFirestore.instance.collection('wish_items');

  static Stream<List<WishItem>> wishItemsStream() {
    return _wishCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WishItem.fromMap(doc.id, doc.data()))
            .toList());
  }

  static Future<void> addWishItem(WishItem item) {
    return _wishCollection.add(item.toMap());
  }
}
