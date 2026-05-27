import 'package:flutter/material.dart';
import '../models/wish_item.dart';
import '../services/firestore_service.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WishItem>>(
      stream: FirestoreService.wishItemsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erro na leitura das estatísticas: ${snapshot.error}'));
        }

        final items = snapshot.data ?? [];
        final totalItems = items.length;
        final totalValue = items.fold<double>(0, (sum, item) => sum + item.value);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Total de itens', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        '$totalItems',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Dinheiro necessário', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        'R\$ ${totalValue.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Itens na lista',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text('A lista está vazia. Adicione novos desejos.'))
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return ListTile(
                            title: Text(item.name),
                            subtitle: Text('R\$ ${item.value.toStringAsFixed(2)}'),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
