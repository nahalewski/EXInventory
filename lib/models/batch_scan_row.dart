import 'package:hive/hive.dart';
import 'transaction.dart';

part 'batch_scan_row.g.dart';

@HiveType(typeId: 8)
class BatchScanRow extends HiveObject {
  @HiveField(0)
  final int lineNumber;
  
  @HiveField(1)
  final DateTime timestamp;
  
  @HiveField(2)
  final String userName;
  
  @HiveField(3)
  final String normalizedUserName;
  
  @HiveField(4)
  final InventoryAction action;
  
  @HiveField(5)
  final String barcode;
  
  @HiveField(6)
  final String qrCodeValue;
  
  @HiveField(7)
  final String sku;
  
  @HiveField(8)
  final String itemName;
  
  @HiveField(9)
  final double quantity;
  
  @HiveField(10)
  final String location;
  
  @HiveField(11)
  final String siteName;
  
  @HiveField(12)
  final String jobNumber;
  
  @HiveField(13)
  final String truckNumber;
  
  @HiveField(14)
  final String notes;
  
  @HiveField(15)
  final String status;
  
  @HiveField(16)
  final bool isDuplicate;
  
  @HiveField(17)
  final int? duplicateOfLineNumber;
  
  @HiveField(18)
  final String duplicateStatus;
  
  @HiveField(19)
  final int duplicateCountMerged;
  
  @HiveField(20)
  final double mainQuantityBefore;
  
  @HiveField(21)
  final double mainQuantityAfter;
  
  @HiveField(22)
  final double employeeQuantityBefore;
  
  @HiveField(23)
  final double employeeQuantityAfter;
  
  @HiveField(24)
  final String fromBucket;
  
  @HiveField(25)
  final String toBucket;
  
  @HiveField(26)
  final bool visibleToAdmin;
  
  @HiveField(27)
  final String ownerUserName;

  BatchScanRow({
    required this.lineNumber,
    required this.timestamp,
    required this.userName,
    required this.normalizedUserName,
    required this.action,
    required this.barcode,
    required this.qrCodeValue,
    required this.sku,
    required this.itemName,
    required this.quantity,
    required this.location,
    required this.siteName,
    required this.jobNumber,
    required this.truckNumber,
    required this.notes,
    required this.status,
    required this.isDuplicate,
    this.duplicateOfLineNumber,
    required this.duplicateStatus,
    required this.duplicateCountMerged,
    required this.mainQuantityBefore,
    required this.mainQuantityAfter,
    required this.employeeQuantityBefore,
    required this.employeeQuantityAfter,
    required this.fromBucket,
    required this.toBucket,
    required this.visibleToAdmin,
    required this.ownerUserName,
  });

  BatchScanRow copyWith({
    double? quantity,
    String? status,
    int? duplicateCountMerged,
    String? duplicateStatus,
  }) {
    return BatchScanRow(
      lineNumber: lineNumber,
      timestamp: timestamp,
      userName: userName,
      normalizedUserName: normalizedUserName,
      action: action,
      barcode: barcode,
      qrCodeValue: qrCodeValue,
      sku: sku,
      itemName: itemName,
      quantity: quantity ?? this.quantity,
      location: location,
      siteName: siteName,
      jobNumber: jobNumber,
      truckNumber: truckNumber,
      notes: notes,
      status: status ?? this.status,
      isDuplicate: isDuplicate,
      duplicateOfLineNumber: duplicateOfLineNumber,
      duplicateStatus: duplicateStatus ?? this.duplicateStatus,
      duplicateCountMerged: duplicateCountMerged ?? this.duplicateCountMerged,
      mainQuantityBefore: mainQuantityBefore,
      mainQuantityAfter: mainQuantityAfter,
      employeeQuantityBefore: employeeQuantityBefore,
      employeeQuantityAfter: employeeQuantityAfter,
      fromBucket: fromBucket,
      toBucket: toBucket,
      visibleToAdmin: visibleToAdmin,
      ownerUserName: ownerUserName,
    );
  }
}
