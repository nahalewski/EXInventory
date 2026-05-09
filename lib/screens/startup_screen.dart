import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'login_screen.dart';
import 'admin/admin_dashboard.dart';
import 'user/user_dashboard.dart';

class StartupScreen extends ConsumerWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionLoaderProvider);
    final settingsAsync = ref.watch(settingsLoaderProvider);

    return sessionAsync.when(
      data: (session) {
        if (session == null) {
          return const LoginScreen();
        }
        
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome back, ${session.displayName}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (session.isAdmin) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const AdminDashboard()),
                      );
                    } else {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const UserDashboard()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Continue Scanning'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    ref.read(userSessionRepoProvider).clearSession();
                    ref.read(currentUserProvider.notifier).state = null;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text('Change User'),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}
