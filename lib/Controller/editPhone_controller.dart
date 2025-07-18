
import 'dart:convert';
import 'package:azpire_new/View/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:timer_count_down/timer_controller.dart';
import '../root/root.dart';

class EditPhoneController {

    Future<void> verify_mob({
    required BuildContext context,
    required StateSetter setState,
    required String completePhoneNumber,
    required String mobnum,
    required bool isLoading_1,
    required bool isLoading,
    required bool verify,
    required CountdownController controller,
  }) async {
    print('PHONE' + mobnum);
    print("Phone number : ${completePhoneNumber.toString()}");

    setState(() {
      isLoading_1 = true;
    });

    final String url = '$root/update_mobile_email';

    final Map<String, String> userData = {
      'mobile_no': completePhoneNumber.toString(),
      'user_id': "102"
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
        print(response.body);

        if (jsonResponse["status"] == "SUCCESS") {
          setState(() {
            verify = true;
            controller.restart();
            isLoading_1 = false;
          });
          showToast("OTP Sent Successfully");
        } else {
          showToast("Mobile number already exists");
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

    Future<void> otp_timeout({
      required String completePhoneNumber,
    }) async {
      final String url = '$root/update_otp_timeout';

      final Map<String, String> userData = {
        'mobile_no': completePhoneNumber.toString(),
        'user_id': "102"
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
      required CountdownController controller,
      required String newotp,
      required bool resend,
    }) async {
      print('Resendno' + completePhoneNumber);
      print('Resendno2' + mobnum);

      final String url = '$root/update_resend_otp';

      final Map<String, String> userData = {
        'mobile_no': completePhoneNumber.toString(),
        'user_id': "102"
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
              newotp=jsonResponse['data']['mobile_otp'].toString();
              resend=false;
            });

            controller.restart(); // Restart countdown
          }
        } else {
          print('Request failed with status: ${response.statusCode}.');
        }
      } catch (e) {
        print('Error:2 $e');
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

      final Map<String, String> userData = {
        'mobile_no': completePhoneNumber,
        'user_id': "102",
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

showToast(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
