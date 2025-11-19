
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import '../View/signup_Mobile_otp.dart';
import '../root/root.dart';




class LoginController {
  // update as needed

  // Future<void> login({
  //   required BuildContext context,
  //   required StateSetter setState,
  //   required GlobalKey<FormState> formKey,
  //   required String? completePhoneNumber,
  //   required String? token,
  //   required Function(bool) setLoading,
  //   required Function(bool) setPhoneValid,
  //   required void Function(String) onOtpReceived,
  //   required void Function(String) onUserReceived,
  //   required void Function(String) onMobileNoReceived,
  // }) async {
  //   print(completePhoneNumber.toString());
  //   print('FCM Token: ${token == null ? " No FCM TOKEN" : token}');
  //
  //   if (completePhoneNumber == null || completePhoneNumber.length < 10) {
  //     setState(() {
  //       setPhoneValid(false);
  //     });
  //     return;
  //   }
  //
  //   if (formKey.currentState!.validate()) {
  //     final String url = '$root/login_resend_otp';
  //     final Map<String, String> userData = {
  //       'mobile_no': completePhoneNumber.toString(),
  //       "access_token": "${token ?? "No FCM TOKEN"}"
  //     };
  //
  //     try {
  //       setState(() {
  //         setLoading(true);
  //       });
  //
  //       final response = await http.post(
  //         Uri.parse(url),
  //         headers: {
  //           'Content-Type': 'application/x-www-form-urlencoded',
  //         },
  //         body: userData,
  //       );
  //
  //       if (response.statusCode == 200) {
  //         final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //         if (jsonResponse["status"] == "SUCCESS") {
  //           print(response.body);
  //
  //           onOtpReceived(jsonResponse['data']['mobile_otp'].toString());
  //           onUserReceived(jsonResponse['data']['user'].toString());
  //           onMobileNoReceived(jsonResponse['data']['mobile_no'].toString());
  //
  //           showToast("OTP Sent Successfully");
  //
  //           Get.to(() =>
  //               MobileOtpScreen(
  //                 MobileOTP: jsonResponse['data']['mobile_otp'].toString(),
  //                 user: jsonResponse['data']['user'].toString(),
  //                 mobileno: jsonResponse['data']['mobile_no'].toString(),
  //               ));
  //         } else {
  //           showToast("User not Registered");
  //         }
  //       } else {
  //         print(response.body);
  //         showToast("Invalid Username");
  //         print("Request failed with status: ${response.statusCode}.");
  //       }
  //     } catch (e) {
  //       print("Error: $e");
  //     } finally {
  //       setState(() {
  //         setLoading(false);
  //       });
  //     }
  //   }
  // }

  Future<void> login({
    required String completePhoneNumber,
    required String token,
    required String onOtpReceived,
    required String onUserReceived,
    required String onMobileNoReceived,
    required String userType
  }) async {
    final String url = '$root/login_resend_otp';

    print('FCM Token: ${token == null ? " No FCM TOKEN" : token}');

    final Map<String, String> userData = {
      'mobile_no': completePhoneNumber,
      'access_token': token,
    };

    print("userData_login:$userData");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: userData,
      );

      print("login_response: ${response.body}");

      if (response.statusCode == 200) {
        print("LoginResponse: ${response.body}");
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse["status"] == "SUCCESS") {
          print("Response: ${response.body}");

          onOtpReceived = jsonResponse['data']['mobile_otp'].toString();
          onUserReceived = jsonResponse['data']['user'].toString();
          onMobileNoReceived = jsonResponse['data']['mobile_no'].toString();
          final String responseUserType = jsonResponse['data']['user_type'].toString();

          showToast("OTP Sent Successfully");
          print("user_Type:$responseUserType");

          Get.to(() =>
              MobileOtpScreen(
                MobileOTP: onOtpReceived,
                user: onUserReceived,
                mobileno: onMobileNoReceived, userType: responseUserType,
              ));
        } else {
          showToast("User not Registered");
        }
      } else {
        print("failed_response:${response.body}");
        //showToast("Invalid Username");
        print("Request failed with status: ${response.statusCode}.");
      }
    } catch (e) {
      print("Log_Error: $e");
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
        begin: Offset(1.2, 0.0), // far right
        end: Offset(-1.2, 0.0),  // f // Slide to original position
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }





// showToast(String msg) {
//     Fluttertoast.showToast(
//       msg: msg,
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       timeInSecForIosWeb: 1,
//       backgroundColor: Colors.black,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//   }

}