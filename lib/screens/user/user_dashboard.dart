import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../startup_screen.dart';
import '../batch_scan/batch_scan_screen.dart';
import 'package:intl/intl.dart';

class UserDashboard extends ConsumerWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final employeeInvAsync = ref.watch(allEmployeeInventoryProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanning as ${user?.displayName ?? "User"}'),
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
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allTransactionsProvider);
          ref.invalidate(allEmployeeInventoryProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.green.shade50,
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.green),
                  title: Text('Welcome, ${user?.displayName}'),
                  subtitle: Text('Role: Standard User'),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Your Quick Stats',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  employeeInvAsync.when(
                    data: (items) {
                      final myInv = items.where((i) => i.normalizedEmployeeName == user?.normalizedName);
                      final count = myInv.fold(0.0, (sum, i) => sum + i.quantityOnHand);
                      return _buildStatCard(context, 'My On-Hand', count.toStringAsFixed(0), Icons.inventory_2, Colors.blue);
                    },
                    loading: () => _buildStatCard(context, 'My On-Hand', '...', Icons.inventory_2, Colors.blue),
                    error: (_, __) => _buildStatCard(context, 'My On-Hand', 'Err', Icons.inventory_2, Colors.blue),
                  ),
                  transactionsAsync.when(
                    data: (txs) {
                      final today = DateTime.now();
                      final myToday = txs.where((t) => 
                        t.normalizedUserName == user?.normalizedName && 
                        t.timestamp.year == today.year && 
                        t.timestamp.month == today.month && 
                        t.timestamp.day == today.day
                      );
                      return _buildStatCard(context, 'My Scans Today', myToday.length.toString(), Icons.qr_code_scanner, Colors.green);
                    },
                    loading: () => _buildStatCard(context, 'My Scans Today', '...', Icons.qr_code_scanner, Colors.green),
                    error: (_, __) => _buildStatCard(context, 'My Scans Today', 'Err', Icons.qr_code_scanner, Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'My Recent Scans',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              transactionsAsync.when(
                data: (txs) {
                  final myTxs = txs.where((t) => t.normalizedUserName == user?.normalizedName).take(5).toList();
                  return _buildRecentScans(context, myTxs);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.history),
                      label: const Text('View All My History'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BatchScanScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(20),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner),
              SizedBox(width: 12),
              Text('START BATCH SCAN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
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
            FittedBox(child: Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentScans(BuildContext context, List txs) {
    if (txs.isEmpty) {
      return const Card(child: Padding(padding: EdgeInsets.all(16), child: Center(child: Text('No scans yet.'))));
    }
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: txs.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final tx = txs[index];
          return ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text('${tx.action.name.toUpperCase()}: ${tx.itemName}'),
            subtitle: Text('${tx.siteName ?? "N/A"} • ${DateFormat('jm').format(tx.timestamp)}'),
          );
        },
      ),
    );
  }
}
