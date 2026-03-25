import 'dart:typed_data';
import 'flutter_usbserial_platform_interface.dart';

/// A Flutter plugin for USB serial communication on Android.
/// This plugin uses the `usb-serial` library to provide easy access to USB devices.
class FlutterUsbserial {
  /// Returns a list of all currently connected USB devices.
  Future<List<UsbDeviceInfo>> getDeviceList() async {
    final devices = await FlutterUsbserialPlatform.instance.getDeviceList();
    return devices.map((e) => UsbDeviceInfo.fromMap(e)).toList();
  }

  /// Checks if the app has permission to access the given device.
  Future<bool> hasPermission(UsbDeviceInfo device) {
    return FlutterUsbserialPlatform.instance.hasPermission(device.deviceName);
  }

  /// Requests USB permission for a device.
  Future<bool> requestPermission(UsbDeviceInfo device) {
    return FlutterUsbserialPlatform.instance.requestPermission(device.deviceName);
  }

  /// Connects to the specified USB device.
  Future<bool> connect(UsbDeviceInfo device, {int baudRate = 9600}) {
    return FlutterUsbserialPlatform.instance.connect(device.deviceName, baudRate);
  }

  /// Closes the USB connection.
  Future<void> disconnect() {
    return FlutterUsbserialPlatform.instance.disconnect();
  }

  /// Checks if the USB connection is open.
  Future<bool> isConnected() {
    return FlutterUsbserialPlatform.instance.isConnected();
  }

  /// Returns the currently connected USB device.
  Future<UsbDeviceInfo?> getConnectedDevice() async {
    final map = await FlutterUsbserialPlatform.instance.getConnectedDevice();
    if (map == null) return null;
    return UsbDeviceInfo.fromMap(map);
  }

  /// Writes data to the serial port.
  Future<void> write(Uint8List data) {
    return FlutterUsbserialPlatform.instance.write(data);
  }

  /// Reads data from the serial port.
  Future<Uint8List?> read({int bufferSize = 1024, int timeout = 1000}) {
    return FlutterUsbserialPlatform.instance.read(bufferSize, timeout);
  }

  /// Stream of raw data received from the serial port.
  /// Use [startRawReadInterval] to begin receiving data.
  Stream<Uint8List> get rawDataStream => FlutterUsbserialPlatform.instance.rawDataStream;

  /// Starts listening for raw data at a specified interval.
  Future<void> startRawReadInterval({
    int intervalMs = 1000,
    int bufferSize = 1024,
    int timeout = 1000,
  }) {
    return FlutterUsbserialPlatform.instance.startRawReadInterval(intervalMs, bufferSize, timeout);
  }

  /// Stops listening for raw data.
  Future<void> stopRawReadInterval() {
    return FlutterUsbserialPlatform.instance.stopRawReadInterval();
  }

  /// Utility for specialized sensor operations (like Soil Sensors).
  final Utils utils = Utils();
}

/// Information about a connected USB device.
class UsbDeviceInfo {
  final String deviceName;
  final int vendorId;
  final int productId;
  final String? manufacturerName;
  final String? productName;
  final String? serialNumber;

  UsbDeviceInfo({
    required this.deviceName,
    required this.vendorId,
    required this.productId,
    this.manufacturerName,
    this.productName,
    this.serialNumber,
  });

  factory UsbDeviceInfo.fromMap(Map<String, dynamic> map) {
    return UsbDeviceInfo(
      deviceName: map['deviceName'] as String,
      vendorId: map['vendorId'] as int,
      productId: map['productId'] as int,
      manufacturerName: map['manufacturerName'] as String? ?? map['manufacturer'] as String?,
      productName: map['productName'] as String?,
      serialNumber: map['serialNumber'] as String?,
    );
  }

  @override
  String toString() {
    return 'UsbDeviceInfo(deviceName: $deviceName, vendorId: $vendorId, productId: $productId, productName: $productName)';
  }
}

/// Utility class to group specialized sensor operations.
class Utils {
  /// Reads and parses data from a standard 8-in-1 Modbus soil sensor.
  Future<Map<String, double?>?> readSoilData({
    int slaveId = 1,
    int startAddress = 0x0000,
    int registerCount = 8,
    int responseDelayMs = 300,
  }) {
    return FlutterUsbserialPlatform.instance.readSoilData(slaveId, startAddress, registerCount, responseDelayMs);
  }

  /// Stream of soil data received from the sensor.
  /// Use [startSoilReadInterval] to begin receiving data.
  Stream<Map<String, double?>> get soilDataStream => FlutterUsbserialPlatform.instance.soilDataStream;

  /// Starts listening for soil data at a specified interval.
  Future<void> startSoilReadInterval({
    int intervalMs = 1000,
    int slaveId = 1,
    int startAddress = 0x0000,
    int registerCount = 8,
    int responseDelayMs = 300,
  }) {
    return FlutterUsbserialPlatform.instance.startSoilReadInterval(
      intervalMs,
      slaveId,
      startAddress,
      registerCount,
      responseDelayMs,
    );
  }

  /// Stops listening for soil data.
  Future<void> stopSoilReadInterval() {
    return FlutterUsbserialPlatform.instance.stopSoilReadInterval();
  }
}
