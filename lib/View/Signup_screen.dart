import 'dart:convert';
import 'package:aspire/View/login_Screen.dart';
import 'package:aspire/utils/app_color.dart';
import 'package:aspire/utils/apptextstyle.dart';
import 'package:aspire/widgets/custom_button/My_Button.dart';
import 'package:aspire/widgets/custom_textfield.dart';
import 'package:aspire/widgets/customphone_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../Controller/register_controller.dart';
import '../utils/appimages.dart';
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
  bool isAdmin = true; // change to false for User

  Future<void> registerUser() async {
    print("usernameController: ${_usernameController.text}");
    print("emailController: ${_emailController.text}");
    print("completePhoneNumber: $completePhoneNumber");

    final userType = isAdmin ? "Admin" : "User";
    print("Selected userType: $userType");

    try {
      if (!_isPhoneValid || completePhoneNumber == null || completePhoneNumber!.isEmpty) {
        setState(() {
          _isPhoneValid = false;
        });
        return;
      }

      setState(() {

        isLoading = true;
      });

      await registerController.registerUser(
        username: _usernameController.text,
        email: _emailController.text,
        completePhoneNumber: completePhoneNumber.toString(),
        userType: userType,
      );



    } catch (e) {
      print("signup error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
                          height:size.height * 0.15,
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
                                hinttext: AppText.user_name,
                                icon: Icons.person,
                                controller: _usernameController,
                                validator: (value){
                                  if (value == null || value.isEmpty) {
                                    return AppText.valid_username;
                                  }
                                },),
                              SizedBox(height: 10,),
                              // IntlPhoneField(
                              //   flagsButtonPadding: const EdgeInsets.all(0),
                              //   dropdownIconPosition: IconPosition.trailing,
                              //   dropdownIcon: Icon(
                              //     Icons.arrow_drop_down,
                              //     size: 15.0,
                              //     color: Colors.black,
                              //   ),
                              //   decoration: InputDecoration(
                              //     hintText: AppText.Phone_number,
                              //     border: UnderlineInputBorder(),
                              //     counterText: '',
                              //     errorText: _isPhoneValid ? null : AppText.valid_phoneno, // Show error message
                              //   ),
                              //   initialCountryCode: AppText.country,
                              //   autovalidateMode: AutovalidateMode.disabled,
                              //   onChanged: (phone) {
                              //     setState(() {
                              //       completePhoneNumber = phone.completeNumber;
                              //       _isPhoneValid = phone.completeNumber.length >= 10;  // Example validation
                              //     });
                              //   },
                              //   inputFormatters: [
                              //     FilteringTextInputFormatter.digitsOnly, // Allow only digits
                              //   ],
                              // ),
                              CustomPhoneField(
                                initialCountryCode: AppText.country,
                                isPhoneValid: _isPhoneValid,
                                onChanged: (number, isValid) {
                                  setState(() {
                                    completePhoneNumber = number;
                                    _isPhoneValid = isValid;
                                  });
                                }, onEnterPressed: () {
                                registerUser();
                              },
                              ),
                              SizedBox(height: 10,),
                              CustomTextfield(
                                inputType: TextInputType.emailAddress,
                                hinttext: AppText.email_id,
                                icon: Icons.email,
                                controller: _emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppText.email_address;
                                  } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
                                    return AppText.valid_email;
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
                            height: size.height*0.07,
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

