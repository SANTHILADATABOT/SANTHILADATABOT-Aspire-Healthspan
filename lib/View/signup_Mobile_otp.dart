import 'dart:convert';
import 'package:azpire_new/Controller/login_otp_controller.dart';
import 'package:azpire_new/utils/app_color.dart';
import 'package:azpire_new/utils/appimages.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:azpire_new/widgets/custom_button/My_Button.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:flutter/cupertino.dart';
import 'package:azpire_new/View/Dashboard_screen.dart';
import 'package:http/http.dart' as http;
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
  bool resend = false;
  //final ApiService _apiService = ApiService();
  final LoginOtpController otpController = LoginOtpController();
  String enteredOtp = '';
  String? newotp;
  bool isLoading = false;
  @override
  void initState(){
    print("User: ${widget.user}");
    print("mobileno: ${widget.mobileno}");
  }

  String formatTime(double time) {
    int minutes = (time / 60).floor();
    int seconds = (time % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> otpverify() async {
    // await _apiService.otpRverify(
    //     context: context,
    //     setState: setState,
    //     enteredOtp: enteredOtp,
    //     newotp: newotp,
    //     user: widget.user,
    //     mobileno: widget.mobileno,
    //     mobileOTP: widget.MobileOTP,
    //     isLoading: (value) => setState(() => isLoading = value),
    //     controller: _controller);

    await otpController.otpVerify(
      context: context,
      setState: setState,
      enteredOtp: enteredOtp,
      newOtp: newotp,
      user: widget.user,
      mobileno: widget.mobileno,
      mobileOTP: widget.MobileOTP,
      setLoading: (value) => setState(() => isLoading = value),
      controller: _controller,
    );
  }

  Future<void> otp_timeout() async{
    await otpController.otpTimeout(mobileno: widget.mobileno);
  }

  Future<void> otp_resend() async{
    await otpController.otpResend(
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.White,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30),
                InkWell(
                  onTap: () {
                    Get.back();
                    // Navigator.of(context).pop();
                  },
                  child: Icon(Icons.arrow_back,size: 18,),
                ),
                SizedBox(height: 30),
                Text(
                  AppText.verificationcode,
                  style:Apptextstyle.s18wbcB
                ),
                SizedBox(height: 10),
                Text(
                  AppText.mobilesentotp,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    resend == true ?
                    GestureDetector(
                      onTap: () {
                        if (resend) {
                          otp_resend();
                        }
                      },
                      child: Text(
                       AppText.resendmobileotp,
                        style: Apptextstyle.  s14wncblue
                      ),
                    ) :
                    SizedBox(),
                    Countdown(
                      controller: _controller,
                      seconds: 60,
                      build: (BuildContext context, double time) => Text(
                        formatTime(time),
                        style: Apptextstyle.s14wncB,
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
                isLoading == false ? MyButton(
                  press: () async {
                    otpverify();
                  },
                  text: AppText.SUBMIT,
                ) : Center(child: Image.asset(
                  Appimages.applogo,
                  height: 50,
                  fit: BoxFit.contain,
                ),),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

