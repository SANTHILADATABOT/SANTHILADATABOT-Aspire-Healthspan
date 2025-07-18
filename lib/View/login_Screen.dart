import 'dart:convert';
import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:azpire_new/Controller/login_controller.dart';
import 'package:azpire_new/FCM_Token/fcm_token.dart';
import 'package:azpire_new/root/root.dart';
import 'package:azpire_new/utils/app_color.dart';
import 'package:azpire_new/utils/appimages.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:azpire_new/widgets/custom_button/My_Button.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:azpire_new/widgets/custom_textfield.dart';
import 'package:azpire_new/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:azpire_new/email_screen/email_screen.dart';
import 'package:azpire_new/View/Signup_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/apptext.dart';
import '../widgets/customphone_field.dart';
import 'login_otp_screen.dart';
import 'package:get/get.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phone = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FCMToken _fcmToken = FCMToken();
  //final ApiService _apiService = ApiService();
  final LoginController _controller = LoginController();
  String? MobileOTP;
  String? mobileno;
  String? user;
  String? completePhoneNumber = '';
  bool isLoading = false;
  String? token;
  bool _isPhoneValid = true;
  late SharedPreferences prefs; // Declare SharedPreferences instance


  @override
  void initState() {
    super.initState();
    initializePreferences();
    requestNotificationPermissions();
   //checkAndRequestATT();
  }

  Future<void> checkAndRequestATT() async {
    if (!Platform.isIOS) {
      print("Not iOS, no ATT required.");
      return;
    }

    final status = await AppTrackingTransparency.trackingAuthorizationStatus;

    if (status == TrackingStatus.notDetermined) {
      // Show custom prompt first
      final userChoice = await showGeneralDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black54,
        transitionDuration: Duration(milliseconds: 300),
        pageBuilder: (context, animation1, animation2) {
          // final screenWidth = MediaQuery.of(context).size.width;
          // final screenheight = MediaQuery.of(context).size.width;
          // final dialogWidth = screenWidth * 0.70;
          // final dialogheight = screenheight * 0.70;
          return WillPopScope(
            onWillPop: () async => false,  // Prevent back button
            child: AlertDialog(
              title: Text('App Tracking Transparency'),
              content: Text("Enabling personalized fitness insights to support your wellness goals and enhance your experience."),
              actions: [
                TextButton(
                  child: Text('Ask App Not to Track',style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                  ),),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text('Allow',style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                  ),),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            ),
          );
        },
      );


      if (userChoice == true) {
        // User tapped Allow -> now show system ATT dialog
        //final systemResult = await AppTrackingTransparency.requestTrackingAuthorization();
        print("System ATT Result:$userChoice");
      } else {
        // User tapped Ask App Not to Track -> handle as denied
        print("User declined in custom prompt, not requesting ATT");
      }
    } else {
      print("ATT status already determined: $status");
    }
  }

  Future<void> initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    getToken();
  }

  Future<void> requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

  }

  Future<void> getToken() async{
    await _fcmToken.getToken(
      prefs: prefs,
      setState: setState,
      token: token,
    );

  }

  Future<void> login() async {

    await _controller.login(
      context: context,
      setState: setState,
      formKey: _formKey,
      completePhoneNumber: completePhoneNumber,
      token: token,
      setLoading: (value) => setState(() => isLoading = value),
      setPhoneValid: (value) => setState(() => _isPhoneValid = value),
      onOtpReceived: (otp) => MobileOTP = otp,
      onUserReceived: (user) => user = user,
      onMobileNoReceived: (mobileNo) => mobileNo = mobileNo,
    );

    // await _apiService.login(
    //   context: context,
    //   setState: setState,
    //   formKey: _formKey,
    //   completePhoneNumber: completePhoneNumber,
    //   token: token,
    //   setLoading: (value) => setState(() => isLoading = value),
    //   setPhoneValid: (value) => setState(() => _isPhoneValid = value),
    //   onOtpReceived: (otp) => MobileOTP = otp,
    //   onUserReceived: (usr) => user = usr,
    //   onMobileNoReceived: (mob) => mobileno = mob,
    // );



  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      bool shouldExit = await showExitConfirmationDialog(context);
      return shouldExit;
    },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: AppColors.White,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 180),
                      Image.asset(
                        Appimages.applogo,
                        height: 115,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 20),
                      Text(AppText.aspireTitle,
                          style: Apptextstyle.s20wbcothers),
                      SizedBox(height: 30),
                      Text(
                       AppText.login,
                        style: Apptextstyle.s20wbcothers
                      ),
                      SizedBox(height: 40),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Text(
                           AppText.mobileno,
                            style: Apptextstyle.s13wbcgery,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          children: [
                          CustomPhoneField(
                          initialCountryCode: AppText.country,
                          isPhoneValid: _isPhoneValid,
                          onChanged: (number, isValid) {
                            setState(() {
                              completePhoneNumber = number;
                              _isPhoneValid = isValid;
                            });
                          },
                        ),
                            SizedBox(height: 25),
                            isLoading == false
                                ? MyButton(
                              press: () {
                                login();
                              },
                              text: AppText.generateotp,
                            )
                                : Center(child: CircularProgressIndicator()),
                            SizedBox(height: 20),
                            Text(AppText.OR, style: Apptextstyle.s16wncothers),
                            SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                Get.to(() => EmailScreen());
                              },
                              child: TextTitle(
                                  title: AppText.emailsignup,
                                  color: AppColors.others),
                            ),
                            SizedBox(height: 100),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(AppText.dontHaveAccount,
                                    style: Apptextstyle.s13wbcgrey),
                                TextButton(
                                    onPressed: () {
                                      Get.to(() => SignupScreen());
                                    },
                                    child: Text(AppText.SIGNUP,
                                        style: Apptextstyle.s13wncblue))
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows a confirmation dialog when the user presses the back button.
Future<bool> showExitConfirmationDialog(BuildContext context) async {
  bool exit = false;
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppText.exitapp, style: Apptextstyle.s15wbcothers,),
        content: Text(AppText.sure_exit, style: Apptextstyle.s13wbcgrey,),
        actions: [
          InkWell(
            onTap: () {
              Navigator.of(context).pop(); // Dismiss dialog
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                child: Row(
                  children: [
                    Text(
                      AppText.cancel,
                      style: Apptextstyle.s15wbcothers
                    ),
                    SizedBox(width: 5,),
                    Icon(Icons.logout,color: Colors.white,)
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              exit = true;
              Navigator.of(context).pop(); // Dismiss dialog
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Center(
                  child: Row(
                    children: [
                      Text(
                        AppText.exit,
                        style: Apptextstyle.s15wbcothers
                      ),
                      SizedBox(width: 5,),
                      Icon(Icons.arrow_right_alt_sharp,color: Colors.white,)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
  return exit;
}

