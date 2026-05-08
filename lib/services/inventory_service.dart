import 'package:uuid/uuid.dart';
import '../models/inventory_item.dart';
import '../models/employee_inventory.dart';
import '../models/transaction.dart';
import '../models/user_session.dart';
import '../repositories/interfaces.dart';

class InventoryService {
  final IInventoryRepository _inventoryRepo;
  final IEmployeeInventoryRepository _employeeRepo;
  final ITransactionRepository _transactionRepo;
  final ISettingsRepository _settingsRepo;

  InventoryService({
    required IInventoryRepository inventoryRepo,
    required IEmployeeInventoryRepository employeeRepo,
    required ITransactionRepository transactionRepo,
    required ISettingsRepository settingsRepo,
  })  : _inventoryRepo = inventoryRepo,
        _employeeRepo = employeeRepo,
        _transactionRepo = transactionRepo,
        _settingsRepo = settingsRepo;

  Future<void> receiveIntoWarehouse({
    required InventoryItem item,
    required double quantity,
    required UserSession user,
    String? notes,
  }) async {
    final newItem = item.copyWith(
      mainQuantity: item.mainQuantity + quantity,
      updatedAt: DateTime.now(),
      updatedBy: user.displayName,
    );

    await _inventoryRepo.save(newItem);

    await _transactionRepo.add(InventoryTransaction(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      userName: user.displayName,
      normalizedUserName: user.normalizedName,
      action: InventoryAction.receiveMain,
      itemId: item.id,
      itemName: item.itemName,
      sku: item.sku,
      barcode: item.barcode,
      qrCodeValue: item.qrCodeValue,
      quantityChanged: quantity,
      mainQuantityBefore: item.mainQuantity,
      mainQuantityAfter: newItem.mainQuantity,
      employeeQuantityBefore: 0,
      employeeQuantityAfter: 0,
      fromBucket: 'EXTERNAL',
      toBucket: 'MAIN',
      notes: notes,
      createdByRole: user.role.name,
    ));
  }

  Future<void> transferToEmployee({
    required InventoryItem item,
    required double quantity,
    required UserSession user,
    required String employeeName,
    String? siteName,
    String? jobNumber,
    String? truckNumber,
    String? notes,
  }) async {
    final normalizedEmployee = employeeName.trim().toLowerCase();
    
    // Update main inventory
    final newItem = item.copyWith(
      mainQuantity: item.mainQuantity - quantity,
      totalEmployeeOnHand: item.totalEmployeeOnHand + quantity,
      updatedAt: DateTime.now(),
      updatedBy: user.displayName,
    );

    // Update employee balance
    var balance = await _employeeRepo.get(normalizedEmployee, item.id);
    final balanceBefore = balance?.quantityOnHand ?? 0;
    
    if (balance == null) {
      balance = EmployeeInventoryBalance(
        id: const Uuid().v4(),
        employeeName: employeeName.trim(),
        normalizedEmployeeName: normalizedEmployee,
        itemId: item.id,
        itemName: item.itemName,
        sku: item.sku,
        barcode: item.barcode,
        qrCodeValue: item.qrCodeValue,
        quantityOnHand: quantity,
        currentSite: siteName,
        jobNumber: jobNumber,
        truckNumber: truckNumber,
        updatedAt: DateTime.now(),
      );
    } else {
      balance = balance.copyWith(
        quantityOnHand: balance.quantityOnHand + quantity,
        currentSite: siteName ?? balance.currentSite,
        jobNumber: jobNumber ?? balance.jobNumber,
        truckNumber: truckNumber ?? balance.truckNumber,
        updatedAt: DateTime.now(),
      );
    }

    await _inventoryRepo.save(newItem);
    await _employeeRepo.save(balance);

    await _transactionRepo.add(InventoryTransaction(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      userName: user.displayName,
      normalizedUserName: user.normalizedName,
      action: InventoryAction.transferToEmployee,
      itemId: item.id,
      itemName: item.itemName,
      sku: item.sku,
      barcode: item.barcode,
      qrCodeValue: item.qrCodeValue,
      quantityChanged: quantity,
      mainQuantityBefore: item.mainQuantity,
      mainQuantityAfter: newItem.mainQuantity,
      employeeQuantityBefore: balanceBefore,
      employeeQuantityAfter: balance.quantityOnHand,
      fromBucket: 'MAIN',
      toBucket: 'EMPLOYEE',
      employeeName: employeeName.trim(),
      normalizedEmployeeName: normalizedEmployee,
      siteName: siteName,
      jobNumber: jobNumber,
      truckNumber: truckNumber,
      notes: notes,
      createdByRole: user.role.name,
    ));
  }

  Future<void> useFromEmployee({
    required InventoryItem item,
    required double quantity,
    required UserSession user,
    String? siteName,
    String? jobNumber,
    String? truckNumber,
    String? notes,
  }) async {
    final normalizedUser = user.normalizedName;
    var balance = await _employeeRepo.get(normalizedUser, item.id);
    
    final balanceBefore = balance?.quantityOnHand ?? 0;
    
    // Check settings for direct use if none on hand
    final settings = await _settingsRepo.getSettings();
    
    if (balance == null || balance.quantityOnHand < quantity) {
       if (settings.allowDirectUseFromMain) {
         // This would be a more complex flow, for now let's assume standard behavior
       }
    }

    if (balance == null) {
      balance = EmployeeInventoryBalance(
        id: const Uuid().v4(),
        employeeName: user.displayName,
        normalizedEmployeeName: normalizedUser,
        itemId: item.id,
        itemName: item.itemName,
        sku: item.sku,
        barcode: item.barcode,
        qrCodeValue: item.qrCodeValue,
        quantityOnHand: -quantity, // Might be negative if settings allow
        currentSite: siteName,
        jobNumber: jobNumber,
        truckNumber: truckNumber,
        updatedAt: DateTime.now(),
      );
    } else {
      balance = balance.copyWith(
        quantityOnHand: balance.quantityOnHand - quantity,
        currentSite: siteName ?? balance.currentSite,
        jobNumber: jobNumber ?? balance.jobNumber,
        truckNumber: truckNumber ?? balance.truckNumber,
        updatedAt: DateTime.now(),
      );
    }

    final newItem = item.copyWith(
      totalEmployeeOnHand: item.totalEmployeeOnHand - quantity,
      totalUsed: item.totalUsed + quantity,
      updatedAt: DateTime.now(),
      updatedBy: user.displayName,
    );

    await _inventoryRepo.save(newItem);
    await _employeeRepo.save(balance);

    await _transactionRepo.add(InventoryTransaction(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      userName: user.displayName,
      normalizedUserName: user.normalizedName,
      action: InventoryAction.useFromEmployee,
      itemId: item.id,
      itemName: item.itemName,
      sku: item.sku,
      barcode: item.barcode,
      qrCodeValue: item.qrCodeValue,
      quantityChanged: quantity,
      mainQuantityBefore: item.mainQuantity,
      mainQuantityAfter: item.mainQuantity,
      employeeQuantityBefore: balanceBefore,
      employeeQuantityAfter: balance.quantityOnHand,
      fromBucket: 'EMPLOYEE',
      toBucket: 'CONSUMED',
      employeeName: user.displayName,
      normalizedEmployeeName: normalizedUser,
      siteName: siteName,
      jobNumber: jobNumber,
      truckNumber: truckNumber,
      notes: notes,
      createdByRole: user.role.name,
    ));
  }

  Future<void> returnToMain({
    required InventoryItem item,
    required double quantity,
    required UserSession user,
    String? notes,
  }) async {
    final normalizedUser = user.normalizedName;
    var balance = await _employeeRepo.get(normalizedUser, item.id);
    
    if (balance == null) return; // Cannot return what you don't have (simplified)

    final balanceBefore = balance.quantityOnHand;
    
    final newItem = item.copyWith(
      mainQuantity: item.mainQuantity + quantity,
      totalEmployeeOnHand: item.totalEmployeeOnHand - quantity,
      updatedAt: DateTime.now(),
      updatedBy: user.displayName,
    );

    balance = balance.copyWith(
      quantityOnHand: balance.quantityOnHand - quantity,
      updatedAt: DateTime.now(),
    );

    await _inventoryRepo.save(newItem);
    await _employeeRepo.save(balance);

    await _transactionRepo.add(InventoryTransaction(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      userName: user.displayName,
      normalizedUserName: user.normalizedName,
      action: InventoryAction.returnToMain,
      itemId: item.id,
      itemName: item.itemName,
      sku: item.sku,
      barcode: item.barcode,
      qrCodeValue: item.qrCodeValue,
      quantityChanged: quantity,
      mainQuantityBefore: item.mainQuantity,
      mainQuantityAfter: newItem.mainQuantity,
      employeeQuantityBefore: balanceBefore,
      employeeQuantityAfter: balance.quantityOnHand,
      fromBucket: 'EMPLOYEE',
      toBucket: 'MAIN',
      employeeName: user.displayName,
      normalizedEmployeeName: normalizedUser,
      notes: notes,
      createdByRole: user.role.name,
    ));
  }

  Future<void> adjustCount({
    required InventoryItem item,
    required double newMainQuantity,
    required UserSession admin,
    String? notes,
  }) async {
    if (!admin.isAdmin) return;

    final newItem = item.copyWith(
      mainQuantity: newMainQuantity,
      updatedAt: DateTime.now(),
      updatedBy: admin.displayName,
    );

    await _inventoryRepo.save(newItem);

    await _transactionRepo.add(InventoryTransaction(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      userName: admin.displayName,
      normalizedUserName: admin.normalizedName,
      action: InventoryAction.adjustment,
      itemId: item.id,
      itemName: item.itemName,
      sku: item.sku,
      barcode: item.barcode,
      qrCodeValue: item.qrCodeValue,
      quantityChanged: newMainQuantity - item.mainQuantity,
      mainQuantityBefore: item.mainQuantity,
      mainQuantityAfter: newItem.mainQuantity,
      employeeQuantityBefore: 0,
      employeeQuantityAfter: 0,
      fromBucket: 'ADJUSTMENT',
      toBucket: 'MAIN',
      notes: notes,
      createdByRole: admin.role.name,
    ));
  }
}
