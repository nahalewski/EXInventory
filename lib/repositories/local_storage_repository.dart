import 'package:hive/hive.dart';
import '../models/user_session.dart';
import '../models/inventory_item.dart';
import '../models/employee_inventory.dart';
import '../models/transaction.dart';
import '../models/duplicate_scan.dart';
import '../models/batch_scan_row.dart';
import '../models/app_settings.dart';
import 'interfaces.dart';

class LocalInventoryRepository implements IInventoryRepository {
  static const String boxName = 'inventory_items';

  @override
  Future<List<InventoryItem>> getAll() async {
    final box = await Hive.openBox<InventoryItem>(boxName);
    return box.values.toList();
  }

  @override
  Future<InventoryItem?> getById(String id) async {
    final box = await Hive.openBox<InventoryItem>(boxName);
    return box.get(id);
  }

  @override
  Future<InventoryItem?> getByBarcode(String barcode) async {
    final box = await Hive.openBox<InventoryItem>(boxName);
    return box.values.cast<InventoryItem?>().firstWhere(
      (item) => item?.barcode == barcode,
      orElse: () => null,
    );
  }

  @override
  Future<InventoryItem?> getByQRCode(String qrCode) async {
    final box = await Hive.openBox<InventoryItem>(boxName);
    return box.values.cast<InventoryItem?>().firstWhere(
      (item) => item?.qrCodeValue == qrCode,
      orElse: () => null,
    );
  }

  @override
  Future<void> save(InventoryItem item) async {
    final box = await Hive.openBox<InventoryItem>(boxName);
    await box.put(item.id, item);
  }

  @override
  Future<void> delete(String id) async {
    final box = await Hive.openBox<InventoryItem>(boxName);
    await box.delete(id);
  }
}

class LocalEmployeeInventoryRepository implements IEmployeeInventoryRepository {
  static const String boxName = 'employee_inventory';

  @override
  Future<List<EmployeeInventoryBalance>> getAll() async {
    final box = await Hive.openBox<EmployeeInventoryBalance>(boxName);
    return box.values.toList();
  }

  @override
  Future<List<EmployeeInventoryBalance>> getByEmployee(String normalizedName) async {
    final box = await Hive.openBox<EmployeeInventoryBalance>(boxName);
    return box.values.where((b) => b.normalizedEmployeeName == normalizedName).toList();
  }

  @override
  Future<EmployeeInventoryBalance?> get(String normalizedEmployeeName, String itemId) async {
    final box = await Hive.openBox<EmployeeInventoryBalance>(boxName);
    return box.values.cast<EmployeeInventoryBalance?>().firstWhere(
      (b) => b?.normalizedEmployeeName == normalizedEmployeeName && b?.itemId == itemId,
      orElse: () => null,
    );
  }

  @override
  Future<void> save(EmployeeInventoryBalance balance) async {
    final box = await Hive.openBox<EmployeeInventoryBalance>(boxName);
    await box.put(balance.id, balance);
  }
}

class LocalTransactionRepository implements ITransactionRepository {
  static const String boxName = 'transactions';

  @override
  Future<List<InventoryTransaction>> getAll() async {
    final box = await Hive.openBox<InventoryTransaction>(boxName);
    return box.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Future<List<InventoryTransaction>> getByUser(String normalizedName) async {
    final all = await getAll();
    return all.where((t) => t.normalizedUserName == normalizedName || t.normalizedEmployeeName == normalizedName).toList();
  }

  @override
  Future<void> add(InventoryTransaction transaction) async {
    final box = await Hive.openBox<InventoryTransaction>(boxName);
    await box.add(transaction);
  }
}

class LocalDuplicateRepository implements IDuplicateRepository {
  static const String boxName = 'duplicates';

  @override
  Future<List<DuplicateScanEvent>> getAll() async {
    final box = await Hive.openBox<DuplicateScanEvent>(boxName);
    return box.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Future<void> add(DuplicateScanEvent event) async {
    final box = await Hive.openBox<DuplicateScanEvent>(boxName);
    await box.add(event);
  }
}

class LocalBatchRepository implements IBatchRepository {
  static const String boxName = 'batch_scans';

  @override
  Future<List<BatchScanRow>> getBatch(String ownerNormalizedName) async {
    final box = await Hive.openBox<BatchScanRow>(boxName);
    return box.values.where((r) => r.ownerUserName == ownerNormalizedName).toList()..sort((a, b) => a.lineNumber.compareTo(b.lineNumber));
  }

  @override
  Future<void> saveRow(BatchScanRow row) async {
    final box = await Hive.openBox<BatchScanRow>(boxName);
    final key = '${row.ownerUserName}_${row.lineNumber}';
    await box.put(key, row);
  }

  @override
  Future<void> deleteRow(String ownerNormalizedName, int lineNumber) async {
    final box = await Hive.openBox<BatchScanRow>(boxName);
    final key = '${ownerNormalizedName}_${lineNumber}';
    await box.delete(key);
  }

  @override
  Future<void> clearBatch(String ownerNormalizedName) async {
    final box = await Hive.openBox<BatchScanRow>(boxName);
    final keysToDelete = box.keys.where((k) => k.toString().startsWith('${ownerNormalizedName}_')).toList();
    await box.deleteAll(keysToDelete);
  }
}

class LocalSettingsRepository implements ISettingsRepository {
  static const String boxName = 'settings';
  static const String settingsKey = 'app_settings';

  @override
  Future<AppSettings> getSettings() async {
    final box = await Hive.openBox<AppSettings>(boxName);
    return box.get(settingsKey) ?? AppSettings();
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final box = await Hive.openBox<AppSettings>(boxName);
    await box.put(settingsKey, settings);
  }
}

class LocalUserSessionRepository implements IUserSessionRepository {
  static const String boxName = 'session';
  static const String sessionKey = 'current_user';

  @override
  Future<UserSession?> getCurrentSession() async {
    final box = await Hive.openBox<UserSession>(boxName);
    return box.get(sessionKey);
  }

  @override
  Future<void> saveSession(UserSession session) async {
    final box = await Hive.openBox<UserSession>(boxName);
    await box.put(sessionKey, session);
  }

  @override
  Future<void> clearSession() async {
    final box = await Hive.openBox<UserSession>(boxName);
    await box.delete(sessionKey);
  }
}
