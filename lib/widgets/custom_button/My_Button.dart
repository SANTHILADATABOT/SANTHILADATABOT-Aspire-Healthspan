
 import 'package:azpire_new/utils/app_color.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:flutter/material.dart';

 class MyButton extends StatelessWidget {
   final VoidCallback press;
   final String text;

   const MyButton({
     Key? key,
     required this.press,
     required this.text,
   }) : super(key: key);

   @override
   Widget build(BuildContext context) {
     return Container(
       width: MediaQuery.of(context).size.width * 0.7,
       height: 50,
       decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(8),
         gradient: AppColors.button
       ),
       child: MaterialButton(
         onPressed: press,
         color: Colors.transparent,
         elevation: 0,
         child: Text(
           text,
           style: Apptextstyle.s20wbcW
         ),
       ),
     );
   }
 }
