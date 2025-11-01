
class HeartRateData {
  final String day;
  final String Years;
  final String months;
  final DateTime date;
  final int heartrate;
  final int targetheartrate;
  final double sd_high;
  final double sd_low;



  HeartRateData({
    required this.day,
    required this.Years,
    required this.months,
    required this.date,
    required this.heartrate,
    required this.targetheartrate,
    required this.sd_low,
    required this.sd_high
  });
}

class HeartRateData1 {
  final String day;
  final String Year;
  final String months;
  final DateTime date;
  final int systolic;
  final int targetSystolic;
  final double systolic_sd_high;
  final double systolic_sd_low;



  HeartRateData1({
    required this.day,
    required this.Year,
    required this.months,
    required this.date,
    required this.systolic,
    required this.targetSystolic,
    required this.systolic_sd_low,
    required this.systolic_sd_high
  });
}