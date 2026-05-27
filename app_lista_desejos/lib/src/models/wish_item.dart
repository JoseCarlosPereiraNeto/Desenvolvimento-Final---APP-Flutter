import 'package:cloud_firestore/cloud_firestore.dart';

class WishItem {
  final String id;
  final String name;
  final double value;
  final String storeUrl;

  WishItem({
    required this.id,
    required this.name,
    required this.value,
    required this.storeUrl,
  });

  factory WishItem.fromMap(String id, Map<String, dynamic> data) {
    final rawValue = data['value'];
    final value = rawValue is num
        ? rawValue.toDouble()
        : double.tryParse(rawValue?.toString() ?? '') ?? 0.0;

    return WishItem(
      id: id,
      name: data['name']?.toString() ?? '',
      value: value,
      storeUrl: data['storeUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
      'storeUrl': storeUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
