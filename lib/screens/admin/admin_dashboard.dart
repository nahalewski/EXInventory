import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../startup_screen.dart';
import '../inventory/inventory_list_screen.dart';
import '../inventory/transaction_history_screen.dart';
import '../settings/settings_screen.dart';
import '../batch_scan/batch_scan_screen.dart';
import 'export_center.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(allInventoryProvider);
    final employeeInvAsync = ref.watch(allEmployeeInventoryProvider);
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final duplicatesAsync = ref.watch(allDuplicatesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin View — Bryan'),
        actions: [
          TextButton.icon(
            onPressed: () {
              ref.read(userSessionRepoProvider).clearSession();
              ref.read(currentUserProvider.notifier).state = null;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const StartupScreen()),
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Change User'),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allInventoryProvider);
          ref.invalidate(allEmployeeInventoryProvider);
          ref.invalidate(allTransactionsProvider);
          ref.invalidate(allDuplicatesProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Glance',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildAsyncStatCard(context, 'Main Inventory', inventoryAsync, (items) => items.fold(0.0, (sum, i) => sum + i.mainQuantity).toStringAsFixed(0), Icons.warehouse, Colors.blue),
                  _buildAsyncStatCard(context, 'Employee On-Hand', employeeInvAsync, (items) => items.fold(0.0, (sum, i) => sum + i.quantityOnHand).toStringAsFixed(0), Icons.person, Colors.orange),
                  _buildAsyncStatCard(context, 'Total Company', inventoryAsync, (items) => items.fold(0.0, (sum, i) => sum + i.totalCompanyQuantity).toStringAsFixed(0), Icons.business, Colors.green),
                  _buildAsyncStatCard(context, 'Total Used', inventoryAsync, (items) => items.fold(0.0, (sum, i) => sum + i.totalUsed).toStringAsFixed(0), Icons.trending_up, Colors.red),
                  _buildAsyncStatCard(context, 'Low Stock Items', inventoryAsync, (items) => items.where((i) => i.mainQuantity <= i.lowStockThreshold).length.toString(), Icons.warning, Colors.amber),
                  _buildAsyncStatCard(context, 'Active Employees', employeeInvAsync, (items) => items.map((i) => i.normalizedEmployeeName).toSet().length.toString(), Icons.people, Colors.purple),
                  _buildAsyncStatCard(context, 'Duplicates Today', duplicatesAsync, (items) => items.length.toString(), Icons.copy, Colors.teal),
                  _buildAsyncStatCard(context, 'Errors Today', transactionsAsync, (items) => '0', Icons.error, Colors.grey),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Recent Transactions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              transactionsAsync.when(
                data: (txs) => _buildRecentTransactions(context, txs),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BatchScanScreen()),
          );
        },
        label: const Text('Start Batch Scan'),
        icon: const Icon(Icons.qr_code_scanner),
      ),
    );
  }

  Widget _buildAsyncStatCard<T>(
    BuildContext context,
    String title,
    AsyncValue<T> asyncValue,
    String Function(T) formatter,
    IconData icon,
    Color color,
  ) {
    return asyncValue.when(
      data: (data) => _buildStatCard(context, title, formatter(data), icon, color),
      loading: () => _buildStatCard(context, title, '...', icon, color),
      error: (_, __) => _buildStatCard(context, title, 'Err', icon, color),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            FittedBox(
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, List txs) {
    if (txs.isEmpty) {
      return const Card(child: Padding(padding: EdgeInsets.all(16), child: Center(child: Text('No transactions yet.'))));
    }
    final recentTxs = txs.take(5).toList();
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentTxs.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final tx = recentTxs[index];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.swap_horiz)),
            title: Text('${tx.action.name.toUpperCase()}: ${tx.itemName}'),
            subtitle: Text('By ${tx.userName} • ${tx.siteName ?? "N/A"} • ${DateFormat('jm').format(tx.timestamp)}'),
            trailing: Text(tx.quantityChanged.toStringAsFixed(0)),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text('Bryan (Admin)'),
            accountEmail: Text('Inventory Controller'),
            currentAccountPicture: CircleAvatar(child: Icon(Icons.admin_panel_settings)),
            decoration: BoxDecoration(color: Colors.green),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.warehouse),
            title: const Text('All Main Inventory'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryListScreen(isAdmin: true))),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Transaction History'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionHistoryScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Export Center'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportCenter())),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('App Settings'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
    );
  }
}
