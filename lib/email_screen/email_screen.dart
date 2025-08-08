
import 'dart:convert';

import 'package:azpire_new/email_screen/verification_otp.dart';
import 'package:azpire_new/root/root.dart';
import 'package:azpire_new/Controller/email_controller.dart';
import 'package:azpire_new/utils/apptext.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:azpire_new/widgets/custom_button/My_Button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:azpire_new/widgets/custom_textfield.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:oktoast/oktoast.dart';
import '../root/root.dart';


 class EmailScreen extends StatefulWidget {
    EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  late final String emailOtp;
  late final String email;
  late final String user;
  bool isLoading = false;

  final TextEditingController emailcontroller = TextEditingController();
  final EmailController _emailcontroller = EmailController();
   final _formKey = GlobalKey<FormState>();

  Future<void> emaillogin() async {
    setState(() {
      isLoading = true;
    });
    final String url = '$root/email_login_resend_otp';

    final Map<String, String> userData = {
      'email': emailcontroller.text,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: userData,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print("email otp response$jsonResponse");
        if(jsonResponse['status'] == "SUCCESS"){
          String emailOtp = jsonResponse['data']['email_otp'].toString()  ;
          var email = jsonResponse['data']["email"];
          showToast("OTP sent to Email");
          Get.to(() => VerificationOtpScreen(
            email: email!,
            emailOtp: emailOtp,
          ));
        } else {
          showToast("Email not Registered");
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }


   @override
   Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: Colors.white,
       appBar: AppBar(
         backgroundColor: Colors.white,
         elevation: 1,
         leading: Padding(
           padding: const EdgeInsets.symmetric(horizontal: 15),
           child: IconButton(
             icon: Icon(Icons.arrow_back_ios,size: 20,),
             onPressed: (){
               Get.back();
             },
           ),
         ),
       ),
       body: Padding(
         padding: EdgeInsets.symmetric(horizontal: 50),
         child: Center(
           child: Form(
             key: _formKey,
             child: Column(
               mainAxisAlignment: MainAxisAlignment.start,
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 SizedBox(height: 80,),
                 Text(AppText.emailadddress,style: Apptextstyle.s13wbcgrey),
                 CustomTextfield(
                   inputType: TextInputType.emailAddress,
                   hinttext: '',
                   icon: null,
                   controller: emailcontroller,
                   validator:  (value) {
                     if (value == null || value.isEmpty) {
                       return 'Please enter an email address';
                     } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
                       return 'Please enter a valid email address';
                     }
                     return null;
                   },),
                 SizedBox(height: 60,),
                 Padding(
                     padding: EdgeInsets.symmetric(horizontal: 20),
                     child:MyButton(press: (){

                     if (_formKey.currentState!.validate()) {
                       emaillogin();
                     }
                     }, text: AppText.emailsendotp)
                 )
               ],
             ),
           ),
         ),
       ),
     );
   }
}

void showToast(String msg) {
  showToastWidget(
    _buildToastWidget(msg),
    position: kIsWeb ? ToastPosition.top : ToastPosition.bottom,
    duration: Duration(seconds: 2),
    animationCurve: kIsWeb ? Curves.easeInOut : Curves.easeIn,
    animationDuration: const Duration(milliseconds: 400),
    animationBuilder: kIsWeb ? _slideFromRight : null,
  );
}

Widget _buildToastWidget(String msg) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 20),
    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Text(
      msg,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16.0,
        color: Colors.white,
      ),
    ),
  );
}

Widget _slideFromRight(BuildContext context,
    Widget child,
    AnimationController controller,
    double percent,) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: Offset(1.2, 0.0), // far right
      end: Offset(-1.2, 0.0), // f // Slide to original position
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    )),
    child: child,
  );
}

//
// showToast(String msg) {
//   Fluttertoast.showToast(
//       msg: msg,
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       timeInSecForIosWeb: 1,
//       backgroundColor: Colors.black,
//       textColor: Colors.white,
//       fontSize: 16.0
//   );
//
// }
