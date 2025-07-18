


import 'dart:convert';

import 'package:azpire_new/View/Dashboard_screen.dart';
import 'package:azpire_new/alert_dialog.dart';
import 'package:azpire_new/View/bluetoothscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_count_down/timer_controller.dart';

import '../root/root.dart';

class LoginOtpController{

  Future<void> otpVerify({
    required BuildContext context,
    required StateSetter setState,
    required String? mobileno,
    required String? enteredOtp,
    required Function(bool) setLoading,
    required CountdownController controller, String? newOtp, required String user, required String mobileOTP,
  }) async {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // var token = prefs.getString('token');
    // String? _registeredDevice;
    // print('FCM Token: ${token == null ? " " : token}');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    print('OTP screen token read: $token');

    setState(() {
      setLoading(true);
    });

    final String url = '$root/mobile_otp_verified';
    print("User: $mobileno");
    print("Entered OTP: $enteredOtp");

    final Map<String, String> userData = {
      'mobile_no': mobileno ?? '',
      'mobile_otp': enteredOtp ?? '',
      "access_token": token ?? "",
    };

    try {
      final response = await http.post(Uri.parse(url), body: userData);
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      print("jsonResponse $jsonResponse");

      if (response.statusCode == 200) {
        if (jsonResponse["status"] == "SUCCESS") {
          var user_id = jsonResponse["user_id"].toString();
          var name = jsonResponse["name"];
          var mobile_no = jsonResponse["mobile_no"].toString();
          var email = jsonResponse["email"];
          var profile = jsonResponse["pofile"] ?? " ";

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLoggedIn', true);
          await prefs.setString('user_id', user_id);
          await prefs.setString('name', name);
          await prefs.setString('mobile_no', mobile_no);
          await prefs.setString('email', email);
          await prefs.setString('pofile', profile);

          showToast("Sign In Successful");
          controller.pause();
         Get.to(() => BluetoothPair());
          //Get.to(() => AlertDialogScreen());

        } else {
          setState(() {
            setLoading(false);
          });
          showToast("OTP Mismatch. Please try again.");
        }
      } else {
        showToast("Request failed with status: ${response.statusCode}.");
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> otpTimeout({required String mobileno}) async {
    final String url = '$root/otp_timeout';

    final Map<String, String> userData = {
      'mobile_no': mobileno,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: userData,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('OTP Timeout Response: $jsonResponse');
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> otpResend({
    required String mobileno,
    required StateSetter setState,
    required String newotp,
    required Function(bool) resend,
    required CountdownController controller,
  }) async {
    final String url = '$root/login_resend_otp';
    final Map<String, String> userData = {
      'mobile_no': mobileno,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: userData,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('OTP Resend Response: $jsonResponse');

        if (jsonResponse["status"] == "SUCCESS") {
          setState(() {
            newotp = (jsonResponse['data']['mobile_otp'].toString());
            resend(false);
          });

          controller.restart(); // Restart the countdown timer
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}



showToast(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

