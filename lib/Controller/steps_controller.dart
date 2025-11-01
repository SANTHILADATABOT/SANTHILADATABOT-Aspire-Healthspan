import 'dart:convert';
import 'package:aspire/Model/steps_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:aspire/root/root.dart';
import 'package:intl/intl.dart';



class StepsController extends GetxController{

  String getShortDayName(String fullDay) {
    switch (fullDay) {
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
        return '';
    }
  }

  Future<Map<String, dynamic>> Day_Chart({
    required String userId,
    required String date,
  }) async {
    final String url = "https://app.aspirehealthspan.ai/aspire_api/daily_step_data";
    final Map<String, dynamic> payload = {
      'user_id': userId,
      'date': date,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print('Request Payload: $payload');
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('Steps Day Response: $jsonResponse');


        if (jsonResponse['status'] == "SUCCESS") {
          final List<dynamic> stepEntries = jsonResponse['step_intervals'] ??
              [];
          final String? dateString = jsonResponse['date'];
          final String recentSteps = jsonResponse['recent_step'] ?? 0;
          final String? recentdate = jsonResponse['recent_datetime']
              ?.toString();
          int target_steps = jsonResponse['target_step'] ?? 4000;
          double r_miles = jsonResponse['recent_miles'].toDouble() ?? 0.0;
          double r_calories = jsonResponse['recent_cal_burn'].toDouble() ?? 0.0;

         r_miles = double.parse(r_miles.toStringAsFixed(1));
          r_calories = double.parse(r_calories.toStringAsFixed(1));




          DateTime parsedDate = DateTime.tryParse(dateString ?? '') ??
              DateTime.parse(date);
          String formattedDate = DateFormat('MMM dd, yyyy – hh:mm a').format(
              parsedDate);


          int max_steps = 0;


          // List<StepsData> chartData = stepEntries.map((entry) {
          //   String hourStr = entry['interval']?.toString() ?? '00:00';
          //   List<String> parts = hourStr.split(":");
          //   int hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
          //   int steps = (entry['total_steps'] as num?)?.toInt() ?? 0;
          //   double miles = (entry['miles'] as num?)?.toDouble() ?? 0.0;
          //   double calories = (entry['cal_burn'] as num?)?.toDouble() ?? 0.0;
          //
          //   print("Miles:$miles");
          //   print("Calories:$calories");
          //
          //   miles = double.parse(miles.toStringAsFixed(1));
          //   calories = double.parse(calories.toStringAsFixed(1));
          //
          //
          //
          //   if (steps > max_steps) {
          //     max_steps = steps;
          //     //maxStepsDate = dayData['date']; // or use `date.toString()` if preferred
          //   }
          //
          //   DateTime fullDateTime = DateTime.utc(
          //     parsedDate.year,
          //     parsedDate.month,
          //     parsedDate.day,
          //     hour,
          //   );
          //
          //   print("Parsed: hourStr=$hourStr, hour=$hour, steps=$steps, date=$fullDateTime");
          //
          //   return StepsData(
          //     day: hourStr,
          //     dailySteps: steps,
          //     date: fullDateTime,
          //     monthName: '',
          //     year: '',
          //     steps: steps,
          //     miles: miles,
          //     caloriesBurned: calories,
          //     totalSteps: steps,
          //     targetsteps: target_steps,
          //   );
          // }).toList();

          // 🔁 Ensure full 24-hour chart data (00 to 23)
          List<StepsData> chartData = [];

          for (int hour = 0; hour < 24; hour++) {
            // String hourStr = hour.toString().padLeft(2, '0') + ":00";
            // String hourKey = hour.toString(); // for x-axis labels
            String hourStr = hour.toString().padLeft(2, '0') + ":00";
            String hourKey = hour.toString(); // for x-axis label (0–23)

            var match = stepEntries.firstWhere(
                  (entry) => entry['interval'] == hourStr,
              orElse: () => null,
            );

            int steps = 0;
            double miles = 0.0;
            double calories = 0.0;

            if (match != null) {
              steps = (match['total_steps'] as num?)?.toInt() ?? 0;
              miles = (match['miles'] as num?)?.toDouble() ?? 0.0;
              calories = (match['cal_burn'] as num?)?.toDouble() ?? 0.0;
            }

            miles = double.parse(miles.toStringAsFixed(1));
            calories = double.parse(calories.toStringAsFixed(1));

            if (steps > max_steps) {
              max_steps = steps;
            }

            DateTime fullDateTime = DateTime.utc(
              parsedDate.year,
              parsedDate.month,
              parsedDate.day,
              hour,
            );

            print("Parsed: hourStr=$hourStr, hour=$hour, steps=$steps, date=$fullDateTime");

            chartData.add(StepsData(
              day: hourKey,
              labelHour: hourStr,// x-axis label: "0" to "23"
              dailySteps: steps,
              date: fullDateTime,
              monthName: '',
              year: '',
              steps: steps,
              miles: miles,
              caloriesBurned: calories,
              totalSteps: steps,
              targetsteps: target_steps,
            ));
          }


          return {
            'date': formattedDate,
            'recentSteps': recentSteps,
            'chartData': chartData,
            'step_intervals': stepEntries,
            'recent_datetime': recentdate,
            'targetsteps': target_steps,
            'maxSteps': max_steps,
            'miles': r_miles,         // ✅ added
            'calories': r_calories,   // ✅ added
          };

        }

        else {
          throw Exception('API Error: ${jsonResponse['message']}');
        }
      }

      else {
        throw Exception('Failed to load steps day chart. Status code: ${response.statusCode}');
      }

    }
    catch (e) {
      print("Error in Day_Chart (Steps): $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> Week_Chart({
    required String userId,
    required String date,
  }) async {
    final String url = 'https://app.aspirehealthspan.ai/aspire_api/daily_step_data';
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
        print('Weekly Steps Response: $jsonResponse');

        if (jsonResponse['status'] == "SUCCESS") {
          List<dynamic> weeklyData = jsonResponse['weekly_step_data'];
          List<StepsData> chartData = [];

          String recentSteps = jsonResponse['recent_step'] ?? 0;
          String? recentdate = jsonResponse['recent_datetime']?.toString();
          int target_steps = jsonResponse['target_step'] ?? 10000;
          double r_miles = jsonResponse['recent_miles'].toDouble() ?? 0.0;
          double r_calories = jsonResponse['recent_cal_burn'].toDouble() ?? 0.0;
          int dailyavgSteps = jsonResponse['daily_avg_steps'] ?? 0;

          r_miles = double.parse(r_miles.toStringAsFixed(1));
          r_calories = double.parse(r_calories.toStringAsFixed(1));

          final Set<String> seenDays = {}; // Track unique day names

          int max_steps = 0;
          for (var dayData in weeklyData) {
            DateTime date = DateFormat('yyyy-MM-dd').parse(dayData['date']);
            String dayName = DateFormat('E').format(date); // Mon, Tue, etc.
            int steps = dayData['total_steps'] ?? 0;
            double miles = (dayData['miles'] as num?)?.toDouble() ?? 0.0;
            double calories = (dayData['cal_burn'] as num?)?.toDouble() ?? 0.0;

            miles = double.parse(miles.toStringAsFixed(1));
            calories = double.parse(calories.toStringAsFixed(1));

            if (steps > max_steps) {
              max_steps = steps;
              //maxStepsDate = dayData['date']; // or use `date.toString()` if preferred
            }

            // Only add if this day hasn't been added already
            if (!seenDays.contains(dayName)) {
              seenDays.add(dayName);

              chartData.add(StepsData(
                date: date,
                day: dayName,
                dailySteps: steps,
                steps: steps,
                miles: miles,
                caloriesBurned: calories,
                monthName: '',
                year: '',
                totalSteps: steps,
                targetsteps: target_steps, labelHour: '',
              ));
            }
          }

          return {
            'chartData': chartData,
            'recent_step': recentSteps,
            'mainDate': '${jsonResponse['week_start']} to ${jsonResponse['week_end']}',
            'recent_datetime': recentdate,
            'targetsteps':target_steps,
            'maxSteps':max_steps,
            'miles': r_miles,         // ✅ added
            'calories': r_calories,
            'daily_avg_steps':dailyavgSteps
          };
        } else {
          throw Exception('API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching weekly steps data: $e');
      rethrow;
    }
  }


  Future<Map<String, dynamic>> Month_Chart({
    required String userId,
    required String date,
  }) async {
    final String url = 'https://app.aspirehealthspan.ai/aspire_api/daily_step_data';
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
        print('Monthly Steps Response: $jsonResponse');

        if (jsonResponse['status'] == "SUCCESS") {
          Map<String, dynamic> monthlyData = jsonResponse['monthly_step_data'];

          List<StepsData> chartData = [];

          String recentSteps = jsonResponse['recent_step'] ?? 0;
          String? recentdate = jsonResponse['recent_datetime']?.toString();
          int target_steps = jsonResponse['target_step'] ?? 10000;
          double r_miles = (jsonResponse['recent_miles'] as num?)?.toDouble() ?? 0.0;
          double r_calories = (jsonResponse['recent_cal_burn'] as num?)?.toDouble() ?? 0.0;
          int dailyavgSteps = jsonResponse['daily_avg_steps'] ?? 0;

          r_miles = double.parse(r_miles.toStringAsFixed(1));
          r_calories = double.parse(r_calories.toStringAsFixed(1));

          final Set<String> seenDays = {};
          int max_steps = 0;

          monthlyData.forEach((weekLabel, weekList) {
            if (weekList is List) {
              for (var weekData in weekList) {
                final String startDateStr = weekData['start_date'] ?? '';
                final DateTime startDate = DateTime.tryParse(startDateStr) ?? DateTime.now();
                int steps = weekData['total_steps'] ?? 0;
                double miles = (weekData['miles'] as num?)?.toDouble() ?? 0.0;
                double calories = (weekData['cal_burn'] as num?)?.toDouble() ?? 0.0;

                miles = double.parse(miles.toStringAsFixed(1));
                calories = double.parse(calories.toStringAsFixed(1));

                if (steps > max_steps) max_steps = steps;

                final String uniqueKey = '$weekLabel-$startDateStr';
                if (!seenDays.contains(uniqueKey)) {
                  seenDays.add(uniqueKey);
                  chartData.add(StepsData(
                    date: startDate,
                    day: '',
                    dailySteps: steps,
                    steps: steps,
                    miles: miles,
                    caloriesBurned: calories,
                    monthName: weekLabel.toUpperCase(),
                    year: '',
                    totalSteps: steps,
                    targetsteps: target_steps, labelHour: '',
                  ));
                }
              }
            }
          });

          return {
            'chartData': chartData,
            'recent_step': recentSteps,
            'mainDate': '${jsonResponse['month_start']} to ${jsonResponse['month_end']}',
            'recent_datetime': recentdate,
            'targetsteps': target_steps,
            'maxSteps': max_steps,
            'miles': r_miles,
            'calories': r_calories,
            'daily_avg_steps':dailyavgSteps
          };
        } else {
          throw Exception('API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching monthly steps data: $e');
      rethrow;
    }
  }




  Future<Map<String, dynamic>> Year_Chart({
    required String userId,
    required String date,
  }) async {
    final String url = '$root/daily_step_data';
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
        print('Yearly Steps Response: $jsonResponse');

        if (jsonResponse['status'] == "SUCCESS") {
          Map<String, dynamic> yearlyData = jsonResponse['yearly_step_data'];

          List<StepsData> chartData = [];

          String recentSteps = jsonResponse['recent_step'] ?? 0;
          String? recentDate = jsonResponse['recent_datetime']?.toString();
          int targetSteps = jsonResponse['target_step'] ?? 10000;
          double rMiles = (jsonResponse['recent_miles'] as num?)?.toDouble() ?? 0.0;
          double rCalories = (jsonResponse['recent_cal_burn'] as num?)?.toDouble() ?? 0.0;
          int dailyavgSteps = jsonResponse['daily_avg_steps'] ?? 0;

          rMiles = double.parse(rMiles.toStringAsFixed(1));
          rCalories = double.parse(rCalories.toStringAsFixed(1));

          int maxSteps = 0;

          yearlyData.forEach((monthName, monthData) {
            if (monthData is Map<String, dynamic>) {
              final String startDateStr = monthData['start_date'] ?? '';
              final DateTime startDate = DateTime.tryParse(startDateStr) ?? DateTime.now();
              int steps = monthData['total_steps'] ?? 0;
              double miles = (monthData['miles'] as num?)?.toDouble() ?? 0.0;
              double calories = (monthData['cal_burn'] as num?)?.toDouble() ?? 0.0;

              miles = double.parse(miles.toStringAsFixed(1));
              calories = double.parse(calories.toStringAsFixed(1));

              if (steps > maxSteps) maxSteps = steps;

              chartData.add(StepsData(
                date: startDate,
                day: '',
                dailySteps: steps,
                steps: steps,
                miles: miles,
                caloriesBurned: calories,
                monthName: monthName,
                year: startDate.year.toString(),
                totalSteps: steps,
                targetsteps: targetSteps, labelHour: '',
              ));
            }
          });

          // Safely parse year from input date
          final DateTime parsedDate = date.length == 7
              ? DateTime.parse('$date-01') // Convert yyyy-MM to yyyy-MM-dd
              : DateTime.tryParse(date) ?? DateTime.now();

          return {
            'chartData': chartData,
            'recent_step': recentSteps,
            'mainDate': 'Year: ${parsedDate.year}',
            'recent_datetime': recentDate,
            'targetsteps': targetSteps,
            'maxSteps': maxSteps,
            'miles': rMiles,
            'calories': rCalories,
            'daily_avg_steps':dailyavgSteps
          };
        } else {
          throw Exception('API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching yearly steps data: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> MultiYear_Chart({
    required String userId,
    //required int fromYear,
    required int toYear,
  }) async {
    final String url = '$root/get_multiyear_step_data';
    final Map<String, dynamic> payload = {
      'user_id': userId,
     // 'from_year': '${fromYear.toString()}',
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
        print('MultiYear Steps Response: $jsonResponse');

        if (jsonResponse['status'] == "SUCCESS") {
          Map<String, dynamic> multiYearData = jsonResponse['multiyear_step_data'];

          List<StepsData> chartData = [];

          String recentSteps = jsonResponse['recent_step'] ?? 0;
          String? recentDate = jsonResponse['recent_datetime']?.toString();
          int targetSteps = jsonResponse['target_step'] ?? 10000;
          double rMiles = (jsonResponse['recent_miles'] as num?)?.toDouble() ?? 0.0;
          double rCalories = (jsonResponse['recent_cal_burn'] as num?)?.toDouble() ?? 0.0;
          int dailyavgSteps = jsonResponse['daily_avg_steps'] ?? 0;

          rMiles = double.parse(rMiles.toStringAsFixed(1));
          rCalories = double.parse(rCalories.toStringAsFixed(1));


          int maxSteps = 0;

          multiYearData.forEach((yearLabel, yearData) {
            if (yearData is Map<String, dynamic>) {
              final String startDateStr = yearData['start_date'] ?? '';
              final DateTime startDate = DateTime.tryParse(startDateStr) ?? DateTime.now();
              int steps = yearData['total_steps'] ?? 0;
              double miles = (yearData['total_miles'] as num?)?.toDouble() ?? 0.0;
              double calories = (yearData['total_cal_burn'] as num?)?.toDouble() ?? 0.0;

              miles = double.parse(miles.toStringAsFixed(1));
              calories = double.parse(calories.toStringAsFixed(1));

              if (steps > maxSteps) maxSteps = steps;

              chartData.add(StepsData(
                date: startDate,
                day: '',
                dailySteps: steps,
                steps: steps,
                miles: miles,
                caloriesBurned: calories,
                monthName: '',  // no month for multiyear
                year: yearLabel,  // year directly from key
                totalSteps: steps,
                targetsteps: targetSteps, labelHour: '',
              ));
            }
          });

          return {
            'chartData': chartData,
            'recent_step': recentSteps,
            'mainDate': 'Years:${toYear}',
            'recent_datetime': recentDate,
            'targetsteps': targetSteps,
            'maxSteps': maxSteps,
            'miles': rMiles,
            'calories': rCalories,
            'daily_avg_steps':dailyavgSteps
          };
        } else {
          throw Exception('API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching multiyear steps data: $e');
      rethrow;
    }
  }












}