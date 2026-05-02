import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:azpire_new/Controller/bloodpressure_controller.dart';
import 'package:azpire_new/Model/bloodpressure_model.dart';
import 'package:azpire_new/View/profile.dart';
import 'package:azpire_new/menu/NavMneu.dart';
import 'package:azpire_new/utils/app_color.dart';
import 'package:azpire_new/utils/appimages.dart';
import 'package:azpire_new/widgets/Appexithelper.dart';
import 'package:azpire_new/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
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
import '../widgets/shimmer_effects.dart';
import 'package:azpire_new/widgets/disclaimers.dart';
import 'Dashboard_screen.dart';


class BloodPressureChartPage extends StatefulWidget {
  var name;

  var email, profile, noti_count;

  BloodPressureChartPage({Key? key, required this.name, required this.email, required this.profile, required this.noti_count,}) : super(key: key);
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
  final _advancedDrawerController = AdvancedDrawerController();
  int? fromYear;
  int? toYear;
  int? fromMonth;
  int? toMonth;
  String yearPickerLabel = "Pick Years";
  String? Upto;
  String? username;
  var name;
  var email;
  var pofileimage;
  var noti_count;
  var user_id;

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


   // await Future.delayed(Duration(seconds: 2)); // Optional delay
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

    if (mounted) setState(() => isLoading = true);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    try {
      final result = await _bloodpressurecontroller.Day_Chart(
          userId: user_id,
          date: DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now()),
          type: 'daily'
      );

      final String? recentRaw = result['recent_datetime'];
      final String formattedDate = recentRaw != null ? formatDateTime(recentRaw) : result['mainDate'];

      if (mounted) {
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
      }
    } catch (e) {
      print('Error fetching BP Day Chart: $e');
    }finally {
    if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> Week_Chart() async {

    if (mounted) setState(() => isLoading = true);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    try {
      final result = await _bloodpressurecontroller.Week_Chart(
          user_id,
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
      print('Error loading BP weekly data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> Month_Chart() async {

    setState(() => isLoading = true);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    try {
      final result = await _bloodpressurecontroller.Month_Chart(
          user_id,
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
      print('Error loading BP Monthly data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> Year_Chart() async {

    setState(() => isLoading = true);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    try {
      final result = await _bloodpressurecontroller.Year_Chart(
          user_id,
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
      print('Error loading BP Yearly data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> MultiYear_Chart() async {

    setState(() => isLoading = true);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    if (toYear == null) {
      print('toYear is null. Cannot call API.');
      return;
    }

    try {
      final result = await _bloodpressurecontroller.MultiYear_Chart(
        user_id,
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
      print('Error loading BP Multi Yearly data: $e');
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
    return WillPopScope(
      // onWillPop: () async {
      //   ExitAppDialog();
      //   return true;
      // },
        onWillPop: () async {
          if (_advancedDrawerController.value.visible) {
            _advancedDrawerController.hideDrawer();
            return false; // stop navigation
          }
          // if drawer is closed, allow normal back
          return true;
        },
      child:AdvancedDrawer(
      controller: _advancedDrawerController,
      backdropColor: Colors.grey.shade100,
      drawer: NavMenu(name: widget.name, email : widget.email, profile:widget.profile, noti_count: widget.noti_count, ),
      child: Scaffold(
          backgroundColor: Color(0xFFffffff),
          appBar: AppBar(
            centerTitle: true,
            title: widget.profile == null ? ShimmerLoadingItem() : Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: (){
              Get.to(()=>Profile());
            },
            child: CircleAvatar(
              backgroundImage: NetworkImage(widget.profile),
              radius: 20,
            ),
          ),
          SizedBox(width: 20),
          TextTitle1(
            title: "Hi, ${username.toString().capitalizeFirst}",
            color: Colors.black,
          ),
          Spacer(),
          IconButton(
            onPressed: () {
              _advancedDrawerController.showDrawer();
            },
            icon: Icon(
              Icons.menu,
              color: Colors.black,
            ),
          ),
        ],
      ),
            leading: IconButton(
              onPressed: () {
                if (_advancedDrawerController.value.visible) {
                  _advancedDrawerController.hideDrawer();
                }
                else {
                 Get.back();
                  // Get.offAll(() => DashboardScreen(
                  //   deviceID: '', // pass params if needed
                  // ));
                }
              },
              icon: Icon(Icons.arrow_back_ios),
            ),
            backgroundColor: Color(0xFFffffff),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
                child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppText.BP_heading,
                        textAlign: TextAlign.center,
                        style: Apptextstyle.s18wbap,
                        )
                      ],
                    ),
                  ),
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
                                      GestureDetector(
                                        child: Text(
                                          AppText.day,
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
                                      GestureDetector(
                                        child: Text(
                                          AppText.week,
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
                                      GestureDetector(
                                        child: Text(
                                          AppText.month,
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
                                      GestureDetector(
                                        child: Text(
                                          AppText.year,
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
                                      GestureDetector(
                                        child: Text(
                                          AppText.multiyear,
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
                                    GestureDetector(
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
                                          color: AppColors.othersT,
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
                                      color: AppColors.systolic_color,
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
                                        border: Border.all(color: AppColors.systolic_color, width: 1),
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
                                      color: AppColors.diastolic_color,
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
                                        border: Border.all(color: AppColors.diastolic_color, width: 1),
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
                                      color: AppColors.target_color,
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
                                                color:AppColors.systolic_color,
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
                                              GestureDetector(
                                                onTap: () =>
                                                    _toggletextinfo(true),
                                                // Toggle text on icon click
                                                child: Icon(
                                                    Icons.info_outline_rounded,
                                                    color: ismmHg220
                                                        ? AppColors.systolic_color
                                                        : AppColors.info_changing,
                                                )
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
                                                  color: AppColors.diastolic_color,
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
                                                GestureDetector(
                                                  onTap: () =>
                                                      _toggletextinfo(false),
                                                  // Toggle text on icon click
                                                  child: Icon(
                                                      Icons.info_outline_rounded,
                                                      color: ismmhg80
                                                          ? AppColors.diastolic_color
                                                          : AppColors.info_changing),
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
                                        color:AppColors.systolic_color,
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
                      height: size.height * 0.07,
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
                                        color:  AppColors.othersT,
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
                                          color: AppColors.othersT),
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
                            DisclaimerFooter(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]
                )
            ),
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
  })
{
    // ✅ Use MediaQuery to get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // ✅ Always use portrait height (the larger of height or width)
    final portraitHeight = screenSize.height > screenSize.width
        ? screenSize.height
        : screenSize.width;

    final chartHeight = portraitHeight * 0.4;
    final xStart = chartData.isNotEmpty ? xValueMapper(chartData.first, 0) : '';
    final xEnd = chartData.isNotEmpty ? xValueMapper(chartData.last, chartData.length - 1) : '';

    final targetSystolicPoints = [
      TargetLinePoint(xStart, targetSystolic.toDouble()),
      TargetLinePoint(xEnd, targetSystolic.toDouble()),
    ];

    final targetDiastolicPoints = [
      TargetLinePoint(xStart, targetDiastolic.toDouble()),
      TargetLinePoint(xEnd, targetDiastolic.toDouble()),
    ];


    return Container(
      width: double.infinity,
      height:chartHeight,
      child: SfCartesianChart(
        title: ChartTitle(text: title),
        tooltipBehavior: TooltipBehavior(
            enable: true,
            textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
            )
        ),
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
          labelPlacement: LabelPlacement.onTicks,
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
          labelPlacement: LabelPlacement.onTicks,
          edgeLabelPlacement: EdgeLabelPlacement.shift,
        ),
        primaryYAxis: NumericAxis(
          minimum: minY,
          maximum: maxY,
          interval: interval,
          title: AxisTitle(text: AppText.bp_unit),
          labelStyle: TextStyle(fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
         // numberFormat: NumberFormat('##0'),
          majorGridLines: MajorGridLines(width: 0),
          minorGridLines: MinorGridLines(width: 0),
          majorTickLines: MajorTickLines(width: 0),
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
          // 2️⃣ Target Lines (Middle)
          // 2️⃣ Target Lines (Middle, Dynamic Full Width)
          LineSeries<TargetLinePoint, String>(
            name: '',
            dataSource: targetSystolicPoints,
            xValueMapper: (point, _) => point.xLabel,
            yValueMapper: (point, _) => point.yValue,
            color:  AppColors.target_color,
            width: 2,
            enableTooltip: false,
            markerSettings: MarkerSettings(
                isVisible: false
            ),
          ),

          LineSeries<TargetLinePoint, String>(
            name: '',
            dataSource: targetDiastolicPoints,
            xValueMapper: (point, _) => point.xLabel,
            yValueMapper: (point, _) => point.yValue,
            color: AppColors.target_color,
            width: 2,
            enableTooltip: false,
            markerSettings: MarkerSettings(
                isVisible: false
            ),
          ),
          SplineSeries<BloodPressureData, String>(
            name: AppText.SYSTOLIC,
            dataSource: chartData,
            xValueMapper: xValueMapper,
            yValueMapper: (data, _) => data.systolic == 0 ? null : data.systolic,
            color: AppColors.systolic_color,
            markerSettings: MarkerSettings(isVisible: true, height: 12, width: 12),
            //emptyPointSettings: EmptyPointSettings(mode: EmptyPointMode.zero),
          ),
          SplineSeries<BloodPressureData, String>(
            name: AppText.DIASTOLIC,
            dataSource: chartData,
            xValueMapper: xValueMapper,
            yValueMapper: (data, _) => data.diastolic == 0 ? null : data.diastolic,
            color: AppColors.diastolic_color,
            markerSettings: MarkerSettings(isVisible: true, height: 12, width: 12),
            //emptyPointSettings: EmptyPointSettings(mode: EmptyPointMode.zero),
          ),
        ],

      ),
    );
  }




}

class TargetLinePoint {
  final String xLabel;
  final double yValue;
  TargetLinePoint(this.xLabel, this.yValue);
}



