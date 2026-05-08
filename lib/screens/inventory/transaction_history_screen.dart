import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionRepo = ref.watch(transactionRepoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: FutureBuilder(
        future: transactionRepo.getAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final txs = snapshot.data ?? [];
          return ListView.separated(
            itemCount: txs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final tx = txs[index];
              return ListTile(
                title: Text('${tx.action.name.toUpperCase()}: ${tx.itemName}'),
                subtitle: Text('By ${tx.userName} • ${DateFormat('yMd jm').format(tx.timestamp)}'),
                trailing: Text('${tx.quantityChanged > 0 ? "+" : ""}${tx.quantityChanged}'),
              );
            },
          );
        },
      ),
    );
  }
}
