import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_usbserial_method_channel.dart';

abstract class FlutterUsbserialPlatform extends PlatformInterface {
  FlutterUsbserialPlatform() : super(token: _token);

  static final Object _token = Object();
  static FlutterUsbserialPlatform _instance = MethodChannelFlutterUsbserial();
  static FlutterUsbserialPlatform get instance => _instance;

  static set instance(FlutterUsbserialPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<List<Map<String, dynamic>>> getDeviceList() {
    throw UnimplementedError('getDeviceList() has not been implemented.');
  }

  Future<bool> hasPermission(String deviceName) {
    throw UnimplementedError('hasPermission() has not been implemented.');
  }

  Future<bool> requestPermission(String deviceName) {
    throw UnimplementedError('requestPermission() has not been implemented.');
  }

  Future<bool> connect(String deviceName, int baudRate) {
    throw UnimplementedError('connect() has not been implemented.');
  }

  Future<void> disconnect() {
    throw UnimplementedError('disconnect() has not been implemented.');
  }

  Future<bool> isConnected() {
    throw UnimplementedError('isConnected() has not been implemented.');
  }

  Future<Map<String, dynamic>?> getConnectedDevice() {
    throw UnimplementedError('getConnectedDevice() has not been implemented.');
  }

  Future<void> write(Uint8List data) {
    throw UnimplementedError('write() has not been implemented.');
  }

  Future<Uint8List?> read(int bufferSize, int timeout) {
    throw UnimplementedError('read() has not been implemented.');
  }

  Stream<Uint8List> get rawDataStream {
    throw UnimplementedError('rawDataStream has not been implemented.');
  }

  Future<void> startRawReadInterval(int interval, int bufferSize, int timeout) {
    throw UnimplementedError(
      'startRawReadInterval() has not been implemented.',
    );
  }

  Future<void> stopRawReadInterval() {
    throw UnimplementedError('stopRawReadInterval() has not been implemented.');
  }

  Future<Map<String, double?>?> readSoilData(
    int slaveId,
    int startAddress,
    int registerCount,
    int responseDelayMs,
  ) {
    throw UnimplementedError('readSoilData() has not been implemented.');
  }

  Stream<Map<String, double?>> get soilDataStream {
    throw UnimplementedError('soilDataStream has not been implemented.');
  }

  Future<void> startSoilReadInterval(
    int interval,
    int slaveId,
    int startAddress,
    int registerCount,
    int responseDelayMs,
  ) {
    throw UnimplementedError(
      'startSoilReadInterval() has not been implemented.',
    );
  }

  Future<void> stopSoilReadInterval() {
    throw UnimplementedError(
      'stopSoilReadInterval() has not been implemented.',
    );
  }
}
