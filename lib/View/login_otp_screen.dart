import 'dart:convert';
import 'package:azpire_new/Controller/login_otp_controller.dart';
import 'package:azpire_new/View/bluetoothscreen.dart';
import 'package:azpire_new/root/root.dart';
import 'package:azpire_new/utils/app_color.dart';
import 'package:azpire_new/utils/appimages.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:azpire_new/widgets/custom_button/My_Button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:flutter/cupertino.dart';
import '../utils/apptext.dart';
import '../widgets/custompincodetextfield.dart';

class MobileOtpScreen extends StatefulWidget {
  final String MobileOTP;
  final String mobileno;
  final String user;
  MobileOtpScreen({super.key, required this.MobileOTP, required this.user, required this.mobileno});

  @override
  State<MobileOtpScreen> createState() => _MobileOtpScreenState();
}

class _MobileOtpScreenState extends State<MobileOtpScreen> {
  final CountdownController _controller = CountdownController(autoStart: true);
  //final ApiService _apiService = ApiService();
  bool resend = false;
  String enteredOtp = '';
  String? newotp;
  bool isLoading = false;
  final LoginOtpController otpcontroller = LoginOtpController();

  @override
  void initState(){
    print("User: ${widget.user}");
    print("mobileno: ${widget.mobileno}");
  }


  Future<void> otpverify() async {


    await otpcontroller.otpVerify(
      context: context,
      setState: setState,
      mobileno: widget.mobileno,
      enteredOtp: enteredOtp,
      setLoading: (value) => setState(() => isLoading = value),
      controller: _controller,
      user: '',
      mobileOTP: '',
    );


    // await _apiService.otpVerify(
    //   context: context,
    //   setState: setState,
    //   mobileno: widget.mobileno,
    //   enteredOtp: enteredOtp,
    //   controller: _controller,
    //   setLoading: (value) => setState(() => isLoading = value),
    // );


  }

  Future<void> otp_timeout() async{

    await otpcontroller.otpTimeout(mobileno: widget.mobileno);

  }

  Future<void> otp_resend() async{

    await otpcontroller.otpResend(
      mobileno: widget.mobileno,
      setState: setState,
      newotp: newotp.toString(),
      resend: (bool loading) {
        setState(() {
          isLoading = loading;
        });
      },
      controller: _controller,
    );
  }

  String formatTime(double time) {
    int minutes = (time / 60).floor();
    int seconds = (time % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.White,
      body: SingleChildScrollView(
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center vertically
              crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
              mainAxisSize: MainAxisSize.min, // Shrinks to fit content
              children: [
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.arrow_back, size: 18),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  AppText.verificationcode,
                  style: Apptextstyle.s18wbcB,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  AppText.mobilesentotp,
                  style: Apptextstyle.s14wncLb,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
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
                      child: Text(
                        AppText.resendmobileotp,
                        style: Apptextstyle.s14wncblue,
                      ),
                    )
                        : const SizedBox(),
                    Countdown(
                      controller: _controller,
                      seconds: 60,
                      build: (BuildContext context, double time) => Text(
                        formatTime(time),
                        style: Apptextstyle.s14wncB,
                      ),
                      interval: const Duration(seconds: 1),
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
                const SizedBox(height: 60),
                isLoading == false
                    ? MyButton(
                  press: () async {
                    otpverify();
                  },
                  text: AppText.SUBMIT,
                )
                    : Center(
                  child: Image.asset(
                    Appimages.applogo,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),

      ),
    );

    }

  }



