import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/batch_scan_row.dart';
import '../../models/transaction.dart';
import '../../providers/providers.dart';
import 'package:intl/intl.dart';

class BatchScanScreen extends ConsumerStatefulWidget {
  const BatchScanScreen({super.key});

  @override
  ConsumerState<BatchScanScreen> createState() => _BatchScanScreenState();
}

class _BatchScanScreenState extends ConsumerState<BatchScanScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final TextEditingController _manualInputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  List<BatchScanRow> _rows = [];
  InventoryAction _selectedAction = InventoryAction.useFromEmployee;
  bool _isScannerVisible = true;
  bool _isProcessing = false;
  // Tracks last scan time per barcode to debounce rapid camera re-detections.
  final Map<String, DateTime> _lastScannedTimes = {};

  @override
  void initState() {
    super.initState();
    _loadBatch();
    _inputFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _manualInputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _loadBatch() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final rows = await ref.read(batchRepoProvider).getBatch(user.normalizedName);
      if (mounted) setState(() => _rows = rows);
    }
  }

  // Returns true if this code was scanned too recently and should be ignored.
  bool _shouldDebounce(String code, int cooldownMs) {
    final now = DateTime.now();
    final last = _lastScannedTimes[code];
    if (last != null && now.difference(last).inMilliseconds < cooldownMs) {
      return true;
    }
    _lastScannedTimes[code] = now;
    return false;
  }

  void _onCodeScanned(String code, {bool bypassDebounce = false}) async {
    // Prevent concurrent processing — avoids race conditions where the same
    // barcode is added twice before the batch state refreshes.
    if (_isProcessing) return;

    final settings = ref.read(appSettingsProvider);

    // Debounce camera detections: camera fires onDetect continuously while
    // a barcode is in view. Manual/gun submissions bypass this.
    if (!bypassDebounce && _shouldDebounce(code, settings.debounceCooldownMs)) return;

    _isProcessing = true;
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final result = await ref.read(duplicateServiceProvider).processScan(
        scannedCode: code,
        currentBatch: _rows,
        mode: settings.duplicateHandlingMode,
        user: user,
        action: _selectedAction.name,
      );

      if (!mounted) return;

      if (result.isDuplicate && !result.shouldAdd && !result.shouldMerge) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? 'Duplicate blocked')),
        );
        return;
      }

      if (result.shouldMerge && result.existingRowIndex != null) {
        final existing = _rows[result.existingRowIndex!];
        final updated = existing.copyWith(
          quantity: existing.quantity + 1,
          duplicateCountMerged: existing.duplicateCountMerged + 1,
          duplicateStatus: 'MERGED',
        );
        await ref.read(batchRepoProvider).saveRow(updated);
        _loadBatch();
        return;
      }

      if (result.showWarning && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Warning: duplicate barcode added'),
            backgroundColor: Colors.amber,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Add new row
      final newRow = BatchScanRow(
        lineNumber: _rows.length + 1,
        timestamp: DateTime.now(),
        userName: user.displayName,
        normalizedUserName: user.normalizedName,
        action: _selectedAction,
        barcode: code,
        qrCodeValue: code,
        sku: 'PENDING',
        itemName: 'Unknown Item',
        quantity: 1.0,
        location: user.defaultLocation ?? 'UNKNOWN',
        siteName: user.defaultSiteName ?? 'UNKNOWN',
        jobNumber: user.defaultJobNumber ?? 'UNKNOWN',
        truckNumber: user.defaultTruckNumber ?? 'UNKNOWN',
        notes: '',
        status: 'SCANNED',
        isDuplicate: result.isDuplicate,
        duplicateOfLineNumber: result.existingRowIndex != null ? _rows[result.existingRowIndex!].lineNumber : null,
        duplicateStatus: result.isDuplicate ? 'WARNING' : 'NONE',
        duplicateCountMerged: 0,
        mainQuantityBefore: 0,
        mainQuantityAfter: 0,
        employeeQuantityBefore: 0,
        employeeQuantityAfter: 0,
        fromBucket: 'UNKNOWN',
        toBucket: 'UNKNOWN',
        visibleToAdmin: true,
        ownerUserName: user.normalizedName,
      );

      await ref.read(batchRepoProvider).saveRow(newRow);
      _loadBatch();
    } finally {
      _isProcessing = false;
    }
  }

  void _submitManual() {
    if (_manualInputController.text.isNotEmpty) {
      _onCodeScanned(_manualInputController.text, bypassDebounce: true);
      _manualInputController.clear();
      _inputFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Scan Mode'),
        actions: [
          IconButton(
            icon: Icon(_isScannerVisible ? Icons.videocam_off : Icons.videocam),
            onPressed: () => setState(() => _isScannerVisible = !_isScannerVisible),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              final user = ref.read(currentUserProvider);
              if (user != null) {
                await ref.read(batchRepoProvider).clearBatch(user.normalizedName);
                _loadBatch();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isScannerVisible)
            SizedBox(
              height: 250,
              child: MobileScanner(
                controller: _scannerController,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      _onCodeScanned(barcode.rawValue!);
                    }
                  }
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButtonFormField<InventoryAction>(
                  value: _selectedAction,
                  decoration: const InputDecoration(labelText: 'Scan Action', border: OutlineInputBorder()),
                  items: InventoryAction.values.map((a) {
                    return DropdownMenuItem(value: a, child: Text(_getActionLabel(a)));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedAction = val!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _manualInputController,
                  focusNode: _inputFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Manual Input / Scanner Gun',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(icon: const Icon(Icons.send), onPressed: _submitManual),
                  ),
                  onSubmitted: (_) => _submitManual(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _rows.length,
              itemBuilder: (context, index) {
                final row = _rows.reversed.toList()[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('#${row.lineNumber}')),
                  title: Text('${row.barcode} (${row.quantity}x)'),
                  subtitle: Text('${_getActionLabel(row.action)} • ${DateFormat('jm').format(row.timestamp)}'),
                  trailing: row.isDuplicate ? const Icon(Icons.warning, color: Colors.amber) : null,
                  onTap: () {
                    // Edit row dialog
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_rows.length} Items in Batch', style: const TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: _rows.isEmpty ? null : () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                child: const Text('EXPORT / SAVE BATCH'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getActionLabel(InventoryAction action) {
    switch (action) {
      case InventoryAction.receiveMain: return 'Receive Into Warehouse';
      case InventoryAction.transferToEmployee: return 'Take To Site / Truck';
      case InventoryAction.useFromEmployee: return 'Use At Site';
      case InventoryAction.returnToMain: return 'Return To Warehouse';
      case InventoryAction.adjustment: return 'Count Adjustment';
    }
  }
}
