import 'dart:convert';
import 'dart:ui';
import 'package:azpire_new/Controller/spo2_controller.dart';
import 'package:azpire_new/Model/spo2_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../utils/appimages.dart';
import '../utils/apptext.dart';
import '../utils/apptextstyle.dart';


class BloodoxygenPressureChartPage extends StatefulWidget {
  @override
  State<BloodoxygenPressureChartPage> createState() => _BloodoxygenPressureChartPageState();
}

class _BloodoxygenPressureChartPageState extends State<BloodoxygenPressureChartPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _opacityAnimation;

  var datetime;
  String currentTitle = 'Daily Blood Oxygen Average';
  String Reports = 'Day';
  List<BloodOxygenData> chartData = [];
  final spo2Controller _spo2controller = Get.put(spo2Controller());
  int? recentSpo2;
  int? targetNormal;
  int? targetHigh;
  String? recentTime;
  bool _isTextVisibleblue = false;
  bool _isTextVisibleorange = false;
  bool _isTextVisiblegreen = false;
  bool _isTextVisibleaccent = false;
  bool ismmHg220 = false;
  bool ismmhg80 = false;
  bool isLoading = false;
  String? _tappedDay;
  String? mainDate; // Variable to store the fetched date
  DateTime? selectedDate;
  TextEditingController syscontroller = TextEditingController();
  TextEditingController diacontroller = TextEditingController();
  bool is_heart_rate = false;
  bool is_oxygen = false;
  late TooltipBehavior _tooltipBehavior;
  int? fromYear;
  int? toYear;
  String yearPickerLabel = "Pick Years";
  String? Upto;



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


  void _toggleTextVisibility({
    bool isBlue = false,
    bool isOrange = false,
    bool isRed = false,
    bool isAccent = false,
  }) {
    setState(() {
      // Toggle visibility while ensuring only one is visible at a time
      if (isBlue) {
        _isTextVisibleblue = !_isTextVisibleblue;
        _isTextVisibleorange = false;
        _isTextVisiblegreen= false;
        _isTextVisibleaccent = false;
      } else if (isOrange) {
        _isTextVisibleorange = !_isTextVisibleorange;
        _isTextVisibleblue = false;
        _isTextVisiblegreen = false;
        //_isTextVisibleaccent = false;
      } else if (isRed) {
        _isTextVisiblegreen = !_isTextVisiblegreen;
        _isTextVisibleblue = false;
        _isTextVisibleorange = false;
        _isTextVisibleaccent = false;
      } else if (isAccent) {
        _isTextVisibleaccent = !_isTextVisibleaccent;
        _isTextVisibleblue = false;
        _isTextVisibleorange = false;
        _isTextVisiblegreen = false;
      }

      // Update the main text visibility based on any active state
      is_oxygen = _isTextVisibleblue ||
          _isTextVisibleorange ||
          _isTextVisiblegreen ||
          _isTextVisibleaccent;
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

  void _toggletextinfo() {
    setState(() {
      is_heart_rate = !is_heart_rate;
      is_oxygen = !is_oxygen;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }



  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.5,
    ).animate(_controller);
    Day_Chart(); // Fixed typo here
    mainDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    selectedDate = DateTime.now();
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
    );
  }

  Future<void> Day_Chart() async {
    setState(() => isLoading = true);
    try {
      final result = await _spo2controller.fetchDayChart(
        userId: '102',
        date: DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now()),
        type: 'daily',
      );

      final String? recentRaw = result['recentDatetime']; // Note the correct key: recentDatetime
      final String rawDate = (recentRaw != null && recentRaw.trim().isNotEmpty)
          ? recentRaw
          : result['mainDate'];

      final String formattedDate = formatDateTime(rawDate);



      setState(() {
        mainDate = formattedDate;
        targetNormal = result['targetNormal'];
        targetHigh = result['targetHigh'];
        recentSpo2 = result['recentSpo2'];
        chartData = result['chartData'];
      });
    } catch (e) {
      print('Error fetching SPO2 data: $e');
    }
    finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> Week_Chart() async {
    setState(() => isLoading = true);
    try {
      final result = await _spo2controller.Week_Chart(
        userId: '102',
        date: DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now()),
      );

      final String? recentRaw = result['recent_datetime']; // Note the correct key: recentDatetime
      final String rawDate = (recentRaw != null && recentRaw.trim().isNotEmpty)
          ? recentRaw
          : result['mainDate'];

      final String formattedDate = formatDateTime(rawDate);


      setState(() {
        mainDate = formattedDate;
        targetNormal = result['target_spo2_normal'];
        targetHigh = result['target_spo2_high'];
        recentSpo2 = result['weekspo2'];
        chartData = result['chartData'];
      });
    } catch (e) {
      print('Error fetching Weekly SPO2 data: $e');
    }
    finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> Month_Chart() async {
    setState(() => isLoading = true);
    try {
      final result = await _spo2controller.Month_Chart(
        userId: '102',
        date: DateFormat('yyyy-MM').format(selectedDate ?? DateTime.now()),
      );

      final String? recentRaw = result['recent_datetime']; // Note the correct key: recentDatetime
      final String rawDate = (recentRaw != null && recentRaw.trim().isNotEmpty)
          ? recentRaw
          : result['mainDate'];

      final String formattedDate = formatDateTime(rawDate);


      setState(() {
        mainDate = formattedDate;
        targetNormal = result['target_spo2_normal'];
        targetHigh = result['target_spo2_high'];
        recentSpo2 = result['weekspo2'];
        chartData = result['chartData'];
      });
    } catch (e) {
      print('Error fetching Monthly SPO2 data: $e');
    }
    finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> Year_Chart() async {
    setState(() => isLoading = true);
    try {
      final result = await _spo2controller.Year_Chart(
        userId: '102',
        date: DateFormat('yyyy-MM').format(selectedDate ?? DateTime.now()),
      );

      final String? recentRaw = result['recent_datetime']; // Note the correct key: recentDatetime
      final String rawDate = (recentRaw != null && recentRaw.trim().isNotEmpty)
          ? recentRaw
          : result['mainDate'];

      final String formattedDate = formatDateTime(rawDate);


      setState(() {
        mainDate = formattedDate;
        targetNormal = result['target_spo2_normal'];
        targetHigh = result['target_spo2_high'];
        recentSpo2 = result['weekspo2'];
        chartData = result['chartData'];
      });
    } catch (e) {
      print('Error fetching Yaerly SPO2 data: $e');
    }
    finally {
      setState(() => isLoading = false);
    }
  }


  Future<void> MultiYear_Chart() async {

    setState(() => isLoading = true);
    try {
      final result = await _spo2controller.MultiYear_Chart(
        '102',
        //fromYear!,
        toYear!,
      );

      final String? recentRaw = result['recent_datetime']; // Note the correct key: recentDatetime
      final String rawDate = (recentRaw != null && recentRaw.trim().isNotEmpty)
          ? recentRaw
          : result['mainDate'];

      final String formattedDate = formatDateTime(rawDate);


      setState(() {
        mainDate = formattedDate;
        targetNormal = result['target_spo2_normal'];
        targetHigh = result['target_spo2_high'];
        recentSpo2 = result['weekspo2'];
        chartData = result['chartData'];
      });
    } catch (e) {
      print('Error fetching Yaerly SPO2 data: $e');
    }
    finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    AppText.spo2_heading,
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
                      SizedBox(height: 10,),
                      Align(
                        alignment: Alignment.center,
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
                                  Reports = 'Day';
                                  currentTitle = 'Daily Blood oxygen Average';
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
                                  Reports = 'Week';
                                  currentTitle = 'Weekly Blood oxygen Average';
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
                                  Reports = 'Month';
                                  currentTitle = 'Monthly Blood oxygen Average';
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
                                  currentTitle = 'Yearly Blood oxygen Average';
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
                                  currentTitle = 'Multi-Year Blood oxygen Average';
                                  Reports = 'Multi-Year';

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
                      const SizedBox(height: 10),
                      // Space between filter and date picker
                      // DATE PICKER BELOW THE FILTER ROW
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () async {

                              if (Reports == 'Multi-Year') {
                                // Pick FROM Date (Year + Month)
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
                                      // From Week to Day
                                      Reports = 'Day';
                                      currentTitle =
                                      'Daily Blood oxygen Average';
                                      mainDate =
                                          DateFormat('MMMM dd, yyyy').format(
                                              datePicked);
                                      simulateLoading(Day_Chart);
                                    } else if (Reports == 'Year') {
                                      // From Year to Month
                                      Reports = 'Month';
                                      currentTitle =
                                      'Monthly Blood oxygen Average';
                                      mainDate = DateFormat('MMMM-yyyy').format(
                                          datePicked);
                                      simulateLoading(Month_Chart);
                                    } else {
                                      // Stay in current report type
                                      switch (Reports) {
                                        case 'Day':
                                          currentTitle =
                                          'Daily Blood oxygen Average';
                                          mainDate = DateFormat('MMMM dd, yyyy')
                                              .format(datePicked);
                                          simulateLoading(Day_Chart);
                                          break;
                                        case 'Month':
                                          currentTitle =
                                          'Monthly Blood oxygen Average';
                                          mainDate =
                                              DateFormat('MMMM-yyyy').format(
                                                  datePicked);
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
              SizedBox(
                height: 25,
              ),

              if (isLoading)
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.40,
                    color: Colors.white,
                  ),
                )
              else if (Reports == "Day")
                buildBloodOxygenChart(
                    context: context,
                    chartData: chartData,
                    targetspo2noraml: targetNormal?.toInt() ?? 91,
                    targetspo2high: targetNormal?.toInt() ?? 95,
                    title: 'Blood Oxygen for this Day' // Your list of BloodOxygenData
                )
              else if (Reports == "Week")
                  WeeklybuildBloodOxygenChart(
                      context: context,
                      chartData: chartData,
                      targetspo2noraml: targetNormal?.toInt() ?? 91,
                      targetspo2high: targetNormal?.toInt() ?? 95 ,// Your
                      title: 'Avg Daily Blood Oxygen '
                  )
                else if (Reports == "Month")
                    MonthlybuildBloodOxygenChart(
                        context: context,
                        chartData: chartData,
                        targetspo2noraml: targetNormal?.toInt() ?? 91,
                        targetspo2high: targetNormal?.toInt() ?? 95, // Your
                        title: 'Avg Weekly Blood Oxygen'
                    )
                  else if (Reports == "Year")
                      YearlybuildBloodOxygenChart(
                          context: context,
                          chartData: chartData,
                          targetspo2noraml: targetNormal?.toInt() ?? 91,
                          targetspo2high: targetNormal?.toInt() ?? 95, // Your
                          title: 'Avg Monthly Blood Oxygen'
                      )
                    else if (Reports == "Multi-Year")
                        MultiYearlybuildBloodOxygenChart(
                            context: context,
                            chartData: chartData,
                            targetspo2noraml: targetNormal?.toInt() ?? 91,
                            targetspo2high: targetNormal?.toInt() ?? 95, // Your
                            title: 'Avg Yearly Blood Oxygen'
                        ),
              SizedBox(height: 30),
              Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // First container with icon
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: size.width * 0.3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: size.width *
                                      0.1, // Width of the small box
                                  height: 10,
                                  // color: Color(0xFFD1FCD1),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFD1FCD1),
                                    //borderRadius: BorderRadius.circular(4), // Optional: rounded corners
                                    border: Border.all(
                                      color:Color(0xFF64EE64), // Optional: border color
                                      width: 1, // Optional: border width
                                    ),
                                  ),

                                ),
                                SizedBox(width: 5), // Reduce spacing to help fit content
                                Flexible( // Constrain this section to avoid overflow
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppText.spo2_n,
                                        style: Apptextstyle.s8wbcB,
                                        overflow: TextOverflow.ellipsis, // handle long text
                                        softWrap: false,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.shade700, width: 1),
                              color: Colors.transparent,
                            ),
                            padding: EdgeInsets.all(5),
                          ),
                        ),
                        SizedBox(width: 10),
                        // Second container with icon
                        Container(
                          width: size.width * 0.3,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade700, width: 1),
                            color: Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: size.width * 0.1,
                                height: 10,
                                decoration: BoxDecoration(
                                    color: Color(0xFFFAF0CC),
                                    border: Border.all(
                                        color: Color(0xFFF5D666),
                                        width: 1
                                    )
                                ),
                              ),
                              SizedBox(width: 5), // Reduce spacing to help fit content
                              Flexible( // Constrain this section to avoid overflow
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      AppText.spo2_h,
                                      style: Apptextstyle.s8wbcB,
                                      overflow: TextOverflow.ellipsis, // handle long text
                                      softWrap: false,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10,),
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade700, width: 1),
                            color: Colors.transparent,
                          ),
                          width: size.width * 0.3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: size.width * 0.1,
                                height: 10,
                                decoration: BoxDecoration(
                                    color: Color(0xFFF6CCCC),
                                    border: Border.all(
                                        color:  Color(0xFFF38F8F),
                                        width: 1
                                    )
                                ),
                              ),
                              SizedBox(width: 5),
                              Flexible( // This fixes the overflow
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppText.spo2_l,
                                      style: Apptextstyle.s8wbcB,
                                      softWrap: true,
                                      maxLines: 2,
                                      //overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Show text outside the containers when visible
                    AnimatedSize(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: AnimatedOpacity(
                        opacity: _isTextVisibleblue ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 300),
                        child: _isTextVisibleblue
                            ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            AppText.spo2normal_info,
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
                            ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            AppText.sp02_concern,
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
                        opacity: _isTextVisiblegreen ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 300),
                        child: _isTextVisiblegreen
                            ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            AppText.sp02_low,
                            style: Apptextstyle.s12wncB,
                            textAlign: TextAlign.left,
                          ),
                        )
                            : SizedBox.shrink(),
                      ),
                    ),
                  ]),
              recentSpo2 == null ?
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
                padding: EdgeInsets.only(right: 15, left: 30),
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
                            // Top section with image and text
                            SizedBox(height: 10,),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(width: 5),
                                  Row(
                                    children: [
                                      Text(
                                        AppText.mostrecent,
                                        style: Apptextstyle.s13wbcB,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        mainDate ?? ' ',
                                        // Default value if no data is available
                                        style: Apptextstyle.s14wbcB,

                                      ),
                                    ],
                                  ),
                                ],
                              ),

                            ),
                            SizedBox(height: 10),
                            // Systolic Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 17),
                                  child: Text(
                                    AppText.b_oxygen,
                                    style: Apptextstyle.s12wncB,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Color(0xffFF0000),
                                            // Border color for Systolic
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                              5), // Optional: Rounded corners
                                        ),
                                        child: Text(
                                          recentSpo2 != null ? '$recentSpo2%' : ' ',
                                          style: Apptextstyle.s12wbcR,
                                        ),

                                      ),
                                      SizedBox(width: 15),
                                      // Space between value and info icon
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: [
                                          InkWell(
                                            onTap: () => _toggletextinfo(),
                                            // Toggle text on icon click
                                            child: Icon(
                                              Icons.info_outline_rounded,
                                              color: is_heart_rate ? Color(
                                                  0xffFF0000) : Color(0xFF997f7f),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            AnimatedSize(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInCubic,
                              child: AnimatedOpacity(
                                opacity: is_heart_rate ? 1.0 : 0.0,
                                duration: Duration(milliseconds: 300),
                                child: is_heart_rate
                                    ? Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    AppText.spo2_info,
                                    style: TextStyle(fontSize: 12.0),
                                    textAlign: TextAlign.left,
                                  ),
                                )
                                    : SizedBox.shrink(),
                              ),
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
                            alignment: Alignment.center,
                            // Align children to center
                            children: [
                              Opacity(
                                opacity: _opacityAnimation.value,
                                // Apply the opacity to the container
                                child: Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Color(0xffFF0000),
                                    // Background color remains constant
                                    shape: BoxShape
                                        .rectangle, // Optional: make it circular
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
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],

                ),
              ),
              SizedBox(height: 20,),
              isLoading ?
              Center(child: Image.asset(
                Appimages.applogo,
                height: 50,
                fit: BoxFit.contain,
              ),) :
              Padding(
                padding: EdgeInsets.only(left: 30, right: 20, bottom: 10),
                child: Container(
                  //height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: Colors.white, // Card background color
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Colors.grey.shade500, // Border color
                      width: 1.0, // Border width
                    ),
                  ),
                  child: Card(
                    color: Colors.white,
                    elevation: 0, // Remove default elevation
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
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
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  Reports,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF275176)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  AppText.b_oxygen2,
                                  style: Apptextstyle.s13wbcothers,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5),
                        SizedBox(height: 10),
                        SizedBox(
                          // height: 250,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            //physics: BouncingScrollPhysics(),
                            itemCount: chartData.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment
                                          .center,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            Reports == 'Month' ?
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
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 20),
                                            child: Text(
                                              '${chartData[index].spo2}%', // Add % here
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.right,
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
              )
              // else if (Reports == "Week")
              //   buildBloodPressureChart(
              //     chartData: chartData,
              //     xValueMapper: (BloodPressureData data, _) => data.day,
              //   )
              //   else if (Reports == "Month")
              //       buildBloodPressureChart(
              //         chartData: chartData,
              //         xValueMapper: (BloodPressureData data, _) => data.months,
              //       )
              //     else if (Reports == "Year")
              //         buildBloodPressureChart(
              //           chartData: chartData,
              //           xValueMapper: (BloodPressureData data, _) => data.Year,
              //         ),
            ]
            )
        )
    );
  }





  Widget buildBloodOxygenChart({
    required String title,
    required BuildContext context,
    required List<BloodOxygenData> chartData,
    required int targetspo2noraml,
    required int targetspo2high,
  }) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.40,
      child: SfCartesianChart(
        title: ChartTitle(text: title),
        margin: const EdgeInsets.only(left: 10, right: 20),
        plotAreaBorderWidth: 0.0,
        backgroundColor: Colors.white,
        tooltipBehavior: TooltipBehavior(enable: true),
        primaryXAxis: CategoryAxis(
          title: AxisTitle(text: 'Time of Day'),
          // minimum: 0,
          // maximum: 23,
          // interval: 1,
          axisLine: const AxisLine(width: 0),
          majorGridLines: const MajorGridLines(width: 0),
          majorTickLines: const MajorTickLines(size: 0),
          axisLabelFormatter: (AxisLabelRenderDetails args) {
            return ChartAxisLabel(
              args.text, // args.text will be the time string like "08:05 AM"
              const TextStyle(fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
              ),
            );
          },
          // axisLabelFormatter: (AxisLabelRenderDetails args) {
          //   return ChartAxisLabel(
          //     args.value.toInt().toString(), // show 0 to 23
          //     const TextStyle(fontSize: 7),
          //   );
          // },
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: 'SpO₂ (%)'),
          majorGridLines: const MajorGridLines(width: 0),
          majorTickLines: MajorTickLines(width: 0),
          minimum: 85,
          maximum: 104,
          interval: 5,
          labelStyle: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
          plotBands: <PlotBand>[
            PlotBand(isVisible: true, start: 95, end: 100, color: const Color(
                0xFFD1FCD1)),
            PlotBand(isVisible: true, start: 91, end: 95, color: const Color(
                0xFFFAF0CC)),
            PlotBand(isVisible: true, start: 0, end: 91, color: const Color(
                0xFFF6CCCC)),
            // PlotBand(isVisible: true, start: targetspo2noraml.toDouble(), end: targetspo2noraml.toDouble(), color: const Color(0xFFE6FFE6)),
            // PlotBand(isVisible: true, start: targetspo2high.toDouble(), end: targetspo2high.toDouble(), color: const Color(0xFFFFF4CC)),
            // PlotBand(isVisible: true, start: 0, end: 91, color: const Color(0xFFFFE6E6)),
          ],
        ),

        series: <CartesianSeries>[
          SplineSeries<BloodOxygenData, String>(
            name: 'SpO₂',
            dataSource: chartData,
            xValueMapper: (BloodOxygenData data, _) => data.day,
            yValueMapper: (data, _) => data.spo2,
            color: const Color(0xffFF0000),
            markerSettings: const MarkerSettings(isVisible: true),
          ),
        ],
      ),
    );
  }




  Widget WeeklybuildBloodOxygenChart({
    required String title,
    required BuildContext context,
    required List<BloodOxygenData> chartData,
    required int targetspo2noraml,
    required int targetspo2high,
  }) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.40,
      child: SfCartesianChart(
        title: ChartTitle(text: title),
        //margin: const EdgeInsets.only(left: 10, right: 20),
        plotAreaBorderWidth: 0.0,
        backgroundColor: Colors.white,
        tooltipBehavior: TooltipBehavior(enable: true),
        primaryXAxis: CategoryAxis(
          title: AxisTitle(text: 'Days'),
          majorGridLines: const MajorGridLines(width: 0),
          majorTickLines: MajorTickLines(width: 0),
          labelStyle: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
          // labelRotation: 45, // Better readability for hour labels
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: 'SpO₂ (%)'),
          majorGridLines: const MajorGridLines(width: 0),
          majorTickLines: MajorTickLines(width: 0),
          minimum: 85,
          maximum: 104,
          interval: 5,
          labelStyle: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
          plotBands: <PlotBand>[
            PlotBand(isVisible: true, start: 95, end: 100, color: const Color(0xFFD1FCD1)),
            PlotBand(isVisible: true, start: 91, end: 95, color: const Color(0xFFFAF0CC)),
            PlotBand(isVisible: true, start: 0, end: 91, color: const Color(0xFFF6CCCC)),
            // PlotBand(isVisible: true, start: targetspo2noraml.toDouble(), end: targetspo2noraml.toDouble(), color: const Color(0xFFE6FFE6)),
            // PlotBand(isVisible: true, start: targetspo2high.toDouble(), end: targetspo2high.toDouble(), color: const Color(0xFFFFF4CC)),
            // PlotBand(isVisible: true, start: 0, end: 91, color: const Color(0xFFFFE6E6)),
          ],
        ),
        series: <CartesianSeries>[
          SplineSeries<BloodOxygenData, String>(
            name: 'SpO₂',
            dataSource: chartData,
            xValueMapper: (BloodOxygenData data, _) => data.day,
            yValueMapper: (data, _) => data.spo2,
            color: const Color(0xffFF0000),
            markerSettings: const MarkerSettings(isVisible: true),
            // For better tooltips:
            dataLabelSettings: DataLabelSettings(
              isVisible: false,
              labelAlignment: ChartDataLabelAlignment.auto,
            ),
          ),
        ],
      ),
    );
  }

  Widget MonthlybuildBloodOxygenChart({
    required String title,
    required BuildContext context,
    required List<BloodOxygenData> chartData,
    required int targetspo2noraml,
    required int targetspo2high,
  }) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.40,
      child: SfCartesianChart(
        title: ChartTitle(text: title),
        margin: const EdgeInsets.only(left: 10, right: 20),
        plotAreaBorderWidth: 0.0,
        backgroundColor: Colors.white,
        tooltipBehavior: TooltipBehavior(enable: true),
        primaryXAxis: CategoryAxis(
          title: AxisTitle(text: 'Weeks'),
          majorGridLines: const MajorGridLines(width: 0),
          majorTickLines: MajorTickLines(width: 0),
          labelStyle: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
          // labelRotation: 45, // Better readability for hour labels
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: 'SpO₂ (%)'),
          majorGridLines: const MajorGridLines(width: 0),
          majorTickLines: MajorTickLines(width: 0),
          minimum: 85,
          maximum: 104,
          interval: 5,
          labelStyle: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
          plotBands: <PlotBand>[
            PlotBand(isVisible: true, start: 95, end: 100, color: const Color(0xFFD1FCD1)),
            PlotBand(isVisible: true, start: 91, end: 95, color: const Color(0xFFFAF0CC)),
            PlotBand(isVisible: true, start: 0, end: 91, color: const Color(0xFFF6CCCC)),
            // PlotBand(isVisible: true, start: targetspo2noraml.toDouble(), end: targetspo2noraml.toDouble(), color: const Color(0xFFE6FFE6)),
            // PlotBand(isVisible: true, start: targetspo2high.toDouble(), end: targetspo2high.toDouble(), color: const Color(0xFFFFF4CC)),
            // PlotBand(isVisible: true, start: 0, end: 91, color: const Color(0xFFFFE6E6)),
          ],
        ),
        series: <CartesianSeries>[
          SplineSeries<BloodOxygenData, String>(
            name: 'SpO₂',
            dataSource: chartData,
            xValueMapper: (BloodOxygenData data, _) => data.months,
            yValueMapper: (data, _) => data.spo2,
            color: const Color(0xffFF0000),
            markerSettings: const MarkerSettings(isVisible: true),
            // For better tooltips:
            dataLabelSettings: DataLabelSettings(
              isVisible: false,
              labelAlignment: ChartDataLabelAlignment.auto,
            ),
          ),
        ],
      ),
    );
  }

  Widget YearlybuildBloodOxygenChart({
    required String title,
    required BuildContext context,
    required List<BloodOxygenData> chartData,
    required int targetspo2noraml,
    required int targetspo2high,
  }) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.40,
      child: SfCartesianChart(
        title: ChartTitle(text: title),
        // margin: const EdgeInsets.only(left: 10, right: 20),
        plotAreaBorderWidth: 0.0,
        backgroundColor: Colors.white,
        tooltipBehavior: TooltipBehavior(enable: true),
        primaryXAxis: CategoryAxis(
          title: AxisTitle(text: 'Months'),
          majorGridLines: const MajorGridLines(width: 0),
          majorTickLines: MajorTickLines(width: 0),
          labelStyle: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
          // labelRotation: 45, // Better readability for hour labels
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: 'SpO₂ (%)'),
          majorGridLines: const MajorGridLines(width: 0),
          majorTickLines: MajorTickLines(width: 0),
          minimum: 85,
          maximum: 104,
          interval: 5,
          labelStyle: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
          plotBands: <PlotBand>[
            PlotBand(isVisible: true, start: 95, end: 100, color: const Color(0xFFD1FCD1)),
            PlotBand(isVisible: true, start: 91, end: 95, color: const Color(0xFFFAF0CC)),
            PlotBand(isVisible: true, start: 0, end: 91, color: const Color(0xFFF6CCCC)),
            // PlotBand(isVisible: true, start: targetspo2noraml.toDouble(), end: targetspo2noraml.toDouble(), color: const Color(0xFFE6FFE6)),
            // PlotBand(isVisible: true, start: targetspo2high.toDouble(), end: targetspo2high.toDouble(), color: const Color(0xFFFFF4CC)),
            // PlotBand(isVisible: true, start: 0, end: 91, color: const Color(0xFFFFE6E6)),
          ],
        ),
        series: <CartesianSeries>[
          SplineSeries<BloodOxygenData, String>(
            name: 'SpO₂',
            dataSource: chartData,
            xValueMapper: (BloodOxygenData data, _) => data.months,
            yValueMapper: (BloodOxygenData data, _) =>
            data.spo2 == 0 ? null : data.spo2,
            color: const Color(0xffFF0000),
            emptyPointSettings: EmptyPointSettings(
              mode: EmptyPointMode.gap, // 👈 avoid connecting 96 to 0
              color: const Color(0xffFF0000),
            ),
            markerSettings: const MarkerSettings(isVisible: true),
            // For better tooltips:
            dataLabelSettings: DataLabelSettings(
              isVisible: false,
              labelAlignment: ChartDataLabelAlignment.auto,
            ),
          ),
        ],
      ),
    );
  }

  Widget MultiYearlybuildBloodOxygenChart({
    required String title,
    required BuildContext context,
    required List<BloodOxygenData> chartData,
    required int targetspo2noraml,
    required int targetspo2high,
  }) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.40,
      child: SfCartesianChart(
        title: ChartTitle(text: title),
        // margin: const EdgeInsets.only(left: 10, right: 20),
        plotAreaBorderWidth: 0.0,
        backgroundColor: Colors.white,
        tooltipBehavior: TooltipBehavior(enable: true),
        primaryXAxis: CategoryAxis(
          title: AxisTitle(text: 'Years'),
          majorGridLines: const MajorGridLines(width: 0),
          majorTickLines: MajorTickLines(width: 0),
          labelStyle: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
          // labelRotation: 45, // Better readability for hour labels
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: 'SpO₂ (%)'),
          majorGridLines: const MajorGridLines(width: 0),
          majorTickLines: MajorTickLines(width: 0),
          minimum: 85,
          maximum: 104,
          interval: 5,
          labelStyle: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
          plotBands: <PlotBand>[
            PlotBand(isVisible: true, start: 95, end: 100, color: const Color(0xFFD1FCD1)),
            PlotBand(isVisible: true, start: 91, end: 95, color: const Color(0xFFFAF0CC)),
            PlotBand(isVisible: true, start: 0, end: 91, color: const Color(0xFFF6CCCC)),
            // PlotBand(isVisible: true, start: targetspo2noraml.toDouble(), end: targetspo2noraml.toDouble(), color: const Color(0xFFE6FFE6)),
            // PlotBand(isVisible: true, start: targetspo2high.toDouble(), end: targetspo2high.toDouble(), color: const Color(0xFFFFF4CC)),
            // PlotBand(isVisible: true, start: 0, end: 91, color: const Color(0xFFFFE6E6)),
          ],
        ),
        series: <CartesianSeries>[
          SplineSeries<BloodOxygenData, String>(
            name: 'SpO₂',
            dataSource: chartData,
            xValueMapper: (BloodOxygenData data, _) => data.Year,
            yValueMapper: (BloodOxygenData data, _) =>
            data.spo2 == 0 ? null : data.spo2,
            color: const Color(0xffFF0000),
            emptyPointSettings: EmptyPointSettings(
              mode: EmptyPointMode.gap, // 👈 avoid connecting 96 to 0
              color: const Color(0xffFF0000),
            ),
            markerSettings: const MarkerSettings(isVisible: true),
            // For better tooltips:
            dataLabelSettings: DataLabelSettings(
              isVisible: false,
              labelAlignment: ChartDataLabelAlignment.auto,
            ),
          ),
        ],
      ),
    );
  }


}








