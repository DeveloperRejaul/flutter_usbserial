import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_usbserial/flutter_usbserial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const UsbSerialExample(),
    );
  }
}

class UsbSerialExample extends StatefulWidget {
  const UsbSerialExample({super.key});

  @override
  State<UsbSerialExample> createState() => _UsbSerialExampleState();
}

class _UsbSerialExampleState extends State<UsbSerialExample> {
  final _usbPlugin = FlutterUsbserial();
  List<UsbDeviceInfo> _devices = [];
  UsbDeviceInfo? _connectedDevice;
  Map<String, double?> _soilData = {};
  bool _isListening = false;
  StreamSubscription? _soilSubscription;

  @override
  void initState() {
    super.initState();
    _refreshDevices();
  }

  Future<void> _refreshDevices() async {
    final devices = await _usbPlugin.getDeviceList();
    setState(() {
      _devices = devices;
    });
  }

  Future<void> _connect(UsbDeviceInfo device) async {
    final hasPermission = await _usbPlugin.hasPermission(device);
    if (!hasPermission) {
      final granted = await _usbPlugin.requestPermission(device);
      if (!granted) return;
    }

    final connected = await _usbPlugin.connect(device, baudRate: 9600);
    if (connected) {
      final dev = await _usbPlugin.getConnectedDevice();
      setState(() {
        _connectedDevice = dev;
      });
    }
  }

  void _toggleSoilListening() async {
    if (_isListening) {
      await _usbPlugin.utils.stopSoilReadInterval();
      _soilSubscription?.cancel();
      setState(() {
        _isListening = false;
      });
    } else {
      _soilSubscription = _usbPlugin.utils.soilDataStream.listen((data) {
        setState(() {
          _soilData = data;
        });
      });
      await _usbPlugin.utils.startSoilReadInterval(intervalMs: 1000);
      setState(() {
        _isListening = true;
      });
    }
  }

  @override
  void dispose() {
    _soilSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('USB Serial & Soil Sensor'),
        actions: [
          IconButton(
            onPressed: _refreshDevices,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_connectedDevice != null)
            Card(
              margin: const EdgeInsets.all(16),
              color: Colors.green.shade50,
              child: ListTile(
                leading: const Icon(Icons.usb, color: Colors.green),
                title: Text('Connected: ${_connectedDevice?.productName}'),
                subtitle: Text(
                  'VID: ${_connectedDevice?.vendorId} PID: ${_connectedDevice?.productId}',
                ),
                trailing: TextButton(
                  onPressed: () async {
                    await _usbPlugin.disconnect();
                    setState(() => _connectedDevice = null);
                  },
                  child: const Text('DISCONNECT'),
                ),
              ),
            ),
          Expanded(
            child: _connectedDevice == null
                ? ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      return ListTile(
                        title: Text(device.productName ?? 'Unknown Device'),
                        subtitle: Text(device.deviceName),
                        trailing: ElevatedButton(
                          onPressed: () => _connect(device),
                          child: const Text('CONNECT'),
                        ),
                      );
                    },
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ElevatedButton.icon(
                        onPressed: _toggleSoilListening,
                        icon: Icon(
                          _isListening ? Icons.stop : Icons.play_arrow,
                        ),
                        label: Text(
                          _isListening
                              ? 'Stop Soil Stream'
                              : 'Start Soil Stream',
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_soilData.isNotEmpty)
                        ..._soilData.entries.map(
                          (e) => Card(
                            child: ListTile(
                              title: Text(e.key.toUpperCase()),
                              trailing: Text(
                                '${e.value?.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
