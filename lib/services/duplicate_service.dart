import '../models/duplicate_scan.dart';
import '../models/batch_scan_row.dart';
import '../models/user_session.dart';
import '../repositories/interfaces.dart';

class DuplicateService {
  final IDuplicateRepository _duplicateRepo;

  DuplicateService({required IDuplicateRepository duplicateRepo}) : _duplicateRepo = duplicateRepo;

  Future<DuplicateResult> processScan({
    required String scannedCode,
    required List<BatchScanRow> currentBatch,
    required DuplicateHandlingMode mode,
    required UserSession user,
    required String action,
  }) async {
    final existingRowIndex = currentBatch.indexWhere((r) => r.barcode == scannedCode || r.qrCodeValue == scannedCode);
    
    if (existingRowIndex == -1) {
      return DuplicateResult(isDuplicate: false);
    }

    final existingRow = currentBatch[existingRowIndex];
    
    await _duplicateRepo.add(DuplicateScanEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      userName: user.displayName,
      normalizedUserName: user.normalizedName,
      action: action,
      scannedCode: scannedCode,
      originalLineNumber: existingRow.lineNumber,
      handlingMode: mode.name,
      result: mode == DuplicateHandlingMode.blockDuplicates ? 'BLOCKED' : 'PROCESSED',
    ));

    switch (mode) {
      case DuplicateHandlingMode.blockDuplicates:
        return DuplicateResult(isDuplicate: true, shouldAdd: false, message: 'Duplicate blocked.');
      case DuplicateHandlingMode.warnBeforeAdding:
        return DuplicateResult(isDuplicate: true, shouldAdd: true, showWarning: true, existingRowIndex: existingRowIndex);
      case DuplicateHandlingMode.mergeDuplicates:
        return DuplicateResult(isDuplicate: true, shouldAdd: false, shouldMerge: true, existingRowIndex: existingRowIndex);
      case DuplicateHandlingMode.allowDuplicates:
        return DuplicateResult(isDuplicate: true, shouldAdd: true);
    }
  }
}

class DuplicateResult {
  final bool isDuplicate;
  final bool shouldAdd;
  final bool shouldMerge;
  final bool showWarning;
  final String? message;
  final int? existingRowIndex;

  DuplicateResult({
    required this.isDuplicate,
    this.shouldAdd = true,
    this.shouldMerge = false,
    this.showWarning = false,
    this.message,
    this.existingRowIndex,
  });
}
