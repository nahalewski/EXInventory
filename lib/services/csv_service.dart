import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../models/inventory_item.dart';
import '../models/employee_inventory.dart';
import '../models/transaction.dart';
import '../models/batch_scan_row.dart';
import '../models/duplicate_scan.dart';

class CsvService {
  String generateInventoryCsv(List<InventoryItem> items) {
    List<List<dynamic>> rows = [
      [
        'item_id', 'item_name', 'sku', 'barcode', 'qr_code_value', 
        'main_quantity', 'total_employee_on_hand', 'total_company_quantity', 
        'total_used', 'location', 'category', 'low_stock_threshold', 'updated_at'
      ]
    ];

    for (var item in items) {
      rows.add([
        item.id, item.itemName, item.sku, item.barcode, item.qrCodeValue,
        item.mainQuantity, item.totalEmployeeOnHand, item.totalCompanyQuantity,
        item.totalUsed, item.location, item.category, item.lowStockThreshold,
        DateFormat('yyyy-MM-dd HH:mm:ss').format(item.updatedAt)
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  String generateEmployeeInventoryCsv(List<EmployeeInventoryBalance> balances) {
    List<List<dynamic>> rows = [
      [
        'employee_name', 'normalized_employee_name', 'item_id', 'item_name', 
        'sku', 'barcode', 'qr_code_value', 'quantity_on_hand', 
        'current_site', 'job_number', 'truck_number', 'updated_at'
      ]
    ];

    for (var b in balances) {
      rows.add([
        b.employeeName, b.normalizedEmployeeName, b.itemId, b.itemName,
        b.sku, b.barcode, b.qrCodeValue, b.quantityOnHand,
        b.currentSite ?? '', b.jobNumber ?? '', b.truckNumber ?? '',
        DateFormat('yyyy-MM-dd HH:mm:ss').format(b.updatedAt)
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  String generateTransactionCsv(List<InventoryTransaction> transactions) {
    List<List<dynamic>> rows = [
      [
        'transaction_id', 'timestamp', 'user_name', 'normalized_user_name', 
        'action', 'item_id', 'item_name', 'sku', 'barcode', 'qr_code_value', 
        'quantity_changed', 'main_quantity_before', 'main_quantity_after', 
        'employee_quantity_before', 'employee_quantity_after', 'from_bucket', 
        'to_bucket', 'employee_name', 'normalized_employee_name', 
        'site_name', 'job_number', 'truck_number', 'notes', 'created_by_role'
      ]
    ];

    for (var t in transactions) {
      rows.add([
        t.id, DateFormat('yyyy-MM-dd HH:mm:ss').format(t.timestamp),
        t.userName, t.normalizedUserName, t.action.name, t.itemId, t.itemName,
        t.sku, t.barcode, t.qrCodeValue, t.quantityChanged,
        t.mainQuantityBefore, t.mainQuantityAfter, t.employeeQuantityBefore,
        t.employeeQuantityAfter, t.fromBucket, t.toBucket,
        t.employeeName ?? '', t.normalizedEmployeeName ?? '',
        t.siteName ?? '', t.jobNumber ?? '', t.truckNumber ?? '',
        t.notes ?? '', t.createdByRole
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  String generateBatchCsv(List<BatchScanRow> batch) {
    List<List<dynamic>> rows = [
      [
        'line_number', 'timestamp', 'user_name', 'normalized_user_name', 
        'action', 'barcode', 'qr_code_value', 'sku', 'item_name', 'quantity', 
        'location', 'site_name', 'job_number', 'truck_number', 'notes', 
        'status', 'is_duplicate', 'duplicate_of_line_number', 'duplicate_status', 
        'duplicate_count_merged', 'main_quantity_before', 'main_quantity_after', 
        'employee_quantity_before', 'employee_quantity_after', 'from_bucket', 'to_bucket'
      ]
    ];

    for (var r in batch) {
      rows.add([
        r.lineNumber, DateFormat('yyyy-MM-dd HH:mm:ss').format(r.timestamp),
        r.userName, r.normalizedUserName, r.action.name, r.barcode, r.qrCodeValue,
        r.sku, r.itemName, r.quantity, r.location, r.siteName, r.jobNumber,
        r.truckNumber, r.notes, r.status, r.isDuplicate, r.duplicateOfLineNumber ?? '',
        r.duplicateStatus, r.duplicateCountMerged, r.mainQuantityBefore,
        r.mainQuantityAfter, r.employeeQuantityBefore, r.employeeQuantityAfter,
        r.fromBucket, r.toBucket
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  String generateDuplicateLogCsv(List<DuplicateScanEvent> events) {
    List<List<dynamic>> rows = [
      ['id', 'timestamp', 'user_name', 'normalized_user_name', 'action', 'scanned_code', 'original_line_number', 'handling_mode', 'result', 'notes']
    ];

    for (var e in events) {
      rows.add([
        e.id, DateFormat('yyyy-MM-dd HH:mm:ss').format(e.timestamp),
        e.userName, e.normalizedUserName, e.action, e.scannedCode,
        e.originalLineNumber ?? '', e.handlingMode, e.result, e.notes ?? ''
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }
}
