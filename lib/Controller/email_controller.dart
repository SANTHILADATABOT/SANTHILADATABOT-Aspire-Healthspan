import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_count_down/timer_controller.dart';

import '../View/Dashboard_screen.dart';
import '../email_screen/verification_otp.dart';
import '../root/root.dart';

class EmailController {

  Future<void> emaillogin({
  required BuildContext context,
  required StateSetter setState,
  required GlobalKey<FormState> formKey,
  required TextEditingController emailcontroller,
  required Function(bool) isLoading,
  required String emailOtp,email,
  required String user,
}) async {
    setState(() {
      isLoading(true);
    });
    final String url = '$root/email_login_resend_otp';

    final Map<String, String> userData = {
      'email': emailcontroller.text,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: userData,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print("email otp response$jsonResponse");
        if(jsonResponse['status'] == "SUCCESS"){
           emailOtp = jsonResponse['data']['email_otp'].toString()  ;
           email = jsonResponse['data']["email"];
          showToast("OTP sent to Email");
          Get.to(() => VerificationOtpScreen(
            email: email!,
            emailOtp: emailOtp,
          ));
        } else {
          showToast("Email not Registered");
          setState(() {
            isLoading(false);
          });
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
        setState(() {
          isLoading(false);
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading(false);
      });
    }
  }

  //Email OTP Verify
  Future<void> otpverify({
    required BuildContext context,
    required StateSetter setState,
    required String email,
    required String enteredOtp,
    required Function(bool) setLoading,
    required CountdownController controller,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? _registeredDevice;
    var token = prefs.getString('token');
    print('FCM Token: ${token == null ? " " : token}');
    print("New OTP: $enteredOtp");
    print("Email: $email");

    final String url = '$root/email_otp_verified';

    final Map<String, String> userData = {
      'email': email,
      'email_otp': enteredOtp,
      'access_token': token ?? " ",
    };

    try {
      setState(() {
        setLoading(true);
      });

      final response = await http.post(
        Uri.parse(url),
        body: userData,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('Full response body: ${response.body}');

        if (jsonResponse["status"] == "SUCCESS") {
          var user_id = jsonResponse["user_id"].toString();
          var name = jsonResponse["name"];
          var mobile_no = jsonResponse["mobile_no"].toString();
          var email = jsonResponse["email"];
          var pofile = jsonResponse["pofile"] ?? " ";

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLoggedIn', true);
          await prefs.setString('user_id', user_id);
          await prefs.setString('name', name);
          await prefs.setString('mobile_no', mobile_no);
          await prefs.setString('email', email);
          await prefs.setString('pofile', pofile);

          showToast("Sign In Successful");
          controller.pause();

          setState(() {
            setLoading(false);
          });

          Get.to(() => DashboardScreen(deviceID:_registeredDevice!,));

        } else {
          setState(() {
            setLoading(false);
          });
          showToast("OTP Mismatch. Please try again.");
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
        setState(() {
          setLoading(false);
        });
      }
    } catch (e) {
      print('Error:1 $e');
      showToast("An error occurred. Please try again.");
    }
  }

  //Email OTP Timeout
  Future<void> otpTimeout({required String email}) async {
    final String url = '$root/otp_timeout';

    final Map<String, String> userData = {
      'email': email,
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

  //Email Resend OTP
  Future<void> otp_resend(
  {
    required String email,
    required StateSetter setState,
    required String newotp,
    required Function(bool)resend,
    required CountdownController controller,
}) async {

    final String url = '$root/email_login_resend_otp';
    final Map<String, String> userData = {
      'email': email,
    };
    try {
      final response = await http.post(
        Uri.parse(url),
        body: userData,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('OTP Resend Response: $jsonResponse');
        if(jsonResponse["status"] == "SUCCESS"){
          setState(() {
            newotp = jsonResponse['data']['email_otp'].toString();
            resend(false);
          });

          // Restart the countdown timer when OTP is resent
          controller.restart();
        }

      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Error:2 $e');
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
      fontSize: 16.0
  );

}



