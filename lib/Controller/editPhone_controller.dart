
import 'dart:convert';
import 'package:aspire/View/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_count_down/timer_controller.dart';
import '../root/root.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb

class EditPhoneController {

  Future<bool> verify_mob({
    required BuildContext context,
    required String completePhoneNumber,
    required String mobnum,
    required CountdownController controller,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    final String url = '$root/update_mobile_email';

    final Map<String, String> userData = {
      'mobile_no': completePhoneNumber,
      'user_id': user_id
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: userData,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse["status"] == "SUCCESS") {
          controller.restart();
          showToast("OTP Sent Successfully");
          return true;
        } else {
          showToast("Mobile number already exists");
          return false;
        }
      } else {
        showToast("Request failed with status: ${response.statusCode}.");
        return false;
      }
    } catch (e) {
      showToast("Error: $e");
      return false;
    }
  }


  Future<void> otp_timeout({
    required String completePhoneNumber,
  }) async {
    final String url = '$root/update_otp_timeout';
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    final Map<String, String> userData = {
      'mobile_no': completePhoneNumber.toString(),
      'user_id': user_id
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
      print('Error:3 $e');
    }
  }

  Future<void> otp_resend({
    required BuildContext context,
    required StateSetter setState,
    required String completePhoneNumber,
    required String mobnum,
    required String newotp,
    required bool resend,
    required CountdownController controller,
  }) async {
    print('Resendno: $completePhoneNumber');
    print('Resendno2: $mobnum');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    final String url = '$root/update_resend_otp';

    final Map<String, String> userData = {
      'mobile_no': completePhoneNumber.toString(),
      'user_id': user_id,
    };

    print("userData:$userData");

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
            newotp = jsonResponse['data']['mobile_otp'].toString(); // now updates widget state
            resend = false; // now updates widget state
          });

          controller.restart(); // ✅ This will now work
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  Future<void> verify_submit({
    required BuildContext context,
    required StateSetter setState,
    required String completePhoneNumber,
    required String enteredOtp,
    required bool isLoading,
    required bool isLoading_1,
    required bool verify,
  }) async {
    print(completePhoneNumber.toString());
    print(enteredOtp.toString());

    setState(() {
      isLoading_1 = true;
    });

    final String url = '$root/updt_mobmail_otp_verify';
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    final Map<String, String> userData = {
      'mobile_no': completePhoneNumber,
      'user_id': user_id,
      'mobile_email_otp': enteredOtp
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: userData,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse["status"] == "SUCCESS") {
          print(response.body);
          showToast("Mobile Number Updated Successfully");
          Get.to(EditProfile());
          setState(() {
            isLoading_1 = false;
            verify = true;
          });
        } else {
          print("Error:1" + response.body);
          setState(() {
            isLoading = false;
          });
          showToast("OTP Mismatch. Please try again.");
        }
      } else {
        showToast("Request failed with status: ${response.statusCode}.");
      }
    } catch (e) {
      showToast("Error:2 $e");
    } finally {
      setState(() {
        isLoading = false;
      });
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
      begin: Offset(1.2, 0.0), // start from right off-screen
      end: Offset(0.0, 0.0),   // slide to original position
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
