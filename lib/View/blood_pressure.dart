import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:azpire_new/Controller/bloodpressure_controller.dart';
import 'package:azpire_new/Model/bloodpressure_model.dart';
import 'package:azpire_new/utils/app_color.dart';
import 'package:azpire_new/utils/appimages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../utils/apptext.dart';
import '../utils/apptextstyle.dart';


class BloodPressureChartPage extends StatefulWidget {
  @override
  State<BloodPressureChartPage> createState() => _BloodPressureChartPageState();
}

class _BloodPressureChartPageState extends State<BloodPressureChartPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _opacityAnimation;
  late TooltipBehavior _tooltipBehavior;

  double? diastolic_sd_low;
  double? systolic_sd_high;
  double? systolic_sd_low;
  double? diastolic_sd_high;
  var datetime;
  String currentTitle = 'Daily Blood Pressure Average';
  String Reports = 'Day';
  List<BloodPressureData> chartData = [];
  String selectedPeriod = 'Day';
  bool _isTextVisibleblue = false;
  bool _isTextVisibleorange = false;
  bool _isTextVisiblegreen = false;
  bool ismmHg220 = false;
  bool ismmhg80 = false;
  bool isLoading = false;
  int? target_sys, target_dys;
  String? mainDate; // Variable to store the fetched date
  int? systolicValue; // Variable to store the systolic value
  int? diastolicValue;
  final BloodPressureController _bloodpressurecontroller = Get.put(BloodPressureController());
  DateTime? selectedDate;
  TextEditingController syscontroller = TextEditingController();
  TextEditingController diacontroller = TextEditingController();
  int? fromYear;
  int? toYear;
  int? fromMonth;
  int? toMonth;
  String yearPickerLabel = "Pick Years";
  String? Upto;
  String? username;

  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("name"); // or "username"
    });
  }



  void simulateLoading(Future<void> Function() chartFunction) async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(Duration(seconds: 2)); // Optional delay
    await chartFunction();

    setState(() {
      isLoading = false;
    });
  }


  @override
  void initState() {
    super.initState();
    loadUsername();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Speed of blinking
    )
      ..repeat(reverse: true); // Repeats the animation in reverse
    _opacityAnimation = Tween<double>(
      begin: 1.0, // Fully visible
      end: 0.5, // Semi-transparent
    ).animate(_controller);
    //Week_Chart();
    Day_Chart();
    mainDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    selectedDate = DateTime.now(); // To show today's date initially
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
    );
  }

  // Calculate the standard deviation
  double calculateStandardDeviation(List<double> values) {
    if (values.isEmpty) return 0.0;

    double mean = values.reduce((a, b) => a + b) / values.length;
    double sumSquaredDiffs = values
        .map((value) => (value - mean) * (value - mean))
        .reduce((a, b) => a + b);
    return sqrt(sumSquaredDiffs / values.length); // Standard deviation
  }


  void _toggleTextVisibility(String type) {
    setState(() {
      if (type == 'blue') {
        _isTextVisibleblue = !_isTextVisibleblue;
        _isTextVisibleorange = false;
        _isTextVisiblegreen = false;
      } else if (type == 'orange') {
        _isTextVisibleorange = !_isTextVisibleorange;
        _isTextVisibleblue = false;
        _isTextVisiblegreen = false;
      } else if (type == 'green') {
        _isTextVisiblegreen = !_isTextVisiblegreen;
        _isTextVisibleblue = false;
        _isTextVisibleorange = false;
      }
    });
  }


  void _toggletextinfo(bool is220Hmmg) {
    setState(() {
      if (is220Hmmg) {
        ismmHg220 = !ismmHg220;
        ismmhg80 = false;
      } else {
        ismmhg80 = !ismmhg80;
        ismmHg220 = false;
      }
    });
  }



  @override
  void dispose() {
    _controller.dispose(); // Dispose the AnimationController
    super.dispose();
  }

  String formatDateTime(String input) {
    try {
      input = input.trim().replaceAll('--', '-'); // Clean up if necessary
      DateTime dateTime = DateFormat("yyyy-MM-dd hh:mm a").parse(input);
      return DateFormat("MMM dd, yyyy HH:mm").format(
          dateTime); // "May 12, 2025 8.58 AM"
    } catch (e) {
      print("Error formatting date: $e");
      return input; // Fallback to raw input if parsing fails
    }
  }


  Future<void> Day_Chart() async {
    setState(() => isLoading = true);
    try {
      final result = await _bloodpressurecontroller.Day_Chart(
          userId: '102',
          date: DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now()),
          type: 'daily'
      );

      final String? recentRaw = result['recent_datetime'];
      final String formattedDate = recentRaw != null ? formatDateTime(recentRaw) : result['mainDate'];

      setState(() {
        mainDate = formattedDate;
        systolicValue = result['dayBpSystolic'];
        diastolicValue = result['dayBpDiastolic'];
        target_sys = result['targetSystolic'];
        target_dys = result['targetDiastolic'];
        chartData = result['chartData'];
        diastolic_sd_low = (result['diastolic_sd_low'] as num?)?.toDouble();
        systolic_sd_high = (result['systolic_sd_high'] as num?)?.toDouble();
        systolic_sd_low = (result['systolic_sd_low'] as num?)?.toDouble();
        diastolic_sd_high = (result['diastolic_sd_high'] as num?)?.toDouble();
      });
    } catch (e) {
      print('Error fetching Day Chart: $e');
    }finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> Week_Chart() async {
    setState(() => isLoading = true);
    try {
      final result = await _bloodpressurecontroller.Week_Chart(
          '102',
          DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now())
      );

      final String? recentRaw = result['recent_datetime'];
      final String formattedDate = recentRaw != null
          ? formatDateTime(recentRaw)
          : 'No recent data';


      setState(() {
        chartData = result['chartData'];
        systolicValue = result['weekBpSystolic'];
        diastolicValue = result['weekBpDiastolic'];
        target_sys = result['targetSystolic'];
        target_dys = result['targetDiastolic'];
        mainDate = formattedDate;
        diastolic_sd_low = result['diastolic_sd_low'];
        systolic_sd_high = result['systolic_sd_high'];
        systolic_sd_low = result['systolic_sd_low'];
        diastolic_sd_high = result['diastolic_sd_high'];
      });
    } catch (e) {
      print('Error loading weekly data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> Month_Chart() async {
    setState(() => isLoading = true);
    try {
      final result = await _bloodpressurecontroller.Month_Chart(
          '102',
          DateFormat('yyyy-MM').format(selectedDate ?? DateTime.now())
      );

      final String? recentRaw = result['recent_datetime'];
      final String formattedDate = recentRaw != null
          ? formatDateTime(recentRaw)
          : 'No recent data';

      setState(() {
        chartData = result['chartData'];
        systolicValue = result['weekBpSystolic'];
        diastolicValue = result['weekBpDiastolic'];
        target_sys = result['targetSystolic'];
        target_dys = result['targetDiastolic'];
        mainDate = formattedDate;
        diastolic_sd_low = result['diastolic_sd_low'];
        systolic_sd_high = result['systolic_sd_high'];
        systolic_sd_low = result['systolic_sd_low'];
        diastolic_sd_high = result['diastolic_sd_high'];
      });
    } catch (e) {
      print('Error loading Monthly data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> Year_Chart() async {
    setState(() => isLoading = true);
    try {
      final result = await _bloodpressurecontroller.Year_Chart(
          '102',
          DateFormat('yyyy-MM').format(selectedDate ?? DateTime.now())
      );

      final String? recentRaw = result['recent_datetime'];
      final String formattedDate = recentRaw != null
          ? formatDateTime(recentRaw)
          : 'No recent data';

      setState(() {
        chartData = result['chartData'];
        systolicValue = result['weekBpSystolic'];
        diastolicValue = result['weekBpDiastolic'];
        target_sys = result['targetSystolic'];
        target_dys = result['targetDiastolic'];
        mainDate = formattedDate;
        diastolic_sd_low = result['diastolic_sd_low'];
        systolic_sd_high = result['systolic_sd_high'];
        systolic_sd_low = result['systolic_sd_low'];
        diastolic_sd_high = result['diastolic_sd_high'];
      });
    } catch (e) {
      print('Error loading Yearly data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> MultiYear_Chart() async {
    setState(() => isLoading = true);

    if (toYear == null) {
      print('toYear is null. Cannot call API.');
      return;
    }

    try {
      final result = await _bloodpressurecontroller.MultiYear_Chart(
        '102',
        toYear!,  // Only pass toYear
      );

      final String? recentRaw = result['recent_datetime'];
      final String formattedDate = recentRaw != null
          ? formatDateTime(recentRaw)
          : 'No recent data';

      setState(() {
        chartData = result['chartData'];
        systolicValue = result['weekBpSystolic'];
        diastolicValue = result['weekBpDiastolic'];
        target_sys = result['targetSystolic'];
        target_dys = result['targetDiastolic'];
        systolic_sd_high = (result['systolic_sd_high'] as num?)?.toDouble();
        systolic_sd_low = (result['systolic_sd_low'] as num?)?.toDouble();
        diastolic_sd_high = (result['diastolic_sd_high'] as num?)?.toDouble();
        diastolic_sd_low = (result['diastolic_sd_low'] as num?)?.toDouble();
        mainDate = formattedDate;
      });
    } catch (e) {
      print('Error loading Multi Yearly data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  String makePossessive(String? name) {
    if (name == null || name.trim().isEmpty) return '';
    name = name.trim();
    if (name.endsWith('s') || name.endsWith('S')) {
      return "$name'";  // Chris → Chris'
    } else {
      return "$name's"; // Amelia → Amelia's
    }
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
        backgroundColor: Color(0xFFffffff),
        appBar: AppBar(
          centerTitle: true,
          title: Row(
            children: [
              // Center the text using the Center widget
              Expanded(
                child: Center(
                  child:Text(
                    username != null
                        ? "${makePossessive(username)} Blood Pressure"
                        : "",
                    textAlign: TextAlign.center,
                    style: Apptextstyle.s18wbap,
                  ),
                ),
              ),
              // Spacer to push the zoom button to the right
            ],
          ),
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
          backgroundColor: Color(0xFFffffff),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
              child:
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    width: double.infinity,
                    // height: 50, // give it a fixed height
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // DAY, WEEK, MONTH, YEAR ROW
                              Container(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      child: Text(
                                        'Day',
                                        style: Reports == 'Day'
                                            ? Apptextstyle.s16wncR
                                            : Apptextstyle.s16wncG,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          //selectedPeriod = 'Day';
                                          currentTitle =
                                          'Daily Blood Pressure Average';
                                          Reports = 'Day';
                                        });
                                        simulateLoading(Day_Chart);
                                      },
                                    ),
                                    SizedBox(width: 20),
                                    InkWell(
                                      child: Text(
                                        'Week',
                                        style: Reports == 'Week'
                                            ? Apptextstyle.s16wncR
                                            : Apptextstyle.s16wncG,
                                      ),
                                      onTap: () {
                                        setState(() {
                                         // selectedPeriod = 'Week';
                                          currentTitle =
                                          'Weekly Blood Pressure Average';
                                          Reports = 'Week';
                                        });
                                        simulateLoading(Week_Chart);
                                      },
                                    ),
                                    SizedBox(width: 20),
                                    InkWell(
                                      child: Text(
                                        'Month',
                                        style: Reports == 'Month'
                                            ? Apptextstyle.s16wncR
                                            : Apptextstyle.s16wncG,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          //selectedPeriod = 'Month';
                                          currentTitle =
                                          'Monthly Blood Pressure Average';
                                          Reports = 'Month';
                                        });
                                        simulateLoading(Month_Chart);
                                      },
                                    ),
                                    SizedBox(width: 20),
                                    InkWell(
                                      child: Text(
                                        'Year',
                                        style: Reports == 'Year'
                                            ? Apptextstyle.s16wncR
                                            : Apptextstyle.s16wncG,
                                      ),
                                      onTap: () {
                                        setState(() {
                                         // selectedPeriod = 'Year';
                                          currentTitle =
                                          'Yearly Blood Pressure Average';
                                          Reports = 'Year';
                                        });
                                        simulateLoading(Year_Chart);
                                      },
                                    ),
                                    SizedBox(width: 20),
                                    InkWell(
                                      child: Text(
                                        'Multi-Year',
                                        style: Reports == 'Multi-Year'
                                            ? Apptextstyle.s16wncR
                                            : Apptextstyle.s16wncG,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          currentTitle = 'Multi-Year Blood Pressure Average';
                                          Reports = 'Multi-Year';

                                          // 👉 INITIALIZE DEFAULT YEAR PICKER LABEL
                                          final now = DateTime.now();
                                         // fromYear = now.year;
                                          toYear = now.year;

                                          yearPickerLabel =
                                              "${DateFormat('yyyy').format(DateTime(toYear!))}";
                                        });

                                        simulateLoading(MultiYear_Chart);
                                      },
                                    ),

                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),
                              // Space between filter and date picker
                              // DATE PICKER BELOW THE FILTER ROW
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      if (Reports == 'Multi-Year') {
                                        var toDatePicked = await DatePicker.showSimpleDatePicker(
                                          context,
                                          initialDate: Upto != null
                                              ? DateTime(int.parse(Upto!))
                                              : DateTime.now(),
                                          firstDate: DateTime(1960),
                                          lastDate: DateTime.now(),
                                          dateFormat: "yyyy",
                                          locale: DateTimePickerLocale.en_us,
                                          looping: false,
                                            titleText: 'Select End Year'
                                        );

                                        if (toDatePicked != null) {
                                          toYear = toDatePicked.year;

                                          setState(() {
                                            Upto = toYear.toString();
                                            yearPickerLabel = "$Upto";
                                          });

                                          await MultiYear_Chart();
                                        }
                                      } else {
                                        String dateFormatString = (Reports == 'Day' || Reports == 'Week')
                                            ? "MMMM dd, yyyy"
                                            : "MMMM-yyyy";

                                        var datePicked = await DatePicker.showSimpleDatePicker(
                                          context,
                                          initialDate: selectedDate ?? DateTime.now(),
                                          firstDate: DateTime(1960),
                                          lastDate: DateTime.now(),
                                          dateFormat: dateFormatString,
                                          locale: DateTimePickerLocale.en_us,
                                          looping: false,
                                        );

                                        if (datePicked != null) {
                                          setState(() {
                                            selectedDate = datePicked;
                                            if (Reports == 'Week') {
                                              Reports = 'Day';
                                              currentTitle = 'Daily Blood Pressure Average';
                                              mainDate = DateFormat('MMMM dd, yyyy').format(datePicked);
                                              simulateLoading(Day_Chart);
                                            } else if (Reports == 'Year') {
                                              Reports = 'Month';
                                              currentTitle = 'Monthly Blood Pressure Average';
                                              mainDate = DateFormat('MMMM-yyyy').format(datePicked);
                                              simulateLoading(Month_Chart);
                                            } else {
                                              switch (Reports) {
                                                case 'Day':
                                                  currentTitle = 'Daily Blood Pressure Average';
                                                  mainDate = DateFormat('MMMM dd, yyyy').format(datePicked);
                                                  simulateLoading(Day_Chart);
                                                  break;
                                                case 'Month':
                                                  currentTitle = 'Monthly Blood Pressure Average';
                                                  mainDate = DateFormat('MMMM-yyyy').format(datePicked);
                                                  simulateLoading(Month_Chart);
                                                  break;
                                              }
                                            }
                                          });
                                        }
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xff275176),
                                        borderRadius: BorderRadius.all(Radius.circular(8)),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            Reports == 'Multi-Year'
                                                ? yearPickerLabel
                                                : selectedDate != null
                                                ? ((Reports == 'Day' || Reports == 'Week')
                                                ? DateFormat('MMMM dd, yyyy').format(selectedDate!)
                                                : DateFormat('MMMM-yyyy').format(selectedDate!))
                                                : "",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(Icons.arrow_drop_down, color: Colors.white),
                                        ],
                                      ),
                                    ),
                                  )



                                ],
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),

                if (isLoading)
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.40,
                      color: Colors.white,
                    ),
                  )
                else
                  if (Reports == "Day")
                  buildBloodPressureChart(
                  context: context,
                  title: 'Blood Pressure for this Day',
                  chartData: chartData,
                  targetSystolic: target_sys?.toInt() ?? 120,
                  targetDiastolic: target_dys?.toInt() ?? 80,
                  xValueMapper: (data, _) => data.day, // Or custom format like "08:00"
                  minY: 60,
                  maxY: 200,
                  interval: 20,
                  Xaxistitle: 'Time of Day',
                      isMonth: false
                  )
                  else
                    if (Reports == "Week")
                      buildBloodPressureChart(
                          context: context,
                          title: 'Avg Daily Blood Pressure',
                          chartData: chartData,
                          targetSystolic: target_sys?.toInt() ?? 120,
                          targetDiastolic: target_dys?.toInt() ?? 80,
                          xValueMapper: (data, _) => data.day, // Or custom format like "08:00"
                          minY: 60,
                          maxY: 200,
                          interval: 20,
                          Xaxistitle: 'Days',
                          isMonth: false
                      )
                    else
                      if (Reports == "Month")
                        buildBloodPressureChart(
                          context: context,
                          title: 'Avg Weekly Blood Pressure',
                            chartData: chartData,
                            targetSystolic: target_sys?.toInt() ?? 120,
                            targetDiastolic: target_dys?.toInt() ?? 80,
                            xValueMapper: (data, _) => data.months, // Or custom format like "08:00"
                            minY: 60,
                            maxY: 200,
                            interval: 20,
                            Xaxistitle: 'Weeks',
                            isMonth: false
                        )
                      else
                        if (Reports == "Year")
                          buildBloodPressureChart(
                            context: context,
                            chartData: chartData,
                            targetSystolic: target_sys?.toInt() ?? 120,
                            targetDiastolic: target_dys?.toInt() ?? 80,
                            xValueMapper: (data, _) => data.months, // Or custom format like "08:00"
                            minY: 60,
                            maxY: 200,
                            interval: 20,
                            Xaxistitle: 'Months',
                            title: 'Avg Monthly Blood Pressure',
                              isMonth: true
                          )
                        else
                          if (Reports == "Multi-Year")
                            buildBloodPressureChart(
                                context: context,
                                chartData: chartData,
                                targetSystolic: target_sys?.toInt() ?? 120,
                                targetDiastolic: target_dys?.toInt() ?? 80,
                                xValueMapper: (data, _) => data.Year, // Or custom format like "08:00"
                                minY: 60,
                                maxY: 200,
                                interval: 20,
                                Xaxistitle: 'Years',
                                title: 'Avg Yearly Blood Pressure',
                                isMonth: false
                            ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Card background color
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.grey.shade500,
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 10),

                        // ─────────── Row 1: SYSTOLIC ───────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: size.width * 0.4,
                              child: Row(
                                children: [
                                  Container(
                                    width: size.width * 0.1,
                                    height: 10,
                                    color: Color(0xFF5454ff),
                                  ),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      AppText.SYSTOLIC,
                                      style: Apptextstyle.s11wbcB,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            SizedBox(
                              width: size.width * 0.4,
                              child: Row(
                                children: [
                                  Container(
                                    width: size.width * 0.1,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFd9d9ff),
                                      border: Border.all(color: Color(0xFF5454ff), width: 1),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      AppText.std,
                                      style: Apptextstyle.s11wbcB,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10),

                        // ─────────── Row 2: DIASTOLIC ───────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: size.width * 0.4,
                              child: Row(
                                children: [
                                  Container(
                                    width: size.width * 0.1,
                                    height: 10,
                                    color: Color(0xFFf6803d),
                                  ),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      AppText.DIASTOLIC,
                                      style: Apptextstyle.s11wbcB,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            SizedBox(
                              width: size.width * 0.4,
                              child: Row(
                                children: [
                                  Container(
                                    width: size.width * 0.1,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFfddcc9),
                                      border: Border.all(color: Color(0xFFf6803d), width: 1),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      AppText.std,
                                      style: Apptextstyle.s11wbcB,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        // ─────────── Row 3: TARGET + INFO ───────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: size.width * 0.4,
                              child: Row(
                                children: [
                                  Container(
                                    width: size.width * 0.1,
                                    height: 10,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      AppText.target,
                                      style: Apptextstyle.s11wbcB,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            SizedBox(
                              width: size.width * 0.4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedSize(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child: AnimatedOpacity(
                                      opacity: _isTextVisibleblue ? 1.0 : 0.0,
                                      duration: Duration(milliseconds: 300),
                                      child: _isTextVisibleblue
                                          ? Padding(
                                        padding: const EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          AppText.bp_blue_info1,
                                          style: Apptextstyle.s12wncB,
                                          textAlign: TextAlign.left,
                                        ),
                                      )
                                          : SizedBox.shrink(),
                                    ),
                                  ),
                                  AnimatedSize(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child: AnimatedOpacity(
                                      opacity: _isTextVisibleorange ? 1.0 : 0.0,
                                      duration: Duration(milliseconds: 300),
                                      child: _isTextVisibleorange
                                          ? Text(
                                        AppText.bp_orange_info2,
                                        style: Apptextstyle.s12wncB,
                                        textAlign: TextAlign.left,
                                      )
                                          : SizedBox.shrink(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // ✅ Bottom Spacing
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                 SizedBox(height: 30),
                systolicValue == null
                    ? Padding(
                  padding: const EdgeInsets.fromLTRB(30, 10, 20, 10),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: double.infinity,
                      height: 75,
                      color: Colors.white,
                    ),
                  ),
                )
                    : Padding(
                  padding: EdgeInsets.only(right: 10, left: 20),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 25),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white, // Card background color
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.grey.shade500,
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          AppText.mostrecent,
                                          style: Apptextstyle.s13wbcB,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            mainDate ??
                                                ' ',
                                            // Default value if no data is available
                                            style: Apptextstyle.s14wbcB
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  // Systolic Row
                                  Padding(
                                      padding: EdgeInsets.only(left: 17),
                                      child: Text(
                                          AppText.SYSTOLIC,
                                          style: Apptextstyle.s12wncB
                                      )
                                  ),
                                  // SizedBox(width: 125), // Space between label and value
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Color(
                                                  0xFF5454ff),
                                              // Border color for Systolic
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                                5), // Optional: Rounded corners
                                          ),
                                          child: Text(
                                              systolicValue != null
                                                  ? '$systolicValue mmHg'
                                                  : ' ',
                                              // Default value if no data is available
                                              style: Apptextstyle.s13wbcO
                                          ),
                                        ),
                                        SizedBox(
                                            width:
                                            15),
                                        // Space between value and info icon
                                        Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () =>
                                                  _toggletextinfo(true),
                                              // Toggle text on icon click
                                              child: Icon(
                                                  Icons.info_outline_rounded,
                                                  color: ismmHg220
                                                      ? Color(0xFF5454ff)
                                                      : Color(0xFF997f7f)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // SizedBox(height: 18),
                              AnimatedSize(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: AnimatedOpacity(
                                  opacity: ismmHg220 ? 1.0 : 0.0,
                                  duration: Duration(milliseconds: 300),
                                  child: ismmHg220
                                      ? Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      AppText.bpinfo3,
                                      style: TextStyle(fontSize: 12.0),
                                      textAlign: TextAlign.left,
                                    ),
                                  )
                                      : SizedBox.shrink(),
                                ),
                              ),
                              SizedBox(
                                height: 18,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 17),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppText.DIASTOLIC,
                                      style: TextStyle(fontSize: 12.0),
                                    ),
                                    // SizedBox(width: 125), // Space between label and value
                                    Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Color(
                                                    0xFFf6803d),
                                                //orange, // Border color for Systolic
                                                width: 1.0,
                                              ),
                                              borderRadius: BorderRadius.circular(
                                                  5), // Optional: Rounded corners
                                            ),
                                            child: Text(
                                                diastolicValue != null
                                                    ? '$diastolicValue mmHg'
                                                    : '80 mmHg',
                                                // Default value if no data is available
                                                style: Apptextstyle.s13wbcOr
                                            ),
                                          ),
                                          SizedBox(width: 15),
                                          Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                onTap: () =>
                                                    _toggletextinfo(false),
                                                // Toggle text on icon click
                                                child: Icon(
                                                    Icons.info_outline_rounded,
                                                    color: ismmhg80
                                                        ? Color(0xFFf6803d)
                                                        : Color(0xFF997f7f)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              AnimatedSize(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: AnimatedOpacity(
                                  opacity: ismmhg80 ? 1.0 : 0.0,
                                  duration: Duration(milliseconds: 300),
                                  child: ismmhg80
                                      ? Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      AppText.bpinfo4,
                                      style: Apptextstyle.s12wncB,
                                      textAlign: TextAlign.left,
                                    ),
                                  )
                                      : SizedBox.shrink(),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 18),
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Stack(
                              children: [
                                Opacity(
                                  opacity: _opacityAnimation.value,
                                  child: Container(
                                    width: 45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF5454ff),
                                      shape: BoxShape
                                          .rectangle, // Apply the opacity to the container
                                      // Background color remains constant
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          Appimages.bp_logo),
                                      fit: BoxFit.cover, // Image remains static
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                isLoading
                    ? Center(
                  child: Image.asset(
                    Appimages.applogo,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                )
                    : Padding(
                  padding: EdgeInsets.only(left: 20, right: 10, bottom: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Card background color
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.grey.shade500,
                        width: 1.0,
                      ),
                    ),
                    child: Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                const EdgeInsets.only(top: 20, bottom: 15),
                                child: Text(
                                  currentTitle,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    Reports,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF275176)),
                                    overflow: TextOverflow
                                        .ellipsis, // Add this line to handle overflow
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        AppText.DIFF,
                                        style: Apptextstyle.s13wbcothers,
                                        overflow: TextOverflow
                                            .ellipsis, // Add this line to handle overflow
                                      ),
                                      Text(AppText.MMHG,
                                          style: Apptextstyle.s13wbcothers)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: chartData.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            Reports == 'Month'
                                                ?
                                            chartData[index].months
                                                : Reports == 'Year'
                                                ? DateFormat("MMM").format(
                                                chartData[index].date)
                                                : Reports == 'Multi-Year'
                                                ? DateFormat("yyyy").format(
                                                chartData[index].date)
                                            // Format for month
                                                :Reports == 'Day' ? DateFormat(
                                                'MMM dd, yyyy HH:mm')
                                                .format(chartData[index]
                                                .date) :
                                            chartData[index].day,
                                            // Format for other reports
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: Text(
                                              '${chartData[index]
                                                  .systolic}/${chartData[index]
                                                  .diastolic}',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 12
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Divider()
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]
              )
          ),
        )
    );


  }


  Widget buildBloodPressureChart({
    required BuildContext context,
    required String title,
    required String Xaxistitle,
    required List<BloodPressureData> chartData,
    required int targetSystolic,
    required int targetDiastolic,
    required String Function(BloodPressureData, int) xValueMapper,
    double maxY = 200,
    double minY = 60,
    double interval = 20,
    required bool isMonth
  }) {
    // ✅ Use MediaQuery to get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // ✅ Always use portrait height (the larger of height or width)
    final portraitHeight = screenSize.height > screenSize.width
        ? screenSize.height
        : screenSize.width;

    final chartHeight = portraitHeight * 0.4;
    return Container(
      width: double.infinity,
      height:chartHeight,
      child: SfCartesianChart(
        title: ChartTitle(text: title),
        tooltipBehavior: TooltipBehavior(enable: true),
        plotAreaBorderWidth: 0.0,
        plotAreaBorderColor: Colors.grey.shade100,
        backgroundColor: Colors.white,
        primaryXAxis: isMonth == true ?
             CategoryAxis(
          title: AxisTitle(text: Xaxistitle),
          labelStyle: TextStyle(fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
          maximumLabels: 12,
          labelIntersectAction: AxisLabelIntersectAction.none,
          majorTickLines: MajorTickLines(width: 0),
          majorGridLines: MajorGridLines(width: 0),
        )
            : CategoryAxis(
          title: AxisTitle(text: Xaxistitle),
          labelStyle: TextStyle(fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
          majorTickLines: MajorTickLines(width: 0),
          majorGridLines: MajorGridLines(width: 0),
        ),
        primaryYAxis: NumericAxis(
          minimum: minY,
          maximum: maxY,
          interval: interval,
          title: AxisTitle(text: "mmHg"),
          labelStyle: TextStyle(fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
         // numberFormat: NumberFormat('##0'),
          majorGridLines: MajorGridLines(width: 0),
          minorGridLines: MinorGridLines(width: 0),
          majorTickLines: MajorTickLines(width: 0),
          plotBands: [
            PlotBand(
              isVisible: true,
              start: targetSystolic.toDouble(),
              end: targetSystolic.toDouble(),
              borderWidth: 2,
              borderColor: Colors.green,
            ),
            PlotBand(
              isVisible: true,
              start: targetDiastolic.toDouble(),
              end: targetDiastolic.toDouble(),
              borderWidth: 2,
              borderColor: Colors.green,
            ),
          ],
        ),
        series: <CartesianSeries>[
          SplineRangeAreaSeries<BloodPressureData, String>(
            // dataSource: chartData.where((d) => d.date.isBefore(DateTime.now().add(Duration(days: 0)))).toList(),
            dataSource: chartData,
            xValueMapper:xValueMapper,
            highValueMapper: (data, _) => systolic_sd_high,
            lowValueMapper: (data, _) => systolic_sd_low,
            color: Color(0xFFd9d9ff).withOpacity(0.6),
            name: '',
            enableTooltip: false,
          ),
          SplineRangeAreaSeries<BloodPressureData, String>(
            dataSource: chartData,
            // dataSource: chartData.where((d) => d.date.isBefore(DateTime.now().add(Duration(days: 0)))).toList(),
            xValueMapper: xValueMapper,
            highValueMapper: (data, _) => diastolic_sd_high,
            lowValueMapper: (data, _) => diastolic_sd_low,
            color: Color(0xFFfddcc9).withOpacity(0.6),
            name: '',
            enableTooltip: false,
          ),
          SplineSeries<BloodPressureData, String>(
            name: 'Systolic',
            dataSource: chartData,
            xValueMapper: xValueMapper,
            yValueMapper: (data, _) => data.systolic == 0 ? null : data.systolic,
            color: Color(0xFF5454ff),
            markerSettings: MarkerSettings(isVisible: true, height: 12, width: 12),
          ),
          SplineSeries<BloodPressureData, String>(
            name: 'Diastolic',
            dataSource: chartData,
            xValueMapper: xValueMapper,
            yValueMapper: (data, _) => data.diastolic == 0 ? null : data.diastolic,
            color: Color(0xffF6803D),
            markerSettings: MarkerSettings(isVisible: true, height: 12, width: 12),
          ),
        ],
      ),
    );
  }


}


