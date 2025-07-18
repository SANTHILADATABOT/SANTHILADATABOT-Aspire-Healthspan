


class SleepData {
  final String date;
  final String weekday; // <-- new
  final Map<String, String> sleepSummary;
  final List<SleepSession> sleepSessions;

  SleepData({
    required this.date,
    required this.weekday,
    required this.sleepSummary,
    required this.sleepSessions,
  });

  factory SleepData.fromJson(String weekday, Map<String, dynamic> json) {
    var sessions = <SleepSession>[];
    if (json['sleep_sessions'] != null) {
      json['sleep_sessions'].forEach((v) {
        sessions.add(SleepSession.fromJson(v));
      });
    }

    var summary = <String, String>{};
    if (json['sleep_summary'] != null) {
      json['sleep_summary'].forEach((key, value) {
        summary[key] = value;
      });
    }

    return SleepData(
      date: json['date'],
      weekday: weekday.toLowerCase(), // Save the lowercase key
      sleepSummary: summary,
      sleepSessions: sessions,
    );
  }
}

class SleepSession {
  final int sleepValue;
  final String startAt;
  final String endAt;

  SleepSession({
    required this.sleepValue,
    required this.startAt,
    required this.endAt,
  });

  factory SleepSession.fromJson(Map<String, dynamic> json) {
    return SleepSession(
      sleepValue: json['sleep_value'],
      startAt: json['start_at'],
      endAt: json['end_at'],
    );
  }
}

class SleepDataChart {
  final String date; // Full date in format YYYY-MM-DD
  final String day; // Abbreviated day such as 'M', 'Tu', etc.
  final int sleepValue; // Total sleep in minutes
  final int awakeValue; // Total awake in minutes

  SleepDataChart(this.date, this.day, this.sleepValue, this.awakeValue);
}

class SleepBarData {
  final String label;      // usually "Sleep" for daily
  final double startHour;  // start time as double (e.g., 2.5 for 2:30 AM)
  final double endHour;    // end time
  final int value;         // sleep state

  SleepBarData({
    required this.label,
    required this.startHour,
    required this.endHour,
    required this.value,
  });
}

class MonthlySleepModel {

  final String label;
  final double startHour;  // start time as double (e.g., 2.5 for 2:30 AM)
  final double endHour;
  final int value;

  MonthlySleepModel({
    required this.label,
    required this.startHour,
    required this.endHour,
    required this.value,
  });
}

class YearlySleepModel {
  final String label;
  final double startHour;  // start time as double (e.g., 2.5 for 2:30 AM)
  final double endHour;
  final int value;

  YearlySleepModel({
    required this.label,
    required this.startHour,
    required this.endHour,
    required this.value,
  });
}

class MultiYearlySleepModel {
  final String label;  // year
  final double light;
  final double rem;
  final double deep;

  MultiYearlySleepModel({
    required this.label,
    required this.light,
    required this.rem,
    required this.deep,
  });
}




