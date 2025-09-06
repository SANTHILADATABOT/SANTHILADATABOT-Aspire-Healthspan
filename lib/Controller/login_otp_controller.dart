


import 'dart:convert';
import 'package:azpire_new/View/Dashboard_screen.dart';
import 'package:azpire_new/View/bluetoothscreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:oktoast/oktoast.dart';
import '../root/root.dart';

class LoginOtpController {

  // Future<void> otpVerify({
  //   required BuildContext context,
  //   required StateSetter setState,
  //   required String? mobileno,
  //   required String? enteredOtp,
  //   required Function(bool) setLoading,
  //   required CountdownController controller, String? newOtp, required String user, required String mobileOTP,
  // }) async {
  //   // final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   // var token = prefs.getString('token');
  //   // String? _registeredDevice;
  //   // print('FCM Token: ${token == null ? " " : token}');
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var token = prefs.getString('token');
  //   print('OTP screen token read: $token');
  //
  //   setState(() {
  //     setLoading(true);
  //   });
  //
  //   final String url = '$root/mobile_otp_verified';
  //   print("User: $mobileno");
  //   print("Entered OTP: $enteredOtp");
  //
  //   final Map<String, String> userData = {
  //     'mobile_no': mobileno ?? '',
  //     'mobile_otp': enteredOtp ?? '',
  //     //"access_token": token ?? "",
  //   };
  //
  //
  //
  //   try {
  //     final response = await http.post(
  //         Uri.parse(url),
  //         headers: {
  //           'Content-Type': 'application/x-www-form-urlencoded',
  //         },
  //         body: userData);
  //
  //     print("SignupResponse Status Code: ${response.statusCode}");
  //     print("SignupResponse Headers: ${response.headers}");
  //     print("SignupResponse Body: ${response.body}");
  //     print("userData:$userData");
  //
  //     final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //     //print("Response:$jsonResponse");
  //
  //     if (response.statusCode == 200) {
  //       print("SignupResponse1$response");
  //       if (jsonResponse["status"] == "SUCCESS") {
  //         print("SignupResponse2$jsonResponse");
  //         var user_id = jsonResponse["user_id"].toString();
  //         var name = jsonResponse["name"];
  //         var mobile_no = jsonResponse["mobile_no"].toString();
  //         var email = jsonResponse["email"];
  //         var profile = jsonResponse["pofile"] ?? " ";
  //
  //         final SharedPreferences prefs = await SharedPreferences.getInstance();
  //         prefs.setBool('isLoggedIn', true);
  //         await prefs.setString('user_id', user_id);
  //         await prefs.setString('name', name);
  //         await prefs.setString('mobile_no', mobile_no);
  //         await prefs.setString('email', email);
  //         await prefs.setString('pofile', profile);
  //
  //         showToast("Sign In Successful");
  //         controller.pause();
  //         await Future.delayed(Duration(milliseconds: 300)); // <- This fixes it
  //         Get.to(() => BluetoothPair());
  //         //Get.offAll(() => BluetoothPair());
  //
  //         //  showToast(context,"Sign In Successful");
  //         //  controller.pause();
  //         // Get.to(() => BluetoothPair());
  //         //Get.to(() => AlertDialogScreen());
  //
  //       } else {
  //         setState(() {
  //           setLoading(false);
  //         });
  //         showToast("OTP Mismatch. Please try again.");
  //       }
  //     } else {
  //       showToast("Request failed with status: ${response.statusCode}.");
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  Future<void> otpResend({
    required String mobileno,
    required CountdownController controller,
    required String newotp,
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

      print("otpresend Status Code: ${response.statusCode}");
      print("otpresend Headers: ${response.headers}");
      print("otpresend Body: ${response.body}");
      print("otpresend_userData:$userData");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('OTP Resend Response: $jsonResponse');

        if (jsonResponse["status"] == "SUCCESS") {
          print('OTP Resend success: $jsonResponse');

          // Update newotp manually in your screen using callback or after calling this method
          newotp = jsonResponse['data']['mobile_otp'].toString();
          print("New OTP: $newotp");

          controller.restart(); // Restart countdown
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  Future<void> otpVerify({
    required String? mobileno,
    required String? enteredOtp,
    required CountdownController controller,
    String? newOtp, required String user, required String mobileOTP,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token') ?? 'No FCM Token';
      String? _registeredDevice;
      print('FCM Token: ${token == null ? " " : token}');
      print('OTP screen token read: $token');
    final String url = '$root/mobile_otp_verified';

    final Map<String, String> userData = {
      'mobile_no': mobileno ?? '',
      'mobile_otp': enteredOtp ?? '',
      "access_token": token ?? "",
      //'user_id' :user ?? ''
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: userData,
      );

      print("login_otp_verify_response1:${response.body}");

      if (response.statusCode == 200) {
        print("Login response1:${response.body}");
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse["status"] == "SUCCESS") {
          print("login_otp_verify_success:${response.body}");
          final String user_id = jsonResponse["user_id"].toString();
          final String name = jsonResponse["name"].toString();
          final String mobile_no = jsonResponse["mobile_no"].toString();
          final String email = jsonResponse["email"].toString();
          final String profile = jsonResponse["pofile"] ?? "";

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLoggedIn', true);
          await prefs.setString('user_id', user_id);
          await prefs.setString('name', name);
          await prefs.setString('mobile_no', mobile_no);
          await prefs.setString('email', email);
          await prefs.setString('pofile', profile);


          showToast("OTP Verified Successfully");
          controller.pause();

          // Navigate to next screen
          Get.to(() => BluetoothPair());
          //Get.to(()=> DashboardScreen(deviceID: _registeredDevice!));
        } else {
          showToast("OTP Mismatch. Please try again.");
        }
      } else {
        showToast("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error during OTP verification: $e");
      showToast("Something went wrong. Please try again.");
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
}
