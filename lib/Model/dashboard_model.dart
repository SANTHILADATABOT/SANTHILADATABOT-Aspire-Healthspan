class DashboardModel {
  String datetime;
  String heartRate;
  String steps;
  String weight;
  String sleep;
  String bps;
  String bpd;
  String weekRange;   // ✅ <-- ADD THIS

  DashboardModel({
    required this.datetime,
    required this.heartRate,
    required this.steps,
    required this.weight,
    required this.sleep,
    required this.bps,
    required this.bpd,
    required this.weekRange,  // ✅ <-- ADD THIS
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      datetime: json['collection_date'] ?? "",
      heartRate: json['heart_rate']?.toString() ?? "",
      steps: json['daily_steps']?.toString() ?? "",
      weight: json['weight']?.toString() ?? "",
      sleep: json['sleep']?.toString() ?? "",
      bps: json['blood_pressure_systolic']?.toString() ?? "",
      bpd: json['blood_pressure_diastolic']?.toString() ?? "",
      weekRange: json['week_range']?.toString() ?? "N/A",  // ✅ <-- ADD THIS
    );
  }
}
