
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class ClingChannelHandler {
  static final ClingChannelHandler _instance =
  ClingChannelHandler._internal();

  factory ClingChannelHandler() => _instance;

  ClingChannelHandler._internal();

  // iOS
  static const platform = MethodChannel('cling_sdk');

  // Android
  static const _minuteChannel = EventChannel('cling/minute_data');
  //static const _dailyChannel = EventChannel('cling/daily_total');
  //static const _dailyChannel = MethodChannel('cling/daily_total');
  //static const MethodChannel _dailyChannel = MethodChannel('cling/daily_total');
  static const  _dailyChannel = EventChannel('cling/daily_total');

  StreamSubscription? _minuteSub;
  StreamSubscription? _dailySub;

  Function(Map<String, dynamic>)? onDailyData;
  Function(List<Map<String, dynamic>>)? onMinuteData;

  // =================================================
  // INIT (handles BOTH platforms automatically)
  // =================================================
  void initialize() {
    if (Platform.isIOS) {
      _setupIOS();
    }

    if (Platform.isAndroid) {
      _setupAndroid();
    }
  }


  // =================================================
  // iOS → MethodChannel
  // =================================================
  void _setupIOS() {
    platform.setMethodCallHandler((call) async {
      print("📡 iOS Method: ${call.method}");

      if (call.method == "onDailyTotalReceived") {
        final data = Map<String, dynamic>.from(call.arguments);
        onDailyData?.call(data);
      }

      if (call.method == "onSyncDataReceived") {
        final args = call.arguments;

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

  // =================================================
  // Android → EventChannel
  // =================================================
  void _setupAndroid() {
    print("📡 Android channels attached");

    _minuteSub =
        _minuteChannel.receiveBroadcastStream().listen((event) {

          print("📥 MINUTE_EVENT: $event");
          print("📥 EVENT TYPE: ${event.runtimeType}");

          if (event is! Map) {
            print("❌ Event is NOT a Map. Ignored.");
            return;
          }
          final data = Map<String, dynamic>.from(event);
          print("🟢 PARSED MINUTE DATA:");
          data.forEach((key, value) {
            print("🔹$key = $value (${value.runtimeType})");
          });

          print("✅ Total fields received: ${data.length}");
          // Forward to callback
          onMinuteData?.call([data]); // SAME AS iOS
        });

    _dailySub = _dailyChannel
        .receiveBroadcastStream()
        .listen((event) {

      print("🟢 ANDROID DAILY DATA :");
      print(event);
      if (event is! Map) return;

      final data = Map<String, dynamic>.from(event);
      onDailyData?.call(data);
    });
  }

  // void _setupAndroid() {
  //   print("📡 Android channels attached");
  //
  //   // 🔄 Cancel existing subscriptions (avoid duplicate streams)
  //   _minuteSub?.cancel();
  //   _dailySub?.cancel();
  //
  //   /// ==============================
  //   /// 🕒 MINUTE DATA LISTENER
  //   /// ==============================
  //   _minuteSub = _minuteChannel
  //       .receiveBroadcastStream()
  //       .listen(
  //
  //         (event) {
  //
  //       print("📥 MINUTE_EVENT: $event");
  //
  //       if (event == null) {
  //         print("❌ Minute event is NULL");
  //         return;
  //       }
  //
  //       if (event is! Map) {
  //         print("❌ Minute event is not a Map → ${event.runtimeType}");
  //         return;
  //       }
  //
  //       final Map<String, dynamic> data =
  //       Map<String, dynamic>.from(event);
  //
  //       print("🟢 Parsed Minute Data (${data.length} fields)");
  //
  //       data.forEach((key, value) {
  //         print("🔹 $key = $value (${value.runtimeType})");
  //       });
  //
  //       // ✅ Forward exactly like iOS (List wrapper)
  //       onMinuteData?.call([data]);
  //     },
  //
  //     onError: (error) {
  //       print("❌ Minute stream error: $error");
  //     },
  //
  //     onDone: () {
  //       print("⚠️ Minute stream closed");
  //     },
  //
  //     cancelOnError: false,
  //   );
  //
  //   /// ==============================
  //   /// 📊 DAILY DATA LISTENER
  //   /// ==============================
  //   _dailySub = _dailyChannel
  //       .receiveBroadcastStream()
  //       .listen(
  //
  //         (event) {
  //
  //       print("📊 DAILY_EVENT: $event");
  //
  //       if (event == null) {
  //         print("❌ Daily event is NULL");
  //         return;
  //       }
  //
  //       if (event is! Map) {
  //         print("❌ Daily event is not a Map → ${event.runtimeType}");
  //         return;
  //       }
  //
  //       final Map<String, dynamic> data =
  //       Map<String, dynamic>.from(event);
  //
  //       print("🟢 Parsed Daily Data (${data.length} fields)");
  //
  //       onDailyData?.call(data);
  //     },
  //
  //     onError: (error) {
  //       print("❌ Daily stream error: $error");
  //     },
  //
  //     onDone: () {
  //       print("⚠️ Daily stream closed");
  //     },
  //
  //     cancelOnError: false,
  //   );
  // }

  void dispose() {
    _minuteSub?.cancel();
    _dailySub?.cancel();
    print("🧹 ClingChannelHandler disposed and subscriptions cancelled");
  }
}
