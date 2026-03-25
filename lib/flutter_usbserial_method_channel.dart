import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_usbserial_platform_interface.dart';

/// An implementation of [FlutterUsbserialPlatform] that uses method channels.
class MethodChannelFlutterUsbserial extends FlutterUsbserialPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_usbserial');

  @visibleForTesting
  final rawDataEventChannel = const EventChannel('flutter_usbserial/raw_data');

  @visibleForTesting
  final soilDataEventChannel = const EventChannel(
    'flutter_usbserial/soil_data',
  );

  @override
  Future<List<Map<String, dynamic>>> getDeviceList() async {
    final List<dynamic>? devices = await methodChannel
        .invokeMethod<List<dynamic>>('getDeviceList');
    return devices?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ??
        [];
  }

  @override
  Future<bool> hasPermission(String deviceName) async {
    return await methodChannel.invokeMethod<bool>('hasPermission', {
          'deviceName': deviceName,
        }) ??
        false;
  }

  @override
  Future<bool> requestPermission(String deviceName) async {
    return await methodChannel.invokeMethod<bool>('requestPermission', {
          'deviceName': deviceName,
        }) ??
        false;
  }

  @override
  Future<bool> connect(String deviceName, int baudRate) async {
    return await methodChannel.invokeMethod<bool>('connect', {
          'deviceName': deviceName,
          'baudRate': baudRate,
        }) ??
        false;
  }

  @override
  Future<void> disconnect() async {
    await methodChannel.invokeMethod('disconnect');
  }

  @override
  Future<bool> isConnected() async {
    return await methodChannel.invokeMethod<bool>('isConnected') ?? false;
  }

  @override
  Future<Map<String, dynamic>?> getConnectedDevice() async {
    final Map<dynamic, dynamic>? device = await methodChannel
        .invokeMethod<Map<dynamic, dynamic>>('getConnectedDevice');
    return device?.cast<String, dynamic>();
  }

  @override
  Future<void> write(Uint8List data) async {
    await methodChannel.invokeMethod('write', {'data': data});
  }

  @override
  Future<Uint8List?> read(int bufferSize, int timeout) async {
    return await methodChannel.invokeMethod<Uint8List>('read', {
      'bufferSize': bufferSize,
      'timeout': timeout,
    });
  }

  @override
  Stream<Uint8List> get rawDataStream {
    return rawDataEventChannel.receiveBroadcastStream().map(
      (event) => event as Uint8List,
    );
  }

  @override
  Future<void> startRawReadInterval(
    int interval,
    int bufferSize,
    int timeout,
  ) async {
    await methodChannel.invokeMethod('startRawReadInterval', {
      'interval': interval,
      'bufferSize': bufferSize,
      'timeout': timeout,
    });
  }

  @override
  Future<void> stopRawReadInterval() async {
    await methodChannel.invokeMethod('stopRawReadInterval');
  }

  @override
  Future<Map<String, double?>?> readSoilData(
    int slaveId,
    int startAddress,
    int registerCount,
    int responseDelayMs,
  ) async {
    final Map<dynamic, dynamic>? data = await methodChannel
        .invokeMethod<Map<dynamic, dynamic>>('readSoilData', {
          'slaveId': slaveId,
          'startAddress': startAddress,
          'registerCount': registerCount,
          'responseDelayMs': responseDelayMs,
        });
    return data?.map(
      (key, value) => MapEntry(key.toString(), value as double?),
    );
  }

  @override
  Stream<Map<String, double?>> get soilDataStream {
    return soilDataEventChannel.receiveBroadcastStream().map((event) {
      final Map<dynamic, dynamic> data = event as Map<dynamic, dynamic>;
      return data.map(
        (key, value) => MapEntry(key.toString(), value as double?),
      );
    });
  }

  @override
  Future<void> startSoilReadInterval(
    int interval,
    int slaveId,
    int startAddress,
    int registerCount,
    int responseDelayMs,
  ) async {
    await methodChannel.invokeMethod('startSoilReadInterval', {
      'interval': interval,
      'slaveId': slaveId,
      'startAddress': startAddress,
      'registerCount': registerCount,
      'responseDelayMs': responseDelayMs,
    });
  }

  @override
  Future<void> stopSoilReadInterval() async {
    await methodChannel.invokeMethod('stopSoilReadInterval');
  }
}
