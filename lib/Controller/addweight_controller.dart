
import 'dart:async';
import 'dart:convert';
import 'package:aspire/Model/addweight_model.dart';
import 'package:aspire/root/root.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter/foundation.dart';



class AddWeightController extends GetxController{

  Future<List<WeightChart>> Weight_Chart({required String userId}) async {
    final String url = "$root/daily_weight_average";

    final Map<String, dynamic> userdata = {
      'user_id': userId,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: userdata)
          .timeout(Duration(seconds: 10),
        onTimeout: () {
          // Just show toast, no need to throw
          showCustomToast("Time Out");
          // Return a dummy response so code continues
          throw TimeoutException("Request Timeout");
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('weight_Response: $jsonResponse');

        if (jsonResponse['status'] == "SUCCESS") {
          List<dynamic>? weightList = jsonResponse['daily_avg_weight'];

          if (weightList != null) {
            return weightList.map((item) {
              String dateStr = item['selected_date'] ?? '';
              double bmi = double.tryParse(item['bmi']?.toString() ?? '0') ?? 0;
              int weight = int.tryParse(item['wweight']?.toString() ?? '0') ?? 0;
              int height = int.tryParse(item['wheight']?.toString() ?? '0') ?? 0;

              DateTime parsedDate;
              try {
                parsedDate = DateFormat('yyyy-MM-dd').parse(dateStr);
              } catch (e) {
                parsedDate = DateTime.now();
              }

              return WeightChart(
                day: DateFormat('EE').format(parsedDate),
                Years: DateFormat('yyyy').format(parsedDate),
                months: DateFormat('MMM').format(parsedDate),
                date: parsedDate,
                weightrate: weight,
                bmidata: bmi, heightrate: height.toDouble(),
              );
            }).toList();
          } else {
            return [];
          }
        } else {
          throw Exception('Failed: ${jsonResponse['message']}');
        }
      } else {
        throw Exception(
            'Failed to load daily average weight. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching daily average weight: $e');
      rethrow;
    }
  }

  Future<void> addData({
    required TextEditingController dateController,
    required TextEditingController weightController,
    required int heightFeet,
    required int heightInches,
    required DateFormat dateFormat,
    required BuildContext context,
    required void Function(String) showToast,
    required VoidCallback weightChartCallback,
  }) async {
    final String url = "$root/add_weight";

    if (dateController.text == "Select Date") {
      showToast("Please select a valid date.");
      return;
    }

    try {
      DateTime parsedDate = dateFormat.parse(dateController.text);
      String formattedDate = DateFormat("yyyy-MM-dd").format(parsedDate);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var user_id = prefs.getString('user_id') ?? "";
      final Map<String, dynamic> userdata = {
        'user_id': user_id,
        'selected_date': formattedDate,
        'weight': int.parse(weightController.text),
        'feet': heightFeet,
        'inches': heightInches,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userdata))
          .timeout(Duration(seconds: 10),
        onTimeout: () {
          // Just show toast, no need to throw
          showCustomToast("Time Out");
          // Return a dummy response so code continues
          throw TimeoutException("Request Timeout");
        },

      );


      print("📤 Sent Data: $userdata");
      print("📥 Response Status: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('✅ weight_Response: $jsonResponse');

        if (jsonResponse['status'] == "SUCCESS") {
          weightChartCallback();
          dateController.text = "Select Date";
          weightController.text = "";
          FocusScope.of(context).requestFocus(FocusNode());
        } else {
          showToast("❌ Failed: ${jsonResponse['message']}");
        }
      } else {
        print('❌ API Error Code: ${response.statusCode}');
        print('❌ Response Body: ${response.body}');
        throw Exception('Failed to load daily average weight');
      }
    } catch (e) {
      print('Error adding weight data: $e');
      showToast("An error occurred while adding weight data.");
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



}