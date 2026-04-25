import 'dart:io';
import 'package:health/health.dart';
import 'package:intl/intl.dart';

class HealthConnectService {
  static final HealthConnectService _instance = HealthConnectService._internal();
  factory HealthConnectService() => _instance;
  HealthConnectService._internal();

  final Health _health = Health();

  // Define the types we want to write to Health Connect
  final List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BLOOD_OXYGEN,
  ];

  /// Core method to mirror Cling data into Health Connect with toggle respect
  Future<void> syncToHealthConnect(Map<String, dynamic> data, {Map<String, bool>? toggles}) async {
    if (!Platform.isAndroid) return;

    // Use default 'true' if toggles are not provided
    final bool showBP = toggles?['BloodPressure'] ?? true;
    final bool showHR = toggles?['HeartRate'] ?? true;
    final bool showSteps = toggles?['Steps'] ?? true;
    final bool showSpo2 = toggles?['Spo2'] ?? true;

    try {
      // 1. Filter types based on toggles for permission request
      final List<HealthDataType> activeTypes = [];
      if (showHR) activeTypes.add(HealthDataType.HEART_RATE);
      if (showSteps) activeTypes.add(HealthDataType.STEPS);
      if (showBP) {
        activeTypes.add(HealthDataType.BLOOD_PRESSURE_SYSTOLIC);
        activeTypes.add(HealthDataType.BLOOD_PRESSURE_DIASTOLIC);
      }
      if (showSpo2) activeTypes.add(HealthDataType.BLOOD_OXYGEN);

      if (activeTypes.isEmpty) return;

      // Request permissions if needed
      bool granted = await _health.hasPermissions(activeTypes, permissions: activeTypes.map((e) => HealthDataAccess.WRITE).toList()) ?? false;

      if (!granted) {
        granted = await _health.requestAuthorization(activeTypes, permissions: activeTypes.map((e) => HealthDataAccess.WRITE).toList());
      }

      if (!granted) {
        print("📥 Health Connect: Permission denied for active types");
        return;
      }

      final now = DateTime.now();
      final startTime = now.subtract(const Duration(seconds: 1)); 

      // 2. Map data fields with toggle checks
      if (showHR && data.containsKey('heartRate') && data['heartRate'] > 0) {
        await _health.writeHealthData(
          value: data['heartRate'].toDouble(),
          type: HealthDataType.HEART_RATE,
          startTime: startTime,
          endTime: now,
        );
      }

      if (showSteps && data.containsKey('totalSteps') && data['totalSteps'] > 0) {
        await _health.writeHealthData(
          value: data['totalSteps'].toDouble(),
          type: HealthDataType.STEPS,
          startTime: startTime,
          endTime: now,
        );
      }

      if (showBP && data.containsKey('iBPHigh') && data['iBPHigh'] > 0) {
        await _health.writeHealthData(
          value: data['iBPHigh'].toDouble(),
          type: HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
          startTime: startTime,
          endTime: now,
        );
      }

      if (showBP && data.containsKey('iBPLow') && data['iBPLow'] > 0) {
        await _health.writeHealthData(
          value: data['iBPLow'].toDouble(),
          type: HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
          startTime: startTime,
          endTime: now,
        );
      }

      if (showSpo2 && data.containsKey('spo2') && data['spo2'] > 0) {
        await _health.writeHealthData(
          value: data['spo2'].toDouble(),
          type: HealthDataType.BLOOD_OXYGEN,
          startTime: startTime,
          endTime: now,
        );
      }

      print("✅ Successfully mirrored enabled data to Health Connect");
    } catch (e) {
      print("❌ Health Connect Sync Error: $e");
    }
  }

  /// Bulk sync with toggle respect
  Future<void> syncBulkToHealthConnect(List<Map<String, dynamic>> rawList, {Map<String, bool>? toggles}) async {
    if (!Platform.isAndroid || rawList.isEmpty) return;
    
    for (var data in rawList) {
      await syncToHealthConnect(data, toggles: toggles);
    }
  }
}
