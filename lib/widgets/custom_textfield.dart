
 import 'package:flutter/material.dart';

 class CustomTextfield extends StatelessWidget {
   final TextInputType inputType;
   final TextEditingController controller;
   final String? Function(String?)? validator;
   //final Border border;
   final IconData? icon;
   final String hinttext;
    CustomTextfield({super.key,
      required this.inputType,
      required this.hinttext,
      required this.icon,
      required this.controller,
      required this.validator});

   @override
   Widget build(BuildContext context) {
     return TextFormField(
       controller: controller,
       decoration: InputDecoration(
         prefixIcon: icon != null ? Icon(icon,color: Colors.grey.shade700) : null,
         hintText: hinttext,
         border: UnderlineInputBorder(),
       ),
       keyboardType: inputType,
       validator: validator,
     );
   }
 }
