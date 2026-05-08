import 'package:hive/hive.dart';

part 'duplicate_scan.g.dart';

@HiveType(typeId: 6)
enum DuplicateHandlingMode {
  @HiveField(0)
  blockDuplicates,
  @HiveField(1)
  warnBeforeAdding,
  @HiveField(2)
  mergeDuplicates,
  @HiveField(3)
  allowDuplicates,
}

@HiveType(typeId: 7)
class DuplicateScanEvent extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final DateTime timestamp;
  
  @HiveField(2)
  final String userName;
  
  @HiveField(3)
  final String normalizedUserName;
  
  @HiveField(4)
  final String action;
  
  @HiveField(5)
  final String scannedCode;
  
  @HiveField(6)
  final int? originalLineNumber;
  
  @HiveField(7)
  final String handlingMode;
  
  @HiveField(8)
  final String result;
  
  @HiveField(9)
  final String? notes;

  DuplicateScanEvent({
    required this.id,
    required this.timestamp,
    required this.userName,
    required this.normalizedUserName,
    required this.action,
    required this.scannedCode,
    this.originalLineNumber,
    required this.handlingMode,
    required this.result,
    this.notes,
  });
}
