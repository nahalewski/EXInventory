import 'package:hive/hive.dart';
import 'duplicate_scan.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 9)
class AppSettings extends HiveObject {
  @HiveField(0)
  final DuplicateHandlingMode duplicateHandlingMode;
  
  @HiveField(1)
  final bool allowNegativeMainInventory;
  
  @HiveField(2)
  final bool allowNegativeEmployeeOnHand;
  
  @HiveField(3)
  final bool allowDirectUseFromMain;
  
  @HiveField(4)
  final bool standardUsersCanReceive;
  
  @HiveField(5)
  final bool standardUsersCanExportAll;
  
  @HiveField(6)
  final bool standardUsersCanAdjust;
  
  @HiveField(7)
  final double defaultScanQuantity;
  
  @HiveField(8)
  final int debounceCooldownMs;

  AppSettings({
    this.duplicateHandlingMode = DuplicateHandlingMode.warnBeforeAdding,
    this.allowNegativeMainInventory = false,
    this.allowNegativeEmployeeOnHand = false,
    this.allowDirectUseFromMain = false,
    this.standardUsersCanReceive = true,
    this.standardUsersCanExportAll = false,
    this.standardUsersCanAdjust = false,
    this.defaultScanQuantity = 1.0,
    this.debounceCooldownMs = 500,
  });

  AppSettings copyWith({
    DuplicateHandlingMode? duplicateHandlingMode,
    bool? allowNegativeMainInventory,
    bool? allowNegativeEmployeeOnHand,
    bool? allowDirectUseFromMain,
    bool? standardUsersCanReceive,
    bool? standardUsersCanExportAll,
    bool? standardUsersCanAdjust,
    double? defaultScanQuantity,
    int? debounceCooldownMs,
  }) {
    return AppSettings(
      duplicateHandlingMode: duplicateHandlingMode ?? this.duplicateHandlingMode,
      allowNegativeMainInventory: allowNegativeMainInventory ?? this.allowNegativeMainInventory,
      allowNegativeEmployeeOnHand: allowNegativeEmployeeOnHand ?? this.allowNegativeEmployeeOnHand,
      allowDirectUseFromMain: allowDirectUseFromMain ?? this.allowDirectUseFromMain,
      standardUsersCanReceive: standardUsersCanReceive ?? this.standardUsersCanReceive,
      standardUsersCanExportAll: standardUsersCanExportAll ?? this.standardUsersCanExportAll,
      standardUsersCanAdjust: standardUsersCanAdjust ?? this.standardUsersCanAdjust,
      defaultScanQuantity: defaultScanQuantity ?? this.defaultScanQuantity,
      debounceCooldownMs: debounceCooldownMs ?? this.debounceCooldownMs,
    );
  }
}
