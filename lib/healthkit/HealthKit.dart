import 'package:flutter/services.dart';

class HealthKitService {
  static const _channel = MethodChannel('com.eugene.aspire.healthkit');

  Future<bool> requestAuthorization() async {
    return await _channel.invokeMethod("requestAuthorization");
  }

  Future<List<Map<String, dynamic>>> fetchHeartRate() async {
    final res = await _channel.invokeMethod("fetchHeartRate");
    return List<Map<String, dynamic>>.from(res ?? []);
  }
}
