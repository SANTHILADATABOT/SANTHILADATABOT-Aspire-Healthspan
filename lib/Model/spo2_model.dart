
import 'package:intl/intl.dart';


// class BloodOxygenData {
//   final int spo2;
//   final String day;
//   final String months;// Display: "07:00 AM"
//   final String Year;
//   final DateTime date; // Used internally
//
//   BloodOxygenData({
//     required this.spo2,
//     required this.day,
//     required this.date,
//     required this.months,
//     required this.Year
//   });
//
//
//
//   factory BloodOxygenData.fromJson(Map<String, dynamic> json, String dateString) {
//     final DateTime dateTime = DateFormat("yyyy-MM-dd hh:mm a").parse(json['datetime']);
//     final String timeString = DateFormat('HH:mm').format(dateTime);
//
//     int parseToInt(dynamic value, {int defaultValue = 0}) {
//       if (value == null) return defaultValue;
//       if (value is num) return value.round();
//       if (value is String) return int.tryParse(value) ?? defaultValue;
//       return defaultValue;
//     }
//
//     return BloodOxygenData(
//       spo2: parseToInt(json['spo2']),
//       date: dateTime,
//       months: '',
//       day: timeString,
//       Year: '',
//     );
//   }
//
//
//
//
//
//
//
//
// }


class BloodOxygenData {
  final double spo2; // ✅ changed to double
  final String day;
  final String months;
  final String Year;
  final DateTime date;

  BloodOxygenData({
    required this.spo2,
    required this.day,
    required this.date,
    required this.months,
    required this.Year,
  });

  factory BloodOxygenData.fromJson(
      Map<String, dynamic> json,
      String dateString,
      ) {

    final DateTime dateTime =
    DateFormat("yyyy-MM-dd hh:mm a").parse(json['datetime']);

    final String timeString =
    DateFormat('HH:mm').format(dateTime);

    double parseSpo2(dynamic value, {double defaultValue = 0.0}) {

      if (value == null) return defaultValue;

      if (value is num) {
        return value / 10;
      }

      if (value is String) {
        return (double.tryParse(value) ?? defaultValue) / 10;
      }

      return defaultValue;
    }

    return BloodOxygenData(
      spo2: parseSpo2(json['spo2']), // ✅ 975 -> 97.5
      date: dateTime,
      months: '',
      day: timeString,
      Year: '',
    );
  }
}




