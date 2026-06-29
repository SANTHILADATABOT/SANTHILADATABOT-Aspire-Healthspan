
class BloodPressureData {
  final DateTime date;
  final int systolic;
  final int diastolic;
  final int targetSystolic;
  final int targetDiastolic;
  final double diastolic_sd_high;
  final double diastolic_sd_low;
  final double systolic_sd_high;
  final double systolic_sd_low;
  final String day;
  final String Year;
  final String months;


  BloodPressureData({
    required this.Year,
    required this.day,
    required this.months,
    required this.date,
    required this.systolic,
    required this.diastolic,
    required this.targetSystolic,
    required this.targetDiastolic,
    required this.diastolic_sd_high,
    required this.systolic_sd_low,
    required this.systolic_sd_high,
    required this.diastolic_sd_low,
  });


}
