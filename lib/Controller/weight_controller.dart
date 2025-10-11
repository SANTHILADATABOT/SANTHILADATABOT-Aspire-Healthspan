
import 'dart:convert';
import 'package:aspire/Model/weight_model.dart';
import 'package:aspire/root/root.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:aspire/root/root.dart';


class WeightController extends GetxController {

  String _getAbbreviatedDay(String dayName) {
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
        return 'Unknown'; // Return 'Unknown' if the day doesn't match
    }
  }



  Future<Map<String, dynamic>> Week_Chart(String userId, String date) async {
    final String url = "$root/weight";
    final Map<String, dynamic> payload = {
      'user_id': userId,
      'date': date,
      'filter': 'week',
    };

    print('Sending payload: $payload');

    try {
      final response = await http.post(Uri.parse(url), body: payload);

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print("Weekly Weight Response: $jsonResponse");

        if (jsonResponse['status'] == "SUCCESS") {
          List<dynamic> weeklyData = jsonResponse['week_chart_weight'] ?? [];
          List<WeightChartData> chartData = [];
          int weighttarget = jsonResponse['weight_target'] ?? 215;
          int bmitarget = jsonResponse['bmi_target'] ?? 30;

          print("weighttarget:$weighttarget");
          print("bmitarget:$bmitarget");

          // ✅ get first data point’s date or fallback to now
          DateTime rawDate;
          try {
            rawDate = weeklyData.isNotEmpty
                ? DateTime.parse(weeklyData.first['datetime']).toUtc()
                : DateTime.now().toUtc();
          } catch (_) {
            rawDate = DateTime.now().toUtc();
          }

          // ✅ align Monday as start of the week (Monday = 1)
          int weekday = rawDate.weekday; // 1 = Mon, 7 = Sun
          DateTime weekStartDate = rawDate.subtract(Duration(days: weekday - 1));

          // ✅ loop from Monday to Sunday
          for (int i = 0; i < 7; i++) {
            DateTime currentDate = weekStartDate.add(Duration(days: i));
            String dateStr = DateFormat('yyyy-MM-dd').format(currentDate);
            String dayName = DateFormat('E').format(currentDate.toLocal());

            var dayData = weeklyData.firstWhere(
                  (entry) {
                DateTime entryDate = DateTime.parse(entry['datetime']).toUtc();
                return DateFormat('yyyy-MM-dd').format(entryDate) == dateStr;
              },
              orElse: () => null,
            );

            double weightValRaw =
                (dayData?['weight_chart'] as num?)?.toDouble() ?? 0.0;
            double bmiValRaw = (dayData?['bmi_chart'] as num?)?.toDouble() ?? 0.0;

            double weightVal = weightValRaw.roundToDouble();
            int bmiVal = bmiValRaw.truncate();

            print(
                "$dayName [$dateStr] → match: ${dayData != null} | weight: $weightVal, bmi: $bmiVal");

            chartData.add(WeightChartData(
              date: currentDate.toLocal(),
              day: dayName,
              weightrate: weightVal,
              bmidata: bmiVal.toDouble(),
              months: '',
              Years: '',
            ));
          }

          return {
            'chartData': chartData,
            'weight': jsonResponse['week_weight'],
            'bmi': jsonResponse['bmi'],
            'mainDate': jsonResponse['week_date_time'],
            'weight_target':weighttarget,
            'bmi_target':bmitarget

          };
        } else {
          throw Exception('API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception(
            'Failed to load weight data. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching weekly weight data: $e');
      rethrow;
    }
  }


  // Future<Map<String, dynamic>> Month_Chart(String userId, String date) async {
  //   final String url = "$root/weight";
  //   final Map<String, dynamic> payload = {
  //     'user_id': userId,
  //     'date': date,
  //     'filter': 'month',
  //   };
  //
  //   print('Sending payload: $payload');
  //
  //   try {
  //     final response = await http.post(Uri.parse(url), body: payload);
  //
  //     print("Response Status: ${response.statusCode}");
  //     print("Response Body: ${response.body}");
  //
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //       print("Monthly Weight Response: $jsonResponse");
  //
  //       if (jsonResponse['status'] == "SUCCESS") {
  //         final Map<String, dynamic> monthChartData = jsonResponse['month_chart_weight'] ?? {};
  //         List<WeightChartData> chartData = [];
  //         int weighttarget = jsonResponse['weight_target'] ?? 215;
  //         int bmitarget = jsonResponse['bmi_target'] ?? 30;
  //
  //         monthChartData.forEach((weekKey, weekData) {
  //           String startDateStr = weekData['start_date'] ?? '';
  //           String endDateStr = weekData['end_date'] ?? '';
  //
  //           DateTime startDate = DateTime.tryParse(startDateStr) ?? DateTime.now();
  //           DateTime endDate = DateTime.tryParse(endDateStr) ?? DateTime.now();
  //
  //           double avgWeight = (weekData['average_weight'] as num?)?.toDouble() ?? 0.0;
  //           double avgBmi = (weekData['average_bmi'] as num?)?.toDouble() ?? 0.0;
  //
  //           double weightVal = avgWeight.roundToDouble();
  //           int bmiVal = avgBmi.truncate();
  //
  //           print(
  //               "$weekKey [${DateFormat('MMM dd').format(startDate)} - ${DateFormat('MMM dd').format(endDate)}] → weight: $weightVal, bmi: $bmiVal");
  //
  //           chartData.add(
  //             WeightChartData(
  //               date: startDate.toLocal(),
  //               day: '', // you can label them as "W1", "W2", etc. in the chart
  //               weightrate: weightVal,
  //               bmidata: bmiVal.toDouble(),
  //               months: weekKey,
  //               Years: '',
  //             ),
  //           );
  //         });
  //
  //         return {
  //           'chartData': chartData,
  //           'weight': jsonResponse['month_weight'],
  //           'bmi': jsonResponse['bmi'],
  //           'mainDate': jsonResponse['month_date_time'],
  //           'weight_target':weighttarget,
  //           'bmi_target':bmitarget
  //         };
  //       } else {
  //         throw Exception('API Error: ${jsonResponse['message']}');
  //       }
  //     } else {
  //       throw Exception(
  //           'Failed to load month weight data. Status: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching monthly weight data: $e');
  //     rethrow;
  //   }
  // }

  Future<Map<String, dynamic>> Month_Chart(String userId, String date) async {
    final String url = "$root/weight";
    final Map<String, dynamic> payload = {
      'user_id': userId,
      'date': date,
      'filter': 'month',
    };

    print('Sending payload: $payload');

    List<String> generateWeekLabels(String yearMonth) {
      final parts = yearMonth.split("-");
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0); // Last day of month

      int totalDays = lastDay.day;
      int offsetDays = firstDay.weekday - 1; // Days before 1st to align with week
      int numWeeks = ((offsetDays + totalDays) / 7).ceil();

      return List.generate(numWeeks, (index) => 'W${index + 1}');
    }

    try {
      final response = await http.post(Uri.parse(url), body: payload);

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print("Monthly Weight Response: $jsonResponse");

        if (jsonResponse['status'] == "SUCCESS") {
          final Map<String, dynamic> monthChartData = jsonResponse['month_chart_weight'] ?? {};
          List<WeightChartData> chartData = [];
          int weighttarget = jsonResponse['weight_target'] ?? 215;
          int bmitarget = jsonResponse['bmi_target'] ?? 30;

          // 🔁 Dynamically generate week labels based on the selected month
          final List<String> weekLabels = generateWeekLabels(date);

          for (String weekKey in weekLabels) {
            if (monthChartData.containsKey(weekKey)) {
              final weekData = monthChartData[weekKey];

              String startDateStr = weekData['start_date'] ?? '';
              String endDateStr = weekData['end_date'] ?? '';

              DateTime startDate = DateTime.tryParse(startDateStr) ?? DateTime.now();
              DateTime endDate = DateTime.tryParse(endDateStr) ?? DateTime.now();

              double avgWeight = (weekData['average_weight'] as num?)?.toDouble() ?? 0.0;
              double avgBmi = (weekData['average_bmi'] as num?)?.toDouble() ?? 0.0;

              double weightVal = avgWeight.roundToDouble();
              int bmiVal = avgBmi.truncate();

              print(
                  "$weekKey [${DateFormat('MMM dd').format(startDate)} - ${DateFormat('MMM dd').format(endDate)}] → weight: $weightVal, bmi: $bmiVal");

              chartData.add(
                WeightChartData(
                  date: startDate.toLocal(),
                  day: '',
                  weightrate: weightVal,
                  bmidata: bmiVal.toDouble(),
                  months: weekKey,
                  Years: '',
                ),
              );
            } else {
              // No data for this week → fill with 0
              chartData.add(
                WeightChartData(
                  date: DateTime.now(), // Optional placeholder
                  day: '',
                  weightrate: 0.0,
                  bmidata: 0.0,
                  months: weekKey,
                  Years: '',
                ),
              );
            }
          }

          return {
            'chartData': chartData,
            'weight': jsonResponse['month_weight'],
            'bmi': jsonResponse['bmi'],
            'mainDate': jsonResponse['month_date_time'],
            'weight_target': weighttarget,
            'bmi_target': bmitarget
          };
        } else {
          throw Exception('API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load month weight data. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching monthly weight data: $e');
      rethrow;
    }
  }



  Future<Map<String, dynamic>> Year_Chart(String userId, String date) async {
    final String url = "$root/weight";
    final Map<String, dynamic> payload = {
      'user_id': userId,
      'date': date,
      'filter': 'year',
    };

    print('Sending payload: $payload');

    try {
      final response = await http.post(Uri.parse(url), body: payload);

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print("Yearly Weight Response: $jsonResponse");

        if (jsonResponse['status'] == "SUCCESS") {
          List<dynamic> yearlyData = jsonResponse['year_chart_weight'] ?? [];
          List<WeightChartData> chartData = [];
          int weighttarget = jsonResponse['weight_target'] ?? 215;
          int bmitarget = jsonResponse['bmi_target'] ?? 30;

          // ✅ Sort data by date_time in ascending order
          yearlyData.sort((a, b) {
            DateTime dateA = DateFormat('yyyy-MM').parse(a['date_time'], true);
            DateTime dateB = DateFormat('yyyy-MM').parse(b['date_time'], true);

            return dateA.compareTo(dateB); // Jan → Dec
          });

          for (var entry in yearlyData) {
            String dateStr = entry['date_time'];
            String monthName = entry['month_name'];

            DateTime parsedDate;
            try {
              parsedDate = DateFormat('yyyy-MM').parse(dateStr, true).toUtc();
            } catch (_) {
              parsedDate = DateTime.now().toUtc();
            }


            double weightValRaw = (entry['weight_chart'] as num?)?.toDouble() ?? 0.0;
            double bmiValRaw = (entry['bmi_chart'] as num?)?.toDouble() ?? 0.0;

            double weightVal = weightValRaw.roundToDouble();
            int bmiVal = bmiValRaw.truncate();

            print("$monthName [$dateStr] → weight: $weightVal, bmi: $bmiVal");

            chartData.add(WeightChartData(
              date: parsedDate.toLocal(),
              day: '',
              weightrate: weightVal,
              bmidata: bmiVal.toDouble(),
              months: DateFormat('MMM').format(parsedDate), // Short month
              Years: parsedDate.year.toString(),
            ));
          }

          return {
            'chartData': chartData,
            'weight': jsonResponse['year_weight'],
            'bmi': jsonResponse['bmi'],
            'mainDate': jsonResponse['month_datetime'],
            'weight_target':weighttarget,
            'bmi_target':bmitarget
          };
        }
        else {
          throw Exception('API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load year data. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching yearly weight data: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> MultiYear_Chart(String userId,  int toYear) async {
    final String url = '$root/weight';
    print("URL: $url");

    final Map<String, dynamic> payload = {
      'user_id': userId,
      'filter':'multiyear',
      // 'from_year': '${fromYear.toString()}',
      'date': '${toYear.toString()}',
    };

    print('Sending payload: $payload');

    try {
      final response = await http.post(Uri.parse(url), body: payload);

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print("Multi-Year Weight Response: $jsonResponse");

        if (jsonResponse['status'] == "SUCCESS") {
          List<dynamic> multiyearData = jsonResponse['multiyear_chart_weight'] ?? [];
          List<WeightChartData> chartData = [];
          int weighttarget = jsonResponse['weight_target'] ?? 215;
          int bmitarget = jsonResponse['bmi_target'] ?? 30;

          // ✅ Sort by date_time ascending (old to recent)
          multiyearData.sort((a, b) {
            DateTime dateA = DateFormat('yyyy-MM-dd HH:mm:ss').parse(a['date_time'], true);
            DateTime dateB = DateFormat('yyyy-MM-dd HH:mm:ss').parse(b['date_time'], true);

            return dateA.compareTo(dateB);
          });

          for (var entry in multiyearData) {
            String dateStr = entry['date_time'];
            String yearLabel = entry['year'];

            DateTime parsedDate;
            try {
              parsedDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateStr, true).toUtc();
            } catch (_) {
              parsedDate = DateTime.now().toUtc();
            }

            double weightValRaw = (entry['weight_chart'] as num?)?.toDouble() ?? 0.0;
            double bmiValRaw = (entry['bmi_chart'] as num?)?.toDouble() ?? 0.0;

            double weightVal = weightValRaw.roundToDouble();
            int bmiVal = bmiValRaw.truncate();

            print("$yearLabel [$dateStr] → weight: $weightVal, bmi: $bmiVal");

            chartData.add(WeightChartData(
              date: parsedDate.toLocal(),
              day: '',
              weightrate: weightVal,
              bmidata: bmiVal.toDouble(),
              months: '',
              Years: parsedDate.year.toString(),
            ));
          }

          return {
            'chartData': chartData,
            'weight': jsonResponse['year_weight'],
            'bmi': jsonResponse['bmi'],
            'mainDate': jsonResponse['year_datetime'],
            'weight_target':weighttarget,
            'bmi_target':bmitarget
          };
        } else {
          throw Exception('API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load multiyear data. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching multiyear weight data: $e');
      rethrow;
    }
  }



}