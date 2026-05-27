import 'package:cloud_firestore/cloud_firestore.dart';

class WishItem {
  final String id;
  final String name;
  final double value;
  final String storeUrl;
  final List<String> imageUrls;

  WishItem({
    required this.id,
    required this.name,
    required this.value,
    required this.storeUrl,
    required this.imageUrls,
  });

  factory WishItem.fromMap(String id, Map<String, dynamic> data) {
    final rawValue = data['value'];
    final value = rawValue is num
        ? rawValue.toDouble()
        : double.tryParse(rawValue?.toString() ?? '') ?? 0.0;

    final rawImages = data['imageUrls'];
    final imageUrls = <String>[];

    if (rawImages is List) {
      imageUrls.addAll(rawImages
          .map((it) => it?.toString() ?? '')
          .where((it) => it.isNotEmpty));
    } else if (rawImages is String) {
      imageUrls.addAll(rawImages
          .split(';')
          .map((it) => it.trim())
          .where((it) => it.isNotEmpty));
    }

    return WishItem(
      id: id,
      name: data['name']?.toString() ?? '',
      value: value,
      storeUrl: data['storeUrl']?.toString() ?? '',
      imageUrls: imageUrls,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
      'storeUrl': storeUrl,
      'imageUrls': imageUrls,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
