import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../models/inventory_item.dart';

class InventoryListScreen extends ConsumerWidget {
  final bool isAdmin;
  const InventoryListScreen({super.key, this.isAdmin = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryRepo = ref.watch(inventoryRepoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Main Inventory' : 'My On-Hand Inventory'),
      ),
      body: FutureBuilder<List<InventoryItem>>(
        future: inventoryRepo.getAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final items = snapshot.data ?? [];
          
          if (items.isEmpty) {
            return const Center(child: Text('No items found.'));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.inventory_2)),
                title: Text(item.itemName),
                subtitle: Text('SKU: ${item.sku} • Location: ${item.location}'),
                trailing: Text(
                  '${isAdmin ? item.mainQuantity : item.totalEmployeeOnHand}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
