import 'dart:convert';
import 'package:azpire_new/View/edit_profile.dart';
import 'package:azpire_new/Controller/editPhone_controller.dart';
import 'package:azpire_new/utils/appimages.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:azpire_new/widgets/custom_button/My_Button.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:azpire_new/root/root.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import '../../utils/apptext.dart';
import '../../widgets/custompincodetextfield.dart';

class edit_phone_number extends StatefulWidget {
  var mobnum, user_id;
   edit_phone_number({super.key, required this.mobnum, required this.user_id});

  @override
  State<edit_phone_number> createState() => _edit_phone_numberState();
}

class _edit_phone_numberState extends State<edit_phone_number> {
  bool isLoading_1 = false;
  TextEditingController mobnumController = TextEditingController();
  final CountdownController _controller = CountdownController(autoStart: false);
  final EditPhoneController _editphonecontroller = EditPhoneController();
  bool verify = false;
  String enteredOtp = '';
  bool resend = false;
  bool isLoading = false;
  bool showbutton = false;
  final _formKey = GlobalKey<FormState>();
  String? newotp;
  String? completePhoneNumber = '';
  bool _isPhoneValid = true;
  void initState() {
    // mobnumController.text = widget.mobnum;
  }

  String formatTime(double time) {
    int minutes = (time / 60).floor();
    int seconds = (time % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(
        2, '0')}';
  }


  // Future<void> verify_mob() async {
  //   print('PHONE' + widget.mobnum);
  //   print("Phone number : ${completePhoneNumber.toString()}");
  //   setState(() {
  //     isLoading_1 = true;
  //   });
  //   final String url = '$root/update_mobile_email';
  //
  //   final Map<String, String> userData = {
  //     'mobile_no': completePhoneNumber.toString(),
  //     'user_id': "102"
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
  //
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //       print(response.body);
  //       if (jsonResponse["status"] == "SUCCESS") {
  //         setState(() {
  //           // showbutton == true;
  //          verify = true;
  //           _controller.restart();
  //           isLoading_1 = false;
  //         });
  //         showToast("OTP Sent Successfully");
  //         //verify == false ;
  //       } else {
  //         showToast("Mobile number already exists");
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

  Future<void> verify_mob() async {

    await _editphonecontroller.verify_mob(
      context: context,
      setState: setState,
      completePhoneNumber: completePhoneNumber.toString(),
      mobnum: widget.mobnum,
      isLoading: isLoading,
      isLoading_1: isLoading_1,
      verify: verify = true,
      controller: _controller,
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

  void _onTextChanged(String value) {
    setState(() {
      verify = false;
    });
  }

  Future<void> verify_submit() async {
    print(completePhoneNumber.toString());
    print(enteredOtp.toString());
    setState(() {
      isLoading_1 = true;
    });
    final String url = '$root/updt_mobmail_otp_verify';
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    final Map<String, String> userData = {
      'mobile_no': completePhoneNumber.toString(),
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
          showToast("Mobile Number Updated Successfully");
          Get.to(EditProfile());
          // setState(() {
          //   isLoading_1 = false;
          //   verify = true;
          // });

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

  // Future<void> verify_submit() async {
  //
  //   await _phoneVerification.verify_submit(
  //     context: context,
  //     setState: setState,
  //     completePhoneNumber: completePhoneNumber.toString(),
  //     enteredOtp: enteredOtp,
  //     isLoading: isLoading,
  //     isLoading_1: isLoading_1,
  //     verify: verify,
  //   );
  //
  // }



  // Future<void> otp_timeout() async {
  //   final String url = '$root/update_otp_timeout';
  //
  //   final Map<String, String> userData = {
  //     'mobile_no': completePhoneNumber.toString(),
  //     'user_id':"102"
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

  Future<void> otp_timeout() async{

    await _editphonecontroller.otp_timeout(
      completePhoneNumber: completePhoneNumber.toString(),
    );
  }


  // Future<void> otp_resend() async {
  //   print('Resendno'+completePhoneNumber.toString());
  //   print('Resendno2'+ widget.mobnum);
  //   final String url = '$root/update_resend_otp';
  //   final Map<String, String> userData = {
  //     'mobile_no': completePhoneNumber.toString(),
  //     'user_id':"102"
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

  Future<void> otp_resend() async{

    await _editphonecontroller.otp_resend(
      context: context,
      setState: setState,
      completePhoneNumber: completePhoneNumber.toString(),
      mobnum: widget.mobnum,
      controller: _controller,
      newotp: newotp.toString(),
      resend: resend
    );
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
          style: TextStyle(
            color: Color(0xFF365c7f),
            fontSize: 17,
          ),
        ),
        backgroundColor: Color(0xFFffffff),

      ),
      body:
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IntlPhoneField(
                     // controller: mobnumController,
                      keyboardType:TextInputType. phone,
                      flagsButtonPadding: const EdgeInsets.all(8),
                      dropdownIconPosition: IconPosition.trailing,
                      dropdownIcon: Icon(
                        Icons.arrow_drop_down, // Replace with your preferred icon
                        size: 15.0, // Adjust the size of the dropdown icon
                        color: Colors.black, // Optional: Adjust the color
                      ),
                      decoration:  InputDecoration(
                        border: UnderlineInputBorder(),
                        counterText: '',
                        errorText: _isPhoneValid == true? null : 'Please enter a valid phone number',// Hides the default counter
                      ),
                      initialCountryCode: 'US',
                      autovalidateMode: AutovalidateMode.disabled,
                      onChanged: (phone) {
                        _onTextChanged(phone.completeNumber);
                        setState(() {
                          completePhoneNumber = phone.completeNumber;
                          isLoading_1 = false;
                          _isPhoneValid = phone.completeNumber.length >= 10;
                        });
                        print('Phone Number: $completePhoneNumber');

                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // Allow only digits
                      ],
                    ),
                    SizedBox(height: 20,),
                    verify == false ?
                    InkWell(
                      onTap: () {
                        if (completePhoneNumber == null || completePhoneNumber!.length < 10) {
                          setState(() {
                            _isPhoneValid = false;
                          });
                          return;
                        }
                        print("Mobile Number $completePhoneNumber");
                        if (completePhoneNumber.toString().isEmpty) {
                          showToast("Mobile Number is Empty");
                        } else {
                          verify_mob();
                        }
                      },
                      child: isLoading_1 == true ? Center(
                        child: CircularProgressIndicator(),) : Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.blue
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 4, 15, 4),
                          child: Text(
                            "Verify",
                            style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    )
                        :
                    InkWell(
                      onTap: () {
                      },
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
                        height: 50,
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
    );
  }

}