

import 'dart:async';
import 'dart:convert';
import 'package:aspire/root/root.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb


class Emailotpcontroller {

  Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String enteredOtp,
    required String? fcmToken,
  }) async {

    final prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";

    final String url = '$root/email_otp_verified';

    final Map<String, String> userData = {
      'email': email,
      'email_otp': enteredOtp,
      "access_token": fcmToken ?? " ",
      'user_id': user_id
    };

    print("user_id:$user_id");

    try {
      final response = await http.post(
        Uri.parse(url),
        body: userData)
          .timeout(Duration(seconds: 10),
        onTimeout: () {
          // Just show toast, no need to throw
          showCustomToast("Time Out");
          // Return a dummy response so code continues
          throw TimeoutException("Request Timeout");
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return {
          'success': jsonResponse['status'] == "SUCCESS",
          'data': jsonResponse,
          'message': jsonResponse['status'] == "SUCCESS"
              ? "Sign In Successful"
              : "OTP Mismatch. Please try again."
        };
      } else {
        return {
          'success': false,
          'message': 'Request failed with status: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  //Timeout API
  Future<bool> otpTimeout(String email) async {
    final String url = '$root/otp_timeout';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'email': email},
      );

      if (response.statusCode == 200) {
        print('OTP Timeout Response: ${response.body}');
        return true;
      }
      return false;
    } catch (e) {
      print('Error in otpTimeout: $e');
      return false;
    }
  }

  // Resend OTP
  Future<Map<String, dynamic>> resendEmailOtp(String email) async {
    final String url = '$root/email_login_resend_otp';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'email': email},
      );

      print('OTP resend Response: ${response.body}');

      if (response.statusCode == 200) {
        print('OTP resend Response1: ${response.body}');
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