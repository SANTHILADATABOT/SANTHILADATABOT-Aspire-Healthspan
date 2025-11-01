
import 'dart:convert';
import 'package:aspire/Model/spo2_model.dart';
import 'package:aspire/root/root.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


class spo2Controller extends GetxController {

  // Future<Map<String, dynamic>> fetchDayChart({
  //   required String userId,
  //   required String date,
  //   required String type,
  // }) async {
  //   final url = Uri.parse('$root/daily_spo2_data');
  //   final payload = {
  //     "user_id": userId,
  //     "date": date,
  //     "type": type,
  //   };
  //
  //   print("📤 Sending request to: $url");
  //   print("📦 Payload: ${jsonEncode(payload)}");
  //
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode(payload),
  //     );
  //
  //     print("📥 Response Status Code: ${response.statusCode}");
  //
  //     if (response.statusCode == 200) {
  //       final jsonResponse = json.decode(response.body);
  //       print("spo2 Response Body: $jsonResponse");
  //
  //       if (jsonResponse['status'] == "SUCCESS") {
  //         print("API SUCCESS:$jsonResponse");
  //
  //         final dateString = jsonResponse['date'];
  //         final entries = (jsonResponse['hourly_spo2_data'] as List)
  //             .map((e) => BloodOxygenData.fromJson(e, dateString))
  //             .toList();
  //         // final entries = (jsonResponse['hourly_spo2_data'] as List)
  //         //     .where((e) => e['spo2'] != null)
  //         //     .map((e) => BloodOxygenData.fromJson(e, dateString))
  //         //     .toList();
  //
  //
  //         return {
  //           'mainDate': jsonResponse['date'],
  //           'targetNormal': (jsonResponse['target_spo2_normal'] as num?)?.toInt() ?? 91,
  //           'targetHigh': (jsonResponse['target_spo2_high'] as num?)?.toInt() ?? 95,
  //           'recentSpo2': (jsonResponse['recent_spo2'] as num?)?.round() ?? 0,
  //           'recentDatetime': jsonResponse['recent_datetime'],
  //           'chartData': entries,
  //         };
  //       } else {
  //         print("API returned failure status: ${jsonResponse['status']}");
  //         throw Exception("API returned failure status.");
  //       }
  //     } else {
  //       print("Server error: ${response.statusCode}");
  //       throw Exception("Failed with status code: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("Exception in fetchDayChart: $e");
  //     rethrow;
  //   }
  // }

  Future<Map<String, dynamic>> fetchDayChart({
    required String userId,
    required String date,
    required String type,
  }) async {
    final url = Uri.parse('$root/daily_spo2_data');
    final payload = {
      "user_id": userId,
      "date": date,
      "type": type,
    };

    // Safe number parser
    int parseToInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    print("📤 Sending request to: $url");
    print("📦 Payload: ${jsonEncode(payload)}");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      print("📥 Response Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print("spo2 Response Body: $jsonResponse");

        if (jsonResponse['status'] == "SUCCESS") {
          print("API SUCCESS: $jsonResponse");

          final dateString = jsonResponse['date'];
          final entries = (jsonResponse['hourly_spo2_data'] as List)
              .map((e) => BloodOxygenData.fromJson(e, dateString))
              .toList();

          return {
            'mainDate': jsonResponse['date'],
            'targetNormal': parseToInt(jsonResponse['target_spo2_normal'], defaultValue: 91),
            'targetHigh': parseToInt(jsonResponse['target_spo2_high'], defaultValue: 95),
            'recentSpo2': parseToInt(jsonResponse['recent_spo2']),
            'recentDatetime': jsonResponse['recent_datetime'],
            'chartData': entries,
          };
        } else {
          throw Exception("API returned failure status: ${jsonResponse['status']}");
        }
      } else {
        throw Exception("Failed with status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception in fetchDayChart: $e");
      rethrow;
    }
  }




  Future<Map<String, dynamic>> Week_Chart({
    required String userId,
    required String date,
  }) async{
    final String url = '$root/daily_spo2_data';
    final Map<String, dynamic> payload = {
      'user_id': userId,
      'date': date,
      'type': 'weekly'
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('Weekly spo2 Response: $jsonResponse');

        if (jsonResponse['status'] == "SUCCESS") {
          // Process weekly data
          List<dynamic> weeklyData = jsonResponse['weekly_spo2_data'];
          List<BloodOxygenData> chartData = [];
          final int spo2traget_normal = jsonResponse['target_spo2_normal'] ?? 91;
          final int spo2traget_high = jsonResponse['target_spo2_high'] ?? 95;
          // Get targets
          final String? recentdate = jsonResponse['recent_datetime']?.toString();

          // Calculate weekly averages
          double spo2Sum = 0;
          int validDays = 0;

          // for (var dayData in weeklyData) {
          //   DateTime date = DateFormat('yyyy-MM-dd').parse(dayData['date']);
          //   String dayName = DateFormat('E').format(date); // Short day name (Mon, Tue, etc.)
          //
          //   double spo2Avg = dayData['average_spo2']?.toDouble() ?? 0;
          //
          //   if (spo2Avg > 0 ) {
          //     spo2Sum += spo2Avg;
          //     validDays++;
          //   }
          //
          //   // In Week_Chart method, modify the chartData creation:
          //   chartData.add(BloodOxygenData
          //     (spo2: spo2Avg.toInt(),
          //       day:dayName,
          //       date: date, months: '', Year: ''));
          // }

          for (var dayData in weeklyData) {
            DateTime date = DateFormat('yyyy-MM-dd').parse(dayData['date']);
            String dayName = DateFormat('E').format(date);

            // Safely parse average_spo2 whether it's string, int, or double
            double spo2Avg = double.tryParse(dayData['average_spo2'].toString()) ?? 0;

            if (spo2Avg > 0) {
              spo2Sum += spo2Avg;
              validDays++;
            }

            chartData.add(
              BloodOxygenData(
                spo2: spo2Avg.toInt(),
                day: dayName,
                date: date,
                months: '',
                Year: '',
              ),
            );
          }

          // // Calculate weekly averages
          // int recentspo2 = jsonResponse['recent_spo2']?.toInt() ?? 0;

          // Safely parse recent_spo2
          int recentspo2 = int.tryParse(jsonResponse['recent_spo2'].toString()) ?? 0;

          return {

            'chartData': chartData,
            'weekspo2': recentspo2,
            'mainDate': '${jsonResponse['week_start']} to ${jsonResponse['week_end']}',
            'recent_datetime': recentdate,
            'target_spo2_normal': spo2traget_normal,
            'target_spo2_high': spo2traget_high,
          };
        } else {
          throw Exception('API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching weekly spo2 data: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> Month_Chart({
    required String userId,
    required String date,
  }) async {
    final String url = '$root/daily_spo2_data';
    final Map<String, dynamic> payload = {
      'user_id': userId,
      'date': date,
      'type': 'monthly',
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('Monthly spo2 Response: $jsonResponse');

        if (jsonResponse['status'] == "SUCCESS") {
          final Map<String, dynamic> monthlyData = jsonResponse['monthly_spo2_data'];
          List<BloodOxygenData> chartData = [];

          final int spo2TargetNormal = jsonResponse['target_spo2_normal'] ?? 91;
          final int spo2TargetHigh = jsonResponse['target_spo2_high'] ?? 95;
          final String? recentDate = jsonResponse['recent_datetime']?.toString();
          final int recentSpo2 = jsonResponse['recent_spo2']?.toInt() ?? 0;

          // monthlyData.forEach((weekLabel, weekData) {
          //   double spo2Avg = weekData['average_spo2']?.toDouble() ?? 0.0;
          //   DateTime startDate = DateFormat('yyyy-MM-dd').parse(weekData['start_date']);
          //   String label = weekLabel; // "W1", "W2", etc.
          //
          //   chartData.add(BloodOxygenData(
          //     spo2: spo2Avg.round(),
          //     day: '', // used as X-axis label
          //     date: startDate, months: label,
          //     Year: '',
          //
          //   ));
          // });

          final DateTime today = DateTime.now();
          final DateTime monthStart = DateTime(today.year, today.month, 1);

          for (int i = 1; i <= 5; i++) {
            String weekKey = 'W$i';
            final data = monthlyData[weekKey];

            // Fallback start date if not present
            final DateTime defaultStartDate = monthStart.add(Duration(days: (i - 1) * 7));
            final String startDateStr = data?['start_date'] ?? defaultStartDate.toIso8601String();
            final DateTime startDate = DateTime.tryParse(startDateStr) ?? defaultStartDate;

            double spo2Avg = data?['average_spo2']?.toDouble() ?? 0.0;

            chartData.add(BloodOxygenData(
              spo2: spo2Avg.round(),
              day: '',
              date: startDate,
              months: weekKey,
              Year: '',
            ));
          }



          return {
            'chartData': chartData,
            'weekspo2': recentSpo2,
            'mainDate': '${jsonResponse['month_start']} to ${jsonResponse['month_end']}',
            'recent_datetime': recentDate,
            'target_spo2_normal': spo2TargetNormal,
            'target_spo2_high': spo2TargetHigh,
          };
        } else {
          throw Exception('API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching monthly SPO2 data: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> Year_Chart({
    required String userId,
    required String date,
  }) async {
    final String url = '$root/daily_spo2_data';
    final Map<String, dynamic> payload = {
      'user_id': userId,
      'date': date,
      'type': 'yearly',
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('Yearly SPO2 Response: $jsonResponse');

        if (jsonResponse['status'] == "SUCCESS") {
          final Map<String, dynamic> yearlyData = jsonResponse['yearly_spo2_data'];
          List<BloodOxygenData> chartData = [];

          final int spo2TargetNormal = jsonResponse['target_spo2_normal'] ?? 91;
          final int spo2TargetHigh = jsonResponse['target_spo2_high'] ?? 95;
          final String? recentDate = jsonResponse['recent_datetime']?.toString();
          final int recentSpo2 = jsonResponse['recent_spo2']?.toInt() ?? 0;

          yearlyData.forEach((monthLabel, monthData) {
            double spo2Avg = monthData['average_spo2']?.toDouble() ?? 0.0;
            DateTime startDate = DateFormat('yyyy-MM-dd').parse(monthData['start_date']);

            chartData.add(BloodOxygenData(
              spo2: spo2Avg.round(),
              day: '', // Not used here
              date: startDate,
              months: monthLabel,
              Year: '', // You can assign year if needed
            ));
          });

          return {
            'chartData': chartData,
            'weekspo2': recentSpo2,
            'mainDate': '${jsonResponse['year_start']} to ${jsonResponse['year_end']}',
            'recent_datetime': recentDate,
            'target_spo2_normal': spo2TargetNormal,
            'target_spo2_high': spo2TargetHigh,
          };
        } else {
          throw Exception('API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching yearly SPO2 data: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> MultiYear_Chart(String userId,  int toYear) async {
    final String url = '$root/get_multiyear_spo2_data';
    final Map<String, dynamic> payload = {
      'user_id': userId,
      //'from_year': '${fromYear.toString()}',
      'to_year': '${toYear.toString()}',
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('MultiYear SPO2 Response: $jsonResponse');

        if (jsonResponse['status'] == "SUCCESS") {
          final Map<String, dynamic> multiYearData = jsonResponse['multiyear_spo2_data'];
          List<BloodOxygenData> chartData = [];

          final int spo2TargetNormal = jsonResponse['target_spo2_normal'] ?? 91;
          final int spo2TargetHigh = jsonResponse['target_spo2_high'] ?? 95;
          final String? recentDate = jsonResponse['recent_datetime']?.toString();
          final int recentSpo2 = jsonResponse['recent_spo2']?.toInt() ?? 0;

          multiYearData.forEach((yearLabel, yearData) {
            double spo2Avg = yearData['average_spo2']?.toDouble() ?? 0.0;
            DateTime startDate = DateFormat('yyyy-MM-dd').parse(yearData['start_date']);

            chartData.add(BloodOxygenData(
              spo2: spo2Avg.round(),
              day: '', // Not used
              date: startDate,
              months: '', // Not used
              Year: yearLabel, // Set year label
            ));
          });

          return {
            'chartData': chartData,
            'weekspo2': recentSpo2,
            'mainDate': '${jsonResponse['to_year']}',
            'recent_datetime': recentDate,
            'target_spo2_normal': spo2TargetNormal,
            'target_spo2_high': spo2TargetHigh,
          };
        } else {
          throw Exception('API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching multiyear SPO2 data: $e');
      rethrow;
    }
  }







}
