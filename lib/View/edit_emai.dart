
import 'dart:convert';

import 'package:aspire/Controller/editEmail_controller.dart';
import 'package:aspire/utils/app_color.dart';
import 'package:aspire/utils/appimages.dart';
import 'package:aspire/utils/apptextstyle.dart';
import 'package:aspire/widgets/custom_button/My_Button.dart';
import 'package:aspire/widgets/custompincodetextfield.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:http/http.dart' as http;
import '../../root/root.dart';
import '../../utils/apptext.dart';
import 'edit_profile.dart';

class edit_email extends StatefulWidget {
  var email_id, user_id;
   edit_email({super.key,required this.email_id,required this.user_id});

  @override
  State<edit_email> createState() => _edit_emailState();
}

class _edit_emailState extends State<edit_email> {
  bool isLoading_1 = false;
  TextEditingController emailController = TextEditingController();
  final CountdownController _controller = CountdownController(autoStart: false);
  final EditEmailController _editemailcontroller = EditEmailController();
  bool verify = false;
  String enteredOtp = '';
  bool resend = false;
  bool isLoading = false;
  bool showbutton = false;
  String? newotp;

  final _formKey = GlobalKey<FormState>();

  // Email validation function using regex
  bool validateEmail(String email) {
    String emailPattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regExp = RegExp(emailPattern);
    return regExp.hasMatch(email);
  }

  String formatTime(double time) {
    int minutes = (time / 60).floor();
    int seconds = (time % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(
        2, '0')}';
  }

  // Future<void> verify_mob() async {
  //
  //   await _emailVerification.verify_email(
  //     context: context,
  //     setState: setState,
  //     emailController: emailController,
  //     controller: _controller,
  //     isLoading: isLoading,
  //     isLoading_1: isLoading_1,
  //     verify: verify = true,
  //   );
  //
  // }
  //
  // Future<void> verify_submit() async {
  //
  //   await _emailVerification.verify_submit_email(
  //     context: context,
  //     setState: setState,
  //     emailController: emailController,
  //     enteredOtp: enteredOtp,
  //     isLoading_1: isLoading_1,
  //     isLoading: isLoading,
  //   );
  //
  // }
  //
  // Future<void> otp_timeout() async{
  //
  //   await _emailVerification.otp_timeout_email(
  //     emailController: emailController,
  //   );
  //
  // }
  //
  // Future<void> otp_resend() async{
  //
  //   await _emailVerification.otp_resend_email(
  //     context: context,
  //     setState: setState,
  //     emailController: emailController,
  //     controller: _controller,
  //     newotp: newotp.toString(),
  //     resend: resend,
  //   );
  //
  // }

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

  void _onTextChanged(String value) {
    setState(() {
      verify = false;
    });
  }

  // Future<void> verify_mob() async {
  //   setState(() {
  //     isLoading_1 = true;
  //   });
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var user_id = prefs.getString('user_id') ?? "";
  //   final String url = '$root/update_mobile_email';
  //
  //   final Map<String, String> userData = {
  //     'email': emailController.text,
  //     'user_id': user_id
  //   };
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {
  //         'Content-Type': 'application/x-www-form-urlencoded',
  //       },
  //       body: userData,
  //     );
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //       if (jsonResponse["status"] == "SUCCESS") {
  //         print(response.body);
  //         setState(() {
  //          // showbutton = true;
  //           verify = true;
  //           isLoading_1 = false;
  //           _controller.restart();
  //         });
  //         showToast("OTP Sent Successfully");
  //         //_controller.pause();
  //       } else {
  //         showToast("Email already exists");
  //         print(response.body);
  //         setState(() {
  //           isLoading_1 = false;
  //           verify = false;
  //         });
  //         //showToast("User not Registered");
  //       }
  //     } else {
  //       showToast("Request failed with status: ${response.statusCode}.");
  //     }
  //   } catch (e) {
  //     showToast("Error: $e");
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  // Future<void> verify_submit() async {
  //   setState(() {
  //     isLoading_1 = true;
  //   });
  //   final String url = '$root/updt_mobmail_otp_verify';
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var user_id = prefs.getString('user_id') ?? "";
  //   final Map<String, String> userData = {
  //     'email': emailController.text,
  //     'user_id': user_id,
  //     'mobile_email_otp': enteredOtp
  //   };
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {
  //         'Content-Type': 'application/x-www-form-urlencoded',
  //       },
  //       body: userData,
  //     );
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //       if (jsonResponse["status"] == "SUCCESS") {
  //         print(response.body);
  //
  //         showToast("Email Updated Successfully");
  //         Get.to(EditProfile());
  //         // setState(() {
  //         //   isLoading_1 = false;
  //         //   verify = true;
  //         // });
  //       } else {
  //         setState(() {
  //           isLoading = false;
  //         });
  //         showToast("OTP Mismatch. Please try again.");
  //       }
  //     } else {
  //       showToast("Request failed with status: ${response.statusCode}.");
  //     }
  //   } catch (e) {
  //     showToast("Error: $e");
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }
  //
  // Future<void> otp_timeout() async {
  //   final String url = '$root/update_otp_timeout';
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var user_id = prefs.getString('user_id') ?? "";
  //   final Map<String, String> userData = {
  //     'email': emailController.text,
  //     'user_id':user_id
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
  //   print(emailController.text);
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var user_id = prefs.getString('user_id') ?? "";
  //   final String url = '$root/email_update_resend_otp';
  //   final Map<String, String> userData = {
  //     'email': emailController.text,
  //     'user_id': user_id
  //   };
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       body: userData,
  //     );
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //       print('OTP Resend Response: $jsonResponse');
  //       if (jsonResponse["status"] == "SUCCESS") {
  //         setState(() {
  //           newotp = jsonResponse['data']['mobile_otp'].toString();
  //           resend = false;
  //         });
  //
  //         // Restart the countdown timer when OTP is resent
  //         _controller.restart();
  //       }
  //     } else {
  //       print('Request failed with status: ${response.statusCode}.');
  //     }
  //   } catch (e) {
  //     print('Error:2 $e');
  //   }
  // }

  Future<void> verify_mob() async {
    setState(() => isLoading_1 = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? "";

    final result = await _editemailcontroller.verify_mob(
      email: emailController.text,
      userId: userId,
    );

    if (result['success']) {
      verify = true;
      _controller.restart();
    }

    showToast(result['message']);

    setState(() => isLoading_1 = false);
  }

  Future<void> verify_submit() async {
    setState(() => isLoading_1 = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? "";

    final result = await _editemailcontroller.verifyOtp(
      email: emailController.text,
      userId: userId,
      otp: enteredOtp,
    );

    showToast(result['message']);
    if (result['success']) {
      Get.to(EditProfile());
    }
    setState(() => isLoading_1 = false);
  }

  Future<void> otp_timeout() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? "";
    await _editemailcontroller.otpTimeout(
      email: emailController.text,
      userId: userId,
    );
  }

  Future<void> otp_resend() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? "";

    final result = await _editemailcontroller.resendOtp(
      email: emailController.text,
      userId: userId,
    );

    if (result['success']) {
      setState(() {
        newotp = result['data']['mobile_otp'].toString();
        resend = false;
      });
      _controller.restart();
    }
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
            'Edit Profile',
            style: Apptextstyle.s17wbcapp_b
        ),
        backgroundColor: Color(0xFFffffff),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.to(() => EditProfile());
          },
        ),
      ),
      body:
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 50,
                        // width: size.width*0.6,
                        child: TextFormField(
                          readOnly: false,
                          onChanged: _onTextChanged,
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an email address';
                            } else if (!RegExp(
                                r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                                .hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "Enter Your Email",
                            focusColor: Color(0xFF275176),
                            hintStyle: TextStyle(
                                color: Colors.grey.shade500, fontSize: 14),
                          ),
                        ),
                      ),

                      SizedBox(height: 20,),
                      verify == false ?
                      InkWell(
                        onTap: () {
                          if (emailController.text.isEmpty) {
                            showToast("Email is Empty");
                          } else {
                            verify_mob();
                          }
                        },
                        child: isLoading_1 == true ? Center(
                          child: CircularProgressIndicator(),) : Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: AppColors.button
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
                            child: Text(
                                AppText.verify,
                                style: Apptextstyle.s16wbcW
                            ),
                          ),
                        ),
                      ) :
                      InkWell(
                        onTap: () {},
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(15, 4, 15, 4),
                            child: Text(
                              " ",
                              style: TextStyle(
                                  fontFamily: "Inter",
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ),
                      verify == true ?
                      Container(
                        height: size.height * 0.28,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                SizedBox(height: 20),
                                Text(
                                  AppText.verificationcode,
                                    style: Apptextstyle.s18wbcB
                                ),
                                SizedBox(height: 10),
                                Text(
                                  AppText.emailsentotp,
                                    style: Apptextstyle.s14wncLb
                                ),
                                SizedBox(height: 20),
                                CustomPinCodeField(
                                  appContext: context,
                                  onChanged: (value) {
                                    print(value);
                                  },
                                  onCompleted: (value) {
                                    setState(() {
                                      enteredOtp = value;
                                    });
                                    print(value);
                                  },
                                ),
                                SizedBox(height: 30),

                              ],
                            ),
                          ),
                        ),
                      ) : Container(height: size.height * 0.28,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          resend == true ?
                          GestureDetector(
                            onTap: () {
                              if (verify == true) {
                                if (resend) {
                                  otp_resend();
                                }
                              }
                            },
                            child: Text(
                              AppText.resendmobileotp,
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 14.0,
                                color: verify == true ? Colors.blue : Colors
                                    .white,
                              ),
                            ),
                          ) :
                          SizedBox(),
                          Countdown(
                            controller: _controller,
                            seconds: 60,
                            build: (BuildContext context, double time) =>
                                Text(

                                  formatTime(time),
                                  style: TextStyle(fontFamily: "Inter",
                                      fontSize: 14,
                                      color: verify == true
                                          ? Colors.black
                                          : Colors.white),
                                ),
                            interval: Duration(seconds: 1),
                            onFinished: () {
                              setState(() {
                                resend = true;
                              });
                              otp_timeout();
                              print('Timer is done!');
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 60),
                      verify == true ?
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50),
                        child: isLoading == false ? MyButton(
                          press: () async {
                            // otpverify();
                            verify_submit();
                          },
                          text: AppText.SUBMIT,
                        ) : Center(child: Image.asset(
                          Appimages.applogo,
                          height: size.height * 0.07,
                          fit: BoxFit.contain,
                        ),),
                      ) : SizedBox()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
      duration: Duration(seconds: 2),
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
        begin: Offset(1.2, 0.0), // start from right off-screen
        end: Offset(0.0, 0.0), // slide to original position
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }
}