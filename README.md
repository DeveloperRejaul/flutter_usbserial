# flutter_usbserial

A Flutter plugin for USB serial communication on Android, powered by the [usb-serial](https://github.com/DeveloperRejaul/usb-serial) library. This plugin provides a high-level API to interact with USB serial devices, including specialized support for Modbus soil sensors.

## Features

- **Device Management**: List connected USB devices and manage permissions.
- **Serial Communication**: Connect, disconnect, read, and write raw serial data.
- **Interval Reading**: Stream raw data or soil sensor data at specified intervals.
- **Soil Sensor Support**: Built-in utility for reading 8-in-1 Modbus soil sensors.

## Installation

Add `flutter_usbserial` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_usbserial:
    path: ../flutter_usbserial # Or use git/pub version when available
```

### Android Setup

The library requires a minimum SDK version of 24. Ensure your `android/app/build.gradle` (or `android/build.gradle.kts` in the plugin) reflects this.

The plugin automatically handles the necessary dependencies from JitPack.

## Usage

### 1. Initialize and List Devices

```dart
final _usbPlugin = FlutterUsbserial();

List<UsbDeviceInfo> devices = await _usbPlugin.getDeviceList();
for (var device in devices) {
  print("Found device: ${device.productName} (VID: ${device.vendorId}, PID: ${device.productId})");
}
```

### 2. Request Permission and Connect

```dart
if (devices.isNotEmpty) {
  bool hasPerm = await _usbPlugin.hasPermission(devices[0]);
  if (!hasPerm) {
    bool granted = await _usbPlugin.requestPermission(devices[0]);
    if (!granted) return;
  }

  bool connected = await _usbPlugin.connect(devices[0], baudRate: 9600);
  if (connected) {
    print("Connected successfully!");
  }
}
```

### 3. Read and Write Data

#### One-time Read/Write
```dart
// Write data
await _usbPlugin.write(Uint8List.fromList([0x01, 0x02, 0x03]));

// Read data
Uint8List? data = await _usbPlugin.read(bufferSize: 1024, timeout: 1000);
```

#### Streaming Raw Data
```dart
// Listen to the stream
_usbPlugin.rawDataStream.listen((data) {
  print("Received raw data: $data");
});

// Start the interval reader
await _usbPlugin.startRawReadInterval(intervalMs: 500);

// Stop later
await _usbPlugin.stopRawReadInterval();
```

### 4. Specialized Soil Sensor Support

The plugin includes a dedicated utility for Modbus soil sensors (8-in-1).

#### One-time Soil Data Read
```dart
Map<String, double?>? soilData = await _usbPlugin.utils.readSoilData(
  slaveId: 1,
  startAddress: 0x0000,
);

if (soilData != null) {
  print("Soil Moisture: ${soilData['moisture']}");
  print("Soil Temp: ${soilData['temperature']}");
}
```

#### Streaming Soil Data
```dart
_usbPlugin.utils.soilDataStream.listen((data) {
  print("Soil Data Update: $data");
});

await _usbPlugin.utils.startSoilReadInterval(intervalMs: 2000);
```

## API Reference

### `FlutterUsbserial`

| Method | Description |
| --- | --- |
| `getDeviceList()` | Returns a list of `UsbDeviceInfo`. |
| `hasPermission(device)` | Checks if permission is granted. |
| `requestPermission(device)` | Requests USB permission. |
| `connect(device, {baudRate})` | Connects to a device. |
| `disconnect()` | Closes the connection. |
| `isConnected()` | Returns true if connected. |
| `write(data)` | Writes bytes to the port. |
| `read({bufferSize, timeout})` | Reads bytes from the port. |
| `startRawReadInterval(...)` | Starts the interval reader. |
| `stopRawReadInterval()` | Stops the interval reader. |

### `Utils` (Soil Sensors)

| Method | Description |
| --- | --- |
| `readSoilData(...)` | Reads Modbus soil data once. |
| `startSoilReadInterval(...)`| Starts interval soil data reading. |
| `stopSoilReadInterval()` | Stops interval soil data reading. |

## Credits
Based on the [usb-serial](https://github.com/DeveloperRejaul/usb-serial) Android library.
