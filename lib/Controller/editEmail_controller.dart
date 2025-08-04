
import 'dart:convert';
import 'package:azpire_new/View/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_count_down/timer_controller.dart';
import '../root/root.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb

class EditEmailController {

   Future<void> verify_email({
    required BuildContext context,
    required StateSetter setState,
    required TextEditingController emailController,
    required CountdownController controller,
    required bool isLoading_1,
    required bool isLoading,
    required bool verify,
  }) async {
    setState(() {
      isLoading_1 = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    final String url = '$root/update_mobile_email';

    final Map<String, String> userData = {
      'email': emailController.text,
      'user_id': user_id
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
          setState(() {
            verify = true;
            isLoading_1 = false;
            controller.restart();
          });
          showToast("OTP Sent Successfully");
        } else {
          showToast("Email already exists");
          print(response.body);
          setState(() {
            isLoading_1 = false;
            verify = false;
          });
        }
      } else {
        showToast("Request failed with status: ${response.statusCode}.");
      }
    } catch (e) {
      showToast("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

    Future<void> otp_timeout_email({
     required TextEditingController emailController,
   }) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var user_id = prefs.getString('user_id') ?? "";
     final String url = '$root/update_otp_timeout';

     final Map<String, String> userData = {
       'email': emailController.text,
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

    Future<void> otp_resend_email({
     required BuildContext context,
     required StateSetter setState,
     required TextEditingController emailController,
     required CountdownController controller,
     required String newotp,
     required bool resend,
   }) async {
     print(emailController.text);
     final SharedPreferences prefs = await SharedPreferences.getInstance();
     var user_id = prefs.getString('user_id') ?? "";
     final String url = '$root/email_update_resend_otp';

     final Map<String, String> userData = {
       'email': emailController.text,
       'user_id': user_id
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
             newotp = jsonResponse['data']['mobile_otp'].toString();
             resend = false;
           });

           controller.restart();
         }
       } else {
         print('Request failed with status: ${response.statusCode}.');
       }
     } catch (e) {
       print('Error:2 $e');
     }
   }

   Future<void> verify_submit_email({
     required BuildContext context,
     required StateSetter setState,
     required TextEditingController emailController,
     required String enteredOtp,
     required bool isLoading_1,
     required bool isLoading,
   }) async {
     setState(() {
       isLoading_1 = true;
     });
     final SharedPreferences prefs = await SharedPreferences.getInstance();
     var user_id = prefs.getString('user_id') ?? "";
     final String url = '$root/updt_mobmail_otp_verify';

     final Map<String, String> userData = {
       'email': emailController.text,
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
           showToast("Email Updated Successfully");
           Get.to(EditProfile());
           // Uncomment below if needed
           // setState(() {
           //   isLoading_1 = false;
           //   verify = true;
           // });
         } else {
           setState(() {
             isLoading = false;
           });
           showToast("OTP Mismatch. Please try again.");
         }
       } else {
         showToast("Request failed with status: ${response.statusCode}.");
       }
     } catch (e) {
       showToast("Error: $e");
     } finally {
       setState(() {
         isLoading = false;
       });
     }
   }


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