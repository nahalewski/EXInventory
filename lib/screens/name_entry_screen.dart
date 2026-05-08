import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_session.dart';
import '../providers/providers.dart';
import 'admin/admin_dashboard.dart';
import 'user/user_dashboard.dart';

class NameEntryScreen extends ConsumerStatefulWidget {
  const NameEntryScreen({super.key});

  @override
  ConsumerState<NameEntryScreen> createState() => _NameEntryScreenState();
}

class _NameEntryScreenState extends ConsumerState<NameEntryScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _siteController = TextEditingController();
  final _jobController = TextEditingController();
  final _truckController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _siteController.dispose();
    _jobController.dispose();
    _truckController.dispose();
    super.dispose();
  }

  void _onStart() async {
    if (_formKey.currentState!.validate()) {
      final session = UserSession.create(
        displayName: _nameController.text,
        defaultLocation: _locationController.text.isEmpty ? null : _locationController.text,
        defaultSiteName: _siteController.text.isEmpty ? null : _siteController.text,
        defaultJobNumber: _jobController.text.isEmpty ? null : _jobController.text,
        defaultTruckNumber: _truckController.text.isEmpty ? null : _truckController.text,
      );

      await ref.read(userSessionRepoProvider).saveSession(session);
      ref.read(currentUserProvider.notifier).state = session;

      if (mounted) {
        if (session.isAdmin) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const UserDashboard()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.qr_code_scanner, size: 64, color: Colors.green),
                  const SizedBox(height: 16),
                  Text(
                    'QuickScan Inventory',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Your Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Defaults (Optional)',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Default Location',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _siteController,
                    decoration: const InputDecoration(
                      labelText: 'Default Site Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _jobController,
                    decoration: const InputDecoration(
                      labelText: 'Default Job Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _truckController,
                    decoration: const InputDecoration(
                      labelText: 'Default Truck Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _onStart,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Start Scanning', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bryan admin mode is name-based only. For secure production use, add real authentication later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
