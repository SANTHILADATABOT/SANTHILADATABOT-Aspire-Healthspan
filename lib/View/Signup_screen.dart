import 'dart:convert';
import 'package:azpire_new/Controller/register_controller.dart';
import 'package:azpire_new/utils/app_color.dart';
import 'package:azpire_new/utils/appimages.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:azpire_new/widgets/custom_button/My_Button.dart';
import 'package:flutter/material.dart';
import 'package:azpire_new/widgets/custom_textfield.dart';
import 'package:azpire_new/View/login_Screen.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../utils/apptext.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  //final ApiService apiService = ApiService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  //final ApiService _apiService = ApiService();
  final _formkey = GlobalKey<FormState>();
  final RegisterController registerController = RegisterController();
  late final String user;
  bool isLoading = false;
  String? completePhoneNumber = '';
  bool _isPhoneValid = true;

  // Future<void> registerUser() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   final String url = 'https://app.aspirehealthspan.ai/aspire_api/signin';
  //   final Map<String, String> userData = {
  //     'username': _usernameController.text.trim(),
  //     'mobile_no': completePhoneNumber?.trim() ?? '',
  //     'email': _emailController.text.trim(),
  //   };
  //
  //   try {
  //     print('User Data: $userData');
  //     final response = await http.post(
  //       Uri.parse(url),
  //       body: userData,
  //     );
  //
  //     print('Response body: ${response.body}');
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //
  //       if (jsonResponse['status'] == "SUCCESS") {
  //         String mobileOtp = jsonResponse['data']['mobile_otp'].toString();
  //         print('Mobile OTP: $mobileOtp');
  //         Get.to(() => MobileOtpScreen(
  //           MobileOTP: mobileOtp,
  //           user: _usernameController.text.toString(),
  //           mobileno: completePhoneNumber.toString(),
  //         ));
  //         showToast("OTP Sent Successfully");
  //       } else if (jsonResponse['status'] == "Failed") {
  //         showToast(jsonResponse['message']); // Show specific failure message
  //         print('Error: ${jsonResponse['message']}');
  //         // Navigate to login if applicable
  //         // Get.to(() => LoginScreen());
  //       }
  //     } else {
  //       print('Request failed with status: ${response.statusCode}');
  //       showToast('Server error: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //     showToast('An error occurred: $e');
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  Future<void> registerUser() async {

    // await _apiService.registerUser(
    //   context: context,
    //   setState: setState,
    //   formKey: _formkey,
    //   usernameController: _usernameController,
    //   emailController: _emailController,
    //   completePhoneNumber: completePhoneNumber,
    //   setLoading: (value) => setState(() => isLoading = value),
    //   setPhoneValid: (value) => setState(() => _isPhoneValid = value),
    // );

   await registerController.registerUser(
      context: context,
      setState: setState,
      formKey: _formkey,
      usernameController: _usernameController,
      emailController: _emailController,
      completePhoneNumber: completePhoneNumber,
      setLoading: (bool loading) {
        setState(() {
          isLoading = loading;
        });
      },
      setPhoneValid: (bool valid) {
        setState(() {
          _isPhoneValid = valid;
        });
      },
    );

  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.White,
      body: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
              child: Center(
                child: Form(
                  key: _formkey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 120,),
                        Image.asset(
                          Appimages.applogo,
                          height: 115,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 22,),
                        Text(AppText.aspireTitle,style: Apptextstyle.s18wbcothers),
                        SizedBox(height: 45,),
                        Text(AppText.signUp,style: Apptextstyle.s20wbcothers,),
                        SizedBox(height: 10,),
                        Text(AppText.createAccount,style:Apptextstyle.s15wbcothers,),
                        SizedBox(height: 30,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            children: [
                              CustomTextfield(
                                inputType: TextInputType.name,
                                hinttext: 'User Name',
                                icon: Icons.person,
                                controller: _usernameController,
                                validator: (value){
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a valid username';
                                  }
                                },),
                              SizedBox(height: 10,),
                              IntlPhoneField(
                                flagsButtonPadding: const EdgeInsets.all(0),
                                dropdownIconPosition: IconPosition.trailing,
                                dropdownIcon: Icon(
                                  Icons.arrow_drop_down,
                                  size: 15.0,
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Phone Number',
                                  border: UnderlineInputBorder(),
                                  counterText: '',
                                  errorText: _isPhoneValid ? null : 'Please enter a valid phone number', // Show error message
                                ),
                                initialCountryCode: AppText.country,
                                autovalidateMode: AutovalidateMode.disabled,
                                onChanged: (phone) {
                                  setState(() {
                                    completePhoneNumber = phone.completeNumber;
                                    _isPhoneValid = phone.completeNumber.length >= 10;  // Example validation
                                  });
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly, // Allow only digits
                                ],
                              ),
                              SizedBox(height: 10,),
                              CustomTextfield(
                                inputType: TextInputType.emailAddress,
                                hinttext: 'Email Id',
                                icon: Icons.email,
                                controller: _emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an email address';
                                  } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },)
                            ],
                          ),
                        ),
                        SizedBox(height: 50,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 50),
                          child: isLoading == false ?
                          MyButton(
                            press: () {
                              // Validate all fields and phone number separately
                              final isFormValid = _formkey.currentState!.validate();
                              if (completePhoneNumber == null || completePhoneNumber!.length < 10) {
                                setState(() {
                                  _isPhoneValid = false; // Show phone number validation message
                                });
                              }
                              if (isFormValid && _isPhoneValid) {
                                registerUser();
                              }
                            },
                            text: AppText.generateotp,
                          ):
                          Center(child: Image.asset(
                            Appimages.applogo,
                            height: 50,
                            fit: BoxFit.contain,
                          ),),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(AppText.alreadyHaveAccount,style: Apptextstyle.s13wbcgrey),
                            TextButton(onPressed: (){
                              Get.to(() => LoginScreen());
                            }, child: Text(AppText.LOGIN,style:Apptextstyle.s13wncblue))

                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
          )
      ),
    );
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
      fontSize: 16.0
  );

}
