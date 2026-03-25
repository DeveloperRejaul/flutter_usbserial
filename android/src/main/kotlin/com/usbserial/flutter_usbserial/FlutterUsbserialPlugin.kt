package com.usbserial.flutter_usbserial

import android.content.Context
import android.hardware.usb.UsbDevice
import com.rezaul.usbserial.UsbManager
import com.rezaul.usbserial.SoilSensorConfig
import com.rezaul.usbserial.RawReadConfig
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class FlutterUsbserialPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var rawDataChannel: EventChannel
    private lateinit var soilDataChannel: EventChannel
    
    private var usbManager: UsbManager? = null
    private var context: Context? = null

    private var rawDataSink: EventChannel.EventSink? = null
    private var soilDataSink: EventChannel.EventSink? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        usbManager = UsbManager(context!!)

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_usbserial")
        channel.setMethodCallHandler(this)

        rawDataChannel = EventChannel(flutterPluginBinding.binaryMessenger, "flutter_usbserial/raw_data")
        rawDataChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                rawDataSink = events
            }
            override fun onCancel(arguments: Any?) {
                rawDataSink = null
                usbManager?.offReadInterval()
            }
        })

        soilDataChannel = EventChannel(flutterPluginBinding.binaryMessenger, "flutter_usbserial/soil_data")
        soilDataChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                soilDataSink = events
            }
            override fun onCancel(arguments: Any?) {
                soilDataSink = null
                usbManager?.utils?.offReadSoilDataInterval()
            }
        })
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getDeviceList" -> {
                val devices = usbManager?.getDeviceList() ?: emptyList()
                val deviceList = devices.map { deviceToMap(it) }
                result.success(deviceList)
            }
            "hasPermission" -> {
                val deviceName = call.argument<String>("deviceName")
                val device = findDevice(deviceName)
                if (device != null) {
                    result.success(usbManager?.hasPermission(device))
                } else {
                    result.error("DEVICE_NOT_FOUND", "Device not found", null)
                }
            }
            "requestPermission" -> {
                val deviceName = call.argument<String>("deviceName")
                val device = findDevice(deviceName)
                if (device != null) {
                    usbManager?.requestUsbPermission(device) { granted ->
                        result.success(granted)
                    }
                } else {
                    result.error("DEVICE_NOT_FOUND", "Device not found", null)
                }
            }
            "connect" -> {
                val deviceName = call.argument<String>("deviceName")
                val baudRate = call.argument<Int>("baudRate") ?: 9600
                val device = findDevice(deviceName)
                if (device != null) {
                    result.success(usbManager?.connect(device, baudRate))
                } else {
                    result.error("DEVICE_NOT_FOUND", "Device not found", null)
                }
            }
            "disconnect" -> {
                usbManager?.disconnect()
                result.success(null)
            }
            "isConnected" -> {
                result.success(usbManager?.isConnected())
            }
            "getConnectedDevice" -> {
                val device = usbManager?.getConnectedDevice()
                if (device != null) {
                    result.success(deviceToMap(device))
                } else {
                    result.success(null)
                }
            }
            "write" -> {
                val data = call.argument<ByteArray>("data")
                if (data != null) {
                    usbManager?.write(data)
                    result.success(null)
                } else {
                    result.error("INVALID_DATA", "Data is null", null)
                }
            }
            "read" -> {
                val bufferSize = call.argument<Int>("bufferSize") ?: 1024
                val timeout = call.argument<Int>("timeout") ?: 1000
                val data = usbManager?.read(bufferSize, timeout)
                result.success(data)
            }
            "startRawReadInterval" -> {
                val interval = (call.argument<Int>("interval") ?: 1000).toLong()
                val bufferSize = call.argument<Int>("bufferSize") ?: 1024
                val timeout = call.argument<Int>("timeout") ?: 1000
                usbManager?.onReadInterval(interval, { data ->
                    rawDataSink?.success(data)
                }, RawReadConfig(bufferSize, timeout))
                result.success(null)
            }
            "stopRawReadInterval" -> {
                usbManager?.offReadInterval()
                result.success(null)
            }
            "readSoilData" -> {
                val slaveId = call.argument<Int>("slaveId") ?: 1
                val startAddress = call.argument<Int>("startAddress") ?: 0x0000
                val registerCount = call.argument<Int>("registerCount") ?: 8
                val responseDelayMs = call.argument<Int>("responseDelayMs") ?: 300
                val data = usbManager?.utils?.readSoilData(slaveId, startAddress, registerCount, responseDelayMs)
                result.success(data)
            }
            "startSoilReadInterval" -> {
                val interval = (call.argument<Int>("interval") ?: 1000).toLong()
                val slaveId = call.argument<Int>("slaveId") ?: 1
                val startAddress = call.argument<Int>("startAddress") ?: 0x0000
                val registerCount = call.argument<Int>("registerCount") ?: 8
                val responseDelayMs = call.argument<Int>("responseDelayMs") ?: 300
                usbManager?.utils?.onReadSoilDataInterval(interval, { data ->
                    soilDataSink?.success(data)
                }, SoilSensorConfig(slaveId, startAddress, registerCount, responseDelayMs))
                result.success(null)
            }
            "stopSoilReadInterval" -> {
                usbManager?.utils?.offReadSoilDataInterval()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun findDevice(deviceName: String?): UsbDevice? {
        if (deviceName == null) return null
        return usbManager?.getDeviceList()?.find { it.deviceName == deviceName }
    }

    private fun deviceToMap(device: UsbDevice): Map<String, Any?> {
        return mapOf(
            "deviceName" to device.deviceName,
            "vendorId" to device.vendorId,
            "productId" to device.productId,
            "manufacturerName" to device.manufacturerName,
            "productName" to device.productName,
            "serialNumber" to device.serialNumber
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        usbManager?.disconnect()
        context = null
    }
}
