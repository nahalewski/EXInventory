import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../models/duplicate_scan.dart';
import '../../models/app_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final settings = ref.watch(appSettingsProvider);
    final isAdmin = user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          if (isAdmin) ...[
             const _SectionHeader(title: 'Admin Logic Settings'),
             ListTile(
               title: const Text('Duplicate Handling Mode'),
               subtitle: Text(settings.duplicateHandlingMode.name),
               trailing: const Icon(Icons.chevron_right),
               onTap: () => _showDuplicateModeDialog(context, ref),
             ),
             SwitchListTile(
               title: const Text('Allow Negative Main Inventory'),
               value: settings.allowNegativeMainInventory,
               onChanged: (val) => _updateSettings(ref, settings.copyWith(allowNegativeMainInventory: val)),
             ),
             SwitchListTile(
               title: const Text('Allow Negative Employee On-Hand'),
               value: settings.allowNegativeEmployeeOnHand,
               onChanged: (val) => _updateSettings(ref, settings.copyWith(allowNegativeEmployeeOnHand: val)),
             ),
             SwitchListTile(
               title: const Text('Standard Users Can Receive'),
               value: settings.standardUsersCanReceive,
               onChanged: (val) => _updateSettings(ref, settings.copyWith(standardUsersCanReceive: val)),
             ),
          ],
          const _SectionHeader(title: 'User Preferences'),
          ListTile(
            title: const Text('Display Name'),
            subtitle: Text(user?.displayName ?? ''),
            leading: const Icon(Icons.person),
          ),
          ListTile(
            title: const Text('Default Site'),
            subtitle: Text(user?.defaultSiteName ?? 'Not Set'),
            leading: const Icon(Icons.location_on),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Bryan admin mode is name-based only. For secure production use, add real authentication later.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _updateSettings(WidgetRef ref, AppSettings settings) {
    ref.read(settingsRepoProvider).saveSettings(settings);
    ref.read(appSettingsProvider.notifier).state = settings;
  }

  void _showDuplicateModeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duplicate Handling'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: DuplicateHandlingMode.values.map((mode) {
            return RadioListTile<DuplicateHandlingMode>(
              title: Text(mode.name.replaceAll('_', ' ').toUpperCase()),
              value: mode,
              groupValue: ref.read(appSettingsProvider).duplicateHandlingMode,
              onChanged: (val) {
                _updateSettings(ref, ref.read(appSettingsProvider).copyWith(duplicateHandlingMode: val));
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
