
import 'package:intl/intl.dart';

// class BloodOxygenData {
//   final int spo2;
//   final String day;         // Display: "07:05 AM"
//   final DateTime date;      // Raw DateTime used for formatting
//
//   BloodOxygenData({
//     required this.spo2,
//     required this.day,
//     required this.date,
//   });
//
//   factory BloodOxygenData.fromJson(Map<String, dynamic> json) {
//     final dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(json['datetime']);
//     final formattedDay = DateFormat('hh:mm a').format(dateTime);
//
//     return BloodOxygenData(
//       spo2: (json['spo2']).round(), // Converts 949 to 95,
//       day: formattedDay,
//       date: dateTime,
//     );
//   }
// }

class BloodOxygenData {
  final int spo2;
  final String day;
  final String months;// Display: "07:00 AM"
  final String Year;
  final DateTime date; // Used internally

  BloodOxygenData({
    required this.spo2,
    required this.day,
    required this.date,
    required this.months,
    required this.Year
  });

  // factory BloodOxygenData.fromJson(Map<String, dynamic> json, String dateString) {
  //   final DateTime dateTime = DateFormat("yyyy-MM-dd hh:mm a").parse(json['datetime']);
  //   final String timeString = DateFormat('HH:mm').format(dateTime);
  //
  //   int parseSpo2(dynamic value) {
  //     if (value == null) return 0;
  //     if (value is num) return value.round();
  //     if (value is String) {
  //       final parsed = double.tryParse(value);
  //       return parsed?.round() ?? 0;
  //     }
  //     return 0;
  //   }
  //
  //   return BloodOxygenData(
  //     spo2: parseSpo2(json['spo2']),
  //     date: dateTime,
  //     months: '',
  //     day: timeString,
  //     Year: '',
  //   );
  // }


// factory BloodOxygenData.fromJson(Map<String, dynamic> json, String dateString) {
//     final DateTime dateTime = DateFormat("yyyy-MM-dd hh:mm a").parse(json['datetime']);
//     final String timeString = DateFormat('HH:mm').format(dateTime); // "08:05", "14:09", "20:16"
//
//     return BloodOxygenData(
//       spo2: (json['spo2'] as num?)?.round() ?? 0,
//       date: dateTime,
//       months: '',
//       day: timeString,
//       Year: '',  // 24-hour format string for x axis labels
//     );
//   }

  factory BloodOxygenData.fromJson(Map<String, dynamic> json, String dateString) {
    final DateTime dateTime = DateFormat("yyyy-MM-dd hh:mm a").parse(json['datetime']);
    final String timeString = DateFormat('HH:mm').format(dateTime);

    int parseToInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is num) return value.round();
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    return BloodOxygenData(
      spo2: parseToInt(json['spo2']),
      date: dateTime,
      months: '',
      day: timeString,
      Year: '',
    );
  }







  // factory BloodOxygenData.fromJson(Map<String, dynamic> json, String dateString) {
  //   final DateTime dateTime = DateFormat("yyyy-MM-dd hh:mm a").parse(json['datetime']);
  //   final String timeString = DateFormat('HH:mm').format(dateTime);
  //
  //   int parseSpo2(dynamic value, {int defaultValue = 0}) {
  //     if (value == null) return defaultValue;
  //     if (value is num) {
  //       final int rounded = value.round();
  //       // Filter: only allow SPO2 in realistic range
  //       if (rounded >= 70 && rounded <= 100) return rounded;
  //       return defaultValue; // Invalid -> default
  //     }
  //     if (value is String) {
  //       final parsed = double.tryParse(value);
  //       if (parsed != null) {
  //         final int rounded = parsed.round();
  //         if (rounded >= 70 && rounded <= 100) return rounded;
  //       }
  //       return defaultValue;
  //     }
  //     return defaultValue;
  //   }
  //
  //   return BloodOxygenData(
  //     spo2: parseSpo2(json['spo2']),
  //     date: dateTime,
  //     months: '',
  //     day: timeString,
  //     Year: '',
  //   );
  // }

}





