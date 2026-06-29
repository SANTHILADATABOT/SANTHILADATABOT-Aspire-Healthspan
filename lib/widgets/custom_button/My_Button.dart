
 import 'package:azpire_new/utils/app_color.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
 import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;



 // class MyButton extends StatelessWidget {
 //   final VoidCallback press;
 //   final String text;
 //
 //   const MyButton({
 //     Key? key,
 //     required this.press,
 //     required this.text,
 //   }) : super(key: key);
 //
 //   @override
 //   Widget build(BuildContext context) {
 //     return Center( // <--- important to ensure center alignment
 //       child: ConstrainedBox(
 //         constraints: const BoxConstraints(
 //           maxWidth: 300, // Ensures it doesn't stretch too wide
 //         ),
 //         child: SizedBox(
 //           height: 50,
 //           width: double.infinity,
 //           child: DecoratedBox(
 //             decoration: BoxDecoration(
 //               borderRadius: BorderRadius.circular(8),
 //               gradient: AppColors.button,
 //             ),
 //             child: MaterialButton(
 //               onPressed: press,
 //               color: Colors.transparent,
 //               elevation: 0,
 //               child: Text(
 //                 text,
 //                 style: Apptextstyle.s20wbcW,
 //               ),
 //             ),
 //           ),
 //         ),
 //       ),
 //     );
 //   }
 // }






 class MyButton extends StatelessWidget {
   final VoidCallback press;
   final String text;

   const MyButton({
     Key? key,
     required this.press,
     required this.text,
   }) : super(key: key);

   bool get _isWebOrDesktop {
     if (kIsWeb) return true;
     return defaultTargetPlatform == TargetPlatform.windows ||
         defaultTargetPlatform == TargetPlatform.linux ||
         defaultTargetPlatform == TargetPlatform.macOS;
   }

   @override
   Widget build(BuildContext context) {
     Widget button = Center(
       child: ConstrainedBox(
         constraints: const BoxConstraints(
           maxWidth: 300,
         ),
         child: SizedBox(
           height: 50,
           width: double.infinity,
           child: DecoratedBox(
             decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(8),
               gradient: AppColors.button,
             ),
             child: MaterialButton(
               onPressed: press,
               color: Colors.transparent,
               elevation: 0,
               child: Text(
                 text,
                 style: Apptextstyle.s20wbcW,
               ),
             ),
           ),
         ),
       ),
     );

     // ✅ Enable Enter & Numpad Enter for Web + Desktop
     if (_isWebOrDesktop) {
       return RawKeyboardListener(
         autofocus: true,
         focusNode: FocusNode(),
         onKey: (event) {
           if (event is RawKeyDownEvent &&
               (event.logicalKey == LogicalKeyboardKey.enter ||
                   event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
             press();
           }
         },
         child: button,
       );
     }
     // ✅ Mobile: normal button
     return button;

   }
 }


 // class MyButton extends StatefulWidget {
 //   final VoidCallback press;
 //   final String text;
 //
 //   const MyButton({
 //     Key? key,
 //     required this.press,
 //     required this.text,
 //   }) : super(key: key);
 //
 //   @override
 //   State<MyButton> createState() => _MyButtonState();
 // }
 //
 // class _MyButtonState extends State<MyButton> {
 //   final FocusNode _focusNode = FocusNode();
 //
 //   bool get _isWebOrDesktop {
 //     if (kIsWeb) return true;
 //     return defaultTargetPlatform == TargetPlatform.windows ||
 //         defaultTargetPlatform == TargetPlatform.linux ||
 //         defaultTargetPlatform == TargetPlatform.macOS;
 //   }
 //
 //   @override
 //   void initState() {
 //     super.initState();
 //     if (_isWebOrDesktop) {
 //       WidgetsBinding.instance.addPostFrameCallback((_) {
 //         if (mounted) {
 //           _focusNode.requestFocus(); // keep button listening
 //         }
 //       });
 //     }
 //   }
 //
 //   @override
 //   void dispose() {
 //     _focusNode.dispose();
 //     super.dispose();
 //   }
 //
 //   @override
 //   Widget build(BuildContext context) {
 //     Widget button = Center(
 //       child: ConstrainedBox(
 //         constraints: const BoxConstraints(maxWidth: 300),
 //         child: SizedBox(
 //           height: 50,
 //           width: double.infinity,
 //           child: DecoratedBox(
 //             decoration: BoxDecoration(
 //               borderRadius: BorderRadius.circular(8),
 //               gradient: AppColors.button,
 //             ),
 //             child: MaterialButton(
 //               onPressed: widget.press,
 //               color: Colors.transparent,
 //               elevation: 0,
 //               child: Text(
 //                 widget.text,
 //                 style: Apptextstyle.s20wbcW,
 //               ),
 //             ),
 //           ),
 //         ),
 //       ),
 //     );
 //
 //     // ✅ Enable Enter/NumpadEnter on Web + Desktop
 //     if (_isWebOrDesktop) {
 //       return RawKeyboardListener(
 //         autofocus: true,
 //         focusNode: _focusNode,
 //         onKey: (event) {
 //           if (event is RawKeyDownEvent &&
 //               (event.logicalKey == LogicalKeyboardKey.enter ||
 //                   event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
 //             widget.press();
 //           }
 //         },
 //         child: button,
 //       );
 //     }
 //
 //     // ✅ Mobile: just normal button
 //     return button;
 //   }
 // }



