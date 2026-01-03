import 'dart:async';
import 'dart:convert';
import 'package:aspire/Model/Heartrate_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:aspire/root/root.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb

class HeartRatecontroller extends GetxController {

  String getAbbreviatedDay(String dayName) {
    switch (dayName) {
      case 'Sunday':
        return 'Su';
      case 'Monday':
        return 'Mo';
      case 'Tuesday':
        return 'Tu';
      case 'Wednesday':
        return 'We';
      case 'Thursday':
        return 'Th';
      case 'Friday':
        return 'Fr';
      case 'Saturday':
        return 'Sa';
      default:
        return 'Unknown';
    }
  }

  // Future<Map<String, dynamic>> Day_Chart({
  //   required String userId,
  //   required String date,
  // }) async
  // {
  //   final String url = "$root/daily_hr_data";
  //   final Map<String, dynamic> payload = {
  //     'user_id': userId,
  //     'date': date,
  //   };
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(payload),
  //     );
  //
  //     print('Request Payload: $payload');
  //     print('Response Status Code: ${response.statusCode}');
  //     print('Response Body: ${response.body}');
  //
  //     if (response.statusCode != 200) {
  //       throw Exception("HTTP error: ${response.statusCode}");
  //     }
  //
  //     final jsonResponse = json.decode(response.body);
  //
  //     if (jsonResponse['status'] != "SUCCESS") {
  //       throw Exception("API Error: ${jsonResponse['message'] ?? 'Unknown error'}");
  //     }
  //
  //     final List<dynamic> hourlyData = jsonResponse['hourly_heart_rate_avg'];
  //     final String? dateString = jsonResponse['date'];
  //     int targetHR = jsonResponse['target_heart_rate'] ?? 75;
  //     final int recentHeartRate = jsonResponse['recent_heart_rate'];
  //     final String? recentdate = jsonResponse['recent_datetime']?.toString();
  //     final double sd_high = jsonResponse['heart_rate_sd_high'];
  //     final double sd_low = jsonResponse['heart_rate_sd_low'];
  //
  //     DateTime parsedDate = DateTime.tryParse(dateString ?? '') ?? DateTime.now();
  //     String formattedDate = DateFormat('MMM dd, yyyy – hh:mm a').format(parsedDate);
  //
  //
  //
  //     List<HeartRateData> chartData = hourlyData.map((entry) {
  //       String hourStr = entry['hour'] ?? '';
  //       double heartRate = (entry['average_heart_rate'] ?? 0).toDouble();
  //
  //       int hour = int.tryParse(hourStr.split(":").first) ?? 0;
  //
  //       DateTime fullDateTime = DateTime(
  //         parsedDate.year,
  //         parsedDate.month,
  //         parsedDate.day,
  //         hour,
  //       );
  //
  //       // 🔄 Fetch individual SD for that hour
  //       double sdHigh = (entry['sd_high'] ?? 0).toDouble();
  //       double sdLow = (entry['sd_low'] ?? 0).toDouble();
  //
  //       return HeartRateData(
  //         day: hourStr,
  //         heartrate: heartRate.toInt(),
  //         date: fullDateTime,
  //         months: '',
  //         Years: '',
  //         targetheartrate: targetHR,
  //         sd_high: sdHigh,
  //         sd_low: sdLow,
  //       );
  //     }).toList();
  //
  //
  //
  //     print("Day Chart Fetched Successfully:");
  //     print("Formatted Date: $formattedDate");
  //     print("Target Heart Rate: $targetHR");
  //     print("Chart Data Count: ${chartData.length}");
  //
  //
  //
  //     return {
  //       'date': formattedDate,
  //       'targetHeartRate': targetHR,
  //       'chartData': chartData,
  //       'recent_heart_rate':recentHeartRate,
  //       'recent_datetime': recentdate,
  //       'sd_high': sd_high,
  //       'sd_low': sd_low,
  //
  //     };
  //   } catch (e) {
  //     print("Error in Day_Chart: $e");
  //     rethrow;
  //   }
  // }

  Future<Map<String, dynamic>> Day_Chart({
    required String userId,
    required String date,
  }) async {
    final String url = "$root/daily_hr_data";
    final Map<String, dynamic> payload = {
      'user_id': userId,
      'date': date,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload))
          .timeout(Duration(seconds: 10),
        onTimeout: () {
          // Just show toast, no need to throw
          showCustomToast("Time Out");
          // Return a dummy response so code continues
          throw TimeoutException("Request Timeout");
        },
      );

      print('Request Payload: $payload');
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception("HTTP error: ${response.statusCode}");
      }

      final jsonResponse = json.decode(response.body);

      if (jsonResponse['status'] != "SUCCESS") {
        throw Exception("API Error: ${jsonResponse['message'] ?? 'Unknown error'}");
      }

      final List<dynamic> hourlyData = jsonResponse['hourly_heart_rate_avg'];
      final String? dateString = jsonResponse['date'];
      final int targetHR = jsonResponse['target_heart_rate'] ?? 75;
      final int recentHeartRate = jsonResponse['recent_heart_rate'] ?? 0;
      final String? recentDate = jsonResponse['recent_datetime']?.toString();

      // Safely convert to double
      final double sdHigh =
      (jsonResponse['heart_rate_sd_high'] is num) ? (jsonResponse['heart_rate_sd_high'] as num).toDouble() : 0.0;
      final double sdLow =
      (jsonResponse['heart_rate_sd_low'] is num) ? (jsonResponse['heart_rate_sd_low'] as num).toDouble() : 0.0;

      final DateTime parsedDate = DateTime.tryParse(dateString ?? '') ?? DateTime.now();
      final String formattedDate = DateFormat('MMM dd, yyyy – hh:mm a').format(parsedDate);

      final List<HeartRateData> chartData = hourlyData.map((entry) {
        final String hourStr = entry['hour'] ?? '';
        final int hour = int.tryParse(hourStr.split(":").first) ?? 0;

        // Safe conversion to double
        final double heartRate =
        (entry['average_heart_rate'] is num) ? (entry['average_heart_rate'] as num).toDouble() : 0.0;
        final double hourSdHigh = (entry['sd_high'] is num) ? (entry['sd_high'] as num).toDouble() : 0.0;
        final double hourSdLow = (entry['sd_low'] is num) ? (entry['sd_low'] as num).toDouble() : 0.0;

        final DateTime fullDateTime = DateTime(
          parsedDate.year,
          parsedDate.month,
          parsedDate.day,
          hour,
        );

        return HeartRateData(
          day: hourStr,
          heartrate: heartRate.round(),
          date: fullDateTime,
          months: '',
          Years: '',
          targetheartrate: targetHR,
          sd_high: hourSdHigh,
          sd_low: hourSdLow,
        );
      }).toList();

      print("Day Chart Fetched Successfully:");
      print("Formatted Date: $formattedDate");
      print("Target Heart Rate: $targetHR");
      print("Chart Data Count: ${chartData.length}");

      return {
        'date': formattedDate,
        'targetHeartRate': targetHR,
        'chartData': chartData,
        'recent_heart_rate': recentHeartRate,
        'recent_datetime': recentDate,
        'sd_high': sdHigh,
        'sd_low': sdLow,
      };
    } catch (e) {
      print("Error in Day_Chart: $e");
      rethrow;
    }
  }


  // Future<Map<String, dynamic>> Week_Chart(String userId, String date,) async {
  //   final String url = 'https://app.aspirehealthspan.ai/aspire_api/daily_hr_data';
  //   final Map<String, dynamic> payload = {
  //     'user_id': userId,
  //     'date': date,
  //     'type': 'weekly'
  //   };
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(payload),
  //     );
  //     print('Week HR Response: $response');
  //
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //       print('Weekly HR Response: $jsonResponse');
  //
  //       if (jsonResponse['status'] == "SUCCESS") {
  //         // Process weekly data
  //         List<dynamic> weeklyData = jsonResponse['weekly_heart_data'];
  //         List<HeartRateData> chartData = [];
  //         final double heartrate_sd_low = jsonResponse['heart_rate_sd_low'];
  //         final double heartrate_sd_high = jsonResponse['heart_rate_sd_high'];
  //         // Get targets
  //         int targetHR = jsonResponse['target_heart_rate'] ?? 75;
  //         final String? recentdate = jsonResponse['recent_datetime']?.toString();
  //         // Calculate weekly averages
  //         int weeklyHr = jsonResponse['recent_heart_rate']?.toInt() ?? 0;
  //
  //         // Calculate weekly averages
  //         double heartrateSum = 0;
  //         int validDays = 0;
  //
  //
  //         DateTime weekStart = DateFormat('yyyy-MM-dd').parse(jsonResponse['week_start']);
  //         DateTime weekEnd = DateFormat('yyyy-MM-dd').parse(jsonResponse['week_end']);
  //
  //         Map<String, double> heartRateMap = {
  //           for (var entry in weeklyData)
  //             entry['date']: entry['average_heart_rate']?.toDouble() ?? 0.0
  //         };
  //
  //         for (int i = 0; i <= weekEnd.difference(weekStart).inDays; i++) {
  //           DateTime currentDate = weekStart.add(Duration(days: i));
  //           String dateStr = DateFormat('yyyy-MM-dd').format(currentDate);
  //           String dayName = DateFormat('E').format(currentDate); // Mon, Tue, ...
  //
  //           double heartRate = heartRateMap[dateStr] ?? 0.0;
  //
  //           if (heartRate > 0) {
  //             heartrateSum += heartRate;
  //             validDays++;
  //           }
  //
  //           chartData.add(
  //             HeartRateData(
  //               months: "",
  //               heartrate: heartRate.round(),
  //               date: currentDate,
  //               day: dayName,
  //               Years: '',
  //               targetheartrate: targetHR,
  //               sd_high: 0, // optional: update if available per-day
  //               sd_low: 0,
  //             ),
  //           );
  //         }
  //
  //         return {
  //
  //           'chartData': chartData,
  //           'weekhr': weeklyHr,
  //           'target_heart_rate': targetHR,
  //           'mainDate': '${jsonResponse['week_start']} to ${jsonResponse['week_end']}',
  //           'recent_datetime': recentdate,
  //           'heartrate_sd_high': heartrate_sd_high,
  //           'heartrate_sd_low': heartrate_sd_low,
  //         };
  //       } else {
  //         throw Exception('API Error: ${jsonResponse['message']}');
  //       }
  //     } else {
  //       throw Exception('Failed to load data. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching weekly BP data: $e');
  //     rethrow;
  //   }
  // }

  Future<Map<String, dynamic>> Week_Chart(String userId, String date) async {
    final String url = 'https://app.aspirehealthspan.ai/aspire_api/daily_hr_data';
    final Map<String, dynamic> payload = {
      'user_id': userId,
      'date': date,
      'type': 'weekly'
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload))
    .timeout(Duration(seconds: 10),
    onTimeout: () {
    // Just show toast, no need to throw
    showCustomToast("Time Out");
    // Return a dummy response so code continues
    throw TimeoutException("Request Timeout");
    },
      );
      print('📤 Week HR Response: $response');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('✅ Weekly HR Response: $jsonResponse');

        if (jsonResponse['status'] == "SUCCESS") {
          List<dynamic> weeklyData = jsonResponse['weekly_heart_data'];
          List<HeartRateData> chartData = [];

          final double heartrate_sd_low = (jsonResponse['heart_rate_sd_low'] ?? 0).toDouble();
          final double heartrate_sd_high = (jsonResponse['heart_rate_sd_high'] ?? 0).toDouble();
          final int targetHR = jsonResponse['target_heart_rate'] ?? 75;
          final String? recentdate = jsonResponse['recent_datetime']?.toString();
          final int weeklyHr = jsonResponse['recent_heart_rate']?.toInt() ?? 0;

          DateTime weekStart = DateFormat('yyyy-MM-dd').parse(jsonResponse['week_start']);
          DateTime weekEnd = DateFormat('yyyy-MM-dd').parse(jsonResponse['week_end']);

          // Safely parse average_heart_rate to double
          Map<String, double> heartRateMap = {
            for (var entry in weeklyData)
              entry['date']: (entry['average_heart_rate'] ?? 0).toDouble()
          };

          double heartrateSum = 0;
          int validDays = 0;

          for (int i = 0; i <= weekEnd.difference(weekStart).inDays; i++) {
            DateTime currentDate = weekStart.add(Duration(days: i));
            String dateStr = DateFormat('yyyy-MM-dd').format(currentDate);
            String dayName = DateFormat('E').format(currentDate); // Mon, Tue, ...

            double heartRate = heartRateMap[dateStr] ?? 0.0;

            if (heartRate > 0) {
              heartrateSum += heartRate;
              validDays++;
            }

            chartData.add(
              HeartRateData(
                months: "",
                heartrate: heartRate.round(),
                date: currentDate,
                day: dayName,
                Years: '',
                targetheartrate: targetHR,
                sd_high: 0,
                sd_low: 0,
              ),
            );
          }

          // Debug: Print chart data
          print("📊 Weekly chartData:");
          for (var data in chartData) {
            print("  ${data.day} (${DateFormat('yyyy-MM-dd').format(data.date)}): HR = ${data.heartrate}");
          }

          return {
            'chartData': chartData,
            'weekhr': weeklyHr,
            'target_heart_rate': targetHR,
            'mainDate': '${jsonResponse['week_start']} to ${jsonResponse['week_end']}',
            'recent_datetime': recentdate,
            'heartrate_sd_high': heartrate_sd_high,
            'heartrate_sd_low': heartrate_sd_low,
          };
        } else {
          throw Exception('API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching weekly BP data: $e');
      rethrow;
    }
  }


  // Future<Map<String, dynamic>> Month_Chart(String userId, String date) async {
  //   final String url = '$root/daily_hr_data';
  //   final Map<String, dynamic> payload = {
  //     'user_id': userId,
  //     'date': date,
  //     'type': 'monthly'
  //   };
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(payload),
  //     );
  //
  //     print('month HR Response: $response');
  //
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //       print('month HR Response: $jsonResponse');
  //
  //       if (jsonResponse['status'] == "SUCCESS") {
  //         print('monthly HR Response: $jsonResponse');
  //
  //         final double heartrate_sd_low = jsonResponse['heart_rate_sd_low'];
  //         final double heartrate_sd_high = jsonResponse['heart_rate_sd_high'];
  //         int targetHR = jsonResponse['target_heart_rate'] ?? 75;
  //         final String? recentdate = jsonResponse['recent_datetime']?.toString();
  //         int weeklyHr = jsonResponse['recent_heart_rate']?.toInt() ?? 0;
  //
  //         List<HeartRateData> chartData = [];
  //
  //         Map<String, dynamic> monthlyData = jsonResponse['monthly_heart_data'];
  //         print('monthlyData keys: ${monthlyData.keys}');
  //
  //         final DateTime today = DateTime.now();
  //         final DateTime monthStart = DateTime(today.year, today.month, 1);
  //
  //
  //
  //         for (int i = 1; i <= 5; i++) {
  //           String weekLabel = 'W$i';
  //           final weekData = monthlyData[weekLabel.toLowerCase()];
  //
  //           if (weekData == null) {
  //             print('Skipping week: $weekLabel because no data is available.');
  //             continue;
  //           }
  //
  //           final DateTime defaultStartDate = monthStart.add(Duration(days: (i - 1) * 7));
  //           final DateTime defaultEndDate = defaultStartDate.add(const Duration(days: 6));
  //
  //           final String? startDateStr = weekData?['start_date'];
  //           final String? endDateStr = weekData?['end_date'];
  //
  //           final DateTime startDate = startDateStr != null ? DateTime.parse(startDateStr) : defaultStartDate;
  //           final DateTime endDate = endDateStr != null ? DateTime.parse(endDateStr) : defaultEndDate;
  //
  //           double heartRateAvg = 0.0;
  //           final dynamic rawAvg = weekData?['average_heart_rate'];
  //
  //           /// 🔽 Add this line here
  //           print('Parsing HR: week=$weekLabel, rawAvg=$rawAvg, type=${rawAvg.runtimeType}');
  //
  //           if (rawAvg != null) {
  //             try {
  //               heartRateAvg = rawAvg is num ? rawAvg.toDouble() : double.parse(rawAvg.toString());
  //             } catch (e) {
  //               print('Error parsing average_heart_rate for $weekLabel: $rawAvg');
  //               heartRateAvg = 0.0;
  //             }
  //           }
  //
  //           bool isCurrentWeek = today.isAfter(startDate.subtract(const Duration(days: 1))) &&
  //               today.isBefore(endDate.add(const Duration(days: 1)));
  //
  //           chartData.add(HeartRateData(
  //             months: weekLabel,
  //             heartrate: heartRateAvg.round(),
  //             date: startDate,
  //             day: '',
  //             Years: '',
  //             targetheartrate: targetHR,
  //             sd_high: isCurrentWeek ? heartrate_sd_high : 0,
  //             sd_low: isCurrentWeek ? heartrate_sd_low : 0,
  //           ));
  //         }
  //
  //         return {
  //           'chartData': chartData,
  //           'weekhr': weeklyHr,
  //           'target_heart_rate': targetHR,
  //           'mainDate': '${jsonResponse['month_start']} to ${jsonResponse['month_end']}',
  //           'recent_datetime': recentdate,
  //           'heartrate_sd_high': heartrate_sd_high,
  //           'heartrate_sd_low': heartrate_sd_low,
  //         };
  //       } else {
  //         throw Exception('API Error: ${jsonResponse['message']}');
  //       }
  //     } else {
  //       throw Exception('Failed to load data. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching monthly HR data: $e');
  //     rethrow;
  //   }
  // }

  Future<Map<String, dynamic>> Month_Chart(String userId, String date) async {
    final String url = '$root/daily_hr_data';
    final Map<String, dynamic> payload = {
      'user_id': userId,
      'date': date,
      'type': 'monthly'
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload))
          .timeout(Duration(seconds: 10),
        onTimeout: () {
          // Just show toast, no need to throw
          showCustomToast("Time Out");
          // Return a dummy response so code continues
          throw TimeoutException("Request Timeout");
        },
      );

      print('📤 month HR Response: $response');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('✅ month HR Response: $jsonResponse');

        if (jsonResponse['status'] == "SUCCESS") {
          final double heartrate_sd_low = (jsonResponse['heart_rate_sd_low'] ?? 0).toDouble();
          final double heartrate_sd_high = (jsonResponse['heart_rate_sd_high'] ?? 0).toDouble();
          final int targetHR = jsonResponse['target_heart_rate'] ?? 75;
          final String? recentdate = jsonResponse['recent_datetime']?.toString();
          final int weeklyHr = jsonResponse['recent_heart_rate']?.toInt() ?? 0;

          List<HeartRateData> chartData = [];

          Map<String, dynamic> monthlyData = jsonResponse['monthly_heart_data'];
          print('📊 monthlyData keys: ${monthlyData.keys}');

          final DateTime today = DateTime.now();
          final DateTime monthStart = DateTime(today.year, today.month, 1);

          for (int i = 1; i <= 5; i++) {
            String weekLabel = 'W$i';
            final weekKey = weekLabel.toLowerCase();
            final weekData = monthlyData[weekKey];

            // Defaults if data is null
            final DateTime defaultStartDate = monthStart.add(Duration(days: (i - 1) * 7));
            final DateTime defaultEndDate = defaultStartDate.add(const Duration(days: 6));

            final String? startDateStr = weekData?['start_date'];
            final String? endDateStr = weekData?['end_date'];

            final DateTime startDate = startDateStr != null ? DateTime.parse(startDateStr) : defaultStartDate;
            final DateTime endDate = endDateStr != null ? DateTime.parse(endDateStr) : defaultEndDate;

            double heartRateAvg = 0.0;
            final dynamic rawAvg = weekData?['average_heart_rate'];

            // 🧠 Parse safely
            print('🔍 Parsing HR: week=$weekLabel, rawAvg=$rawAvg, type=${rawAvg.runtimeType}');
            if (rawAvg != null) {
              try {
                heartRateAvg = rawAvg is num ? rawAvg.toDouble() : double.parse(rawAvg.toString());
              } catch (e) {
                print('⚠️ Error parsing average_heart_rate for $weekLabel: $rawAvg');
                heartRateAvg = 0.0;
              }
            }

            bool isCurrentWeek = today.isAfter(startDate.subtract(const Duration(days: 1))) &&
                today.isBefore(endDate.add(const Duration(days: 1)));

            chartData.add(
              HeartRateData(
                months: weekLabel,
                heartrate: heartRateAvg.round(),
                date: startDate,
                day: '',
                Years: '',
                targetheartrate: targetHR,
                sd_high: isCurrentWeek ? heartrate_sd_high : 0,
                sd_low: isCurrentWeek ? heartrate_sd_low : 0,
              ),
            );
          }

          // Log chart data
          print("📈 Final chartData:");
          chartData.forEach((data) {
            print("${data.months}: ${data.heartrate}");
          });

          return {
            'chartData': chartData,
            'weekhr': weeklyHr,
            'target_heart_rate': targetHR,
            'mainDate': '${jsonResponse['month_start']} to ${jsonResponse['month_end']}',
            'recent_datetime': recentdate,
            'heartrate_sd_high': heartrate_sd_high,
            'heartrate_sd_low': heartrate_sd_low,
          };
        } else {
          throw Exception('API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching monthly HR data: $e');
      rethrow;
    }
  }




  Future<Map<String, dynamic>> Year_Chart(String userId, String date) async {
    final String url = '$root/daily_hr_data';
    final Map<String, dynamic> payload = {
      'user_id': userId,
      'date': date,
      'type': 'yearly'
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload))
          .timeout(Duration(seconds: 10),
        onTimeout: () {
          // Just show toast, no need to throw
          showCustomToast("Time Out");
          // Return a dummy response so code continues
          throw TimeoutException("Request Timeout");
        },
      );

      print('Year HR Response: $response');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('Year HR Response: $jsonResponse');

        if (jsonResponse['status'] == "SUCCESS") {
          final double heartrateSdLow = (jsonResponse['heart_rate_sd_low'] as num?)?.toDouble() ?? 0.0;
          final double heartrateSdHigh = (jsonResponse['heart_rate_sd_high'] as num?)?.toDouble() ?? 0.0;
          int targetHR = jsonResponse['target_heart_rate'] ?? 75;
          final String? recentDate = jsonResponse['recent_datetime']?.toString();
          int yearlyHR = jsonResponse['recent_heart_rate']?.toInt() ?? 0;

          List<HeartRateData> chartData = [];
          Map<String, dynamic> yearlyData = jsonResponse['yearly_heart_data'];

          yearlyData.forEach((monthLabel, monthData) {
            double heartRateAvg = (monthData['average_heart_rate'] as num?)?.toDouble() ?? 0.0;

            final String startDateStr = monthData['start_date'] ?? '';
            final DateTime startDate = DateTime.tryParse(startDateStr) ?? DateTime.now();

            chartData.add(HeartRateData(
              months: monthLabel, // e.g., Jan, Feb, ...
              heartrate: heartRateAvg.round(),
              date: startDate,
              day: '',
              Years: startDate.year.toString(),
              targetheartrate: targetHR,
              sd_high: heartrateSdHigh,
              sd_low: heartrateSdLow,
            ));
          });

          return {
            'chartData': chartData,
            'weekhr': yearlyHR,
            'target_heart_rate': targetHR,
            'mainDate': '${jsonResponse['year_start']} to ${jsonResponse['year_end']}',
            'recent_datetime': recentDate,
            'heartrate_sd_high': heartrateSdHigh,
            'heartrate_sd_low': heartrateSdLow,
          };
        } else {
          throw Exception('API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching yearly HR data: $e');
      rethrow;
    }
  }

  // Future<Map<String, dynamic>> MultiYear_Chart(String userId,  int toYear) async {
  //   final String url = '$root/get_multiyear_hr_data';
  //   final Map<String, dynamic> payload = {
  //     'user_id': userId,
  //    // 'from_year': '${fromYear.toString()}',
  //     'to_year': '${toYear.toString()}',
  //   };
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(payload),
  //     );
  //
  //     print('MultiYear HR Response: $response');
  //
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //
  //       print('MultiYear HR Response status: ${response.statusCode}');
  //       print('MultiYear HR Response body: ${response.body}');
  //
  //       if (jsonResponse['status'] == "SUCCESS") {
  //
  //         final Map<String, dynamic> multiYearData = jsonResponse['multiyear_heart_data'] ?? {};
  //
  //         print("multiYearData:$multiYearData");
  //
  //         final double heartrateSdLow = (jsonResponse['heart_rate_sd_low'] as num?)?.toDouble() ?? 0.0;
  //         final double heartrateSdHigh = (jsonResponse['heart_rate_sd_high'] as num?)?.toDouble() ?? 0.0;
  //         int targetHR = jsonResponse['target_heart_rate'] ?? 75;
  //         final String? recentDate = jsonResponse['recent_datetime']?.toString();
  //         int recentHR = jsonResponse['recent_heart_rate']?.toInt() ?? 0;
  //
  //         List<HeartRateData> chartData = [];
  //
  //
  //         multiYearData.forEach((yearLabel, yearData) {
  //           double heartRateAvg = (yearData['average_heart_rate'] as num?)?.toDouble() ?? 0.0;
  //
  //           final int year = int.tryParse(yearLabel) ?? DateTime.now().year;
  //           final DateTime yearDate = DateTime(year);
  //
  //           chartData.add(HeartRateData(
  //             months: '', // Not needed for multiyear, can keep blank
  //             heartrate: heartRateAvg.round(),
  //             date:  yearDate,
  //             day: '',
  //             Years: yearLabel,
  //             targetheartrate: targetHR,
  //             sd_high: heartrateSdHigh,
  //             sd_low: heartrateSdLow,
  //           ));
  //         });
  //
  //         return {
  //           'chartData': chartData,
  //           'weekhr': recentHR,
  //           'target_heart_rate': targetHR,
  //           'mainDate': '${jsonResponse['to_year']}',
  //           'recent_datetime': recentDate,
  //           'heartrate_sd_high': heartrateSdHigh,
  //           'heartrate_sd_low': heartrateSdLow,
  //         };
  //       } else {
  //         throw Exception('API Error: ${jsonResponse['message']}');
  //       }
  //     } else {
  //       throw Exception('Failed to load data. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching multiyear HR data: $e');
  //     rethrow;
  //   }
  // }
  Future<Map<String, dynamic>> MultiYear_Chart(String userId,  int toYear) async {
    final String url = '$root/get_multiyear_hr_data';
    print("URL: $url");

    final Map<String, dynamic> payload = {
      'user_id': userId,
      // 'from_year': '${fromYear.toString()}',
      'to_year': '${toYear.toString()}',
    };

    print("Request Payload: $payload");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload))
          .timeout(Duration(seconds: 10),
        onTimeout: () {
          // Just show toast, no need to throw
          showCustomToast("Time Out");
          // Return a dummy response so code continues
          throw TimeoutException("Request Timeout");
        },
      );

      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('MultiYear Response: $jsonResponse');

        if (jsonResponse['status'] == "SUCCESS") {
          final Map<String, dynamic> multiYearData = jsonResponse['multiyear_heart_data'] ?? {};
          List<HeartRateData> chartData = [];

          int targetHR = jsonResponse['target_heart_rate'] ?? 130;
          // int targetDiastolic = jsonResponse['target_diastolic_bp'] ?? 80;
          final String? recentDate = jsonResponse['recent_datetime']?.toString();

          // Initialize for last processed values
          double systolicAvg = 0.0;
          // double diastolicAvg = 0.0;
          double systolicSdHigh = 0.0;
          double systolicSdLow = 0.0;
          // double diastolicSdHigh = 0.0;
          // double diastolicSdLow = 0.0;

          List<String> sortedYears = multiYearData.keys.toList()..sort();

          for (String yearKey in sortedYears) {
            var data = multiYearData[yearKey];

            double systolicAvg = data?['average_heart_rate']?.toDouble() ?? 0;
            // double diastolicAvg = data?['average_diastolic']?.toDouble() ?? 0;
            systolicSdHigh = (data['heart_rate_sd_high'] as num?)?.toDouble() ?? 0.0;
            systolicSdLow = (data['heart_rate_sd_low'] as num?)?.toDouble() ?? 0.0;
            // diastolicSdHigh = (data['diastolic_sd_high'] as num?)?.toDouble() ?? 0.0;
            // diastolicSdLow = (data['diastolic_sd_low'] as num?)?.toDouble() ?? 0.0;

            chartData.add(HeartRateData(
              date: DateTime(int.parse(yearKey)),
              heartrate: systolicAvg.round(),
              // diastolic: diastolicAvg.round(),
              day: '',
              months: '',
              Years: yearKey,
              targetheartrate: targetHR,
              // targetDiastolic: targetDiastolic,
              // diastolic_sd_high: diastolicSdHigh,
              // diastolic_sd_low: diastolicSdLow,
              sd_high: systolicSdHigh,
              sd_low: systolicSdLow,
            ));
          }

          int yearlyHR = jsonResponse['recent_heart_rate']?.toInt() ?? 0;
          // int yearlyDiastolic = jsonResponse['recent_diastolic_bp']?.toInt() ?? 0;
          //
          return {
            'chartData': chartData,
            'target_heart_rate': yearlyHR,
            // 'targetDiastolic': targetDiastolic,
            'mainDate': '${jsonResponse['from_year']} to ${jsonResponse['to_year']}',
            'recent_datetime': recentDate,
            'weekBpSystolic':yearlyHR,
            // 'weekBpDiastolic':yearlyDiastolic,
            'heartrate_sd_high': systolicSdHigh,
            'heartrate_sd_low': systolicSdLow,
            // 'diastolic_sd_high': diastolicSdHigh,
            // 'diastolic_sd_low': diastolicSdLow,
          };
        } else {
          throw Exception('API Error: ${jsonResponse['error'] ?? jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching multi-year BP data: $e');
      rethrow;
    }
  }
// Future<Map<String, dynamic>> MultiYear_Chart(String userId, int toYear) async {
//   final String url = '$root/get_multiyear_hr_data';
//   final Map<String, dynamic> payload = {
//     'user_id': userId,
//     'to_year': '${toYear.toString()}',
//   };
//
//   try {
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(payload),
//     );
//
//     print('MultiYear HR Response: $response');
//
//
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> jsonResponse = json.decode(response.body);
//
//       print('MultiYear HR Response status: ${response.statusCode}');
//       print('MultiYear HR Response body: ${response.body}');
//
//       if (jsonResponse['status'] == "SUCCESS") {
//         final Map<String, dynamic> multiYearData = jsonResponse['multiyear_heart_data'] ?? {};
//
//         int targetHR = jsonResponse['target_heart_rate'] ?? 75;
//         final String? recentDate = jsonResponse['recent_datetime']?.toString();
//         int recentHR = jsonResponse['recent_heart_rate']?.toInt() ?? 0;
//
//         List<HeartRateData> chartData = [];
//
//         double heartrateSdLow = 0.0;
//         double heartrateSdHigh = 0.0;
//
//         multiYearData.forEach((yearLabel, yearData) {
//           double heartRateAvg = (yearData['average_heart_rate'] as num?)?.toDouble() ?? 0.0;
//           heartrateSdLow = (yearData['heart_rate_sd_low'] as num?)?.toDouble() ?? 0.0;
//           heartrateSdHigh = (yearData['heart_rate_sd_high'] as num?)?.toDouble() ?? 0.0;
//
//           final int year = int.tryParse(yearLabel) ?? DateTime.now().year;
//           final DateTime yearDate = DateTime(year);
//
//           chartData.add(HeartRateData(
//             months: '',
//             heartrate: heartRateAvg.round(),
//             date: yearDate,
//             day: '',
//             Years: yearLabel,
//             targetheartrate: targetHR,
//             sd_high: heartrateSdHigh,
//             sd_low: heartrateSdLow,
//           ));
//         });
//
//         return {
//           'chartData': chartData,
//           'weekhr': recentHR,
//           'target_heart_rate': targetHR,
//           'mainDate': '${jsonResponse['to_year']}',
//           'recent_datetime': recentDate,
//           'heartrate_sd_high': heartrateSdHigh,
//           'heartrate_sd_low': heartrateSdLow,
//         };
//       } else {
//         throw Exception('API Error: ${jsonResponse['message']}');
//       }
//     } else {
//       throw Exception('Failed to load data. Status code: ${response.statusCode}');
//     }
//   } catch (e) {
//     print('Error fetching multiyear HR data: $e');
//     rethrow;
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