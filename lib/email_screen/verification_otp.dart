
import 'dart:convert';
import 'package:azpire_new/Controller/EmailOTPController.dart';
import 'package:azpire_new/View/bluetoothscreen.dart';
import 'package:azpire_new/root/root.dart';
import 'package:azpire_new/Controller/email_controller.dart';
import 'package:azpire_new/utils/app_color.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:azpire_new/widgets/custom_button/My_Button.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:flutter/cupertino.dart';
import 'package:azpire_new/View/Dashboard_screen.dart';
import 'package:http/http.dart' as http;
import '../utils/appimages.dart';
import '../utils/apptext.dart';
import '../widgets/custompincodetextfield.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb

class VerificationOtpScreen extends StatefulWidget {
  var email;
  var emailOtp;
  VerificationOtpScreen({super.key, required this.email,required this.emailOtp });

  @override
  State<VerificationOtpScreen> createState() => _VerificationOtpScreenState();
}

class _VerificationOtpScreenState extends State<VerificationOtpScreen> {
  final CountdownController _controller = CountdownController(autoStart: true);
  final Emailotpcontroller _otpController = Emailotpcontroller();
  bool resend = false;

  //final ApiService apiService = ApiService();
  String enteredOtp = '';
  String? newotp;
  bool isLoading = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    print(widget.email);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kIsWeb) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }


  Future<void> otpverify() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    setState(() => isLoading = true);

    final result = await _otpController.verifyEmailOtp(
      email: widget.email,
      enteredOtp: enteredOtp,
      fcmToken: token,
    );

    if (result['success']) {
      final data = result['data'];
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('user_id', data["user_id"].toString());
      await prefs.setString('name', data["name"]);
      await prefs.setString('mobile_no', data["mobile_no"].toString());
      await prefs.setString('email', data["email"]);
      await prefs.setString('pofile', data["pofile"] ?? " ");

      showToast(result['message']);
      _controller.pause();
      Get.offAll(() => BluetoothPair());
     // Get.to(() => DashboardScreen(deviceID: ''));

    } else {
      showToast(result['message']);
    }

    setState(() => isLoading = false);
  }

  Future<void> otp_timeout() async {
    await _otpController.otpTimeout(widget.email);
  }

  Future<void> otp_resend() async {
    final result = await _otpController.resendEmailOtp(widget.email);
    if (result['success']) {
      setState(() {
        newotp = result['data']['email_otp'].toString();
        resend = false;
      });
      _controller.restart();
    }
  }


  // Future<void> otpverify() async {
  //   String? _registeredDevice;
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var token = prefs.getString('token');
  //   print('FCM Token: ${token == null ? " ":token}');
  //   setState(() {
  //     isLoading = true;
  //   });
  //   final String url = '$root/email_otp_verified';
  //   print("New OTP: $newotp");
  //   print("New OTP: ${widget.email}");
  //   print("New OTP: $enteredOtp");
  //
  //   final Map<String, String> userData = {
  //     'email': widget.email,
  //     'email_otp': enteredOtp,
  //     "access_token" : "${token == null ? " " : token}')"
  //   };
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       body: userData,
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //       print('Full response body: ${response.body}');
  //       //print('Mobile OTP Response: $jsonResponse');
  //       if(jsonResponse["status"] == "SUCCESS"){
  //         setState(() {
  //           isLoading = false;
  //         });
  //
  //         var user_id = jsonResponse["user_id"].toString();
  //         var name = jsonResponse["name"];
  //         var mobile_no = jsonResponse["mobile_no"].toString();
  //         var email = jsonResponse["email"];
  //         var pofile = jsonResponse["pofile"] ?? " ";
  //         final SharedPreferences prefs = await SharedPreferences.getInstance();
  //         prefs.setBool('isLoggedIn', true);
  //         await prefs.setString('user_id', user_id);
  //         await prefs.setString('name', name);
  //         await prefs.setString('mobile_no', mobile_no);
  //         await prefs.setString('email', email);
  //         await prefs.setString('pofile', pofile);
  //         showToast("Sign In Successful");
  //         _controller.pause();
  //         Get.to(() => DashboardScreen(deviceID:''));
  //         //Get.to(() => DashboardScreen(deviceID:_registeredDevice!));
  //
  //       }else {
  //         setState(() {
  //           isLoading = false;
  //         });
  //         showToast("OTP Mismatch. Please try again.");
  //         // ScaffoldMessenger.of(context).showSnackBar(
  //         //   SnackBar(content: Text('OTP Mismatch. Please try again.')),
  //         // );
  //       }
  //     } else {
  //       print('Request failed with status: ${response.statusCode}.');
  //     }
  //   } catch (e) {
  //     print('Error:1 $e');
  //   }
  // }
  //
  // Future<void> otp_timeout() async {
  //   final String url = '$root/otp_timeout';
  //
  //   final Map<String, String> userData = {
  //     'email': widget.email,
  //   };
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       body: userData,
  //     );
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //       print('OTP Timeout Response: $jsonResponse');
  //     } else {
  //       print('Request failed with status: ${response.statusCode}.');
  //     }
  //   } catch (e) {
  //     print('Error:3 $e');
  //   }
  // }
  //
  // Future<void> otp_resend() async {
  //
  //   final String url = '$root/email_login_resend_otp';
  //   final Map<String, String> userData = {
  //     'email': widget.email,
  //   };
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       body: userData,
  //     );
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //       print('OTP Resend Response: $jsonResponse');
  //       if(jsonResponse["status"] == "SUCCESS"){
  //         setState(() {
  //           newotp = jsonResponse['data']['email_otp'].toString();
  //           resend = false;
  //         });
  //
  //         // Restart the countdown timer when OTP is resent
  //         _controller.restart();
  //       }
  //
  //     } else {
  //       print('Request failed with status: ${response.statusCode}.');
  //     }
  //   } catch (e) {
  //     print('Error:2 $e');
  //   }
  // }

  String formatTime(double time) {
    int minutes = (time / 60).floor();
    int seconds = (time % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(
        2, '0')}';
  }


  // Future<void> otp_timeout() async{
  //
  //   await _emailService.otpTimeout(email: widget.email);
  //
  // }


  @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.white,
  //     body: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 50),
  //       child: Center(
  //         child: SingleChildScrollView(
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               SizedBox(height: 30),
  //               InkWell(
  //                 onTap: () {
  //                   Get.back();
  //                   // Navigator.of(context).pop();
  //                 },
  //                 child: Icon(Icons.arrow_back),
  //               ),
  //               SizedBox(height: 30),
  //               Text(
  //                 AppText.verificationcode,
  //                 style: Apptextstyle.s18wbcB
  //               ),
  //               SizedBox(height: 10),
  //               Text(
  //                   AppText.emailsentotp,
  //                 style: Apptextstyle.s14wncLb
  //               ),
  //               SizedBox(height: 20),
  //               CustomPinCodeField(
  //                 appContext: context,
  //                 onChanged: (value) {
  //                   print(value);
  //                 },
  //                 onCompleted: (value) {
  //                   setState(() {
  //                     enteredOtp = value;
  //                   });
  //                   print(value);
  //                 },
  //               ),
  //               SizedBox(height: 30),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   resend == true ?
  //                   GestureDetector(
  //                     onTap: () {
  //                       if (resend) {
  //                         otp_resend();
  //                       }
  //                     },
  //                     child: Text(
  //                         AppText.resendmobileotp,
  //                       style: Apptextstyle. s14wncblue
  //                     ),
  //                   ) :
  //                   SizedBox(),
  //                   Countdown(
  //                     controller: _controller,
  //                     seconds: 60,
  //                     build: (BuildContext context, double time) => Text(
  //                       formatTime(time),
  //                       style: TextStyle(fontSize: 14, fontFamily: "Inter",),
  //                     ),
  //                     interval: Duration(seconds: 1),
  //                     onFinished: () {
  //                       setState(() {
  //                         resend = true;
  //                       });
  //                       otp_timeout();
  //                       print('Timer is done!');
  //                     },
  //                   ),
  //                 ],
  //               ),
  //               SizedBox(height: 60),
  //               Padding(
  //                 padding: EdgeInsets.symmetric(horizontal: 50),
  //                 child: isLoading == false ? MyButton(
  //                   press: () async {
  //                     otpverify();
  //                   },
  //                   text: AppText.SUBMIT,
  //                 ) : Center(child: Image.asset(
  //                   Appimages.applogo,
  //                   height: 50,
  //                   fit: BoxFit.contain,
  //                 ),
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //       if (kIsWeb) {
  //     return RawKeyboardListener(
  //       focusNode: _focusNode,
  //       autofocus: true,
  //       onKey: (event) {
  //         if (event is RawKeyDownEvent &&
  //             event.logicalKey == LogicalKeyboardKey.enter &&
  //             !isLoading) {
  //           otpverify();
  //         }
  //       },
  //       child: Scaffold(
  //         backgroundColor: AppColors.White,
  //         body: content,
  //       ),
  //     );
  //   }
  //
  //   return Scaffold(
  //     backgroundColor: AppColors.White,
  //     body: content,
  //   );
  // }
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;

    // build your main content
    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              InkWell(
                onTap: () => Get.back(),
                child: const Icon(Icons.arrow_back),
              ),
              const SizedBox(height: 30),
              Text(AppText.verificationcode, style: Apptextstyle.s18wbcB),
              const SizedBox(height: 10),
              Text(AppText.emailsentotp, style: Apptextstyle.s14wncLb),
              const SizedBox(height: 20),
              // CustomPinCodeField(
              //   appContext: context,
              //   onChanged: (value) => print(value),
              //   onCompleted: (value) {
              //     setState(() => enteredOtp = value);
              //     print(value);
              //   },
              // ),
              CustomPinCodeField(
                appContext: context,
                onChanged: (value) {
                  setState(() {
                    enteredOtp = value;
                    print(value); // ✅ keep state in sync
                  });
                },
                onCompleted: (value) {
                  setState(() {
                    enteredOtp = value;
                  });
                  print(value);
                },
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  resend
                      ? GestureDetector(
                    onTap: () {
                      if (resend) {
                        otp_resend();
                      }
                    },
                    child: Text(AppText.resendmobileotp,
                        style: Apptextstyle.s14wncblue),
                  )
                      : const SizedBox(),
                  Countdown(
                    controller: _controller,
                    seconds: 60,
                    build: (_, double time) =>
                        Text(
                          formatTime(time),
                          style: const TextStyle(
                              fontSize: 14, fontFamily: "Inter"),
                        ),
                    interval: const Duration(seconds: 1),
                    onFinished: () {
                      setState(() => resend = true);
                      otp_timeout();
                      print('Timer is done!');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: !isLoading
                    ? MyButton(
                  // press: () async => otpverify(),
                  press: () async {
                    if (enteredOtp.trim().isEmpty) {
                      showToast("Please enter OTP");
                      return;
                    }

                    if (enteredOtp.length != 5) {
                      showToast("Please enter a valid OTP");
                      return;
                    }

                    otpverify();
                  },

                  text: AppText.SUBMIT,
                )
                    : Center(
                  child: Image.asset(
                    Appimages.applogo,
                    height: size.height * 0.07,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // ✅ Wrap with RawKeyboardListener only for Web
    if (kIsWeb) {
      return RawKeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        // onKey: (event) {
        //   if (event is RawKeyDownEvent &&
        //       event.logicalKey == LogicalKeyboardKey.enter &&
        //       !isLoading) {
        //     otpverify();
        //   }
        // },
        onKey: (event) {
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.enter &&
              !isLoading) {

            if (enteredOtp.trim().isEmpty) {
              showToast("Please enter OTP");
              return;
            }

            if (enteredOtp.length != 5) {
              showToast("Please enter a valid OTP");
              return;
            }

            otpverify();
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.White,
          body: content,
        ),
      );
    }

    // default (mobile)
    return Scaffold(
      backgroundColor: AppColors.White,
      body: content,
    );
  }
}


void showToast(String msg) {
  showToastWidget(
    Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 75),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16.0, color: Colors.white),
      ),
    ),
    position: kIsWeb ? ToastPosition.top : ToastPosition.bottom,
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
