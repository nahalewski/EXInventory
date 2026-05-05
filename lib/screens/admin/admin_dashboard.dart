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
    final user = ref.watch(currentUserProvider);
    
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
      body: SingleChildScrollView(
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
                _buildStatCard(context, 'Main Inventory', '4,250', Icons.warehouse, Colors.blue),
                _buildStatCard(context, 'Employee On-Hand', '840', Icons.person, Colors.orange),
                _buildStatCard(context, 'Total Company', '5,090', Icons.business, Colors.green),
                _buildStatCard(context, 'Total Used', '1,120', Icons.trending_up, Colors.red),
                _buildStatCard(context, 'Low Stock Items', '12', Icons.warning, Colors.amber),
                _buildStatCard(context, 'Active Employees', '8', Icons.people, Colors.purple),
                _buildStatCard(context, 'Duplicates Today', '3', Icons.copy, Colors.teal),
                _buildStatCard(context, 'Errors Today', '0', Icons.error, Colors.grey),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildRecentTransactions(context),
          ],
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
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.swap_horiz)),
            title: Text('Transferred 10x Item $index'),
            subtitle: Text('By John Doe • Site A • ${DateFormat('jm').format(DateTime.now())}'),
            trailing: const Icon(Icons.chevron_right),
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
