
import 'dart:convert';
import 'package:azpire_new/Model/sleep_model.dart';
import 'package:azpire_new/View/Sleep_chart.dart';
import 'package:azpire_new/root/root.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';




class SleepController extends GetxController{

  Future<Map<String, dynamic>> Day_Chart({
    required String userId,
    required String date,
    required String type,
  }) async
  {

    double parseDurationToHours(String duration) {
      final regex = RegExp(r'(\d+)h\s*(\d+)m');
      final match = regex.firstMatch(duration);
      if (match != null) {
        final hours = double.parse(match.group(1)!);
        final minutes = double.parse(match.group(2)!);
        return hours + (minutes / 60);
      }
      return 0;
    }

    final response = await http.post(
      Uri.parse("$root/weekly_sleep_data"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'date': date,
        'type': type,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

        final data = jsonResponse['sleep_data'] as Map<String, dynamic>;
        final recentSleepList = jsonResponse['sleep_list'] ?? [];
        final recentDatetime = jsonResponse['recent_datetime'];
        final targetsleep = jsonResponse['target_sleep'];

        print("SleepList:$recentSleepList");

        String? recentDeep;
        String? recentLight;
        String? recentMiddle;
        String? recentTotal;
        String? recentDeepPercent;
        String? recentLightPercent;
        String? recentMiddlePercent;
        String? recenttotalPercent;

        double yAxisMax = 0.0;

        for (var item in recentSleepList) {
          switch (item['sleep_value']) {
            case 2:
              recentLight = item['hours'];
              recentLightPercent = item['percentage'];
              break;
            case 3:
              recentDeep = item['hours'];
              recentDeepPercent = item['percentage'];
              break;
            case 4:
              recentMiddle = item['hours'];
              recentMiddlePercent = item['percentage'];
              break;
            case 6:
              recentTotal = item['hours'];
              recenttotalPercent = item['percentage'];
              break;
          }
        }

        print('recentTotal:$recentTotal');

        List<SleepBarData> dailyBars = [];
        List<SleepDataChart1> daySummaryList = [];
        double maxTotalSleep = 0.0;

        for (var entry in data.entries) {
          final summary = entry.value['sleep_summary'] ?? {};
          DateTime date = DateTime.tryParse(entry.value['date']) ??
              DateTime.now();

          final lightRaw = summary['2'] ?? '0h 0m';
          final deepRaw = summary['3'] ?? '0h 0m';
          final remRaw = summary['4'] ?? '0h 0m';
          final totalSleepRaw = summary['total'] ?? '0h 0m';

          final lightSleepHours = parseDurationToHours(lightRaw);
          final deepSleepHours = parseDurationToHours(deepRaw);
          final remSleepHours = parseDurationToHours(remRaw);
          final totalSleepHours = parseDurationToHours(totalSleepRaw);

          if (totalSleepHours > maxTotalSleep) {
            maxTotalSleep = totalSleepHours;
          }

          double lightStart = 0;
          double lightEnd = lightSleepHours;

          double deepStart = lightEnd;
          double deepEnd = deepStart + deepSleepHours;

          double remStart = deepEnd;
          double remEnd = remStart + remSleepHours;

          double currentStart = 0;

          if (lightSleepHours > 0) {
            double lightStart = currentStart;
            double lightEnd = lightStart + lightSleepHours;
            dailyBars.add(SleepBarData(
              label: '', // or day name
              startHour: lightStart,
              endHour: lightEnd,
              value: 2, // Light
            ));
            currentStart = lightEnd;
          }

          if (remSleepHours > 0) {
            double remStart = currentStart;
            double remEnd = remStart + remSleepHours;
            dailyBars.add(SleepBarData(
              label: '',
              startHour: remStart,
              endHour: remEnd,
              value: 4, // REM (Middle)
            ));
            currentStart = remEnd;
          }

          if (deepSleepHours > 0) {
            double deepStart = currentStart;
            double deepEnd = deepStart + deepSleepHours;
            dailyBars.add(SleepBarData(
              label: '',
              startHour: deepStart,
              endHour: deepEnd,
              value: 3, // Deep
            ));
          }


          daySummaryList.add(SleepDataChart1(
            time_s: date,
            day_name: '',
            month_name: '',
            years: '',
            awake_s: 0,
            lightSleep_s: 0,
            deepSleep_s: 0,
            remSleep_s: 0,
            awake_s1: 0,
            lightSleep_s1: 0,
            remSleep_s1: 0,
            total_sleep: totalSleepRaw,
            totalLight: lightRaw,
            totalMiddle: remRaw,
            totalDeep: deepRaw,
            light2: 0,
            week_names: '',
          ));

        }

      // Final yAxisMax calculation (rounded to next even number after adding 2 hours)
      final roundedTotal = maxTotalSleep.ceil();
      yAxisMax = ((roundedTotal + 4) / 2).ceil() * 2;

      // return {
      //   'chartData': dailyBars,
      //   'summaryData': daySummaryList,
      //   'recent_datetime': recentDatetime?.toString(),
      //   'recent_sleep_list': recentSleepList,
      //   'recent_light': recentLight?.toString(),
      //   'recent_deep': recentDeep?.toString(),
      //   'recent_rem': recentMiddle?.toString(),
      //   'recent_light_percent': recentLightPercent?.toString(),
      //   'recent_deep_percent': recentDeepPercent?.toString(),
      //   'recent_rem_percent': recentMiddlePercent?.toString(),
      //   'y_axis_max': yAxisMax.toDouble(),
      //   'recent_total': recentTotal?.toString(),
      //   'recent_total_percent': recenttotalPercent?.toString(),
      //   'target_sleep': targetsleep?.toString(),
      // };


      return {
        'chartData': dailyBars,
        'summaryData': daySummaryList,
        'recent_datetime': recentDatetime,
        'recent_sleep_list': recentSleepList,
        'recent_light': recentLight,
        'recent_deep': recentDeep,
        'recent_rem': recentMiddle,
        'recent_light_percent': recentLightPercent,
        'recent_deep_percent': recentDeepPercent,
        'recent_rem_percent': recentMiddlePercent,
        'y_axis_max': yAxisMax,
         'recent_total': recentTotal,
         'recent_total_percent':recenttotalPercent,
        'target_sleep':targetsleep
      };
    } else {
      throw Exception('Failed to fetch sleep daily chart');
    }
  }

  Future<Map<String, dynamic>> Week_Chart({
    required String userId,
    required String date,
    required String type,
  }) async
  {

    double parseDurationToHours(String duration) {
      final regex = RegExp(r'(\d+)h\s*(\d+)m');
      final match = regex.firstMatch(duration);
      if (match != null) {
        final hours = double.parse(match.group(1)!);
        final minutes = double.parse(match.group(2)!);
        return hours + (minutes / 60);
      }
      return 0;
    }

    final response = await http.post(
      Uri.parse("$root/weekly_sleep_data"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'date': date,
        'type': type,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final data = jsonResponse['sleep_data'] as Map<String, dynamic>;
      final recentSleepList = jsonResponse['sleep_list'] ?? [];
      final targetsleep = jsonResponse['target_sleep'];
      final avgsleep = jsonResponse['daily_avg_sleep'];

      print("weekrecentSleepList:$recentSleepList");

      List<SleepBarData> weeklyBars = [];
      List<SleepDataChart1> weekSummaryList = [];
      double maxTotalSleep = 0.0;

      final daysOfWeekMap = {
        'sunday': 'Sun',
        'monday': 'Mon',
        'tuesday': 'Tue',
        'wednesday': 'Wed',
        'thursday': 'Thu',
        'friday': 'Fri',
        'saturday': 'Sat',
      };

      String? recentDeep;
      String? recentLight;
      String? recentMiddle;
      String? recentTotal;
      String? recentDeepPercent;
      String? recentLightPercent;
      String? recentMiddlePercent;
      String? recenttotalPercent;



      for (var item in recentSleepList) {
        switch (item['sleep_value']) {
          case 2:
            recentLight = item['hours'];
            recentLightPercent = item['percentage'];
            break;
          case 3:
            recentDeep = item['hours'];
            recentDeepPercent = item['percentage'];
            break;
          case 4:
            recentMiddle = item['hours'];
            recentMiddlePercent = item['percentage'];
            break;
          case 6:
            recentTotal = item['hours'];
            recenttotalPercent = item['percentage'];
            break;
        }
      }

      print('recenttotalPercent:$recenttotalPercent');
      print('recentLightPercent:$recentLightPercent');
      print('recentDeepPercent:$recentDeepPercent');
      print('recentMiddlePercent:$recentMiddlePercent');

      for (var entry in data.entries) {
        final day = entry.key;
        final dayData = entry.value;
        final summary = dayData['sleep_summary'] ?? {};
        final date = DateTime.tryParse(dayData['date']) ?? DateTime.now();

        final lightRaw = summary['2'] ?? '0h 0m';
        final deepRaw = summary['3'] ?? '0h 0m';
        final remRaw = summary['4'] ?? '0h 0m';
        final totalSleepRaw = summary['total'] ?? '0h 0m';

        final lightSleepHours = parseDurationToHours(lightRaw);
        final deepSleepHours = parseDurationToHours(deepRaw);
        final remSleepHours = parseDurationToHours(remRaw);
        final totalSleepHours = parseDurationToHours(totalSleepRaw);

        if (totalSleepHours > maxTotalSleep) {
          maxTotalSleep = totalSleepHours;
        }

        String label = daysOfWeekMap[day.toLowerCase()] ?? '';

        double currentStart = 0;

        // 1. Light (bottom)
        if (lightSleepHours > 0) {
          double lightStart = currentStart;
          double lightEnd = lightStart + lightSleepHours;
          weeklyBars.add(SleepBarData(
            label: label,
            startHour: lightStart,
            endHour: lightEnd,
            value: 2,
          ));
          currentStart = lightEnd;
        }

        // 2. REM (middle)
        if (remSleepHours > 0) {
          double remStart = currentStart;
          double remEnd = remStart + remSleepHours;
          weeklyBars.add(SleepBarData(
            label: label,
            startHour: remStart,
            endHour: remEnd,
            value: 4,
          ));
          currentStart = remEnd;
        }

        // 3. Deep (top)
        if (deepSleepHours > 0) {
          double deepStart = currentStart;
          double deepEnd = deepStart + deepSleepHours;
          weeklyBars.add(SleepBarData(
            label: label,
            startHour: deepStart,
            endHour: deepEnd,
            value: 3,
          ));
        }

        weekSummaryList.add(SleepDataChart1(
          time_s: date,
          day_name: label,
          month_name: '',
          years: '',
          awake_s: 0,
          lightSleep_s: 0,
          deepSleep_s: 0,
          remSleep_s: 0,
          awake_s1: 0,
          lightSleep_s1: 0,
          remSleep_s1: 0,
          total_sleep: totalSleepRaw,
          totalLight: lightRaw,
          totalMiddle: remRaw,
          totalDeep: deepRaw,
          light2: 0,
          week_names: '',
        ));
      }


      final roundedTotal = maxTotalSleep.ceil();
      final yAxisMax = ((roundedTotal + 2) / 2).ceil() * 2;

      return {
        'chartData': weeklyBars,
        'summaryData': weekSummaryList,
        'y_axis_max': yAxisMax,
        'recent_sleep_list': recentSleepList,
        'recent_light': recentLight,
        'recent_deep': recentDeep,
        'recent_rem': recentMiddle,
        'recent_light_percent': recentLightPercent,
        'recent_deep_percent': recentDeepPercent,
        'recent_rem_percent': recentMiddlePercent,
        'recent_total': recentTotal,
        'recent_total_percent':recenttotalPercent,
        'target_sleep': targetsleep?.toString(),
         'daily_avg_sleep':avgsleep

      };
    } else {
      throw Exception('Failed to fetch sleep weekly chart');
    }
  }

  Future<Map<String, dynamic>> Month_Chart({
    required String userId,
    required String date,
    required String type,
  }) async
  {
    String formatHourMinute(double hours) {
      final int h = hours.floor();
      final int m = ((hours - h) * 60).round();
      return '${h}h ${m}m';
    }

    double parseDuration(DateTime start, DateTime end) {
      return end.difference(start).inMinutes / 60.0;
    }

    final response = await http.post(
      Uri.parse("$root/weekly_sleep_data"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'date': date,
        'type': type,
      }),
    );

    print("response:${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final rawList = jsonResponse['sleep_data']['overall_sleep_sessions'] as List;
      final recentSleepList = jsonResponse['sleep_list'] ?? [];
      final targetsleep = jsonResponse['target_sleep'];
      final avgsleep = jsonResponse['daily_avg_sleep'];

      String? recentDeepPercent;
      String? recentLightPercent;
      String? recentMiddlePercent;
      String? recenttotalPercent;

      for (var item in recentSleepList) {
        switch (item['sleep_value']) {
          case 2:
            recentLightPercent = item['percentage'];
            break;
          case 3:
            recentDeepPercent = item['percentage'];
            break;
          case 4:
            recentMiddlePercent = item['percentage'];
            break;
          case 6:
            recenttotalPercent = item['percentage'];
            break;
        }
      }

      Map<String, dynamic> dateMap = {};
      for (var item in rawList) {
        final dayKey = (item as Map<String, dynamic>).keys.first;
        final dayData = item[dayKey];
        final dateStr = dayData['date'];
        dateMap[dateStr] = dayData;
      }

      // ✅ Dynamically parse month start
      DateTime monthStart;
      if (RegExp(r'^\d{4}-\d{2}$').hasMatch(date)) {
        final parts = date.split('-');
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        monthStart = DateTime(year, month, 1);
      } else {
        monthStart = DateTime.parse(date);
      }

      int totalDays = DateUtils.getDaysInMonth(monthStart.year, monthStart.month);

      List<SleepBarData> monthlyBars = [];
      List<SleepDataChart1> monthlySummaryList = [];
      double maxTotalSleep = 0;

      for (int i = 1; i <= totalDays; i++) {
        DateTime current = DateTime(monthStart.year, monthStart.month, i);
        String dateKey = DateFormat('yyyy-MM-dd').format(current);

        // final data = dateMap[dateKey];
        // final sessions = data != null ? data['sleep_sessions'] as List : [];
        // final summary = data['sleep_summary'] ?? {};
        final data = dateMap[dateKey];

        final sessions = (data != null && data['sleep_sessions'] != null)
            ? data['sleep_sessions'] as List
            : [];

        final summary = (data != null && data['sleep_summary'] != null)
            ? data['sleep_summary']
            : {};
        final totalSleepRaw = summary['total'] ?? '0h 0m';

        double light = 0, deep = 0, rem = 0, total = 0;

        final dateFormat = DateFormat('yyyy-MM-dd hh:mm a');

        for (var session in sessions) {
          try {
            final start = dateFormat.parse(session['start_at']);
            final end = dateFormat.parse(session['end_at']);
            final value = session['sleep_value'];
            double hours = parseDuration(start, end);

            switch (value) {
              case 2:
                light += hours;
                break;
              case 3:
                deep += hours;
                break;
              case 4:
                rem += hours;
                break;
            }
          } catch (e) {
            print('⚠️ Failed to parse date in session: $e');
          }
        }

        total = light + deep + rem;
        if (total > maxTotalSleep) maxTotalSleep = total;

        double lightStart = 0;
        double lightEnd = lightStart + light;
        double remStart = lightEnd;
        double remEnd = remStart + rem;
        double deepStart = remEnd;
        double deepEnd = deepStart + deep;

        if (light > 0) {
          monthlyBars.add(SleepBarData(
            label: i.toString(),
            startHour: lightStart,
            endHour: lightEnd,
            value: 2,
          ));
        }
        if (rem > 0) {
          monthlyBars.add(SleepBarData(
            label: i.toString(),
            startHour: remStart,
            endHour: remEnd,
            value: 4,
          ));
        }
        if (deep > 0) {
          monthlyBars.add(SleepBarData(
            label: i.toString(),
            startHour: deepStart,
            endHour: deepEnd,
            value: 3,
          ));
        }

        monthlySummaryList.add(SleepDataChart1(
          time_s: current,
          day_name: DateFormat('EEEE').format(current),
          month_name: DateFormat('MMM dd').format(current),
          years: current.year.toString(),
          awake_s: 0,
          lightSleep_s: 0,
          deepSleep_s: 0,
          remSleep_s: 0,
          awake_s1: 0,
          lightSleep_s1: 0,
          remSleep_s1: 0,
          total_sleep: totalSleepRaw,
          totalLight: formatHourMinute(light),
          totalMiddle: formatHourMinute(rem),
          totalDeep: formatHourMinute(deep),
          light2: 0,
          week_names: '',
        ));
      }

      final yAxisMax = ((maxTotalSleep + 2) / 2).ceil() * 2;

      return {
        'chartData': monthlyBars,
        'summaryData': monthlySummaryList,
        'y_axis_max': yAxisMax,
        'mainDate': date,
        // 'recent_light_percent': recentLightPercent,
        // 'recent_deep_percent': recentDeepPercent,
        // 'recent_rem_percent': recentMiddlePercent,
        // 'recent_total_percent': recenttotalPercent,
        'recent_light_percent': recentLightPercent?.toString(),
        'recent_deep_percent': recentDeepPercent?.toString(),
        'recent_rem_percent': recentMiddlePercent?.toString(),
        'recent_total_percent': recenttotalPercent?.toString(),
        'target_sleep':targetsleep,
        'daily_avg_sleep':avgsleep
      };
    } else {
      throw Exception('Failed to fetch month sleep chart');
    }
  }




  Future<Map<String, dynamic>> Year_Chart({
    required String userId,
    required String date,
    required String type,
  }) async
  {
    String formatHourMinute(double hours) {
      final int h = hours.floor();
      final int m = ((hours - h) * 60).round();
      return '${h}h ${m}m';
    }

    double parseDurationFromString(String duration) {
      try {
        duration = duration.replaceAll('\u00a0', ' ').replaceAll('\u200b', '').trim();
        final regex = RegExp(r'(\d+)h\s*(\d+)m');
        final match = regex.firstMatch(duration);
        if (match != null) {
          final hours = int.tryParse(match.group(1)!) ?? 0;
          final minutes = int.tryParse(match.group(2)!) ?? 0;
          return hours + (minutes / 60.0);
        }
      } catch (e) {
        print("Error parsing duration: $duration");
      }
      return 0.0;
    }

    final response = await http.post(
      Uri.parse("$root/weekly_sleep_data"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'date': date,
        'type': type,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print("Yearlyresponse: $jsonResponse");

      final Map<String, dynamic> yearData = jsonResponse['sleep_data'] ?? {};
      final List<dynamic> recentSleepList = jsonResponse['sleep_list'] ?? [];
      final targetsleep = jsonResponse['target_sleep'];
      final avgsleep = jsonResponse['daily_avg_sleep'];

      String? recentDeepPercent;
      String? recentLightPercent;
      String? recentMiddlePercent;
      String? recentTotalPercent;

      for (var item in recentSleepList) {
        if (item is Map<String, dynamic>) {
          switch (item['sleep_value']) {
            case 2:
              recentLightPercent = item['percentage'];
              break;
            case 3:
              recentDeepPercent = item['percentage'];
              break;
            case 4:
              recentMiddlePercent = item['percentage'];
              break;
            case 6:
              recentTotalPercent = item['percentage'];
              break;
          }
        }
      }

      List<SleepBarData> yearlyBars = [];
      List<SleepDataChart1> yearlySummaryList = [];
      double maxTotalSleep = 0;

      final monthNames = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
        'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
        'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
      };

      /// Safely extract year even if date is in "yyyy-MM" or "yyyy-MM-dd"
      int parsedYear = 0;
      try {
        parsedYear = DateTime.parse(date.length == 7 ? "$date-01" : date).year;
      } catch (e) {
        print("❌ Failed to parse year from date: $date");
        throw FormatException("Invalid date format: $date");
      }

      for (var monthKey in monthNames.keys) {
        print('Processing month: $monthKey');
        final monthData = yearData[monthKey];

        if (monthData is Map<String, dynamic>) {
          final summary = monthData;
          print('Raw Summary for $monthKey: $summary');

          if (summary is Map<String, dynamic>) {
            final lightStr = summary['2']?.toString() ?? summary[2]?.toString() ?? '0h 0m';
            final deepStr  = summary['3']?.toString() ?? summary[3]?.toString() ?? '0h 0m';
            final remStr   = summary['4']?.toString() ?? summary[4]?.toString() ?? '0h 0m';
            final totalStr = summary['total']?.toString() ?? '0h 0m';

            final light = parseDurationFromString(lightStr);
            final deep  = parseDurationFromString(deepStr);
            final rem   = parseDurationFromString(remStr);
            final total = parseDurationFromString(totalStr);

            print("📊 $monthKey → Light: $lightStr → $light, Deep: $deepStr → $deep, REM: $remStr → $rem");

            // if (light == 0 && deep == 0 && rem == 0) {
            //   print('⚠️ Skipping $monthKey due to 0 values');
            //   continue;
            // }

            if (total > maxTotalSleep) {
              maxTotalSleep = total;
            }

            double start = 0;

            // Light (bottom)
            yearlyBars.add(SleepBarData(
              label: monthKey,
              startHour: start,
              endHour: start + light,
              value: 2,
            ));
            start += light;

            // REM (middle)
            yearlyBars.add(SleepBarData(
              label: monthKey,
              startHour: start,
              endHour: start + rem,
              value: 4,
            ));
            start += rem;

            // Deep (top)
            yearlyBars.add(SleepBarData(
              label: monthKey,
              startHour: start,
              endHour: start + deep,
              value: 3,
            ));

            final dummyDate = DateTime(parsedYear, monthNames[monthKey]!, 1);

            yearlySummaryList.add(SleepDataChart1(
              time_s: dummyDate,
              day_name: DateFormat('EEEE').format(dummyDate),
              month_name: monthKey,
              years: dummyDate.year.toString(),
              awake_s: 0,
              lightSleep_s: 0,
              deepSleep_s: 0,
              remSleep_s: 0,
              awake_s1: 0,
              lightSleep_s1: 0,
              remSleep_s1: 0,
              total_sleep: totalStr,
              totalLight: formatHourMinute(light),
              totalMiddle: formatHourMinute(rem),
              totalDeep: formatHourMinute(deep),
              light2: 0,
              week_names: '',
            ));
          }
        }
      }

      final yAxisMax = ((maxTotalSleep + 2) / 2).ceil() * 2;

      return {
        'chartData': yearlyBars,
        'summaryData': yearlySummaryList,
        'y_axis_max': yAxisMax,
        'mainDate': date,
        'recent_light_percent': recentLightPercent,
        'recent_deep_percent': recentDeepPercent,
        'recent_rem_percent': recentMiddlePercent,
        'recent_total_percent': recentTotalPercent,
        'target_sleep':targetsleep,
        'daily_avg_sleep':avgsleep
      };
    } else {
      throw Exception('Failed to fetch year sleep chart');
    }
  }




// Future<Map<String, dynamic>> MultiYear_Chart({
//     required String userId,
//    // required int fromYear,
//     required int toYear,
//   }) async
// {
//     String formatHourMinute(double hours) {
//       final int h = hours.floor();
//       final int m = ((hours - h) * 60).round();
//       return '${h}h ${m}m';
//     }
//
//     double parseDurationFromString(String duration) {
//       try {
//         duration = duration.replaceAll('\u00a0', ' ').replaceAll('\u200b', '').trim();
//         final regex = RegExp(r'(\d+)h\s*(\d+)m');
//         final match = regex.firstMatch(duration);
//         if (match != null) {
//           final hours = int.tryParse(match.group(1)!) ?? 0;
//           final minutes = int.tryParse(match.group(2)!) ?? 0;
//           return hours + (minutes / 60.0);
//         }
//       } catch (e) {
//         print("Error parsing duration: $duration");
//       }
//       return 0.0;
//     }
//
//     final response = await http.post(
//       Uri.parse("$root/get_multiyear_sleep_data"),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'user_id': userId,
//         //'from_year': '${fromYear.toString()}',
//         'to_year': '${toYear.toString()}',
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       final jsonResponse = json.decode(response.body);
//       print("MultiYear Sleep Response: $jsonResponse");
//
//       final Map<String, dynamic> yearData = jsonResponse['sleep_data'] ?? {};
//       final List<dynamic> recentSleepList = jsonResponse['sleep_list'] ?? [];
//       final targetsleep = jsonResponse['target_sleep'];
//       final avgsleep = jsonResponse['daily_avg_sleep'];
//
//       print("avgsleep:$avgsleep");
//
//       String? recentDeepPercent;
//       String? recentLightPercent;
//       String? recentMiddlePercent;
//       String? recentTotalPercent;
//
//       for (var item in recentSleepList) {
//         if (item is Map<String, dynamic>) {
//           switch (item['sleep_value']) {
//             case 2:
//               recentLightPercent = item['percentage'];
//               break;
//             case 3:
//               recentDeepPercent = item['percentage'];
//               break;
//             case 4:
//               recentMiddlePercent = item['percentage'];
//               break;
//             case 6:
//               recentTotalPercent = item['percentage'];
//               break;
//           }
//         }
//       }
//
//       List<SleepBarData> multiYearBars = [];
//       List<SleepDataChart1> summaryList = [];
//       double maxTotalSleep = 0;
//
//       for (var yearKey in yearData.keys) {
//         final yearSleep = yearData[yearKey];
//
//         if (yearSleep is Map<String, dynamic>) {
//           final lightStr = yearSleep['2']?.toString() ?? '0h 0m';
//           final deepStr  = yearSleep['3']?.toString() ?? '0h 0m';
//           final remStr   = yearSleep['4']?.toString() ?? '0h 0m';
//           final totalStr = yearSleep['total']?.toString() ?? '0h 0m';
//
//           final light = parseDurationFromString(lightStr);
//           final deep  = parseDurationFromString(deepStr);
//           final rem   = parseDurationFromString(remStr);
//           final total = parseDurationFromString(totalStr);
//
//           print("📅 Year: $yearKey → Light: $lightStr → $light, Deep: $deepStr → $deep, REM: $remStr → $rem");
//
//           if (total > maxTotalSleep) {
//             maxTotalSleep = total;
//           }
//
//           double start = 0;
//
//           // Light (bottom)
//           multiYearBars.add(SleepBarData(
//             label: yearKey,
//             startHour: start,
//             endHour: start + light,
//             value: 2,
//           ));
//           start += light;
//
//           // REM (middle)
//           multiYearBars.add(SleepBarData(
//             label: yearKey,
//             startHour: start,
//             endHour: start + rem,
//             value: 4,
//           ));
//           start += rem;
//
//           // Deep (top)
//           multiYearBars.add(SleepBarData(
//             label: yearKey,
//             startHour: start,
//             endHour: start + deep,
//             value: 3,
//           ));
//
//           final yearDate = DateTime(int.parse(yearKey));
//
//           summaryList.add(SleepDataChart1(
//             time_s: yearDate,
//             day_name: DateFormat('EEEE').format(yearDate),
//             month_name: '',
//             years: yearKey,
//             awake_s: 0,
//             lightSleep_s: 0,
//             deepSleep_s: 0,
//             remSleep_s: 0,
//             awake_s1: 0,
//             lightSleep_s1: 0,
//             remSleep_s1: 0,
//             total_sleep: totalStr,
//             totalLight: formatHourMinute(light),
//             totalMiddle: formatHourMinute(rem),
//             totalDeep: formatHourMinute(deep),
//             light2: 0,
//             week_names: '',
//           ));
//         }
//       }
//
//       final yAxisMax = ((maxTotalSleep + 2) / 2).ceil() * 2;
//
//       return {
//         'chartData': multiYearBars,
//         'summaryData': summaryList,
//         'y_axis_max': yAxisMax,
//         'recent_light_percent': recentLightPercent,
//         'recent_deep_percent': recentDeepPercent,
//         'recent_rem_percent': recentMiddlePercent,
//         'recent_total_percent': recentTotalPercent,
//         'target_sleep':targetsleep,
//         'daily_avg_sleep':avgsleep
//       };
//     } else {
//       throw Exception('Failed to fetch multiyear sleep chart');
//     }
//   }


  Future<Map<String, dynamic>> MultiYear_Chart({
    required String userId,
    required int toYear,
  }) async {
    String formatHourMinute(double hours) {
      final int h = hours.floor();
      final int m = ((hours - h) * 60).round();
      return '${h}h ${m}m';
    }

    double parseDurationFromString(String duration) {
      try {
        duration = duration.replaceAll('\u00a0', ' ').replaceAll('\u200b', '').trim();
        final regex = RegExp(r'(\d+)h\s*(\d+)m');
        final match = regex.firstMatch(duration);
        if (match != null) {
          final hours = int.tryParse(match.group(1)!) ?? 0;
          final minutes = int.tryParse(match.group(2)!) ?? 0;
          return hours + (minutes / 60.0);
        }
      } catch (e) {
        print("Error parsing duration: $duration");
      }
      return 0.0;
    }

    final response = await http.post(
      Uri.parse("$root/get_multiyear_sleep_data"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'to_year': '$toYear',
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print("MultiYear Sleep Response: $jsonResponse");

      final Map<String, dynamic> yearData = jsonResponse['sleep_data'] ?? {};
      final List<dynamic> recentSleepList = jsonResponse['sleep_list'] ?? [];
      final targetsleep = jsonResponse['target_sleep'];
      final avgsleep = jsonResponse['daily_avg_sleep'];

      String? recentDeepPercent;
      String? recentLightPercent;
      String? recentMiddlePercent;
      String? recentTotalPercent;

      for (var item in recentSleepList) {
        if (item is Map<String, dynamic>) {
          switch (item['sleep_value']) {
            case 2:
              recentLightPercent = item['percentage'];
              break;
            case 3:
              recentDeepPercent = item['percentage'];
              break;
            case 4:
              recentMiddlePercent = item['percentage'];
              break;
            case 6:
              recentTotalPercent = item['percentage'];
              break;
          }
        }
      }

      List<SleepBarData> multiYearBars = [];
      List<SleepDataChart1> summaryList = [];
      double maxTotalSleep = 0;

      for (var yearKey in yearData.keys) {
        final yearSleep = yearData[yearKey];
        if (yearSleep is Map<String, dynamic>) {
          final lightStr = yearSleep['2']?.toString() ?? '0h 0m';
          final deepStr = yearSleep['3']?.toString() ?? '0h 0m';
          final remStr = yearSleep['4']?.toString() ?? '0h 0m';
          final totalStr = yearSleep['total']?.toString() ?? '0h 0m';

          final light = parseDurationFromString(lightStr);
          final deep = parseDurationFromString(deepStr);
          final rem = parseDurationFromString(remStr);
          final total = parseDurationFromString(totalStr);

          print("📅 Year: $yearKey → Light: $lightStr → $light, Deep: $deepStr → $deep, REM: $remStr → $rem");

          if (total > maxTotalSleep) {
            maxTotalSleep = total;
          }

          double start = 0;

          multiYearBars.add(SleepBarData(
            label: yearKey,
            startHour: start,
            endHour: start + light,
            value: 2,
          ));
          start += light;

          multiYearBars.add(SleepBarData(
            label: yearKey,
            startHour: start,
            endHour: start + rem,
            value: 4,
          ));
          start += rem;

          multiYearBars.add(SleepBarData(
            label: yearKey,
            startHour: start,
            endHour: start + deep,
            value: 3,
          ));

          final yearDate = DateTime(int.parse(yearKey));

          summaryList.add(SleepDataChart1(
            time_s: yearDate,
            day_name: DateFormat('EEEE').format(yearDate),
            month_name: '',
            years: yearKey,
            awake_s: 0,
            lightSleep_s: 0,
            deepSleep_s: 0,
            remSleep_s: 0,
            awake_s1: 0,
            lightSleep_s1: 0,
            remSleep_s1: 0,
            total_sleep: totalStr,
            totalLight: formatHourMinute(light),
            totalMiddle: formatHourMinute(rem),
            totalDeep: formatHourMinute(deep),
            light2: 0,
            week_names: '',
          ));
        }
      }

      final yAxisMax = ((maxTotalSleep + 2) / 2).ceil() * 2;

      return {
        'chartData': multiYearBars,
        'summaryData': summaryList,
        'y_axis_max': yAxisMax,
        'recent_light_percent': recentLightPercent,
        'recent_deep_percent': recentDeepPercent,
        'recent_rem_percent': recentMiddlePercent,
        'recent_total_percent': recentTotalPercent,
        'target_sleep': targetsleep,
        'daily_avg_sleep': avgsleep,
        'mainDate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      };
    } else {
      throw Exception('Failed to fetch multiyear sleep chart');
    }
  }



}

