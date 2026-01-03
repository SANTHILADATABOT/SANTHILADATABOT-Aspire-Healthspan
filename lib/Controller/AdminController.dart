import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Model/Adminmodel.dart';
import '../root/root.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb


class AdminController {

  Future<AdminModel?> updateOrFetchStatus({
    required String tableType,
    String? toggleStatus, // null = fetch mode
  }) async {
    final Uri url = Uri.parse("$root/toggle_status");

    try {
      final Map<String, dynamic> body = {
        "table_type": tableType
      };

      if (toggleStatus != null &&
          (toggleStatus.toUpperCase() == "ON" || toggleStatus.toUpperCase() == "OFF")) {
        body["toggle_status"] = toggleStatus;
      }

      print("📤 Sending body for $tableType → $body");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body))
          .timeout(Duration(seconds: 10),
        onTimeout: () {
          // Just show toast, no need to throw
          showCustomToast("Time Out");
          // Return a dummy response so code continues
          return http.Response('{"status":"TIMEOUT"}', 408);
        },
      );

      print("🔄 API Response ($tableType): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["status"] == "SUCCESS") {
          return AdminModel.fromJson(data);
        } else {
          print("⚠️ ${data["message"]}");
        }
      } else {
        print("❌ HTTP ${response.statusCode}");
      }
      return null;
    } catch (e) {
      print("⚠️ Error for $tableType: $e");
      return null;
    }
  }

  /// 🔵 Fetch ALL toggle statuses from server
  Future<AdminModel?> fetchAllToggles() async {
    final Uri url = Uri.parse("$root/get_all_toggles");

    print("Fetching all toggle statuses...");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"})
          .timeout(Duration(seconds: 10),
        onTimeout: () {
          // Just show toast, no need to throw
          showCustomToast("Time Out");
          // Return a dummy response so code continues
          throw TimeoutException("Request Timeout");
        },
      );

      print("API Response (All Toggles): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["status"] == "SUCCESS") {
          return AdminModel.fromJson(data);
        } else {
          print("Fetch failed: ${data["message"]}");
        }
      } else {
        print("HTTP ${response.statusCode}");
      }

      return null;
    } catch (e) {
      print("Error fetching all toggles: $e");
      return null;
    }
  }

  void showCustomToast(String msg) {
    showToast(
      msg,
      duration: Duration(seconds: 2),
      position: kIsWeb ? ToastPosition.top : ToastPosition.bottom,
      backgroundColor: Colors.black,
      radius: 8.0,
      textPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      textStyle: TextStyle(
        fontSize: 16.0,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
      animationCurve: kIsWeb ? Curves.easeInOut : Curves.easeIn,
      animationDuration: const Duration(milliseconds: 400),
      animationBuilder: kIsWeb ? _slideFromRight : null,
    );
  }

  Widget _slideFromRight(BuildContext context,
      Widget child,
      AnimationController controller,
      double percent,) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(1.2, 0.0), // far right
        end: Offset(-1.2, 0.0), // f // Slide to original position
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }

}


