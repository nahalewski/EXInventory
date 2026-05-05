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
      body: SingleChildScrollView(
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
                _buildStatCard(context, 'My On-Hand', '42', Icons.inventory_2, Colors.blue),
                _buildStatCard(context, 'My Scans Today', '12', Icons.qr_code_scanner, Colors.green),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'My Recent Scans',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildRecentScans(context),
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
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentScans(BuildContext context) {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text('Used 1x Item ${index + 100}'),
            subtitle: Text('Site X • ${DateFormat('jm').format(DateTime.now())}'),
          );
        },
      ),
    );
  }
}
