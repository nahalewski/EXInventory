import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 4)
enum InventoryAction {
  @HiveField(0)
  receiveMain,
  @HiveField(1)
  transferToEmployee,
  @HiveField(2)
  useFromEmployee,
  @HiveField(3)
  returnToMain,
  @HiveField(4)
  adjustment,
}

@HiveType(typeId: 5)
class InventoryTransaction extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final DateTime timestamp;
  
  @HiveField(2)
  final String userName;
  
  @HiveField(3)
  final String normalizedUserName;
  
  @HiveField(4)
  final InventoryAction action;
  
  @HiveField(5)
  final String itemId;
  
  @HiveField(6)
  final String itemName;
  
  @HiveField(7)
  final String sku;
  
  @HiveField(8)
  final String barcode;
  
  @HiveField(9)
  final String qrCodeValue;
  
  @HiveField(10)
  final double quantityChanged;
  
  @HiveField(11)
  final double mainQuantityBefore;
  
  @HiveField(12)
  final double mainQuantityAfter;
  
  @HiveField(13)
  final double employeeQuantityBefore;
  
  @HiveField(14)
  final double employeeQuantityAfter;
  
  @HiveField(15)
  final String fromBucket;
  
  @HiveField(16)
  final String toBucket;
  
  @HiveField(17)
  final String? employeeName;
  
  @HiveField(18)
  final String? normalizedEmployeeName;
  
  @HiveField(19)
  final String? siteName;
  
  @HiveField(20)
  final String? jobNumber;
  
  @HiveField(21)
  final String? truckNumber;
  
  @HiveField(22)
  final String? notes;
  
  @HiveField(23)
  final String createdByRole;

  InventoryTransaction({
    required this.id,
    required this.timestamp,
    required this.userName,
    required this.normalizedUserName,
    required this.action,
    required this.itemId,
    required this.itemName,
    required this.sku,
    required this.barcode,
    required this.qrCodeValue,
    required this.quantityChanged,
    required this.mainQuantityBefore,
    required this.mainQuantityAfter,
    required this.employeeQuantityBefore,
    required this.employeeQuantityAfter,
    required this.fromBucket,
    required this.toBucket,
    this.employeeName,
    this.normalizedEmployeeName,
    this.siteName,
    this.jobNumber,
    this.truckNumber,
    this.notes,
    required this.createdByRole,
  });
}
