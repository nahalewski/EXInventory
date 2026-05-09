import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'login_screen.dart';

class StartupScreen extends ConsumerStatefulWidget {
  const StartupScreen({super.key});

  @override
  ConsumerState<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends ConsumerState<StartupScreen> {
  bool _cleared = false;

  @override
  void initState() {
    super.initState();
    _clearSession();
  }

  Future<void> _clearSession() async {
    await ref.read(userSessionRepoProvider).clearSession();
    ref.read(currentUserProvider.notifier).state = null;
    if (mounted) setState(() => _cleared = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_cleared) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return const LoginScreen();
  }
}
