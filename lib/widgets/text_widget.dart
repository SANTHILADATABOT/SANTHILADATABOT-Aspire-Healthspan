
 import 'package:flutter/material.dart';

 class TextTitle extends StatelessWidget {
   final String title;
   final Color color;
   const TextTitle({super.key, required this.title, required this.color});

   @override
   Widget build(BuildContext context) {
     return Text(
       title,
       style: TextStyle(
           fontFamily: "Inter",
         fontSize: 16,
         color: color
       ),
     );
   }
 }

 class TextTitle1 extends StatelessWidget {
   final String title;
   final Color color;
   const TextTitle1({super.key, required this.title, required this.color});

   @override
   Widget build(BuildContext context) {
     return Text(
       title,
       style: TextStyle(
           fontFamily: "Inter",
           fontSize: 18,
           color: color
       ),
     );
   }
 }
