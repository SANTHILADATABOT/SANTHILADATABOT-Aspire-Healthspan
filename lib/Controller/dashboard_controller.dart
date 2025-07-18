// lib/controller/dashboard_controller.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../model/dashboard_model.dart';
import '../root/root.dart';

class DashboardController {


  // Future<DashboardModel?> fetchDashboardDetails(String userId) async {
  //   final String url = "$root/dashboard";
  //   final Map<String, dynamic> userData = {
  //     'user_id': userId,
  //   };
  //
  //   try {
  //     final response = await http.post(Uri.parse(url), body: userData);
  //
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //       if (jsonResponse['status'] == "SUCCESS") {
  //         // Returning DashboardModel instead of Map<String, dynamic>
  //         return DashboardModel.fromJson({
  //           'datetime': jsonResponse['collection_date'],
  //           'heartRate': jsonResponse['heart_rate'].toString(),
  //           'steps': jsonResponse['daily_steps'].toString(),
  //           'weight': jsonResponse['weight'].toString(),
  //           'sleep': jsonResponse['sleep'].toString(),
  //           'bps': jsonResponse['blood_pressure_systolic'].toString(),
  //           'bpd': jsonResponse['blood_pressure_diastolic'].toString(),
  //         });
  //       } else {
  //         throw Exception('Failed to load dashboard data');
  //       }
  //     } else {
  //       throw Exception('HTTP Error: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching dashboard details: $e');
  //     return null;
  //   }
  // }

  Future<Map<String, dynamic>?> fetchDashboardload(String userId) async {
    final String url = "$root/dashboard";
    print('URL: $url');

    final Map<String, dynamic> userData = {
      'user_id': userId,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: userData,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('JsonResponse: $jsonResponse');

        if (jsonResponse['status'] == "SUCCESS") {
          return jsonResponse;
        } else {
          throw Exception('Failed to load dashboard data');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching dashboard details: $e');
      return null;
    }
  }




}
