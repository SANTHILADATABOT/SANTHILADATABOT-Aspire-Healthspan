
import 'dart:convert';
import 'package:aspire/Model/bloodpressure_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:aspire/root/root.dart';
import 'package:intl/intl.dart';

 class BloodPressureController extends GetxController  {

  Future<Map<String, dynamic>> Day_Chart({
    required String userId,
    required String date,
    required String type,
  }) async {
    const String url = "https://app.aspirehealthspan.ai/aspire_api/daily_bp_data";
    final Map<String, dynamic> payload = {
      'user_id': userId,
      'date': date,
      'type': type,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('Day Response: $jsonResponse');

        final List<dynamic> bpEntries = jsonResponse['bp_data'] ?? [];

        final int targetSystolic = jsonResponse['target_systolic_bp']?.toInt() ?? 120;
        final int targetDiastolic = jsonResponse['target_diastolic_bp']?.toInt() ?? 80;
        final double diastolic_sd_high = (jsonResponse['diastolic_sd_high'] as num?)?.toDouble() ?? 0.0;
        final double systolic_sd_low = (jsonResponse['systolic_sd_low'] as num?)?.toDouble() ?? 0.0;
        final double systolic_sd_high = (jsonResponse['systolic_sd_high'] as num?)?.toDouble() ?? 0.0;
        final double diastolic_sd_low = (jsonResponse['diastolic_sd_low'] as num?)?.toDouble() ?? 0.0;
        final String? recentdate = jsonResponse['recent_datetime']?.toString();
        final String? dateString = jsonResponse['date'];

        DateTime parsedDate = DateTime.tryParse(dateString ?? '') ?? DateTime.now();
        String formattedDate = DateFormat('MMM dd, yyyy – hh:mm a').format(parsedDate);

        List<BloodPressureData> chartData = bpEntries.map((entry) {
          String hourString = entry['hours'] ?? "00:00"; // e.g., "08:08"
          List<String> parts = hourString.split(':');
          int hour = int.tryParse(parts[0]) ?? 0;
          int minute = int.tryParse(parts[1]) ?? 0;

          DateTime fullDateTime = DateTime(
            parsedDate.year,
            parsedDate.month,
            parsedDate.day,
            hour,
            minute,
          );

          // Use HH:mm format (e.g., "08:08") for x-axis
          String hourLabel = DateFormat('HH:mm').format(fullDateTime);

          return BloodPressureData(
            months: '',
            Year: '',
            day: hourLabel, // used for x-axis label
            date: fullDateTime,
            systolic: (entry['systolic'] as num?)?.round() ?? 0,
            diastolic: (entry['diastolic'] as num?)?.round() ?? 0,
            targetSystolic: targetSystolic,
            targetDiastolic: targetDiastolic,
            diastolic_sd_high: diastolic_sd_high,
            systolic_sd_low: systolic_sd_low,
            systolic_sd_high: systolic_sd_high,
            diastolic_sd_low: diastolic_sd_low,
          );
        }).toList();

        // Sort by time just in case entries are unordered
        //chartData.sort((a, b) => a.date.compareTo(b.date));

        int avgSystolic = jsonResponse['recent_systolic_bp']?.toInt() ?? 0;
        int avgDiastolic = jsonResponse['recent_diastolic_bp']?.toInt() ?? 0;

        return {
          //'date': formattedDate,
          'dayBpSystolic': avgSystolic,
          'dayBpDiastolic': avgDiastolic,
          'chartData': chartData,
          'targetSystolic': targetSystolic,
          'diastolic_sd_high': diastolic_sd_high,
          'diastolic_sd_low': diastolic_sd_low,
          'systolic_sd_high': systolic_sd_high,
          'systolic_sd_low': systolic_sd_low,
          'targetDiastolic': targetDiastolic,
          'recent_datetime': recentdate,
        };
      } else {
        throw Exception('Failed Day Chart: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching Day Chart: $e');
      rethrow;
    }
  }






  Future<Map<String, dynamic>> Week_Chart(String userId, String date,) async {
    final String url = '$root/daily_bp_data';
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
        print('Weekly BP Response: $jsonResponse');

        if (jsonResponse['status'] == "SUCCESS") {
          // Process weekly data
          List<dynamic> weeklyData = jsonResponse['weekly_bp_data'];
          List<BloodPressureData> chartData = [];

          // Get targets
          int targetSystolic = jsonResponse['target_systolic_bp'] ?? 120;
          int targetDiastolic = jsonResponse['target_diastolic_bp'] ?? 80;
          final String? recentdate = jsonResponse['recent_datetime']?.toString();
          final double diastolic_sd_high = (jsonResponse['diastolic_sd_high'] as num?)?.toDouble() ?? 0.0;
          final double systolic_sd_low = (jsonResponse['systolic_sd_low'] as num?)?.toDouble() ?? 0.0;
          final double systolic_sd_high = (jsonResponse['systolic_sd_high'] as num?)?.toDouble() ?? 0.0;
          final double diastolic_sd_low = (jsonResponse['diastolic_sd_low'] as num?)?.toDouble() ?? 0.0;
          // Calculate weekly averages
          double systolicSum = 0;
          double diastolicSum = 0;
          int validDays = 0;

          //List<BloodPressureData> chartData = [];

          DateTime weekStart = DateFormat('yyyy-MM-dd').parse(jsonResponse['week_start']);
          Map<String, dynamic> dataMap = {
            for (var entry in weeklyData) entry['date']: entry
          };

          for (int i = 0; i < 7; i++) {
            DateTime currentDate = weekStart.add(Duration(days: i));
            String dateStr = DateFormat('yyyy-MM-dd').format(currentDate);
            String dayName = DateFormat('E').format(currentDate); // Mon, Tue, ..., Sun

            var dayData = dataMap[dateStr];

            // If data exists for the date, use it; else use 0
            double systolicAvg = dayData?['average_systolic']?.toDouble() ?? 0;
            double diastolicAvg = dayData?['average_diastolic']?.toDouble() ?? 0;

            chartData.add(BloodPressureData(
              date: currentDate,
              day: dayName,
              systolic: systolicAvg.round(),
              diastolic: diastolicAvg.round(),
              months: '',
              Year: '',
              targetSystolic: targetSystolic,
              targetDiastolic: targetDiastolic,
              diastolic_sd_high: dayData?['diastolic_sd_high']?.toDouble() ?? 0,
              diastolic_sd_low: dayData?['diastolic_sd_low']?.toDouble() ?? 0,
              systolic_sd_high: dayData?['systolic_sd_high']?.toDouble() ?? 0,
              systolic_sd_low: dayData?['systolic_sd_low']?.toDouble() ?? 0,
            ));
          }


          int weeklySystolic = jsonResponse['recent_systolic_bp']?.toInt() ?? 0;
          int weeklyDiastolic = jsonResponse['recent_diastolic_bp']?.toInt() ?? 0;

          return {
            'chartData': chartData,
            'weekBpSystolic': weeklySystolic,
            'weekBpDiastolic': weeklyDiastolic,
            'targetSystolic': targetSystolic,
            'targetDiastolic': targetDiastolic,
            'mainDate': '${jsonResponse['week_start']} to ${jsonResponse['week_end']}',
            'recent_datetime': recentdate,
            'diastolic_sd_low': diastolic_sd_low,
            'systolic_sd_high': systolic_sd_high,
            'systolic_sd_low': systolic_sd_low,
            'diastolic_sd_high': diastolic_sd_high,
          };
        } else {
          throw Exception('API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching weekly BP data: $e');
      rethrow;
    }
  }



  Future<Map<String, dynamic>> Month_Chart(String userId, String date) async {
    final String url = '$root/daily_bp_data';
    final Map<String, dynamic> payload = {
      'user_id': userId,
      'date': date,
      'type': 'monthly'
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('Monthly BP Response: $jsonResponse');

        if (jsonResponse['status'] == "SUCCESS") {
          final Map<String, dynamic> monthlyData = jsonResponse['monthly_bp_data'];
          List<BloodPressureData> chartData = [];

          int targetSystolic = jsonResponse['target_systolic_bp'] ?? 120;
          int targetDiastolic = jsonResponse['target_diastolic_bp'] ?? 80;
          final String? recentDate = jsonResponse['recent_datetime']?.toString();
          final double diastolic_sd_high = (jsonResponse['diastolic_sd_high'] as num?)?.toDouble() ?? 0.0;
          final double systolic_sd_low = (jsonResponse['systolic_sd_low'] as num?)?.toDouble() ?? 0.0;
          final double systolic_sd_high = (jsonResponse['systolic_sd_high'] as num?)?.toDouble() ?? 0.0;
          final double diastolic_sd_low = (jsonResponse['diastolic_sd_low'] as num?)?.toDouble() ?? 0.0;

          final DateTime today = DateTime.now();
          final DateTime monthStart = DateTime(today.year, today.month, 1);

          for (int i = 1; i <= 5; i++) {
            String weekKey = 'W$i';
            final data = monthlyData[weekKey];

            // Default start/end dates
            final DateTime defaultStartDate = monthStart.add(Duration(days: (i - 1) * 7));
            final String startDateStr = data?['start_date'] ?? defaultStartDate.toIso8601String();

            final DateTime startDate = DateTime.tryParse(startDateStr) ?? defaultStartDate;

            // Extract averages or fallback to 0
            double systolicAvg = data?['average_systolic']?.toDouble() ?? 0;
            double diastolicAvg = data?['average_diastolic']?.toDouble() ?? 0;

            final DateTime endDate = data?['end_date'] != null
                ? DateTime.tryParse(data['end_date']) ?? startDate.add(const Duration(days: 6))
                : startDate.add(const Duration(days: 6));

            bool isCurrentWeek = today.isAfter(startDate.subtract(const Duration(days: 1))) &&
                today.isBefore(endDate.add(const Duration(days: 1)));

            chartData.add(BloodPressureData(
              date: startDate,
              systolic: systolicAvg.round(),
              diastolic: diastolicAvg.round(),
              day: 'Week $i',
              months: weekKey,
              Year: '',
              targetSystolic: targetSystolic,
              targetDiastolic: targetDiastolic,
              systolic_sd_high: isCurrentWeek ? systolic_sd_high : 0,
              systolic_sd_low: isCurrentWeek ? systolic_sd_low : 0,
              diastolic_sd_high: isCurrentWeek ? diastolic_sd_high : 0,
              diastolic_sd_low: isCurrentWeek ? diastolic_sd_low : 0,
            ));
          }

          int monthlySystolic = jsonResponse['recent_systolic_bp']?.toInt() ?? 0;
          int monthlyDiastolic = jsonResponse['recent_diastolic_bp']?.toInt() ?? 0;

          return {
            'chartData': chartData,
            'weekBpSystolic': monthlySystolic,
            'weekBpDiastolic': monthlyDiastolic,
            'targetSystolic': targetSystolic,
            'targetDiastolic': targetDiastolic,
            'mainDate': '${jsonResponse['month_start']} to ${jsonResponse['month_end']}',
            'recent_datetime': recentDate,
            'diastolic_sd_low': diastolic_sd_low,
            'systolic_sd_high': systolic_sd_high,
            'systolic_sd_low': systolic_sd_low,
            'diastolic_sd_high': diastolic_sd_high,
          };
        } else {
          throw Exception('API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching monthly BP data: $e');
      rethrow;
    }
  }



  Future<Map<String, dynamic>> Year_Chart(String userId, String date) async {
    final String url = '$root/daily_bp_data';
    final Map<String, dynamic> payload = {
      'user_id': userId,
      'date': date,
      'type': 'yearly'
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('Yearly BP Response: $jsonResponse');

        if (jsonResponse['status'] == "SUCCESS") {
          final Map<String, dynamic> yearlyData = jsonResponse['yearly_bp_data'];
          List<BloodPressureData> chartData = [];

          int targetSystolic = jsonResponse['target_systolic_bp'] ?? 120;
          int targetDiastolic = jsonResponse['target_diastolic_bp'] ?? 80;
          final String? recentDate = jsonResponse['recent_datetime']?.toString();
          final double diastolicSdHigh = (jsonResponse['diastolic_sd_high'] as num?)?.toDouble() ?? 0.0;
          final double systolicSdLow = (jsonResponse['systolic_sd_low'] as num?)?.toDouble() ?? 0.0;
          final double systolicSdHigh = (jsonResponse['systolic_sd_high'] as num?)?.toDouble() ?? 0.0;
          final double diastolicSdLow = (jsonResponse['diastolic_sd_low'] as num?)?.toDouble() ?? 0.0;

          yearlyData.forEach((monthKey, data) {
            final String startDate = data['start_date'] ?? '';
            double systolicAvg = (data['average_systolic'] as num?)?.toDouble() ?? 0.0;
            double diastolicAvg = (data['average_diastolic'] as num?)?.toDouble() ?? 0.0;


            chartData.add(BloodPressureData(
              date: DateTime.tryParse(startDate) ?? DateTime.now(),
              systolic: systolicAvg.round(),
              diastolic: diastolicAvg.round(),
              day: '',
              months: monthKey,
              Year: DateTime.tryParse(startDate)?.year.toString() ?? '',
              targetSystolic: targetSystolic,
              targetDiastolic: targetDiastolic,
              diastolic_sd_high: 0,
              diastolic_sd_low: 0,
              systolic_sd_high: 0,
              systolic_sd_low: 0,
            ));
          });

          int yearlySystolic = jsonResponse['recent_systolic_bp']?.toInt() ?? 0;
          int yearlyDiastolic = jsonResponse['recent_diastolic_bp']?.toInt() ?? 0;

          return {
            'chartData': chartData,
            'weekBpSystolic': yearlySystolic,
            'weekBpDiastolic': yearlyDiastolic,
            'targetSystolic': targetSystolic,
            'targetDiastolic': targetDiastolic,
            'mainDate': '${jsonResponse['year_start']} to ${jsonResponse['year_end']}',
            'recent_datetime': recentDate,
            'diastolic_sd_low': diastolicSdLow,
            'systolic_sd_high': systolicSdHigh,
            'systolic_sd_low': systolicSdLow,
            'diastolic_sd_high': diastolicSdHigh,
          };
        } else {
          throw Exception('API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching yearly BP data: $e');
      rethrow;
    }

  }


  Future<Map<String, dynamic>> MultiYear_Chart(String userId,  int toYear) async {
    final String url = '$root/get_multiyear_bp_data';
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
        body: jsonEncode(payload),
      );

      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('MultiYear Response: $jsonResponse');

        if (jsonResponse['status'] == "SUCCESS") {
          final Map<String, dynamic> multiYearData = jsonResponse['multiyear_bp_data'] ?? {};
          List<BloodPressureData> chartData = [];

          int targetSystolic = jsonResponse['target_systolic_bp'] ?? 130;
          int targetDiastolic = jsonResponse['target_diastolic_bp'] ?? 80;
          final String? recentDate = jsonResponse['recent_datetime']?.toString();

          // Initialize for last processed values
          double systolicAvg = 0.0;
          double diastolicAvg = 0.0;
          double systolicSdHigh = 0.0;
          double systolicSdLow = 0.0;
          double diastolicSdHigh = 0.0;
          double diastolicSdLow = 0.0;

          List<String> sortedYears = multiYearData.keys.toList()..sort();

          for (String yearKey in sortedYears) {
            var data = multiYearData[yearKey];

            double systolicAvg = data?['average_systolic']?.toDouble() ?? 0;
            double diastolicAvg = data?['average_diastolic']?.toDouble() ?? 0;
            systolicSdHigh = (data['systolic_sd_high'] as num?)?.toDouble() ?? 0.0;
            systolicSdLow = (data['systolic_sd_low'] as num?)?.toDouble() ?? 0.0;
            diastolicSdHigh = (data['diastolic_sd_high'] as num?)?.toDouble() ?? 0.0;
            diastolicSdLow = (data['diastolic_sd_low'] as num?)?.toDouble() ?? 0.0;

            chartData.add(BloodPressureData(
              date: DateTime(int.parse(yearKey)),
              systolic: systolicAvg.round(),
              diastolic: diastolicAvg.round(),
              day: '',
              months: '',
              Year: yearKey,
              targetSystolic: targetSystolic,
              targetDiastolic: targetDiastolic,
              diastolic_sd_high: diastolicSdHigh,
              diastolic_sd_low: diastolicSdLow,
              systolic_sd_high: systolicSdHigh,
              systolic_sd_low: systolicSdLow,
            ));
          }

          int yearlySystolic = jsonResponse['recent_systolic_bp']?.toInt() ?? 0;
          int yearlyDiastolic = jsonResponse['recent_diastolic_bp']?.toInt() ?? 0;

          return {
            'chartData': chartData,
            'targetSystolic': targetSystolic,
            'targetDiastolic': targetDiastolic,
            'mainDate': '${jsonResponse['from_year']} to ${jsonResponse['to_year']}',
            'recent_datetime': recentDate,
            'weekBpSystolic':yearlySystolic,
            'weekBpDiastolic':yearlyDiastolic,
            'systolic_sd_high': systolicSdHigh,
            'systolic_sd_low': systolicSdLow,
            'diastolic_sd_high': diastolicSdHigh,
            'diastolic_sd_low': diastolicSdLow,
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

  // Future<Map<String, dynamic>> MultiYear_Chart(String userId, int fromYear, int fromMonth, int toYear, int toMonth) async {
  //   final String url = '$root/get_multiyear_bp_data';
  //   print("URL: $url");
  //
  //   final Map<String, dynamic> payload = {
  //     'user_id': userId,
  //     'from_year': '${fromYear.toString()}-${fromMonth.toString().padLeft(2, '0')}',
  //     'to_year': '${toYear.toString()}-${toMonth.toString().padLeft(2, '0')}',
  //   };
  //
  //   print("Request Payload: $payload");
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(payload),
  //     );
  //
  //     print('Response Body: ${response.body}');
  //
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //       print('MultiYear Response: $jsonResponse');
  //
  //       if (jsonResponse['status'] == "SUCCESS") {
  //         final Map<String, dynamic> multiYearData = jsonResponse['multiyear_bp_data'] ?? {};
  //         List<BloodPressureData> chartData = [];
  //
  //         int targetSystolic = jsonResponse['target_systolic_bp'] ?? 120;
  //         int targetDiastolic = jsonResponse['target_diastolic_bp'] ?? 80;
  //         final String? recentDate = jsonResponse['recent_datetime']?.toString();
  //
  //         // Initialize for last processed values
  //         double systolicAvg = 0.0;
  //         double diastolicAvg = 0.0;
  //         double systolicSdHigh = 0.0;
  //         double systolicSdLow = 0.0;
  //         double diastolicSdHigh = 0.0;
  //         double diastolicSdLow = 0.0;
  //
  //         List<String> sortedYears = multiYearData.keys.toList()..sort();
  //
  //         for (String yearKey in sortedYears) {
  //           var data = multiYearData[yearKey];
  //
  //           systolicAvg = data?['average_systolic']?.toDouble() ?? 0;
  //           diastolicAvg = data?['average_diastolic']?.toDouble() ?? 0;
  //           systolicSdHigh = (data['systolic_sd_high'] as num?)?.toDouble() ?? 0.0;
  //           systolicSdLow = (data['systolic_sd_low'] as num?)?.toDouble() ?? 0.0;
  //           diastolicSdHigh = (data['diastolic_sd_high'] as num?)?.toDouble() ?? 0.0;
  //           diastolicSdLow = (data['diastolic_sd_low'] as num?)?.toDouble() ?? 0.0;
  //
  //           chartData.add(BloodPressureData(
  //             date: DateTime(int.parse(yearKey)),
  //             systolic: systolicAvg.round(),
  //             diastolic: diastolicAvg.round(),
  //             day: '',
  //             months: '',
  //             Year: yearKey,
  //             targetSystolic: targetSystolic,
  //             targetDiastolic: targetDiastolic,
  //             diastolic_sd_high: diastolicSdHigh,
  //             diastolic_sd_low: diastolicSdLow,
  //             systolic_sd_high: systolicSdHigh,
  //             systolic_sd_low: systolicSdLow,
  //           ));
  //         }
  //
  //         return {
  //           'chartData': chartData,
  //           'targetSystolic': targetSystolic,
  //           'targetDiastolic': targetDiastolic,
  //           'mainDate': '${jsonResponse['from_year']} to ${jsonResponse['to_year']}',
  //           'recent_datetime': recentDate,
  //           'weekBpSystolic': systolicAvg.round(),
  //           'weekBpDiastolic': diastolicAvg.round(),
  //           'systolic_sd_high': systolicSdHigh,
  //           'systolic_sd_low': systolicSdLow,
  //           'diastolic_sd_high': diastolicSdHigh,
  //           'diastolic_sd_low': diastolicSdLow,
  //         };
  //       } else {
  //         throw Exception('API Error: ${jsonResponse['error'] ?? jsonResponse['message']}');
  //       }
  //     } else {
  //       throw Exception('Failed to load data. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching multi-year BP data: $e');
  //     rethrow;
  //   }
  // }


















}