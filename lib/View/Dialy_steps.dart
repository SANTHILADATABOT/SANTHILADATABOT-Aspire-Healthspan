import 'dart:convert';
import 'dart:ui';
import 'package:azpire_new/Controller/steps_controller.dart';
import 'package:azpire_new/Model/steps_model.dart';
import 'package:azpire_new/utils/app_color.dart';
import 'package:azpire_new/utils/appimages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import '../root/root.dart';
import '../utils/apptext.dart';
import '../utils/apptextstyle.dart';


class StepsChartPage extends StatefulWidget {
  @override
  State<StepsChartPage> createState() => _StepsChartPageState();
}
class _StepsChartPageState extends State<StepsChartPage>
    with SingleTickerProviderStateMixin {

  late Animation<double> _opacityAnimation;
  late AnimationController _controller;
  var datetime;
  String currentTitle = 'Average Daily Data';
  String Reports = 'Day';
 // String selectedPeriod = 'Day';
  bool ismmHg220 = false;
  bool ismmhg80 = false;
  bool isLoading = false;
  bool _isLoading = false;
  bool is_steps = false;
  List<StepsData> _stepsData = [];
  final List<String> daysOfWeek = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
  // New variables to track the tapped bar index and steps count
  int? _tappedIndex;
  int? _tappeddayIndex;
  int? _tappedSteps;
  String? mainDate;
  String? _tappedday;
  double? milesValue; // Variable to store the systolic value
  double? calValue;
  int? dailyAvgSteps;
  String? stespsvalue;
  int? target_steps,max_steps, day_target_steps;
  bool target_visible = false;
  final StepsController _stepscontroller = Get.put(StepsController());
  DateTime? selectedDate;
  int? fromYear;
  int? toYear;
  String yearPickerLabel = "Pick Years";
  String? Upto;
  final numberFormatter = NumberFormat.decimalPattern('en_US');
  String _formattedTappedSteps = '';


  void simulateLoading(Future<void> Function() chartFunction) async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration(seconds: 2)); // Optional delay
    await chartFunction();

    setState(() {
      _isLoading = false;
    });
  }


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Speed of blinking
    )..repeat(reverse: true); // Repeats the animation in reverse
    _opacityAnimation = Tween<double>(
      begin: 1.0, // Fully visible
      end: 0.7,   // Semi-transparent
    ).animate(_controller);
    //Week_Chart();
    Day_Chart();
    mainDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    selectedDate = DateTime.now(); // To show today's date initially

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggletextinfo( ) {

    setState(() {
      is_steps = !is_steps;
    });
  }



  String formatDateTime(String input) {
    try {
      input = input.trim().replaceAll('--', '-'); // Clean up if necessary
      DateTime dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(input);
      return DateFormat("MMM dd yyyy HH:mm").format(dateTime); // "May 16 2025 12:08"
    } catch (e) {
      print("Error formatting date: $e");
      return input; // Fallback to raw input if parsing fails
    }
  }

  Future<void> Day_Chart() async {
    setState(() => _isLoading = true);
    try {
      //final service = StepsService();
      final result = await _stepscontroller.Day_Chart(
        userId: '102',
        date: DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now()),
      );

      // final String? recentRaw = result['recent_datetime'];
      // final String formattedDate = recentRaw != null ? formatDateTime(recentRaw) : result['mainDate'];


      // print("Day Chart Fetched Successfully:");
      // print("Formatted Date: ${result['mainDate']}");
      // print("Chart Data Count: ${result['chartData'].length}");
      // print("Step Intervals:");
      for (var entry in result['step_intervals']) {
        print("Interval: ${entry['interval']}, Total Steps: ${entry['total_steps']}");
      }



      setState(() {
        mainDate = result['mainDate'];
        stespsvalue = result['recentSteps'];
        milesValue = result['miles'];
        calValue = result['calories'];
        _stepsData = result['chartData'];
        target_steps = result['targetsteps'];
        day_target_steps = result['targetsteps'];
        max_steps = result['maxSteps'];
        target_visible = false;

      });
    } catch (e) {
      print('Error loading Daily steps: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> Week_Chart() async {
    setState(() => _isLoading = true);
    try {
      //final service = StepsService();
      final result = await _stepscontroller.Week_Chart(
        userId: '102',
        date: DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now()),
      );

      // final String? recentRaw = result['recent_datetime'];
      // final String formattedDate = recentRaw != null ? formatDateTime(recentRaw) : result['mainDate'];

      setState(() {
       mainDate = result['mainDate'];
        stespsvalue = result['recent_step'];
        milesValue = result['miles'];
        calValue = result['calories'];
        _stepsData = result['chartData'];
       target_steps = result['targetsteps'];
       max_steps = result['maxSteps'];
       dailyAvgSteps = result['daily_avg_steps'];
       target_visible = true;
      });
    } catch (e) {
      print('Error loading weekly steps: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> Month_Chart() async {
    setState(() => _isLoading = true);
    try {
     // final service = StepsService();
      final result = await _stepscontroller.Month_Chart(
        userId: '102',
        date: DateFormat('yyyy-MM').format(selectedDate ?? DateTime.now()),
      );


      // final String? recentRaw = result['recent_datetime'];
      // final String formattedDate = recentRaw != null ? formatDateTime(recentRaw) : result['mainDate'];


      setState(() {
        mainDate = result['mainDate'];
        stespsvalue = result['recent_step'];
        milesValue = result['miles'];
        calValue = result['calories'];
        _stepsData = result['chartData'];
        target_steps = result['targetsteps'];
        max_steps = result['maxSteps'];
        dailyAvgSteps = result['daily_avg_steps'];
        target_visible = true;

      });
    } catch (e) {
      print('Error loading monthly steps: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> Year_Chart() async {
    setState(() => _isLoading = true);
    try {
      // final service = StepsService();
      final result = await _stepscontroller.Year_Chart(
        userId: '102',
        date: DateFormat('yyyy-MM').format(selectedDate ?? DateTime.now()),
      );


      // final String? recentRaw = result['recent_datetime'];
      // final String formattedDate = recentRaw != null ? formatDateTime(recentRaw) : result['mainDate'];


      setState(() {
        mainDate = result['mainDate'];
        stespsvalue = result['recent_step'];
        milesValue = result['miles'];
        calValue = result['calories'];
        _stepsData = result['chartData'];
        target_steps = result['targetsteps'];
        max_steps = result['maxSteps'];
        dailyAvgSteps = result['daily_avg_steps'];
        target_visible = true;
      });
    } catch (e) {
      print('Error loading monthly steps: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> MultiYear_Chart() async {
    setState(() => _isLoading = true);
    try {
      // final service = StepsService();
      final result = await _stepscontroller.MultiYear_Chart(
        userId: '102',
        //fromYear: fromYear!,
        toYear: toYear!
      );

      // final String? recentRaw = result['recent_datetime'];
      // final String formattedDate = recentRaw != null ? formatDateTime(recentRaw) : result['mainDate'];

      setState(() {
        mainDate = result['mainDate'];
        stespsvalue = result['recent_step'];
        milesValue = result['miles'];
        calValue = result['calories'];
        _stepsData = result['chartData'];
        target_steps = result['targetsteps'];
        max_steps = result['maxSteps'];
        dailyAvgSteps = result['daily_avg_steps'];
        target_visible = true;
      });
    } catch (e) {
      print('Error loading multiyear steps: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    //Find the maximum steps value in the data
    // int maxSteps = _stepsData.isNotEmpty
    //     ? _stepsData.map((data) => data.dailySteps).reduce((a, b) => a > b ? a : b)
    //     : 0;
    //
    // double maxinterval = ((maxSteps + 150) / 100).ceil() * 100.0;
    //
    // Size size = MediaQuery.of(context).size;

    // int maxSteps = _stepsData.isNotEmpty
    //     ? _stepsData.map((data) => data.dailySteps).reduce((a, b) => a > b ? a : b)
    //     : 0;
    //
    // double maxinterval = ((maxSteps + 50 + 49) ~/ 50) * 50;

    // int maxSteps = _stepsData.isNotEmpty
    //     ? _stepsData.map((data) => data.dailySteps).reduce((a, b) => a > b ? a : b)
    //     : 0;
    //
    // double maxinterval = ((maxSteps + 49) / 50).ceil() * 50;

    int maxSteps = _stepsData.isNotEmpty
        ? _stepsData.map((data) => data.dailySteps).reduce((a, b) => a > b ? a : b)
        : 0;

    double maxinterval = ((maxSteps + 50 ) ~/ 50) * 50;

    Size size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: Color(0xFFffffff),
        appBar: AppBar(
          centerTitle: true,
          title: Row(
            children: [
              // Center the text using the Center widget
              Expanded(
                child: Center(
                  child: Text(
                    AppText.steps_heading,
                    textAlign: TextAlign.center,
                    style: Apptextstyle.s18wbap,
                  ),
                ),
              ),
              // Spacer to push the zoom button to the right
            ],
          ),
          leading: IconButton(
            onPressed: (){
              Get.back();
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
          backgroundColor: Color(0xFFffffff),
        ),
        body: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      width: double.infinity,
                      // height: 50, // give it a fixed height
                      child: Column(
                        children: [
                      //   Row(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     InkWell(
                      //       onTap: () async {
                      //         var datePicked = await DatePicker.showSimpleDatePicker(
                      //           context,
                      //           initialDate: selectedDate ?? DateTime.now(),
                      //           firstDate: DateTime(1960),
                      //           lastDate: DateTime.now(),
                      //           dateFormat: "MMMM dd, yyyy",
                      //           locale: DateTimePickerLocale.en_us,
                      //           looping: false,
                      //         );
                      //
                      //         if (datePicked != null) {
                      //           DateTime today = DateTime.now();
                      //           // Remove time part for accurate date comparison
                      //           DateTime selected = DateTime(
                      //               datePicked.year, datePicked.month,
                      //               datePicked.day);
                      //           DateTime current = DateTime(
                      //               today.year, today.month, today.day);
                      //
                      //           // if (selected.isAtSameMomentAs(current)) {
                      //           setState(() {
                      //             selectedDate = datePicked;
                      //             mainDate = DateFormat('dd-MMMM-yyyy').format(datePicked);
                      //             selectedPeriod = 'Day';
                      //             currentTitle = 'Average Daily Data';
                      //             Reports = 'Day';
                      //           });
                      //           simulateLoading(Day_Chart);
                      //
                      //         }
                      //
                      //       },
                      //       child: Container(
                      //         decoration: BoxDecoration(
                      //           color: Color(0xff275176),
                      //           borderRadius: BorderRadius.all(Radius.circular(8)),
                      //         ),
                      //         child: Padding(
                      //           padding:
                      //           const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      //           child: Text(
                      //             selectedDate != null
                      //                 ? DateFormat('MMMM dd, yyyy').format(selectedDate!)
                      //                 : "Pick Date",
                      //             style: TextStyle(
                      //               color: Colors.white,
                      //               fontWeight: FontWeight.bold,
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                          // Date Picker button aligned right
                      SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
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
                                onTap: ()  {
                                  setState(() {
                                    //selectedPeriod = 'Day';
                                    currentTitle = 'Average Daily Data';
                                    Reports = 'Day';
                                    _tappedSteps = null;
                                  });
                                  simulateLoading(Day_Chart);
                                },
                              ),
                              SizedBox(width: 20),
                              InkWell(
                                child: Text(
                                    'Week',
                                    style: Reports == 'Week' ? Apptextstyle.s16wncR: Apptextstyle.s16wncG
                                ),
                                onTap: () {
                                  setState(() {
                                    //selectedPeriod = 'Week';
                                    currentTitle = ' Weekly Daily Data';
                                    Reports = 'Week';
                                    _tappedSteps = null;
                                    //Week_Chart();
                                  });
                                  simulateLoading(Week_Chart);
                                },
                              ),
                              SizedBox(width: 20,),
                              InkWell(
                                child: Text(
                                    'Month',
                                    style: Reports == 'Month' ? Apptextstyle.s16wncR: Apptextstyle.s16wncG
                                ),
                                onTap: () {
                                  setState(() {
                                   // selectedPeriod = 'Month';
                                    currentTitle = 'Average Monthly Data';
                                    Reports = 'Month';
                                    _tappedSteps = null;
                                    //month_Chart();
                                  });
                                  simulateLoading(Month_Chart);
                                },
                              ),
                              SizedBox(width: 20,),
                              InkWell(
                                child: Text(
                                    'Year',
                                    style: Reports == 'Year' ? Apptextstyle.s16wncR: Apptextstyle.s16wncG
                                ),
                                onTap: () {
                                  setState(() {
                                   // selectedPeriod = 'Year';
                                    currentTitle = ' Average Yearly Data';
                                    Reports = 'Year';
                                    _tappedSteps = null;
                                    //Year_Chart();
                                  });
                                  simulateLoading(Year_Chart);
                                },
                              ),
                              SizedBox(width: 20,),
                              InkWell(
                                child: Text(
                                    'Multi-Year',
                                    style: Reports == 'Multi-Year' ? Apptextstyle.s16wncR: Apptextstyle.s16wncG
                                ),
                                onTap: () {
                                  setState(() {
                                    // selectedPeriod = 'Year';
                                    currentTitle = ' Multi-Year Yearly Data';
                                    Reports = 'Multi-Year';
                                    _tappedSteps = null;

                                    final now = DateTime.now();
                                    //fromYear = now.year;
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
                                  }
                                  else {
                                    String dateFormatString =
                                    (Reports == 'Day' || Reports == 'Week')
                                        ? "MMMM dd, yyyy"
                                        : "MMMM-yyyy";
                                    var datePicked = await DatePicker
                                        .showSimpleDatePicker(
                                      context,
                                      initialDate: selectedDate ??
                                          DateTime.now(),
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
                                          // From Week to Day
                                          Reports = 'Day';
                                          currentTitle = 'Average Daily Data';
                                          mainDate = DateFormat('MMMM dd, yyyy')
                                              .format(datePicked);
                                          simulateLoading(Day_Chart);
                                        } else if (Reports == 'Year') {
                                          // From Year to Month
                                          Reports = 'Month';
                                          currentTitle = 'Average Monthly Data';
                                          mainDate =
                                              DateFormat('MMMM-yyyy').format(
                                                  datePicked);
                                          simulateLoading(Month_Chart);
                                        } else {
                                          // Stay in current report type
                                          switch (Reports) {
                                            case 'Day':
                                              currentTitle =
                                              'Average Daily Data';
                                              mainDate =
                                                  DateFormat('MMMM dd, yyyy')
                                                      .format(datePicked);
                                              simulateLoading(Day_Chart);
                                              break;
                                            case 'Month':
                                              currentTitle =
                                              'Average Monthly Data';
                                              mainDate = DateFormat('MMMM-yyyy')
                                                  .format(datePicked);
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
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 25,),
            // if (_tappedSteps != null)
            //   Card(
            //         color: Colors.white,
            //         child: Padding(
            //           padding: const EdgeInsets.all(8.0),
            //           child:
            //               Text(
            //                 '${NumberFormat.decimalPattern('en_US').format(_tappedSteps)} Steps',
            //                 style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff775DD0)),
            //               ),
            //         ),
            //       ),

                if (_isLoading)
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Container(
                          width: double.infinity,
                          height: size.height * 0.5,
                          color: Colors.white,
                        ),
                      ),
                    )
                else if (Reports == "Day")
                  buildStepsChartWidget(
                    context: context,
                    size: size,
                    title: " Hourly Steps for this Day",
                    data: _stepsData,
                      xValueMapper: (d, _) => d.labelHour,
                    maxInterval: maxinterval,
                    onPointTap: (details) {
                      setState(() {
                        // print("_tappedSteps${details.dataPoints}");
                        _tappedIndex = details.pointIndex;
                        _tappedSteps = details.dataPoints![details.pointIndex!].y as int;
                        // print("_tappedSteps$_tappedSteps");
                      });
                    },
                    targetSteps: target_steps ?? 10000,
                    isweek: true,
                    Daysteps: true,
                      Xaxistitle: 'Time of Day'
                  )
                else if (Reports == "Week")
                    buildStepsChartWidget(
                    context: context,
                    size: size,
                    title: "Avg Daily Steps per Day",
                        data: _stepsData,
                        xValueMapper: (d, _) => d.day,
                        maxInterval: maxinterval,
                        onPointTap: (details) {
                          setState(() {
                            // print("_tappedSteps${details.dataPoints}");
                            _tappedIndex = details.pointIndex;
                            _tappedSteps = details.dataPoints![details.pointIndex!].y as int;
                            // print("_tappedSteps$_tappedSteps");
                          });
                        },
                        targetSteps: target_steps ?? 10000,
                        isweek: false,
                        Daysteps: false,
                        Xaxistitle: 'Days'
                  )
                else if (Reports == "Month")
                      buildStepsChartWidget(
                      context: context,
                      size: size,
                      title: "Avg Weekly Steps",
                          data: _stepsData,
                          xValueMapper: (d, _) => d.monthName,
                          maxInterval: maxinterval,
                          onPointTap: (details) {
                            setState(() {
                              // print("_tappedSteps${details.dataPoints}");
                              _tappedIndex = details.pointIndex;
                              _tappedSteps = details.dataPoints![details.pointIndex!].y as int;
                              // print("_tappedSteps$_tappedSteps");
                            });
                          },
                          targetSteps: target_steps ?? 10000,
                          isweek: false,
                          Daysteps: false,
                          Xaxistitle: 'Weeks'

                    )
                  else if (Reports == "Year")
                        buildStepsChartWidget(
                        context: context,
                        size: size,
                        title: "Avg Monthly Steps",
                            data: _stepsData,
                            xValueMapper: (d, _) => d.monthName,
                            maxInterval: maxinterval,
                            onPointTap: (details) {
                              setState(() {
                                // print("_tappedSteps${details.dataPoints}");
                                _tappedIndex = details.pointIndex;
                                _tappedSteps = details.dataPoints![details.pointIndex!].y as int;
                                // print("_tappedSteps$_tappedSteps");
                              });
                            },
                            targetSteps: target_steps ?? 10000,
                            isweek: false,
                            Daysteps: false,
                            Xaxistitle: 'Months'
                      )
                      else if (Reports == "Multi-Year")
                          buildStepsChartWidget(
                            context: context,
                            size: size,
                            title: "Avg Yearly Steps",
                              data: _stepsData,
                              xValueMapper: (d, _) => d.year,
                              maxInterval: maxinterval,
                              onPointTap: (details) {
                                setState(() {
                                  // print("_tappedSteps${details.dataPoints}");
                                  _tappedIndex = details.pointIndex;
                                  _tappedSteps = details.dataPoints![details.pointIndex!].y as int;
                                  // print("_tappedSteps$_tappedSteps");
                                });
                              },
                              targetSteps: target_steps ?? 10000,
                              isweek: false,
                              Daysteps: false,
                              Xaxistitle: 'Years'

                          ),
                  SizedBox(height: 10,),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Container(
                  //       width: size.width * 0.4,
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           Container(
                  //               width: size.width *
                  //                   0.1, // Width of the small box
                  //               height: 10, // Height of the small box
                  //               color: Colors.green //orange, // Color of the box
                  //           ),
                  //           Text(
                  //               AppText.target,
                  //               style: Apptextstyle.s13wbcB
                  //           ),
                  //         ],
                  //       ),
                  //       decoration: BoxDecoration(
                  //         border: Border.all(color: Colors.grey.shade700, width: 1),
                  //         color: Colors.transparent,
                  //       ),
                  //       padding: EdgeInsets.all(
                  //           8), // Optional: Add padding for better spacing
                  //     ),
                  //     SizedBox(width: 10,),
                  //     if(target_visible)
                  //     Container(
                  //       width: size.width * 0.4,
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           RichText(
                  //             text: TextSpan(
                  //               children: [
                  //                 TextSpan(
                  //                   text: '$max_steps',
                  //                   style: TextStyle(
                  //                     color: Colors.black, // color for max_steps
                  //                     fontWeight: FontWeight.bold,
                  //                     fontSize: 12,
                  //                   ),
                  //                 ),
                  //                 TextSpan(
                  //                   text: '/',
                  //                   style: TextStyle(
                  //                     color: Colors.black,
                  //                   ),
                  //                 ),
                  //                 TextSpan(
                  //                   text: '$target_steps',
                  //                   style: TextStyle(
                  //                     color: Colors.green, // color for target_steps
                  //                     fontWeight: FontWeight.bold,
                  //                     fontSize: 12,
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           )
                  //
                  //         ],
                  //       ),
                  //       decoration: BoxDecoration(
                  //         border: Border.all(color: Colors.grey.shade700, width: 1),
                  //         color: Colors.transparent,
                  //       ),
                  //       padding: EdgeInsets.all(
                  //           8), // Optional: Add padding for better spacing
                  //     ),
                  //   ],
                  // ),
                  SizedBox(height: 20,),
                  stespsvalue == null ?
                  Padding(
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
                  ) :
                  Padding(
                    padding: EdgeInsets.only(right: 10, left: 20),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 25),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFffffff), // Card background color
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: Colors.grey.shade500,
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Top section with image and text
                                SizedBox(height: 10,),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.end,
                                //   children: [
                                //     Row(
                                //       mainAxisAlignment: MainAxisAlignment.end,
                                //       children: [
                                //         Text(
                                //           AppText.mostrecent,
                                //           style: Apptextstyle.s13wbcB
                                //         ),
                                //         SizedBox(width: 5),
                                //         Padding(
                                //           padding: const EdgeInsets.only(right: 8),
                                //           child: Text(
                                //             mainDate ?? '', // Default value if no data is available
                                //             style: Apptextstyle.s14wbcB
                                //           ),
                                //         )
                                //       ],
                                //     ),
                                //   ],
                                // ),
                                SizedBox(height: 15),
                                // row1
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                   Column(
                                     crossAxisAlignment: CrossAxisAlignment.center,
                                     children: [
                                       Text(
                                         AppText.steps_count,
                                         style: Apptextstyle.s12wcb
                                       ),
                                       SizedBox(height: 10,),
                                       Container(
                                         padding: EdgeInsets.zero,
                                         decoration: BoxDecoration(
                                           border: Border.all(
                                             color: Color(0xff775DD0), // Border color for Systolic
                                             width: 1.0,
                                           ),
                                           borderRadius: BorderRadius.circular(5), // Optional: Rounded corners
                                         ),
                                         child: Padding(
                                           padding: EdgeInsets.symmetric(horizontal: 4),
                                           child: Text(
                                             stespsvalue != null ? '$stespsvalue steps' : '',
                                             style: Apptextstyle.s12wbcv
                                           ),
                                         ),
                                       ),
                                     ],
                                   ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          AppText.distance,
                                          style: Apptextstyle.s12wcb ,
                                        ),
                                        SizedBox(height: 10,),
                                        Container(
                                          padding: EdgeInsets.zero,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Color(0xff775DD0), // Border color for Systolic
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.circular(5), // Optional: Rounded corners
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4),
                                            child: Text(
                                                milesValue != null ? '${numberFormatter.format(milesValue)} mi' : '0 mi',
                                              style: Apptextstyle.s12wbcv
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          AppText.cal_burnt,
                                          style: Apptextstyle.s12wcb
                                        ),
                                        SizedBox(height: 10,),
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.zero,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff775DD0), // Border color for Systolic
                                                  width: 1.0,
                                                ),
                                                borderRadius: BorderRadius.circular(5), // Optional: Rounded corners
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 4),
                                                child: Text(
                                                    calValue != null ? '${numberFormatter.format(calValue)} kcal' : '0 kcal',
                                                  style: Apptextstyle.s12wbcv
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 4,),
                                            InkWell(
                                              onTap: () => _toggletextinfo(), // Toggle text on icon click
                                              child: Icon(
                                                Icons.info_outline_rounded,
                                                color:is_steps?Colors.indigo : Color(0xFF997f7f),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )

                                  ],
                                ),
                                SizedBox(height: 10),
                                Column(
                                  children: [
                                    AnimatedSize(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInCubic,
                                      child: AnimatedOpacity(
                                        opacity: is_steps? 1.0 : 0.0,
                                        duration: Duration(milliseconds: 300),
                                        child: is_steps
                                            ?  Center(
                                          child: Padding(padding: const EdgeInsets.all(10),
                                            child: Text(
                                              AppText.steps_info,
                                              style: TextStyle(fontSize: 12.0),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )
                                            : SizedBox.shrink(),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Target Daily Steps are ${NumberFormat.decimalPattern('en_US').format(day_target_steps)}',
                                        style: Apptextstyle.s12wbcG
                                    )
                                  ],
                                ),
                               SizedBox(height: 10,),
                                if(target_visible)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      Reports == 'Month'
                                          ? 'Current Actual Weekly Average Steps is '
                                          '${NumberFormat.decimalPattern('en_US').format(dailyAvgSteps)}'
                                          : 'Current Actual Daily Average Steps is '
                                          '${NumberFormat.decimalPattern('en_US').format(dailyAvgSteps)}',
                                      style: Apptextstyle.s12wbcp,
                                    )
                                    // Text(''
                                    //     'Current Actual Daily Average Steps is '
                                    //     '${NumberFormat.decimalPattern('en_US').format(dailyAvgSteps)}',
                                    //     style: Apptextstyle.s12wbcp
                                    // )
                                  ],
                                ),
                                // Info text
                                SizedBox(height: 15,)
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
                                alignment: Alignment.center, // Align children to center
                                children: [
                                  Opacity(
                                    opacity: _opacityAnimation.value, // Apply the opacity to the container
                                    child: Container(
                                      width: 45,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: Color(0xff775DD0), // Background color remains constant
                                        shape: BoxShape.rectangle, // Optional: make it circular
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(Appimages.Steps_logo),
                                        fit: BoxFit.cover, // Image remains static
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                       // if(target_visible)
                      ],
                    ),
                  ),
                  //SizedBox(height: 10,),

                  SizedBox(height: 10,),
                  _isLoading ?
                  Center(child: Image.asset(
                    Appimages.applogo,
                    height: 50,
                    fit: BoxFit.contain,
                  ),) :
                  Padding(
                    padding:  EdgeInsets.only(left: 30,right: 15, bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                       // color:  Colors.white,// Card background color
                        borderRadius: BorderRadius.circular(5),
                        /*boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5), // Shadow color
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3), // Shadow position
                          ),
                        ],*/
                        border: Border.all(
                          color: Colors.grey, // Border color
                          width: 1.0, // Border width
                        ),
                      ),
                      child:  Card(
                        color: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 15,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  currentTitle,
                                  style: TextStyle(
                                      color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 0, 0),
                              child: Row(
                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,// Spreads children evenly
                                children: [
                                  Expanded(
                                    child: Text(
                                      Reports,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF275176),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left, // Centers the text within its space
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      AppText.avgstesp,
                                      style: Apptextstyle.swbothers,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      AppText.dmil,
                                      style: Apptextstyle.swbothers,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      AppText.kcal,
                                      style: Apptextstyle.swbothers,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                             SizedBox(height: 10),
                            SizedBox(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _stepsData.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                Reports == 'Month'
                                                    ? _stepsData[index].monthName
                                                    : Reports == 'Year'
                                                    ? DateFormat("MMM").format(
                                                    _stepsData[index].date)
                                                    : Reports == 'Multi-Year'
                                                    ? DateFormat("yyyy").format(
                                                    _stepsData[index].date)
                                                // Format for month
                                                    :Reports == 'Day' ? DateFormat(
                                                    'MMM dd, yyyy HH:mm')
                                                    .format(_stepsData[index]
                                                    .date) :
                                                _stepsData[index].day,
                                                // Format for other reports
                                               //overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    fontSize: 12
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                 NumberFormat.decimalPattern('en_US').format(_stepsData[index].dailySteps),
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 12
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  '${numberFormatter.format(_stepsData[index].miles)}', // use toStringAsFixed
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 12
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  '${numberFormatter.format(_stepsData[index].caloriesBurned)}',
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 12
                                                  ),
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
        )
    );
  }

  Widget buildStepsChartWidget({
    required BuildContext context,
    required Size size,
    required String title,
    required List<StepsData> data,
    required double maxInterval,
    required Function(ChartPointDetails) onPointTap,
    required String Function(StepsData, int) xValueMapper,
    required int targetSteps,
    required bool isweek, Daysteps,
    required String Xaxistitle,
  }) {

    return Container(
      width: double.infinity,
      height: size.height * 0.5,
      child: SfCartesianChart(
        tooltipBehavior: TooltipBehavior(
          enable: true,
          // ✅ Custom formatter for tooltip text
        ),
        //margin: const EdgeInsets.only(left: 10),
        plotAreaBorderWidth: 0,
        backgroundColor: AppColors.White,
        title: ChartTitle(text: title),
        /// ✅ Use CategoryAxis for String-based x-axis
        primaryXAxis: isweek == true ? CategoryAxis (
          minimum: 0,
          maximum: 23,
          interval: 2,
          axisLabelFormatter: (AxisLabelRenderDetails args) {
            final value = args.value.toInt();
            final label = value.toString(); // ✅ Always plain number
            return ChartAxisLabel(
              label,
              TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                // fontWeight: FontWeight.bold, // Optional
                //color: Colors.black,
              ),
            );
          },
          title: AxisTitle(text: Xaxistitle),
          majorTickLines: const MajorTickLines(size: 0),
          majorGridLines: const MajorGridLines(width: 0),
          axisLine: const AxisLine(width: 1, color: Colors.grey),
        ):
        CategoryAxis (
          title: AxisTitle(text: Xaxistitle),
          labelStyle: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          majorTickLines: const MajorTickLines(size: 0),
          majorGridLines: const MajorGridLines(width: 0),
          axisLine: const AxisLine(width: 1, color: Colors.grey),
          labelIntersectAction: AxisLabelIntersectAction.none, // ✅ Prevents skipping
          maximumLabels: 12,
        ),
        /// ✅ Numeric Y-Axis for step count
        primaryYAxis: NumericAxis(
          title: const AxisTitle(
            text: 'Steps',
           // textStyle: TextStyle(color: AppColors.contentColorBlack),
          ),
          minimum: 0,
          maximum: maxInterval,
          interval: maxInterval / 10,
          labelStyle: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
          majorTickLines: const MajorTickLines(width: 0),
          majorGridLines: const MajorGridLines(width: 0),
          numberFormat: NumberFormat.decimalPattern('en_US'),
          plotBands: [
            /// 🎯 Target Line
            PlotBand(
              isVisible: true,
              start: targetSteps.toDouble(),
              end: targetSteps.toDouble(),
              borderWidth: 0,
              borderColor: Colors.green,
              //text: 'Target: $targetSteps',
              textStyle: const TextStyle(color: Colors.green, fontSize: 12,),
              horizontalTextAlignment: TextAnchor.middle,
              verticalTextAlignment: TextAnchor.start,
            ),
          ],
        ),
        series: <CartesianSeries>[
          Daysteps == true ?ColumnSeries<StepsData, String>(
            name: 'Steps',
            dataSource: data,
            xValueMapper: xValueMapper, // ✅ shows "08:00" in tooltip
            yValueMapper: (StepsData d, _) => d.dailySteps,
            //dataLabelMapper: (StepsData d, _) => '${d.labelHour} : ${d.dailySteps}',
            dataLabelSettings: const DataLabelSettings(isVisible: false),
            color: AppColors.steps_graph,
            onPointTap: onPointTap,
          ):
          ColumnSeries<StepsData, String>(
            name: 'Steps',
            dataSource: data,
            xValueMapper: xValueMapper,  // ✅ shows "08:00" in tooltip
            yValueMapper: (StepsData d, _) => d.dailySteps,
            //dataLabelMapper: (StepsData d, _) => '${d.labelHour} : ${d.dailySteps}',
            dataLabelSettings: const DataLabelSettings(isVisible: false),
            color: AppColors.steps_graph,
            onPointTap: onPointTap,
          )
        ],
      ),
    );
  }




}










