// lib/controller/dashboard_controller.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../model/dashboard_model.dart';
import '../root/root.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb

class DashboardController {


  Future<Map<String, dynamic>?> fetchDashboardload(String userId) async {
    final String url = "$root/dashboard";
    print('URL: $url');

    final Map<String, dynamic> userData = {
      'user_id': userId,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: userData)
          .timeout(Duration(seconds: 10),
        onTimeout: () {
          // Just show toast, no need to throw
          //showCustomToast("Time Out");
          // Return a dummy response so code continues
          throw TimeoutException("Request Timeout");
        },
      );
      print('userId: $userId');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('JsonResponse: $jsonResponse');
        print('userId1: $userId');

        if (jsonResponse['status'] == "SUCCESS") {
          print('userId2: $userId');
          return jsonResponse;
        } else {
          throw Exception('Failed to load dashboard data');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      if (e is TimeoutException) {
        showCustomToast("Timed Out");
      }
      else if (e is SocketException) {
        showCustomToast("No Internet Connection");
      }
      else {
        showCustomToast("Something went wrong. Please try again.");
      }
      print('Error fetching dashboard details: $e');
      return null;
    }
  }

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



}
