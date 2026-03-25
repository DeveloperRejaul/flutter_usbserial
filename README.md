# flutter_usbserial

A high-performance Flutter plugin for USB serial communication on Android. This plugin is a wrapper around the [usb-serial](https://github.com/DeveloperRejaul/usb-serial) Android library, providing a simple and robust API for interacting with USB devices, including specialized support for Modbus soil sensors.

[![pub package](https://img.shields.io/pub/v/flutter_usbserial.svg)](https://pub.dev/packages/flutter_usbserial)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/DeveloperRejaul/usb-serial/blob/main/LICENSE)

## Features

- **Device Discovery**: List all connected USB devices with detailed information (VID, PID, Serial, etc.).
- **Permission Management**: Easy-to-use API for checking and requesting USB permissions.
- **Serial Communication**: 
    - Support for multiple baud rates.
    - Synchronous and asynchronous (Interval-based) reading.
    - Robust write operations.
- **Specialized Utils**: Built-in support for 8-in-1 Modbus Soil Sensors (Moisture, Temperature, EC, PH, N, P, K, Salinity).

## Installation

Add this to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_usbserial: ^0.0.1
```

Or run the following command in your terminal:

```bash
flutter pub add flutter_usbserial
```

### Android Configuration

Ensure your `minSdkVersion` is set to **24** or higher in your `android/app/build.gradle`.

```gradle
android {
    defaultConfig {
        minSdkVersion 24
    }
}
```

## Documentation & Usage

### 1. Initialize and Discovery

```dart
final usb = FlutterUsbserial();

// Get list of connected devices
List<UsbDeviceInfo> devices = await usb.getDeviceList();

for (var device in devices) {
  print("Device: ${device.productName}, VID: ${device.vendorId}, PID: ${device.productId}");
}
```

### 2. Connection Handling

```dart
// Check permission
bool hasPermission = await usb.hasPermission(devices[0]);

if (!hasPermission) {
  // Request permission
  bool granted = await usb.requestPermission(devices[0]);
  if (!granted) return;
}

// Connect with baud rate
bool connected = await usb.connect(devices[0], baudRate: 9600);
```

### 3. Reading and Writing Data

#### Synchronous Write
```dart
await usb.write(Uint8List.fromList([0x01, 0x03, 0x00, 0x00, 0x00, 0x08, 0x44, 0x0C]));
```

#### Synchronous Read
```dart
Uint8List? response = await usb.read(bufferSize: 1024, timeout: 1000);
```

#### Real-time Streaming (Interval)
```dart
// 1. Start listening to the stream
usb.rawDataStream.listen((data) {
  print("Received: $data");
});

// 2. Start the interval reader
await usb.startRawReadInterval(intervalMs: 500);

// 3. Stop when done
await usb.stopRawReadInterval();
```

### 4. Soil Sensor (Modbus) Utility

This plugin includes a dedicated helper for standard 8-in-1 soil sensors.

```dart
// Start streaming soil data
usb.utils.soilDataStream.listen((data) {
  print("Moisture: ${data['moisture']}%");
  print("Temperature: ${data['temperature']}°C");
  print("PH: ${data['ph']}");
});

await usb.utils.startSoilReadInterval(
  intervalMs: 1000, 
  slaveId: 1
);
```

## API Reference

### `FlutterUsbserial` Methods

| Method | Description |
| --- | --- |
| `getDeviceList()` | Returns `Future<List<UsbDeviceInfo>>` of connected devices. |
| `hasPermission(device)` | Returns `Future<bool>` if the app has access. |
| `requestPermission(device)` | Requests USB permission via system dialog. |
| `connect(device, {baudRate})` | Connects to the device. Default baud: 9600. |
| `disconnect()` | Closes the active connection. |
| `isConnected()` | Checks if a connection is active. |
| `getConnectedDevice()` | Returns the current `UsbDeviceInfo` or null. |
| `write(data)` | Sends `Uint8List` data to the serial port. |
| `read({bufferSize, timeout})` | Reads data once from the port. |
| `startRawReadInterval(...)` | Starts a recurring read loop and emits to `rawDataStream`. |
| `stopRawReadInterval()` | Stops the raw read loop. |

### `Utils` (Soil Sensor) Methods

| Method | Description |
| --- | --- |
| `readSoilData(...)` | Performs a single Modbus read for soil parameters. |
| `startSoilReadInterval(...)`| Starts a loop and emits parsed maps to `soilDataStream`. |
| `stopSoilReadInterval()` | Stops the soil sensor loop. |

## Supported Sensors (8-in-1)
- Moisture
- Temperature
- Conductivity (EC)
- PH
- Nitrogen (N)
- Phosphorus (P)
- Potassium (K)
- Salinity

## Credits
This plugin is maintained by [MedinaTech](https://github.com/medinatech) and uses the [usb-serial](https://github.com/DeveloperRejaul/usb-serial) library.

## License
MIT License.
