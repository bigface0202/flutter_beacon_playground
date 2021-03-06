import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

import '../ble/ble_scanner.dart';
import 'device_detail_screen.dart';

class DeviceListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer2<BleScanner, BleScannerState>(
        builder: (_, bleScanner, bleScannerState, __) => _DeviceList(
          scannerState: bleScannerState,
          startScan: bleScanner.startScan,
          stopScan: bleScanner.stopScan,
        ),
      );
}

class _DeviceList extends StatefulWidget {
  const _DeviceList(
      {@required this.scannerState,
      @required this.startScan,
      @required this.stopScan})
      : assert(scannerState != null),
        assert(startScan != null),
        assert(stopScan != null);

  final BleScannerState scannerState;
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;

  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<_DeviceList> {
  TextEditingController _uuidController;
  bool _test = false;
  @override
  void initState() {
    super.initState();
    _uuidController = TextEditingController()
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    widget.stopScan();
    _uuidController.dispose();
    super.dispose();
  }

  bool _isValidUuidInput() {
    final uuidText = _uuidController.text;
    if (uuidText.isEmpty) {
      return true;
    } else {
      try {
        Uuid.parse(uuidText);
        return true;
      } on Exception {
        return false;
      }
    }
  }

  void _startScanning(bool scan) async {
    final text = _uuidController.text;
    if (scan) {
      Timer.periodic(Duration(seconds: 2), (timer) {
        widget
            .startScan(text.isEmpty ? [] : [Uuid.parse(_uuidController.text)]);
      });
    } else {
      widget.stopScan();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Scan for devices'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text('Service UUID (2, 4, 16 bytes):'),
                  TextField(
                    controller: _uuidController,
                    enabled: !widget.scannerState.scanIsInProgress,
                    decoration: InputDecoration(
                        errorText:
                            _uuidController.text.isEmpty || _isValidUuidInput()
                                ? null
                                : 'Invalid UUID format'),
                    autocorrect: false,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RaisedButton(
                          child: const Text('Scan'),
                          onPressed: () {
                            !widget.scannerState.scanIsInProgress &&
                                    _isValidUuidInput()
                                ? _test = true
                                : _test = false;
                            _startScanning(_test);
                          }),
                      RaisedButton(
                          child: const Text('Stop'),
                          onPressed: () {
                            widget.scannerState.scanIsInProgress
                                ? _test = false
                                : _test = true;
                            _startScanning(_test);
                          }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(!widget.scannerState.scanIsInProgress
                            ? 'Enter a UUID above and tap start to begin scanning'
                            : 'Tap a device to connect to it'),
                      ),
                      if (widget.scannerState.scanIsInProgress ||
                          widget.scannerState.discoveredDevices.isNotEmpty)
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.only(start: 18.0),
                          child: Text(
                              'count: ${widget.scannerState.discoveredDevices.length}'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                children: widget.scannerState.discoveredDevices
                    .map(
                      (device) => device.name.startsWith('LINE BEACON')
                          ? ListTile(
                              title: Text(device.name),
                              subtitle:
                                  Text("${device.id}\nRSSI: ${device.rssi}"),
                              leading: const SizedBox(
                                width: 64,
                                height: 64,
                                child: Align(
                                    alignment: Alignment.center,
                                    child: Icon(Icons.bluetooth)),
                              ),
                              onTap: () async {
                                widget.stopScan();
                                await Navigator.push<void>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DeviceDetailScreen(device: device),
                                  ),
                                );
                              },
                            )
                          : Container(),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      );
}
