import 'package:flutter/material.dart';
import '../models/wish_item.dart';
import '../services/firestore_service.dart';
import '../widgets/wish_item_tile.dart';

class WishWallPage extends StatelessWidget {
  const WishWallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WishItem>>(
      stream: FirestoreService.wishItemsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Erro ao carregar desejos: ${snapshot.error}'),
          );
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return const Center(
            child: Text(
              'Nenhum desejo encontrado. Adicione um item novo!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: items.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = items[index];
            return WishItemTile(item: item);
          },
        );
      },
    );
  }
}
