
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
      final response = await http.post(
        Uri.parse(url),
        body: {'email': email},
      );

      print("emailresponse:${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return {
          'success': jsonResponse['status'] == "SUCCESS",
          'data': jsonResponse['data'],
          'message': jsonResponse['status'] == "SUCCESS"
              ? "OTP sent to Email"
              : "Email not Registered"
        };
      } else {
        return {
          'success': false,
          'message': 'Request failed with status: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e'
      };
    }
  }


}









