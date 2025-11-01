
import 'package:flutter/services.dart';

class ClingChannelHandler {
  static final ClingChannelHandler _instance = ClingChannelHandler._internal();
  static const platform = MethodChannel('cling_sdk');

  factory ClingChannelHandler() => _instance;

  ClingChannelHandler._internal();

  Function(Map<String, dynamic>)? onDailyData;
  Function(List<Map<String, dynamic>>)? onMinuteData;

  void initialize() {
    platform.setMethodCallHandler((call) async {
      print("📡 Method call received: ${call.method}");

      if (call.method == "onDailyTotalReceived") {
        final data = Map<String, dynamic>.from(call.arguments);
        //print("📥 Daily data: $data");
        onDailyData?.call(data);
      }

      if (call.method == "onSyncDataReceived") {
        final args = call.arguments;
        //print("📥 Minute data: $args");

        List<Map<String, dynamic>> list = [];

        if (args is Map) {
          list.add(Map<String, dynamic>.from(args));
        } else if (args is List) {
          list = args.map((e) => Map<String, dynamic>.from(e)).toList();
        }
        onMinuteData?.call(list);
      }
    });
  }
}
