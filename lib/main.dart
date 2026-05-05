import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/user_session.dart';
import 'models/inventory_item.dart';
import 'models/employee_inventory.dart';
import 'models/transaction.dart';
import 'models/duplicate_scan.dart';
import 'models/batch_scan_row.dart';
import 'models/app_settings.dart';
import 'providers/providers.dart';
import 'screens/startup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Register adapters
  Hive.registerAdapter(UserRoleAdapter());
  Hive.registerAdapter(UserSessionAdapter());
  Hive.registerAdapter(InventoryItemAdapter());
  Hive.registerAdapter(EmployeeInventoryBalanceAdapter());
  Hive.registerAdapter(InventoryActionAdapter());
  Hive.registerAdapter(InventoryTransactionAdapter());
  Hive.registerAdapter(DuplicateHandlingModeAdapter());
  Hive.registerAdapter(DuplicateScanEventAdapter());
  Hive.registerAdapter(BatchScanRowAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
  
  runApp(
    const ProviderScope(
      child: QuickScanApp(),
    ),
  );
}

class QuickScanApp extends StatelessWidget {
  const QuickScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickScan Inventory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: const StartupScreen(),
    );
  }
}
