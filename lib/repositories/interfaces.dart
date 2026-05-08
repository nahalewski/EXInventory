import '../models/user_session.dart';
import '../models/inventory_item.dart';
import '../models/employee_inventory.dart';
import '../models/transaction.dart';
import '../models/duplicate_scan.dart';
import '../models/batch_scan_row.dart';
import '../models/app_settings.dart';

abstract class IInventoryRepository {
  Future<List<InventoryItem>> getAll();
  Future<InventoryItem?> getById(String id);
  Future<InventoryItem?> getByBarcode(String barcode);
  Future<InventoryItem?> getByQRCode(String qrCode);
  Future<void> save(InventoryItem item);
  Future<void> delete(String id);
}

abstract class IEmployeeInventoryRepository {
  Future<List<EmployeeInventoryBalance>> getAll();
  Future<List<EmployeeInventoryBalance>> getByEmployee(String normalizedName);
  Future<EmployeeInventoryBalance?> get(String normalizedEmployeeName, String itemId);
  Future<void> save(EmployeeInventoryBalance balance);
}

abstract class ITransactionRepository {
  Future<List<InventoryTransaction>> getAll();
  Future<List<InventoryTransaction>> getByUser(String normalizedName);
  Future<void> add(InventoryTransaction transaction);
}

abstract class IDuplicateRepository {
  Future<List<DuplicateScanEvent>> getAll();
  Future<void> add(DuplicateScanEvent event);
}

abstract class IBatchRepository {
  Future<List<BatchScanRow>> getBatch(String ownerNormalizedName);
  Future<void> saveRow(BatchScanRow row);
  Future<void> deleteRow(String ownerNormalizedName, int lineNumber);
  Future<void> clearBatch(String ownerNormalizedName);
}

abstract class ISettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);
}

abstract class IUserSessionRepository {
  Future<UserSession?> getCurrentSession();
  Future<void> saveSession(UserSession session);
  Future<void> clearSession();
}
