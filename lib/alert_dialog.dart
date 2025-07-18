//
// import 'package:azpire_new/pair_with_bluetooth_screen/bluetoothscreen.dart';
// import 'package:flutter/material.dart';
//
// import 'package:flutter/material.dart';
//
// import 'utils/app_color.dart';
//
//
//
// class AlertDialogScreen extends StatefulWidget {
//   const AlertDialogScreen({super.key});
//
//   @override
//   State<AlertDialogScreen> createState() => _AlertDialogScreenState();
// }
//
//
//
// class _AlertDialogScreenState extends State<AlertDialogScreen> {
//   void _navigateToBluetoothScreen() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => BluetoothPair()),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final double screenHeight = MediaQuery.of(context).size.height;
//     final double screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       backgroundColor: Colors.black.withOpacity(0.4),
//       body: Center(
//         child: Container(
//           height: screenHeight * 0.20,
//           width: screenWidth * 0.85,
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20.0),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.2),
//                 blurRadius: 10,
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Device ID Permission',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Text(
//                     'We use your device ID to send you important updates and alerts through Firebase Cloud Messaging (FCM). This data is not used for tracking or shared with third parties for advertising.',
//                     style: TextStyle(fontSize: 15, color: Colors.black),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//                   const SizedBox(height: 5),
//                   ElevatedButton(
//                     onPressed: _navigateToBluetoothScreen,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.others, // Button background color
//                       foregroundColor: Colors.white, // Text (and icon) color
//                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10), // Rounded corners
//                       ),
//                     ),
//                     child: const Text("ok"),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//     );
//   }
// }


