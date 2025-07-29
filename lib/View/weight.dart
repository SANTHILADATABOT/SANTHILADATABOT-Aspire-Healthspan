
import 'package:azpire_new/Controller/weight_controller.dart';
import 'package:azpire_new/Model/weight_model.dart';
import 'package:azpire_new/View/add_weight.dart';
import 'package:azpire_new/utils/appimages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../utils/apptext.dart';
import '../utils/apptextstyle.dart';




class WeightChart extends StatefulWidget {
  @override
  State<WeightChart> createState() => _WeightChartState();
}

class _WeightChartState extends State<WeightChart> with SingleTickerProviderStateMixin {

  List<WeightChartData> chartData = [];
  String Reports = 'Week';
  String currentTitle = 'Daily Weight Average';
  bool selectColor = false;
  bool isLoading = false;
  bool is_weight = false;
  String? mainDate; // Variable to store the fetched date
  DateTime? selectedDate;
  double? weightrate; // Variable to store the systolic value
  var bmi1;

  //animation controller
  late Animation<double> _opacityAnimation;
  late AnimationController _controller;

  //final WeightChartController controller = WeightChartController();
  final WeightController weightcontroller = Get.put(WeightController());
  List<WeightChartData> weekChart = [];
  List<WeightChartData> monthChart = [];
  List<WeightChartData> yearChart = [];
  int? fromYear;
  int? toYear;
  int? fromMonth;
  int? toMonth;
  String yearPickerLabel = "Pick Years";
  String? Upto;
  int? target_weight, target_bmi;
  String? username;

  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("name"); // or "username"
    });
  }


  void simulateLoading(Function chartFunction) async {
    setState(() {
      //chartData = [];
      isLoading = true; // Set loading state
    });
    await Future.delayed(Duration(seconds: 2)); // Simulate a delay
    chartFunction();
    loadUsername();
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUsername();
    Week_Chart();
    mainDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    selectedDate = DateTime.now(); // To show today's date initially
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Speed of blinking
    )
      ..repeat(reverse: true); // Repeats the animation in reverse

    // Define the opacity animation from fully opaque to fully opaque
    _opacityAnimation = Tween<double>(
      begin: 1.0, // Fully visible
      end: 0.7, // Semi-transparent
    ).animate(_controller);
    // mainDate = DateFormat('dd-MMMM-yyyy').format(DateTime.now());
    // selectedDate = DateTime.now(); // To show today's date initially
  }

  void _toggletextinfo() {
    setState(() {
      is_weight = !is_weight;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> Week_Chart() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await weightcontroller.Week_Chart(
          '102',
          DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now())
      );

      final List<WeightChartData> data = result['chartData'];
      final String mainDateString = result['mainDate'];
      final double weekWeight = double.tryParse(result['weight'].toString()) ??
          0.0;
      final String bmi = result['bmi'].toString();

      String formattedDate = '';
      try {
        DateTime parsedMainDateTime = DateTime.parse(mainDateString);
        formattedDate = DateFormat('MMM dd, yyyy').format(parsedMainDateTime);
      } catch (e) {
        print('Error parsing main date: $e');
        formattedDate = mainDateString;
      }

      setState(() {
        chartData = data;
        mainDate = formattedDate;
        weightrate = weekWeight;
        bmi1 = bmi;
        target_weight = result['weight_target'];
        target_bmi = result['bmi_target'];
      });
    } catch (e) {
      print('Error fetching weight chart: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> Month_Chart() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await weightcontroller.Month_Chart(
          '102',
          DateFormat('yyyy-MM').format(selectedDate ?? DateTime.now())
      );

      final List<WeightChartData> data = result['chartData'];
      final String mainDateString = result['mainDate'];
      final double weekWeight = double.tryParse(result['weight'].toString()) ??
          0.0;
      final String bmi = result['bmi'].toString();

      String formattedDate = '';
      try {
        DateTime parsedMainDateTime = DateTime.parse(mainDateString);
        formattedDate = DateFormat('MMM dd, yyyy').format(parsedMainDateTime);
      } catch (e) {
        print('Error parsing main date: $e');
        formattedDate = mainDateString;
      }

      setState(() {
        chartData = data;
        mainDate = formattedDate;
        weightrate = weekWeight;
        bmi1 = bmi;
        target_weight = result['weight_target'];
        target_bmi = result['bmi_target'];
      });
    } catch (e) {
      print('Error fetching weight Month chart: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> Year_Chart() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await weightcontroller.Year_Chart(
        '102',
        DateFormat('yyyy-MM').format(selectedDate ?? DateTime.now()),
      );

      final List<WeightChartData> data = result['chartData'];
      final String mainDateString = result['mainDate'];
      final double yearWeight = double.tryParse(result['weight'].toString()) ??
          0.0;
      final String bmi = result['bmi'].toString();


      String formattedDate = '';
      try {
        DateTime parsedMainDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(mainDateString);

        formattedDate = DateFormat('MMM dd, yyyy').format(parsedMainDateTime);
      } catch (e) {
        print('Error parsing main date: $e');
        formattedDate = mainDateString;
      }


      setState(() {
        chartData = data;
        mainDate = formattedDate;
        weightrate = yearWeight;
        bmi1 = bmi;
        target_weight = result['weight_target'];
        target_bmi = result['bmi_target'];
      });
    } catch (e) {
      print('Error fetching weight chart: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> MultiYear_Chart() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await weightcontroller.MultiYear_Chart(
        '102',
        toYear!,  // Only pass toYear
      );

      final List<WeightChartData> data = result['chartData'];
      final String mainDateString = result['mainDate'];
      final double yearWeight = double.tryParse(result['weight'].toString()) ??
          0.0;
      final String bmi = result['bmi'].toString();


      String formattedDate = '';
      try {
        DateTime parsedMainDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(mainDateString);
        formattedDate = DateFormat('MMM dd, yyyy').format(parsedMainDateTime);
      } catch (e) {
        print('Error parsing main date: $e');
        formattedDate = mainDateString;
      }



      setState(() {
        chartData = data;
        mainDate = formattedDate;
        weightrate = yearWeight;
        bmi1 = bmi;
        target_weight = result['weight_target'];
        target_bmi = result['bmi_target'];
      });
    } catch (e) {
      print('Error fetching weight chart: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
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
                child: Text(
                  username != null
                      ? "${makePossessive(username)} Weight" : "",
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
          physics: ScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: double.infinity,
                  // height: 50,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Centered Week / Month / Year
                      Container(
                        width: double.infinity,
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
                                        // InkWell(
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
                                              'Weekly Weight Average';
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
                                              'Monthly Weight Average';
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
                                              'Yearly Weight Average';
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
                                              currentTitle =
                                              'Multi-Year Weight Average';
                                              Reports = 'Multi-Year';

                                              // 👉 INITIALIZE DEFAULT YEAR PICKER LABEL
                                              final now = DateTime.now();
                                              // fromYear = now.year;
                                              toYear = now.year;

                                              yearPickerLabel =
                                              "${DateFormat('yyyy').format(
                                                  DateTime(toYear!))}";
                                            });

                                            simulateLoading(MultiYear_Chart);
                                          },
                                        ),

                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          if (Reports == 'Multi-Year') {
                                            var toDatePicked = await DatePicker
                                                .showSimpleDatePicker(
                                                context,
                                                initialDate: Upto != null
                                                    ? DateTime(int.parse(Upto!))
                                                    : DateTime.now(),
                                                firstDate: DateTime(1960),
                                                lastDate: DateTime.now(),
                                                dateFormat: "yyyy",
                                                locale: DateTimePickerLocale
                                                    .en_us,
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
                                            String dateFormatString = (Reports ==
                                                'Week')
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
                                                  Reports = 'Week';
                                                  currentTitle =
                                                  'Weekly Weight Average';
                                                  mainDate =
                                                      DateFormat('MMMM dd, yyyy')
                                                          .format(datePicked);
                                                  simulateLoading(Week_Chart);
                                                } else if (Reports == 'Year') {
                                                  Reports = 'Month';
                                                  currentTitle =
                                                  'Monthly Weight Average';
                                                  mainDate =
                                                      DateFormat('MMMM-yyyy')
                                                          .format(datePicked);
                                                  simulateLoading(Month_Chart);
                                                } else {
                                                  switch (Reports) {
                                                  // case 'Day':
                                                  //   currentTitle = 'Daily Blood Pressure Average';
                                                  //   mainDate = DateFormat('MMMM dd, yyyy').format(datePicked);
                                                  //   simulateLoading(Day_Chart);
                                                  //   break;
                                                    case 'Month':
                                                      currentTitle =
                                                      'Monthly Weight Average';
                                                      mainDate =
                                                          DateFormat('MMMM-yyyy')
                                                              .format(datePicked);
                                                      simulateLoading(
                                                          Month_Chart);
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
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8)),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                Reports == 'Multi-Year'
                                                    ? yearPickerLabel
                                                    : selectedDate != null
                                                    ? ((Reports == 'Week')
                                                    ? DateFormat('MMMM dd, yyyy')
                                                    .format(selectedDate!)
                                                    : DateFormat('MMMM-yyyy')
                                                    .format(selectedDate!))
                                                    : "",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(Icons.arrow_drop_down,
                                                  color: Colors.white),
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
                      const SizedBox(height: 30),
                      // Space between filter and date picker
                      // DATE PICKER BELOW THE FILTER ROW
                      // // (+) Add and Date Picker aligned right
                      Positioned(
                        right: 0,
                        top: 30,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: InkWell(
                            onTap: () {
                              Get.to(() => AddWeight());
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xff275176),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(8)),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25,),
              if (isLoading)
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: double.infinity,
                    height: 400,
                    color: Colors.white,
                  ),
                )
              // else if (Reports == "Week")
              //   Column(
              //     children: [
              //       _buildChart(
              //         title: AppText.weight_lbs,
              //         seriesName: "Weight(lbs)",
              //         dataSource: chartData,
              //         xMapper: (data, _) => data.day,
              //         yMapper: (data, _) => data.weightrate.toDouble(),
              //         color: Color(0xffF5B849),
              //       ),
              //
              //       _buildChart(
              //         title: AppText.bmiu,
              //         seriesName: "BMI(lbs/m\u00b2)",
              //         dataSource: chartData,
              //         xMapper: (data, _) => data.day,
              //         yMapper: (data, _) => data.bmidata.toDouble(),
              //         color: Color(0xff1AB9EA),
              //         maxY: 35,
              //         minY: 15,
              //         interval: 0.5,
              //       ),
              //     ],
              //   )
              else
                if (Reports == "Week")
                  Column(
                    children: [
                      _buildChart(
                        title: 'Avg Daily Weight',
                        seriesName: "Weight(lbs)",
                        dataSource: chartData,
                        xMapper: (data, _) => data.day,
                        yMapper: (data, _) => data.weightrate.toDouble(),
                        color: Color(0xffF5B849),
                        // Optional: keep weight chart fixed or dynamic
                        maxY: 240,
                        minY: 30,
                        interval: 10,
                        xaxistitle: 'Days',
                        yaxistitle: AppText.weight_lbs, ismonth: false,
                          targetweight: target_weight ?? 215,
                          targetBmi: 0,
                      ),
                      _buildChart(
                          ismonth: false,
                        title: 'Avg Daily BMI',
                        seriesName: "BMI(lbs/m\u00b2)",
                        dataSource: chartData,
                        xMapper: (data, _) => data.day,
                        yMapper: (data, _) => data.bmidata.toDouble(),
                        color: Color(0xff1AB9EA),
                          maxY: 70,
                        minY: 10,
                        interval: 10,
                          xaxistitle: 'Days',
                          yaxistitle:  AppText.bmiu,
                        targetBmi: target_bmi ?? 30,
                        targetweight: 0
                        // Let _buildChart auto-calculate BMI min/max/interval
                      ),
                    ],
                  )
                else
                  if (Reports == "Month")
                    Column(
                      children: [
                        _buildChart(
                            ismonth: false,
                          title:  'Avg Weekly Weight',
                          seriesName: "Weight(lbs)",
                          dataSource: chartData,
                          xMapper: (data, _) => data.months,
                          yMapper: (data, _) => data.weightrate,
                            maxY: 240,
                            minY: 30,
                            interval: 30,
                            color: Color(0xffF5B849),
                            xaxistitle: 'Weeks',
                            yaxistitle: AppText.weight_lbs,
                          targetweight: target_weight ?? 215,
                          targetBmi: 0,
                        ),
                        _buildChart(
                            ismonth: false,
                          title: 'Avg Weekly BMI',
                          seriesName: "BMI(lbs/m\u00b2)",
                          dataSource: chartData,
                          xMapper: (data, _) => data.months,
                          yMapper: (data, _) => data.bmidata,
                          color: Color(0xff1AB9EA),
                            maxY: 70,
                            minY: 10,
                            interval: 10,
                            xaxistitle: 'Weeks',
                            yaxistitle:  AppText.bmiu,
                            targetBmi: target_bmi ?? 30,
                            targetweight: 0
                        ),
                      ],
                    )
                  else if (Reports == "Year")
                      Column(
                        children: [
                          _buildChart(
                              ismonth: true,
                            title: 'Avg Monthly Weight',
                            seriesName: "Weight(lbs)",
                            dataSource: chartData,
                             // xMapper: (data, _) => getMonthAbbreviation(data.months),
                            xMapper: (data, _) => data.months,
                              yMapper: (data, _) => data.weightrate == 0 ? null : data.weightrate,
                            color: Color(0xffF5B849),
                              maxY: 240,
                            minY: 30,
                              interval: 30,
                              xaxistitle: 'Months',
                              yaxistitle: AppText.weight_lbs,
                            targetweight: target_weight ?? 215,
                            targetBmi: 0,
                          ),
                          _buildChart(
                              ismonth: true,
                            title: 'Avg Monthly BMI',
                            seriesName: "BMI(lbs/m\u00b2)",
                            dataSource: chartData,
                              //xMapper: (data, _) => getMonthAbbreviation(data.months),
                            xMapper: (data, _) => data.months,
                            yMapper: (data, _) => data.bmidata == 0 ? null: data.bmidata,
                            color: Color(0xff1AB9EA),
                              maxY: 70,
                            minY: 10,
                            interval: 10,
                              xaxistitle: 'Months',
                              yaxistitle:  AppText.bmiu,
                              targetBmi: target_bmi ?? 30,
                              targetweight: 0
                            // Let _buildChart auto-calculate BMI min/max/interval
                          ),
                        ],
                      )
                  else if (Reports == "Multi-Year")
                      Column(
                        children: [
                          _buildChart(
                              ismonth: false,
                            title: 'Avg Yearly Weight',
                            seriesName: "Weight(lbs)",
                            dataSource: chartData,
                            xMapper: (data, _) => data.Years,
                            yMapper: (data, _) => data.weightrate.toDouble(),
                            color: Color(0xffF5B849),
                              maxY: 240,
                            minY: 30,
                              interval: 30,
                              xaxistitle: 'Years',
                              yaxistitle: AppText.weight_lbs,
                            targetweight: target_weight ?? 215,
                            targetBmi: 0,
                          ),
                          _buildChart(
                              ismonth: false,
                            title: 'Avg Yearly BMI',
                            seriesName: "BMI(lbs/m\u00b2)",
                            dataSource: chartData,
                            xMapper: (data, _) => data.Years,
                            yMapper: (data, _) => data.bmidata.toDouble(),
                            color: Color(0xff1AB9EA),
                              maxY: 70,
                            minY: 10,
                            interval: 10,
                              xaxistitle: 'Years',
                              yaxistitle:  AppText.bmiu,
                              targetBmi: target_bmi ?? 30,
                              targetweight: 0
                            // Let _buildChart auto-calculate BMI min/max/interval
                          ),
                        ],
                      ),
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Colors.grey.shade500,
                      width: 1.0,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.center, // centers the whole column
                    child: Container(
                      width: size.width * 0.75, // match graph's starting point (adjust if needed)
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                width: size.width * 0.1,
                                height: 10,
                                color: Color(0xffF5B849),
                              ),
                              SizedBox(width: 5),
                              Text(
                                AppText.WEIGHT,
                                style: Apptextstyle.s11wbcB,
                              ),
                              SizedBox(width: size.width * 0.1),
                              Container(
                                width: size.width * 0.1,
                                height: 10,
                                color: Color(0xff1AB9EA),
                              ),
                              SizedBox(width: 5),
                              Text(
                                AppText.bmi_1,
                                style: Apptextstyle.s11wbcB,
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                width: size.width * 0.1,
                                height: 10,
                                color: Colors.green,
                              ),
                              SizedBox(width: 5),
                              Text(
                                AppText.target,
                                style: Apptextstyle.s11wbcB,
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),

                ),
              ),
              SizedBox(height: 30,),
              weightrate == null ?
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
                          color: Colors.white, // Card background color
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                        AppText.mostrecent,
                                        style: Apptextstyle.s13wbcB
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          8, 0, 8, 0),
                                      child: Text(
                                          mainDate ?? ' ',
                                          // Default value if no data is available
                                          style: Apptextstyle.s14wbcB
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            // Systolic Row
                            // Row(
                            //   crossAxisAlignment: CrossAxisAlignment.center,
                            //   mainAxisAlignment: MainAxisAlignment.end,
                            //   children: [
                            //     Column(
                            //       children: [
                            //         Text(
                            //             AppText.weight_lbs,
                            //             style: Apptextstyle.s12wncB
                            //         ),
                            //         SizedBox(height: 10,),
                            //         Container(
                            //           padding: EdgeInsets.symmetric(
                            //               horizontal: 8),
                            //           decoration: BoxDecoration(
                            //             border: Border.all(
                            //               color: Color(0xffF5B849),
                            //               // Border color for Systolic
                            //               width: 1.0,
                            //             ),
                            //             borderRadius: BorderRadius.circular(
                            //                 5), // Optional: Rounded corners
                            //           ),
                            //           child:
                            //
                            //           Text(
                            //               '$weightrate lbs',
                            //               style: Apptextstyle.s13wbcY
                            //           ),
                            //
                            //         ),
                            //
                            //       ],
                            //     ),
                            //     SizedBox(width: 30),
                            //     Column(
                            //       children: [
                            //         Text(
                            //           AppText.bmi_1,
                            //           style: Apptextstyle.s12wncB,
                            //         ),
                            //         SizedBox(height: 10,),
                            //         Container(
                            //           padding: EdgeInsets.symmetric(
                            //               horizontal: 8),
                            //           decoration: BoxDecoration(
                            //             border: Border.all(
                            //               color: Color(0xff1AB9EA),
                            //               // Border color for Systolic
                            //               width: 1.0,
                            //             ),
                            //             borderRadius: BorderRadius.circular(
                            //                 5), // Optional: Rounded corners
                            //           ),
                            //           child: Text(
                            //               bmi1 != null ? '$bmi1 lbs' : ' ',
                            //               style: Apptextstyle.s13wbcBl
                            //           ),
                            //         ),
                            //
                            //       ],
                            //     ),
                            //     Padding(
                            //       padding: const EdgeInsets.only(left: 15),
                            //       child:
                            //       Column(
                            //         mainAxisAlignment: MainAxisAlignment.center,
                            //         children: [
                            //           InkWell(
                            //             onTap: () => _toggletextinfo(),
                            //             // Toggle text on icon click
                            //             child: Icon(
                            //               Icons.info_outline_rounded,
                            //               color: is_weight
                            //                   ? Color(0xff1AB9EA)
                            //                   : Color(0xFF997f7f),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //
                            //     ),
                            //   ],
                            // ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // left side: Weight
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppText.weight_lbs,
                                        style: Apptextstyle.s12wncB,
                                      ),
                                      SizedBox(height: 10),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Color(0xffF5B849), width: 1.0),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          '$weightrate lbs',
                                          style: Apptextstyle.s13wbcY,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // right side: BMI + info icon
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppText.bmi_1,
                                          style: Apptextstyle.s12wncB,
                                        ),
                                        SizedBox(height: 10),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Color(0xff1AB9EA), width: 1.0),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            bmi1 != null ? '$bmi1 lbs/in\u00b2' : ' ',
                                            style: Apptextstyle.s13wbcBl,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 5),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: InkWell(
                                        onTap: _toggletextinfo,
                                        child: Icon(
                                          Icons.info_outline_rounded,
                                          color: is_weight
                                              ? Color(0xff1AB9EA)
                                              : Color(0xFF997f7f),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                              ],
                            ),
                            SizedBox(height: 5,),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Target Daily Weight is $target_weight',
                                          style: Apptextstyle.s12wbcG
                                      ),
                                      SizedBox(height: 5,),
                                      Text('Target Daily BMI is $target_bmi',
                                          style: Apptextstyle.s12wbcG
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            AnimatedSize(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: AnimatedOpacity(
                                opacity: is_weight ? 1.0 : 0.0,
                                duration: Duration(milliseconds: 300),
                                child: is_weight
                                    ? Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    AppText.weight_info,
                                    style: Apptextstyle.s12wncb,
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
                                    color: Color(0xffF5B849),
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
                                    image: AssetImage(Appimages.Weight_logo),
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
                padding: EdgeInsets.only(left: 20, right: 10, bottom: 10),
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
                          padding: const EdgeInsets.fromLTRB(10, 8, 0, 0),
                          child: Row(
                            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  Reports,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF275176)),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  AppText.bmi_1,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF275176)),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  AppText.weight_lbs,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF275176)),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5),
                        SizedBox(height: 10),
                        Container(
                          color: Colors.white,
                          // height: 250,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            //physics: BouncingScrollPhysics(),
                            itemCount: chartData.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(10, 8, 0, 0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment
                                          .center,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            Reports == 'Month'
                                                ? chartData[index].months:
                                                 Reports == 'Year'
                                                     ? chartData[index].months
                                                // ? DateFormat("MMM").format(
                                                // chartData[index].date)
                                                : Reports == 'Multi-Year'
                                                     ? chartData[index].Years
                                                : Reports == 'Week'
                                                ? DateFormat('EEE').format(
                                                chartData[index]
                                                    .date) // 🟢 Fix here
                                                : chartData[index].day,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),

                                        // Expanded(
                                        //   child: Text(
                                        //     Reports == 'Month'
                                        //         ? chartData[index].months
                                        //         : Reports == 'Year'
                                        //         ? DateFormat("MMM").format(
                                        //         chartData[index].date)
                                        //         : Reports == 'Multi-Year'
                                        //         ? DateFormat("yyyy").format(
                                        //         chartData[index].date)
                                        //     // Format for month
                                        //         :Reports == 'Week' ? DateFormat(
                                        //         'MMM dd, yyyy HH:mm')
                                        //         .format(chartData[index]
                                        //         .date) :
                                        //     chartData[index].day,
                                        //     // Format for other reports
                                        //     overflow: TextOverflow.ellipsis,
                                        //     style: TextStyle(
                                        //         fontSize: 12
                                        //     ),
                                        //   ),
                                        // ),
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              '${chartData[index].bmidata}',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 12
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              '${chartData[index].weightrate}',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
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

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart({
    required String title,
    required bool ismonth,
    required String seriesName,
    required String xaxistitle,
    required String yaxistitle,
    required List<WeightChartData> dataSource,
    required String Function(WeightChartData, int) xMapper,
    required double? Function(WeightChartData, int) yMapper,
    required Color color,
    required int targetweight,
    required int targetBmi,
    double? maxY,
    double? minY,
    double? interval,

  }) {

    final screenSize = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // ✅ Always use portrait height (the larger of height or width)
    final portraitHeight = screenSize.height > screenSize.width
        ? screenSize.height
        : screenSize.width;

    final chartHeight = portraitHeight * 0.25;
    // Automatically calculate Y-axis bounds if not provided
    List<double> yValues = dataSource
        .map((e) => yMapper(e, 0))
        .whereType<double>()
        .toList();

    double computedMin = yValues.isNotEmpty ? yValues.reduce((a, b) =>
    a < b
        ? a
        : b) : 0;
    double computedMax = yValues.isNotEmpty ? yValues.reduce((a, b) =>
    a > b
        ? a
        : b) : 0;

    // Round min and max to nearest whole numbers
    computedMin = computedMin.floorToDouble();
    computedMax = computedMax.ceilToDouble();

    // Add padding to min/max
    double buffer = ((computedMax - computedMin) * 0.1).ceilToDouble();
    computedMin = (computedMin - buffer).clamp(0, double.infinity);
    computedMax = computedMax + buffer;

    // Set interval to 1 for whole number steps unless custom provided
    double computedInterval = interval ?? 1;

    return Container(
      width: double.infinity,
      height: chartHeight,
      child: SfCartesianChart(
        tooltipBehavior: TooltipBehavior(enable: true),
        // title: ChartTitle(
        //   alignment: ChartAlignment.near,
        //   text: title,
        //   textStyle: Apptextstyle.swn14cothers,
        // ),
        title: ChartTitle(text: title),
        plotAreaBorderWidth: 0.0,
        plotAreaBorderColor: Colors.grey.shade100,
        backgroundColor: Colors.white,
        primaryXAxis: ismonth == true ?
        CategoryAxis(
          majorTickLines: MajorTickLines(width: 0),
          majorGridLines: const MajorGridLines(width: 0),
          title: AxisTitle(text: xaxistitle),
          labelStyle: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
          labelIntersectAction: AxisLabelIntersectAction.none, // 👈 Prevents skipping
          maximumLabels: 12,
        // 👈 Show all 12 month labels
        )
            : CategoryAxis(
          majorTickLines: MajorTickLines(width: 0),
          majorGridLines: const MajorGridLines(width: 0),
          title: AxisTitle(text: xaxistitle),
          labelStyle: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
        ),
        primaryYAxis: NumericAxis(
          maximum: maxY ?? computedMax,
          minimum: minY ?? computedMin,
          interval: computedInterval,
          title: AxisTitle(text: yaxistitle),
          labelStyle: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
          numberFormat: NumberFormat('##0'),
          // 👈 removes decimals
          majorGridLines: const MajorGridLines(width: 0),
          minorGridLines: const MinorGridLines(width: 0),
          majorTickLines: MajorTickLines(width: 0),
            plotBands: [
              PlotBand(
                isVisible: true,
                start: targetweight.toDouble(),
                end: targetweight.toDouble(),
                borderWidth: 2,
                borderColor: Colors.green,
                text: '',
                textStyle: TextStyle(color: Colors.green),
                horizontalTextAlignment: TextAnchor.end,

              ),
              PlotBand(
                isVisible: true,
                start: targetBmi.toDouble(),
                end: targetBmi.toDouble(),
                borderWidth: 2,
                borderColor: Colors.green,
                text: '',
                textStyle: TextStyle(color: Colors.green),
                horizontalTextAlignment: TextAnchor.end,

              ),
            ]
        ),
        series: <CartesianSeries>[
          SplineSeries<WeightChartData, String>(
            name: seriesName,
            dataSource: dataSource,
            xValueMapper: xMapper,
            yValueMapper: yMapper,
            color: color,
            markerSettings: MarkerSettings(
                isVisible: true,
                //color: color,
                height: 12,width: 12
            ),
          ),
        ],
      ),
    );
  }




}
