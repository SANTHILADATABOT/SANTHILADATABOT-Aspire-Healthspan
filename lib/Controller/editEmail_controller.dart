
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:aspire/View/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_count_down/timer_controller.dart';
import '../root/root.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb

class EditEmailController {

  Future<Map<String, dynamic>> verify_mob({
    required String email,
    required String userId,
  }) async {
    final String url = '$root/update_mobile_email';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'email': email, 'user_id': userId})
            .timeout(Duration(seconds: 10),
          onTimeout: () {
            // Just show toast, no need to throw
            //showCustomToast("Time Out");
            // Return a dummy response so code continues
            throw TimeoutException("Request Timeout");
          },
      );

      print("verifyresponse:${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return {
          'success': jsonResponse['status'] == "SUCCESS",
          'data': jsonResponse,
          'message': jsonResponse['status'] == "SUCCESS"
              ? "OTP Sent Successfully"
              : "Email already exists"
        };
      } else {
        return {
          'success': false,
          'message': 'Request failed with status: ${response.statusCode}'
        };
      }
    } catch (e) {
      if (e is TimeoutException) {
        showCustomToast("Timed Out");
      }
      else if (e is SocketException) {
        showCustomToast("No Internet Connection");
      }
      else {
        showCustomToast("Something went wrong. Please try again.");
      }
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Step 2: Verify OTP for updating email/mobile
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String userId,
    required String otp,
  }) async {
    final String url = '$root/updt_mobmail_otp_verify';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'email': email,
          'user_id': userId,
          'mobile_email_otp': otp
        })
          .timeout(Duration(seconds: 10),
        onTimeout: () {
          // Just show toast, no need to throw
          //showCustomToast("Time Out");
          // Return a dummy response so code continues
          throw TimeoutException("Request Timeout");
        },

      );

      print("verifyotpresponse:${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return {
          'success': jsonResponse['status'] == "SUCCESS",
          'data': jsonResponse,
          'message': jsonResponse['status'] == "SUCCESS"
              ? "Email Updated Successfully"
              : "OTP Mismatch. Please try again."
        };
      } else {
        return {
          'success': false,
          'message': 'Request failed with status: ${response.statusCode}'
        };
      }
    } catch (e) {
      if (e is TimeoutException) {
        showCustomToast("Timed Out");
      }
      else if (e is SocketException) {
        showCustomToast("No Internet Connection");
      }
      else {
        showCustomToast("Something went wrong. Please try again.");
      }
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Step 3: Timeout API
  Future<bool> otpTimeout({
    required String email,
    required String userId,
  }) async {
    final String url = '$root/update_otp_timeout';


    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'email': email, 'user_id': userId})
          .timeout(Duration(seconds: 10),
        onTimeout: () {
          // Just show toast, no need to throw
          //showCustomToast("Time Out");
          // Return a dummy response so code continues
          throw TimeoutException("Request Timeout");
        },
      );
      print("timeoutresponse:${response.body}");
      return response.statusCode == 200;
    } catch (e) {
    if (e is TimeoutException) {
    showCustomToast("Timed Out");
    }
    else if (e is SocketException) {
    showCustomToast("No Internet Connection");
    }
    else {
    showCustomToast("Something went wrong. Please try again.");
    }
      return false;
    }
  }

  /// Step 4: Resend OTP
  Future<Map<String, dynamic>> resendOtp({
    required String email,
    required String userId,
  }) async {
    final String url = '$root/email_update_resend_otp';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'email': email, 'user_id': userId})
    .timeout(Duration(seconds: 10),
    onTimeout: () {
    // Just show toast, no need to throw
    //showCustomToast("Time Out");
    // Return a dummy response so code continues
    throw TimeoutException("Request Timeout");
    },
      );

      print("otpresendresponse:${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return {
          'success': jsonResponse['status'] == "SUCCESS",
          'data': jsonResponse['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Request failed with status: ${response.statusCode}'
        };
      }
    } catch (e) {
      if (e is TimeoutException) {
        showCustomToast("Timed Out");
      }
      else if (e is SocketException) {
        showCustomToast("No Internet Connection");
      }
      else {
        showCustomToast("Something went wrong. Please try again.");
      }
      return {'success': false, 'message': 'Error: $e'};
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

