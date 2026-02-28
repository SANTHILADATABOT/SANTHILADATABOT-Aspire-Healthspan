import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

class ClingBleService {
  static const _methodChannel = MethodChannel('cling/methods');
  static const _scanChannel = EventChannel('cling/scan');
  static const _minuteChannel = EventChannel('cling/minute_data');
  static const _dailyChannel = EventChannel('cling/daily_total');
  static const _syncStatusChannel = EventChannel('cling/sync_status');
  static const _pairChannel = EventChannel('cling/pair_status');



  static Stream<List<Map<String, dynamic>>> scanResults() {
    return _scanChannel.receiveBroadcastStream().map((event) {
      return (event as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    });
  }



  static Stream<Map<String, dynamic>> minuteDataStream() {
    return _minuteChannel.receiveBroadcastStream().map((event) {
      return Map<String, dynamic>.from(event);
    });
  }

  // ---------------- Android / Daily Total Data ----------------
  static Stream<Map<String, dynamic>> dailyDataStream() {
    if (!Platform.isAndroid) return const Stream.empty();

    return _dailyChannel.receiveBroadcastStream().map((event) {
      // Android sends formatted string like "Key: Value\nKey2: Value2"
      if (event is String) {
        final map = <String, dynamic>{};
        final lines = event.split('\n');
        for (var line in lines) {
          final parts = line.split(':');
          if (parts.length >= 2) {
            final key = parts[0].trim();
            final value = parts.sublist(1).join(':').trim();
            map[key] = value;
          }
        }
        return map;
      } else if (event is Map) {
        return Map<String, dynamic>.from(event);
      } else {
        return {};
      }
    });
  }

  // ---------------- Android / Sync Status ----------------
  static Stream<Map<String, dynamic>> syncStatusStream() {
    if (!Platform.isAndroid) return const Stream.empty();

    return _syncStatusChannel.receiveBroadcastStream().map((event) {
      // Android sends JSON string like '{"status":"SYNC_COMPLETED"}'
      if (event is String) {
        try {
          return Map<String, dynamic>.from(jsonDecode(event));
        } catch (e) {
          print('⚠️ Error parsing sync status string: $e');
          return {};
        }
      } else if (event is Map) {
        return Map<String, dynamic>.from(event);
      } else {
        return {};
      }
    });
  }

  static Future<void> startScan() async {
    await _methodChannel.invokeMethod('startScan');
  }

  // static Future<void> connectToDevice(String mac) async {
  //   await _methodChannel.invokeMethod('connect', {"name": mac});
  // }

  // static Future<void> connectToDevice(String deviceName) async {
  //   print("📡 connectToDevice() called with NAME: $deviceName");
  //   await _methodChannel.invokeMethod('connect', {"name": deviceName});
  // }

  static Future<void> connectToDevice(String name) async {
    print("📡 connectToDevice() called with name: $name");
    await _methodChannel.invokeMethod('connect', {"name": name});
  }


  static Future<void> deregisterDevice() async {
    await _methodChannel.invokeMethod('deregister');
  }

  static Future<void> syncdata() async {
    await _methodChannel.invokeMethod('loadDeviceData');
  }


  static Future<void> stopScan() async {
    await _methodChannel.invokeMethod('stopScan');
  }

  // Add this method to check bond status
  static Future<Map<String, dynamic>> checkBondStatus() async {
    try {
      final result =
      await _methodChannel.invokeMethod<Map>('checkBonded');

      return {
        'isBonded': result?['isBonded'] ?? false,
        'clingId': result?['clingId'] ?? '',
      };
    } catch (e) {
      print('❌ Bond check failed: $e');
      return {'isBonded': false, 'clingId': ''};
    }
  }

  static Future<void> connectByClingId(String id) async {
    await _methodChannel.invokeMethod('connectByClingId', {"clingId": id});
  }



  // static Future<void> connectByClingId(String clingId) async {
  //   await _methodChannel.invokeMethod('connectByClingId', {"clingId": clingId});
  // }

// ---------------- Android / Pair Status ----------------
  static Stream<String> pairStatusStream() {
    if (!Platform.isAndroid) return const Stream.empty();

    return _pairChannel.receiveBroadcastStream().map((event) {
      return event.toString(); // clingId
    });
  }

  static Future<int> getConnectionState() async {
    final result =
    await _methodChannel.invokeMethod<Map>('getConnectionState');

    return result?['state'] ?? 0;
  }


  // static Future<void> reconnectByClingId(String clingId) async {
  //   await _methodChannel.invokeMethod(
  //     'reconnectByClingId',
  //     {"clingId": clingId},
  //   );
  // }

  // static Future<void> reconnectByName(String name) async {
  //   await _methodChannel.invokeMethod(
  //     'reconnectByName',
  //     {"name": name},
  //   );
  // }








}
