
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

  factory BloodOxygenData.fromJson(Map<String, dynamic> json, String dateString) {
    final DateTime dateTime = DateFormat("yyyy-MM-dd hh:mm a").parse(json['datetime']);
    final String timeString = DateFormat('HH:mm').format(dateTime); // "08:05", "14:09", "20:16"

    return BloodOxygenData(
      spo2: (json['spo2'] as num?)?.round() ?? 0,
      date: dateTime,
      months: '',
      day: timeString,
      Year: '',  // 24-hour format string for x axis labels
    );
  }


}

  // factory BloodOxygenData.fromJson(Map<String, dynamic> json, String fallbackDate) {
  //   final rawDateTime = json['datetime'] ?? fallbackDate;
  //   final parsedDateTime = DateFormat("yyyy-MM-dd hh:mm a").parse(rawDateTime);
  //
  //   return BloodOxygenData(
  //     spo2: (json['spo2'] as num?)?.round() ?? 0,
  //     day: DateFormat('hh:mm a').format(parsedDateTime), // e.g., "02:09 PM"
  //     date: parsedDateTime,
  //   );
  // }

  // factory BloodOxygenData.fromJson(Map<String, dynamic> json, dateString) {
  //   final DateTime dateTime = DateFormat("yyyy-MM-dd hh:mm a").parse(json['datetime']);
  //   return BloodOxygenData(
  //     spo2: (json['spo2'] as num?)?.round() ?? 0,
  //     day: DateFormat('HH').format(dateTime),  // Not used for plotting
  //     date: dateTime,
  //   );
  // }

//   factory BloodOxygenData.fromJson(Map<String, dynamic> json, String dateString) {
//     final DateTime dateTime = DateFormat("yyyy-MM-dd hh:mm a").parse(json['datetime']);
//     return BloodOxygenData(
//       spo2: (json['spo2'] as num?)?.round() ?? 0,
//       date: dateTime, day: '',
//     );
//   }
//
//
//
// }



