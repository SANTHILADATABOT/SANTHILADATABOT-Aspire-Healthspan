
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../Model/register_screen_model.dart';
import '../View/signup_Mobile_otp.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter/foundation.dart';

class RegisterController{

  Future<void> registerUser({
    required BuildContext context,
    required StateSetter setState,
    required GlobalKey<FormState> formKey,
    required TextEditingController usernameController,
    required TextEditingController emailController,
    required String? completePhoneNumber,
    required Function(bool) setLoading,
    required Function(bool) setPhoneValid,
  }) async {
    if (completePhoneNumber == null || completePhoneNumber.length < 10) {
      setState(() {
        setPhoneValid(false);
      });
      return;
    }

    if (formKey.currentState!.validate()) {
      print("completePhoneNumber$completePhoneNumber");
      print("usernameController$usernameController");
      print("emailController$emailController");
      final RegisterModel user = RegisterModel(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        mobileNumber: completePhoneNumber!.trim(),
      );

      final String url = 'https://app.aspirehealthspan.ai/aspire_api/signin';

      try {
        setState(() {
          setLoading(true);
        });

        final response = await http.post(
          Uri.parse(url),
          body: user.toJson(),
        );

        if (response.statusCode == 200) {
          final RegisterResponse registerResponse =
          RegisterResponse.fromJson(json.decode(response.body));

          if (registerResponse.status == "SUCCESS") {
            String mobileOtp = registerResponse.data['mobile_otp'].toString();
            String user = usernameController.text.toString();
            String mobile = completePhoneNumber.toString();

            showToast("OTP Sent Successfully");

            Get.to(() => MobileOtpScreen(
              MobileOTP: mobileOtp,
              user: user,
              mobileno: mobile,
            ));
          } else if (registerResponse.status == "Failed") {
            showToast(registerResponse.message ?? "Unknown error");
            print('Error: ${registerResponse.message}');
          }
        } else {
          print('Request failed with status: ${response.statusCode}');
          showToast('Server error: ${response.statusCode}');
        }
      } catch (e) {
        print('Error: $e');
        showToast('An error occurred: $e');
      } finally {
        setState(() {
          setLoading(false);
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