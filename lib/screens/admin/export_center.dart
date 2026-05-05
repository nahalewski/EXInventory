import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import 'dart:html' as html;

class ExportCenter extends ConsumerWidget {
  const ExportCenter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Center')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExportTile(
            context,
            ref,
            'Full Main Inventory CSV',
            Icons.warehouse,
            () async {
              final items = await ref.read(inventoryRepoProvider).getAll();
              final csv = ref.read(csvServiceProvider).generateInventoryCsv(items);
              _downloadCsv(csv, 'main_inventory.csv');
            },
          ),
          _buildExportTile(
            context,
            ref,
            'Full Employee On-Hand CSV',
            Icons.person,
            () async {
              final balances = await ref.read(employeeRepoProvider).getAll();
              final csv = ref.read(csvServiceProvider).generateEmployeeInventoryCsv(balances);
              _downloadCsv(csv, 'employee_inventory.csv');
            },
          ),
          _buildExportTile(
            context,
            ref,
            'Full Transaction History CSV',
            Icons.history,
            () async {
              final txs = await ref.read(transactionRepoProvider).getAll();
              final csv = ref.read(csvServiceProvider).generateTransactionCsv(txs);
              _downloadCsv(csv, 'transactions.csv');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExportTile(BuildContext context, WidgetRef ref, String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.download),
        onTap: onTap,
      ),
    );
  }

  void _downloadCsv(String csv, String filename) {
    final bytes = html.Blob([csv]);
    final url = html.Url.createObjectUrlFromBlob(bytes);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
