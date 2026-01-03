
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import '../View/Dashboard_screen.dart';
import '../root/root.dart';

class EmailLoginController {

  Future<Map<String, dynamic>> emailLogin(String email) async {
    final String url = '$root/email_login_resend_otp';

    try {
      print("email1");
      final response = await http.post(
        Uri.parse(url),
        body: {'email': email})
          .timeout(Duration(seconds: 10),
        onTimeout: () {
          // Just show toast, no need to throw
          showCustomToast("Time Out");
          // Return a dummy response so code continues
          throw TimeoutException("Request Timeout");
        },
      );
      print("emailresponse:${response.body}");
      if (response.statusCode == 200) {
        print("email2");
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return {
          'success': jsonResponse['status'] == "SUCCESS",
          'data': jsonResponse['data'],
          'message': jsonResponse['status'] == "SUCCESS"
              ? "OTP sent to Email"
              : "Email not Registered"
        };
      } else {
        print("email3");
        return {
          'success': false,
          'message': 'Request failed with status: ${response.statusCode}'
        };
      }
    } catch (e) {
      print("email4");
      return {
        'success': false,
        'message': 'Error: $e'
      };
    }
  }

  void showCustomToast(String msg) {
    showToastWidget(
      _buildToastWidget(msg),
      duration: Duration(seconds: 2),
      position: kIsWeb ? ToastPosition.top : ToastPosition.bottom,
      animationCurve: kIsWeb ? Curves.easeInOut : Curves.easeIn,
      animationDuration: const Duration(milliseconds: 400),
      animationBuilder: kIsWeb ? _slideFromRight : null,
    );
  }

  Widget _buildToastWidget(String msg) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.white,
        ),
      ),
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
        begin: Offset(1.2, 0.0), // start from right off-screen
        end: Offset(0.0, 0.0),   // slide to original position
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }

}









