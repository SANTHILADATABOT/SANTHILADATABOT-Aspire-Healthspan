import 'dart:convert';
import 'package:azpire_new/Controller/login_otp_controller.dart';
import 'package:azpire_new/utils/app_color.dart';
import 'package:azpire_new/utils/appimages.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:azpire_new/widgets/custom_button/My_Button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final String userType;
  MobileOtpScreen({super.key, required this.MobileOTP, required this.user, required this.mobileno,required this.userType});

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
  final FocusNode _focusNode = FocusNode();


  @override
  void initState(){
    print("User: ${widget.user}");
    print("mobileno: ${widget.mobileno}");
    print("User Type: ${widget.userType}");
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

  String formatTime(double time) {
    int minutes = (time / 60).floor();
    int seconds = (time % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> otpverify() async {

    // final prefs = await SharedPreferences.getInstance();
    // final userType = prefs.getString('user_type') ?? 'Unknown';
    // print("Retrieved user_type : $userType");



    setState(() {
      isLoading = true;
    });

    await otpController.otpVerify(
     //context: context,
      //setState: setState,
      enteredOtp: enteredOtp,
      newOtp: newotp,
      user: widget.user,
      mobileno: widget.mobileno,
      mobileOTP: widget.MobileOTP,
     // setLoading: (value) => setState(() => isLoading = value),
      controller: _controller,
      userType: widget.userType
    );



    setState(() {
      isLoading = false;
    });

  }

  Future<void> otp_timeout() async{
    await otpController.otpTimeout(mobileno: widget.mobileno);
  }



  Future<void> otp_resend() async{
    setState(() {
      isLoading = false;
    });
    await otpController.otpResend(
      mobileno: widget.mobileno,
      newotp: newotp.toString(),
      controller: _controller,
    );
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
                    AppText.sentotp,
                    style: Apptextstyle.s14wncLb
                ),
                SizedBox(height: 20),
                //Wrap OTP field in RawKeyboardListener for web/desktop
                if (kIsWeb ||
                    defaultTargetPlatform == TargetPlatform.windows ||
                    defaultTargetPlatform == TargetPlatform.macOS ||
                    defaultTargetPlatform == TargetPlatform.linux)
                  RawKeyboardListener(
                    focusNode: _focusNode,
                    autofocus: true,
                    onKey: (event) {
                      if (event is RawKeyDownEvent &&
                          (event.logicalKey == LogicalKeyboardKey.enter ||
                              event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
                        if (enteredOtp.isNotEmpty) {
                          otpverify(); // ✅ trigger submit
                        }
                      }
                    },
                    child: CustomPinCodeField(
                      appContext: context,
                      onChanged: (value) {
                        setState(() {
                          enteredOtp = value; // keep updating OTP
                        });
                      },
                      onCompleted: (value) {
                        setState(() {
                          enteredOtp = value;
                        });
                        print("OTP completed: $value");
                      },
                    ),
                  )
                else
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
                          setState(() {
                            resend = false;
                          });
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
                  height: size.height*0.07,
                  fit: BoxFit.contain,
                ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }






}


