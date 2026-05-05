import 'package:hive/hive.dart';

part 'inventory_item.g.dart';

@HiveType(typeId: 2)
class InventoryItem extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String itemName;
  
  @HiveField(2)
  final String sku;
  
  @HiveField(3)
  final String barcode;
  
  @HiveField(4)
  final String qrCodeValue;
  
  @HiveField(5)
  final double mainQuantity;
  
  @HiveField(6)
  final double totalEmployeeOnHand;
  
  @HiveField(7)
  final double totalUsed;
  
  @HiveField(8)
  final String category;
  
  @HiveField(9)
  final String location;
  
  @HiveField(10)
  final double lowStockThreshold;
  
  @HiveField(11)
  final DateTime createdAt;
  
  @HiveField(12)
  final DateTime updatedAt;
  
  @HiveField(13)
  final String createdBy;
  
  @HiveField(14)
  final String updatedBy;

  InventoryItem({
    required this.id,
    required this.itemName,
    required this.sku,
    required this.barcode,
    required this.qrCodeValue,
    required this.mainQuantity,
    required this.totalEmployeeOnHand,
    required this.totalUsed,
    required this.category,
    required this.location,
    required this.lowStockThreshold,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });

  double get totalCompanyQuantity => mainQuantity + totalEmployeeOnHand;

  InventoryItem copyWith({
    String? itemName,
    String? sku,
    String? barcode,
    String? qrCodeValue,
    double? mainQuantity,
    double? totalEmployeeOnHand,
    double? totalUsed,
    String? category,
    String? location,
    double? lowStockThreshold,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return InventoryItem(
      id: id,
      itemName: itemName ?? this.itemName,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      qrCodeValue: qrCodeValue ?? this.qrCodeValue,
      mainQuantity: mainQuantity ?? this.mainQuantity,
      totalEmployeeOnHand: totalEmployeeOnHand ?? this.totalEmployeeOnHand,
      totalUsed: totalUsed ?? this.totalUsed,
      category: category ?? this.category,
      location: location ?? this.location,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}
