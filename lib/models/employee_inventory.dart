import 'package:hive/hive.dart';

part 'employee_inventory.g.dart';

@HiveType(typeId: 3)
class EmployeeInventoryBalance extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String employeeName;
  
  @HiveField(2)
  final String normalizedEmployeeName;
  
  @HiveField(3)
  final String itemId;
  
  @HiveField(4)
  final String itemName;
  
  @HiveField(5)
  final String sku;
  
  @HiveField(6)
  final String barcode;
  
  @HiveField(7)
  final String qrCodeValue;
  
  @HiveField(8)
  final double quantityOnHand;
  
  @HiveField(9)
  final String? currentSite;
  
  @HiveField(10)
  final String? jobNumber;
  
  @HiveField(11)
  final String? truckNumber;
  
  @HiveField(12)
  final DateTime updatedAt;

  EmployeeInventoryBalance({
    required this.id,
    required this.employeeName,
    required this.normalizedEmployeeName,
    required this.itemId,
    required this.itemName,
    required this.sku,
    required this.barcode,
    required this.qrCodeValue,
    required this.quantityOnHand,
    this.currentSite,
    this.jobNumber,
    this.truckNumber,
    required this.updatedAt,
  });

  EmployeeInventoryBalance copyWith({
    double? quantityOnHand,
    String? currentSite,
    String? jobNumber,
    String? truckNumber,
    DateTime? updatedAt,
  }) {
    return EmployeeInventoryBalance(
      id: id,
      employeeName: employeeName,
      normalizedEmployeeName: normalizedEmployeeName,
      itemId: itemId,
      itemName: itemName,
      sku: sku,
      barcode: barcode,
      qrCodeValue: qrCodeValue,
      quantityOnHand: quantityOnHand ?? this.quantityOnHand,
      currentSite: currentSite ?? this.currentSite,
      jobNumber: jobNumber ?? this.jobNumber,
      truckNumber: truckNumber ?? this.truckNumber,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
