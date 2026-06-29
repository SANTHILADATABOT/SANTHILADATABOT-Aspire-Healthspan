

import 'dart:convert';

import 'package:azpire_new/root/root.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Emailotpcontroller {

  // Future<Map<String, dynamic>> verifyEmailOtp({
  //   required String email,
  //   required String enteredOtp,
  //   required String? fcmToken,
  // }) async {
  //
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   var user_id = prefs.getString('user_id') ?? "";
  //
  //   final String url = '$root/email_otp_verified';
  //
  //   final Map<String, String> userData = {
  //     'email': email,
  //     'email_otp': enteredOtp,
  //     "access_token": fcmToken ?? " ",
  //     'user_id': user_id
  //   };
  //
  //   print("user_id:$user_id");
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       body: userData,
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final jsonResponse = json.decode(response.body);
  //       return {
  //         'success': jsonResponse['status'] == "SUCCESS",
  //         'data': jsonResponse,
  //         'message': jsonResponse['status'] == "SUCCESS"
  //             ? "Sign In Successful"
  //             : "OTP Mismatch. Please try again."
  //       };
  //     } else {
  //       return {
  //         'success': false,
  //         'message': 'Request failed with status: ${response.statusCode}'
  //       };
  //     }
  //   } catch (e) {
  //     return {'success': false, 'message': 'Error: $e'};
  //   }
  // }

  Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String enteredOtp,
    required String? fcmToken,
    required String usertype

  }) async {

    // 🚨 HARD STOP — DO NOT CALL API
    if (enteredOtp.trim().isEmpty) {
      return {
        'success': false,
        'message': 'Please enter OTP',
      };
    }

    if (enteredOtp.length != 5) {
      return {
        'success': false,
        'message': 'Please enter a valid OTP',
      };
    }

    final prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";


    final String url = '$root/email_otp_verified';

    final Map<String, String> userData = {
      'email': email,
      'email_otp': enteredOtp,
      'access_token': fcmToken ?? '',
      'user_id': user_id,
      "user_type": usertype
    };

    try {
      final response = await http.post(Uri.parse(url), body: userData);

      print("email_login_verify:${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print("email_login_verify1:$jsonResponse");
        return {
          'success': jsonResponse['status'] == "SUCCESS",
          'data': jsonResponse,
          'message': jsonResponse['status'] == "SUCCESS"
              ? "Sign In Successful"
              : "OTP Mismatch. Please try again.",
        };
      } else {
        return {
          'success': false,
          'message': 'Request failed with status: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
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

   }