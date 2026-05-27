import 'package:flutter/material.dart';
import '../models/wish_item.dart';

class WishItemTile extends StatelessWidget {
  final WishItem item;

  const WishItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Valor estimado: R\$ ${item.value.toStringAsFixed(2)}'),
          if (item.storeUrl.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(item.storeUrl, style: const TextStyle(color: Colors.blueGrey)),
          ],
        ],
      ),
      trailing: const Icon(Icons.favorite_outline),
    );
  }
}
