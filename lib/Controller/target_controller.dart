
import 'dart:async';
import 'dart:convert';
import 'package:aspire/View/Dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:oktoast/oktoast.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb

class TargetController {
  static const String _apiUrl = 'https://app.aspirehealthspan.ai/aspire_api/add_user_target';

  static Future<void> saveTarget({
    required String systolic,
    required String diastolic,
    required String heartRate,
    required String steps,
    required String userId,
    required String strideLength,
    required String targetSleep,
    required String targetweight,
    required String targetBmi,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },



        body: {
          'user_id': userId,
          'high_bp_target': systolic,
          'low_bp_target': diastolic,
          'hr_target': heartRate,
          'step_target': steps,
          'stride_length':strideLength,
          'sleep_target': targetSleep,
           'weight_target': targetweight,
           'bmi_target': targetBmi
        },)
              .timeout(Duration(seconds: 10),
          onTimeout: () {
    // Just show toast, no need to throw
    showCustomToast("Time Out");
    // Return a dummy response so code continues
    throw TimeoutException("Request Timeout");
    },
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      print("Sending sleep target: $targetSleep");

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("Decoded response: $data");

        if (data["status"] == "SUCCESS") {
          Get.to(()=>DashboardScreen(deviceID: ''));
          showToast("Saved Your target settings have been updated!",);
        } else {
          showToast("Error,Failed to save target settings. Try again.",);
        }
      } else {
        showToast("Server Error, Failed to save target. Status: ${response.statusCode}",);
      }
    } catch (e) {
      print("Error in saveTarget: $e");
      showToast("Exception An error occurred while saving target.",);
    }
  }

  static Future<Map<String, dynamic>?> viewTargetData({required String userId}) async {
    const String url = 'https://app.aspirehealthspan.ai/aspire_api/get_user_target_data';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'user_id': userId})
          .timeout(Duration(seconds: 10),
        onTimeout: () {
          // Just show toast, no need to throw
          showCustomToast("Time Out");
          // Return a dummy response so code continues
          throw TimeoutException("Request Timeout");
        },
      );

      print("ViewTarget status: ${response.statusCode}");
      print("ViewTarget body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'SUCCESS') {
          return data['target']; // ✅ if you're sure you'll only use target fields
          // Return only the target data map
        }
      }
      return null;
    } catch (e) {
      print("Error fetching view target: $e");
      return null;
    }
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

Widget _slideFromRight(
    BuildContext context,
    Widget child,
    AnimationController controller,
    double percent,
    ) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: Offset(1.2, 0.0), // far right
      end: Offset(-1.2, 0.0),  // f // Slide to original position
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    )),
    child: child,
  );
}

// showToast(String msg) {
//   Fluttertoast.showToast(
//     msg: msg,
//     toastLength: Toast.LENGTH_SHORT,
//     gravity: ToastGravity.BOTTOM,
//     timeInSecForIosWeb: 1,
//     backgroundColor: Colors.black,
//     textColor: Colors.white,
//     fontSize: 16.0,
//   );
// }


