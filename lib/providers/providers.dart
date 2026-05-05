import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/interfaces.dart';
import '../repositories/local_storage_repository.dart';
import '../services/inventory_service.dart';
import '../services/duplicate_service.dart';
import '../services/csv_service.dart';
import '../models/user_session.dart';
import '../models/app_settings.dart';

// Repositories
final inventoryRepoProvider = Provider<IInventoryRepository>((ref) => LocalInventoryRepository());
final employeeRepoProvider = Provider<IEmployeeInventoryRepository>((ref) => LocalEmployeeInventoryRepository());
final transactionRepoProvider = Provider<ITransactionRepository>((ref) => LocalTransactionRepository());
final duplicateRepoProvider = Provider<IDuplicateRepository>((ref) => LocalDuplicateRepository());
final batchRepoProvider = Provider<IBatchRepository>((ref) => LocalBatchRepository());
final settingsRepoProvider = Provider<ISettingsRepository>((ref) => LocalSettingsRepository());
final userSessionRepoProvider = Provider<IUserSessionRepository>((ref) => LocalUserSessionRepository());

// Services
final inventoryServiceProvider = Provider<InventoryService>((ref) => InventoryService(
  inventoryRepo: ref.watch(inventoryRepoProvider),
  employeeRepo: ref.watch(employeeRepoProvider),
  transactionRepo: ref.watch(transactionRepoProvider),
  settingsRepo: ref.watch(settingsRepoProvider),
));

final duplicateServiceProvider = Provider<DuplicateService>((ref) => DuplicateService(
  duplicateRepo: ref.watch(duplicateRepoProvider),
));

final csvServiceProvider = Provider<CsvService>((ref) => CsvService());

// State
final currentUserProvider = StateProvider<UserSession?>((ref) => null);
final appSettingsProvider = StateProvider<AppSettings>((ref) => AppSettings());

// Async data loaders
final settingsLoaderProvider = FutureProvider<AppSettings>((ref) async {
  final settings = await ref.watch(settingsRepoProvider).getSettings();
  ref.read(appSettingsProvider.notifier).state = settings;
  return settings;
});

final sessionLoaderProvider = FutureProvider<UserSession?>((ref) async {
  final session = await ref.watch(userSessionRepoProvider).getCurrentSession();
  ref.read(currentUserProvider.notifier).state = session;
  return session;
});
