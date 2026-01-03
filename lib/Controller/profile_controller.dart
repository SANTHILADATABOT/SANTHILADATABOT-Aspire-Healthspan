
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../root/root.dart';

class ProfileController {

  Future<void> Profile_Details(Function setStateCallback) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String Url = "$root/get_user_profile";
    var user_id = prefs.getString('user_id') ?? "";
    final Map<String, dynamic> userData = {
      'user_id': user_id
    };

    try {
      final response = await http.post(
        Uri.parse(Url),
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
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == "SUCCESS") {
          setStateCallback(jsonResponse);
        } else {
          throw Exception('Failed to load Profile');
        }
      }
    } catch (e) {
      print('Error fetching Profile: $e');
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
