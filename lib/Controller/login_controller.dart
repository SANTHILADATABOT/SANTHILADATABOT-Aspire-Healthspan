
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/io_client.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import '../View/signup_Mobile_otp.dart';
import '../root/root.dart';
import 'package:http_certificate_pinning/http_certificate_pinning.dart';
import '../network/SecureApiClient.dart';


class LoginController {
  // update as needed

  // Future<void> login({
  //   required BuildContext context,
  //   required StateSetter setState,
  //   required GlobalKey<FormState> formKey,
  //   required String? completePhoneNumber,
  //   required String? token,
  //   required Function(bool) setLoading,
  //   required Function(bool) setPhoneValid,
  //   required void Function(String) onOtpReceived,
  //   required void Function(String) onUserReceived,
  //   required void Function(String) onMobileNoReceived,
  // }) async {
  //   print(completePhoneNumber.toString());
  //   print('FCM Token: ${token == null ? " No FCM TOKEN" : token}');
  //
  //   if (completePhoneNumber == null || completePhoneNumber.length < 10) {
  //     setState(() {
  //       setPhoneValid(false);
  //     });
  //     return;
  //   }
  //
  //   if (formKey.currentState!.validate()) {
  //     final String url = '$root/login_resend_otp';
  //     final Map<String, String> userData = {
  //       'mobile_no': completePhoneNumber.toString(),
  //       "access_token": "${token ?? "No FCM TOKEN"}"
  //     };
  //
  //     try {
  //       setState(() {
  //         setLoading(true);
  //       });
  //
  //       final response = await http.post(
  //         Uri.parse(url),
  //         headers: {
  //           'Content-Type': 'application/x-www-form-urlencoded',
  //         },
  //         body: userData,
  //       );
  //
  //       if (response.statusCode == 200) {
  //         final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //         if (jsonResponse["status"] == "SUCCESS") {
  //           print(response.body);
  //
  //           onOtpReceived(jsonResponse['data']['mobile_otp'].toString());
  //           onUserReceived(jsonResponse['data']['user'].toString());
  //           onMobileNoReceived(jsonResponse['data']['mobile_no'].toString());
  //
  //           showToast("OTP Sent Successfully");
  //
  //           Get.to(() =>
  //               MobileOtpScreen(
  //                 MobileOTP: jsonResponse['data']['mobile_otp'].toString(),
  //                 user: jsonResponse['data']['user'].toString(),
  //                 mobileno: jsonResponse['data']['mobile_no'].toString(),
  //               ));
  //         } else {
  //           showToast("User not Registered");
  //         }
  //       } else {
  //         print(response.body);
  //         showToast("Invalid Username");
  //         print("Request failed with status: ${response.statusCode}.");
  //       }
  //     } catch (e) {
  //       print("Error: $e");
  //     } finally {
  //       setState(() {
  //         setLoading(false);
  //       });
  //     }
  //   }
  // }
  // Future<void> login({
  //   required String completePhoneNumber,
  //   required String token,
  //   required String onOtpReceived,
  //   required String onUserReceived,
  //   required String onMobileNoReceived,
  //   required String userType
  // }) async {
  //   final String url = '$root/login_resend_otp';
  //
  //   print('FCM Token: ${token == null ? " No FCM TOKEN" : token}');
  //
  //   final Map<String, String> userData = {
  //     'mobile_no': completePhoneNumber,
  //     'access_token': token,
  //   };
  //
  //   print("userData_login:$userData");
  //
  //   try {
  //     final response = await http.post(
  //         Uri.parse(url),
  //         headers: {
  //           'Content-Type': 'application/x-www-form-urlencoded',
  //         },
  //         body: userData).timeout(Duration(seconds: 10),
  //       onTimeout: () {
  //         // Just show toast, no need to throw
  //         //showCustomToast("Time Out");
  //         // Return a dummy response so code continues
  //         throw TimeoutException("Request Timeout");
  //       },
  //
  //     );
  //
  //     print("login_response: ${response.body}");
  //
  //     if (response.statusCode == 200) {
  //       print("LoginResponse: ${response.body}");
  //       final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //
  //       if (jsonResponse["status"] == "SUCCESS") {
  //         print("Response: ${response.body}");
  //
  //         onOtpReceived = jsonResponse['data']['mobile_otp'].toString();
  //         onUserReceived = jsonResponse['data']['user'].toString();
  //         onMobileNoReceived = jsonResponse['data']['mobile_no'].toString();
  //         final String responseUserType = jsonResponse['data']['user_type'].toString();
  //
  //         showToast("OTP Sent Successfully");
  //         print("user_Type:$responseUserType");
  //
  //         Get.to(() =>
  //             MobileOtpScreen(
  //               MobileOTP: onOtpReceived,
  //               user: onUserReceived,
  //               mobileno: onMobileNoReceived, userType: responseUserType,
  //             ));
  //       } else {
  //         showToast("User not Registered");
  //       }
  //     } else {
  //       print("failed_response:${response.body}");
  //       //showToast("Invalid Username");
  //       print("Request failed with status: ${response.statusCode}.");
  //     }
  //   } catch (e) {
  //     if (e is TimeoutException) {
  //       showCustomToast("Timed Out");
  //     }
  //     else if (e is SocketException) {
  //       showCustomToast("No Internet Connection");
  //     }
  //     else {
  //       showCustomToast("Something went wrong. Please try again.");
  //     }
  //     print("Log_Error: $e");
  //   }
  // }

 // flutter login http
  Future<void> login({
    required String completePhoneNumber,
    required String token,
    required String onOtpReceived,
    required String onUserReceived,
    required String onMobileNoReceived,
    required String userType,
  }) async
  {
    final String url = '$root/login_resend_otp';


    print('FCM Token: ${token == null ? " No FCM TOKEN" : token}');

    final Map<String, String> userData = {
      'mobile_no': completePhoneNumber,
      'access_token': token,
    };

    print("userData_login:$userData");

    try {
      print("🌍 Region Debug Test Started");
      print("➡️ Device Locale: ${Platform.localeName}");
      print("➡️ Using VPN or No VPN");
      print("➡️ API URL: $url");
      // final HttpClient httpClient = HttpClient()
      //   ..badCertificateCallback =
      //       (X509Certificate cert, String host, int port) {
      //     print('⚠️ Ignoring SSL error for $host:$port. Due to network issue.');
      //     return true; // ❌ Set to true to accept the "bad" certificate
      //   };

      //final IOClient client = IOClient(httpClient);

      print("helllo1 ${url}");
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          //'User-Agent': 'FlutterApp/1.0.0',
        },
        body: userData,
      );
// client.close();
      print("⏳ STATUS: ${response.statusCode}");
      print("📩 RESPONSE RAW: ${response.body}");
      print("📡 RESPONSE HEADERS: ${response.headers}");
      print("helllo2");
      print("login_response: ${response.body}");

      if (response.statusCode == 200) {
        print("LoginResponse: ${response.body}");
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print("helllo3");
        if (jsonResponse["status"] == "SUCCESS") {
          print("Response: ${response.body}");
          print("helllo4");
          onOtpReceived = jsonResponse['data']['mobile_otp'].toString();
          onUserReceived = jsonResponse['data']['user'].toString();
          onMobileNoReceived = jsonResponse['data']['mobile_no'].toString();

          showToast("OTP Sent Successfully");

          Get.to(() =>
              MobileOtpScreen(
                MobileOTP: onOtpReceived,
                user: onUserReceived,
                mobileno: onMobileNoReceived,
                userType: userType,
              ));
        }
        else {
          print("helllo5");
          print("Request failed with status: ${response.statusCode}.");
          showToast("User not Registered");
        }
      } else {
        print("helllo6");
        print("failed_response:${response.body}");
        //showToast("Invalid Username");
        print("Request failed with status: ${response.statusCode}.");
      }
    } catch (e) {
      print("❌ CAUGHT EXCEPTION");
      print("❌ Error Type: ${e.runtimeType}");
      print("❌ Error Details: $e");
      SnackBar(content: Text(e.toString()));
      if (e.toString().contains("HandshakeException")) {

      }
      showCustomToast(e.toString());
      print("helllo7");
      print("Log_Error: $e");
    }
  }



// // flutter login http (OPTION 1 – INSECURE)
//   Future<void> login({
//     required String completePhoneNumber,
//     required String token,
//     required String onOtpReceived,
//     required String onUserReceived,
//     required String onMobileNoReceived,
//     required String userType,
//   }) async {
//     final String url = '$root/login_resend_otp';
//
//     print('FCM Token: ${token.isEmpty ? " No FCM TOKEN" : token}');
//
//     final Map<String, String> userData = {
//       'mobile_no': completePhoneNumber,
//       'access_token': token,
//     };
//
//     print("userData_login:$userData");
//
//     try {
//       print("🌍 Region Debug Test Started");
//       print("➡️ Device Locale: ${Platform.localeName}");
//       print("➡️ Using VPN or No VPN");
//       print("➡️ API URL: $url");
//
//       // 🔓 INSECURE HTTP CLIENT (DISABLE SSL VERIFICATION)
//       final HttpClient httpClient = HttpClient()
//         ..badCertificateCallback =
//             (X509Certificate cert, String host, int port) {
//           print('⚠️ Ignoring SSL error for $host');
//           return true; // ❌ accept all certificates
//         };
//
//       final IOClient client = IOClient(httpClient);
//
//       print("helllo1 $url");
//       final response = await client.post(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/x-www-form-urlencoded',
//         },
//         body: userData,
//       );
//
//       print("⏳ STATUS: ${response.statusCode}");
//       print("📩 RESPONSE RAW: ${response.body}");
//       print("📡 RESPONSE HEADERS: ${response.headers}");
//       print("helllo2");
//       print("login_response: ${response.body}");
//
//       if (response.statusCode == 200) {
//         print("LoginResponse: ${response.body}");
//         final Map<String, dynamic> jsonResponse =
//         json.decode(response.body);
//         print("helllo3");
//
//         if (jsonResponse["status"] == "SUCCESS") {
//           print("Response: ${response.body}");
//           print("helllo4");
//
//           onOtpReceived =
//               jsonResponse['data']['mobile_otp'].toString();
//           onUserReceived =
//               jsonResponse['data']['user'].toString();
//           onMobileNoReceived =
//               jsonResponse['data']['mobile_no'].toString();
//
//           showToast("OTP Sent Successfully");
//
//           Get.to(() => MobileOtpScreen(
//             MobileOTP: onOtpReceived,
//             user: onUserReceived,
//             mobileno: onMobileNoReceived,
//             userType: userType,
//           ));
//         } else {
//           print("helllo5");
//           showToast("User not Registered");
//         }
//       } else {
//         print("helllo6");
//         print("failed_response:${response.body}");
//         print("Request failed with status: ${response.statusCode}.");
//         showCustomToast(response.body);
//       }
//
//       client.close(); // important
//     } catch (e) {
//       print("❌ CAUGHT EXCEPTION");
//       print("❌ Error Type: ${e.runtimeType}");
//       print("❌ Error Details: $e");
//
//       showCustomToast(e.toString());
//       print("helllo7");
//       print("Log_Error: $e");
//
//     }
//   }


  // //http_certificate_pinning
  // Future<void> login({
  //   required String completePhoneNumber,
  //   required String token,
  //   required String onOtpReceived,
  //   required String onUserReceived,
  //   required String onMobileNoReceived,
  //   required String userType,
  // }) async {
  //   final Uri uri = Uri.parse('$root/login_resend_otp');
  //
  //   print('FCM Token: ${token.isEmpty ? "No FCM TOKEN" : token}');
  //   print("🌍 Region Debug Test Started");
  //   print("➡️ Device Locale: ${Platform.localeName}");
  //   print("➡️ API URL: $uri");
  //
  //   final Map<String, String> userData = {
  //     'mobile_no': completePhoneNumber,
  //     'access_token': token,
  //   };
  //
  //   print("📤 Request Body: $userData");
  //
  //   try {
  //     // 🔐 PINNED CLIENT
  //     final SecureHttpClient client = SecureApiClient.client();
  //
  //     final response = await client.post(
  //       uri, // ✅ correct
  //       headers: {
  //         'Content-Type': 'application/x-www-form-urlencoded',
  //         'host': 'app.aspirehealthspan.ai',
  //       },
  //       body: userData,
  //     );
  //
  //     print("⏳ STATUS: ${response.statusCode}");
  //     print("📩 RESPONSE RAW: ${response.body}");
  //
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse =
  //       json.decode(response.body);
  //
  //       if (jsonResponse["status"] == "SUCCESS") {
  //         onOtpReceived =
  //             jsonResponse['data']['mobile_otp'].toString();
  //         onUserReceived =
  //             jsonResponse['data']['user'].toString();
  //         onMobileNoReceived =
  //             jsonResponse['data']['mobile_no'].toString();
  //
  //         showToast("OTP Sent Successfully");
  //
  //         Get.to(() => MobileOtpScreen(
  //           MobileOTP: onOtpReceived,
  //           user: onUserReceived,
  //           mobileno: onMobileNoReceived,
  //           userType: userType,
  //         ));
  //       } else {
  //         showToast("User not Registered");
  //       }
  //     } else {
  //       showToast("Login failed. Please try again.");
  //     }
  //   }
  //
  //   // 🔐 SSL / PINNING FAILURE (Airtel MITM)
  //   on HandshakeException catch (e) {
  //     print("🚨 SSL HANDSHAKE FAILED (PINNING)");
  //     print(e);
  //
  //     showCustomToast(
  //       "Secure connection failed. Please disable VPN or try another network.",
  //     );
  //   }
  //
  //   on TlsException catch (e) {
  //     print("🚨 TLS ERROR (PINNING)");
  //     print(e.toString()
  //     );
  //
  //     showCustomToast(
  //       "Secure connection failed due to certificate validation.",
  //     );
  //   }
  //
  //   // 🌐 OTHER NETWORK ERRORS
  //   on SocketException catch (e) {
  //     print("🌐 SOCKET ERROR");
  //     print(e);
  //
  //     showCustomToast("No internet connection.");
  //   }
  //
  //   catch (e) {
  //     print("❌ UNKNOWN ERROR");
  //     print("❌ Error Type: ${e.runtimeType}");
  //     print("❌ Error Details: $e");
  //
  //     showCustomToast(e.toString());
  //   }
  // }







  void showCustomToast(String msg) {
    showToast(
      msg,
      duration: Duration(seconds: 2),
      position: kIsWeb ? ToastPosition.top : ToastPosition.bottom,
      backgroundColor: Colors.black,
      radius: 8.0,
        textPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      textStyle: TextStyle(
        fontSize: 16.0,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
      animationCurve: kIsWeb ? Curves.easeInOut : Curves.easeIn,
      animationDuration: const Duration(milliseconds: 400),
      animationBuilder: kIsWeb ? _slideFromRight : null,
    );
  }

  Widget _slideFromRight(
      BuildContext context,
      Widget child,
      AnimationController controller,
      double percent,
      ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(1.2, 0.0), // far right
        end: Offset(-1.2, 0.0),  // f // Slide to original position
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }





// showToast(String msg) {
//     Fluttertoast.showToast(
//       msg: msg,
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       timeInSecForIosWeb: 1,
//       backgroundColor: Colors.black,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//   }

}