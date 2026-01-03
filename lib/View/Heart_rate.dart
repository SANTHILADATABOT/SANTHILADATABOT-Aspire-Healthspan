
import 'dart:convert';
import 'package:aspire/Controller/Heartrate_controller.dart';
import 'package:aspire/Model/Heartrate_model.dart';
import 'package:aspire/View/profile.dart';
import 'package:aspire/menu/NavMneu.dart';
import 'package:aspire/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../utils/app_color.dart';
import '../utils/appimages.dart';
import '../utils/apptext.dart';
import '../utils/apptextstyle.dart';
import '../widgets/shimmer_effects.dart';
import 'Dashboard_screen.dart';

class HeartRateChart extends StatefulWidget {
  var name;

  var email, profile, noti_count;

  HeartRateChart({Key? key, required this.name, required this.email, required this.profile, required this.noti_count,}) : super(key: key);
  @override
  State<HeartRateChart> createState() => _HeartRateChartState();
}

class _HeartRateChartState extends State<HeartRateChart> with SingleTickerProviderStateMixin {

  List<HeartRateData> chartData = [];
  //List<HeartRateData1> chartData1 = [];
  String Reports = 'Day';
  String currentTitle = 'Daily Heart Rate Average';
  String selectedPeriod = 'Day';
  bool selectColor = false;
  bool isLoading = false;
  bool is_heart_rate = false;
  DateTime? selectedDate;
  String? mainDate; // Variable to store the fetched date
  int? weekhearrtrate; // Variable to store the systolic value
  int? heartrateValue;
  double? sd_low;
  double? sd_high;
  final HeartRatecontroller _Heartratecontroller = Get.put(HeartRatecontroller());
  final _advancedDrawerController = AdvancedDrawerController();
  //animation controller
  late Animation<double> _opacityAnimation;
  late AnimationController _controller;
  int? HeartateValue;
  int? target_HR;
  double? heartrate_sd_high;
  double? heartrate_sd_low;
  int? fromYear;
  int? toYear;
  String yearPickerLabel = "Pick Years";
  String? Upto;
  String? username;
  var name;
  var email;
  var pofileimage;
  var noti_count;

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
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(_controller);


    Day_Chart();  // Now selectedDate has a proper value
    mainDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    selectedDate = DateTime.now(); // To show today's date initially
  }
  void _toggletextinfo() {
    setState(() {
      is_heart_rate = !is_heart_rate;
    });
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String formatDateTime(String input) {
    try {
      input = input.trim().replaceAll('--', '-'); // Clean up if necessary
      DateTime dateTime = DateFormat("yyyy-MM-dd hh:mm a").parse(input);
      return DateFormat("MMM dd, yyyy HH:mm").format(dateTime); // "May 12, 2025 8.58 AM"
    } catch (e) {
      print("Error formatting date: $e");
      return input; // Fallback to raw input if parsing fails
    }
  }
  Future<void> Day_Chart() async {
    setState(() => isLoading = true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    try {
      final result = await _Heartratecontroller.Day_Chart(
        userId: user_id,
        date: DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now()),
      );

      print('✅ Day Chart API result: $result');
      final String? recentRaw = result['recent_datetime'];
      final String formattedDate = recentRaw != null ? formatDateTime(recentRaw) : result['mainDate'];

      setState(() {
        setState(() {
          mainDate = formattedDate;
          heartrateValue = result['targetHeartRate'];
          weekhearrtrate = result['recent_heart_rate'];
          chartData = result['chartData'];
          sd_low = result['sd_low'];
          sd_high = result['sd_high'];
        });

      });
      print("sd_low${sd_low.toString()} sd_high ${sd_high.toString()}");
      print('✅ mainDate: $mainDate');
      print('✅ weekhearrtrate: $weekhearrtrate');
    } catch (e) {
      print('❌ Error fetching Day Chart: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> Week_Chart() async {
    setState(() => isLoading = true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    try {
      final result = await _Heartratecontroller.Week_Chart(
          user_id,
          DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now())
      );

      final String? recentRaw = result['recent_datetime'];
      final String formattedDate = recentRaw != null
          ? formatDateTime(recentRaw)
          : 'No recent data';
      setState(() {
        chartData = result['chartData'];
        HeartateValue = result['weekhr'];
        target_HR = result['target_heart_rate'];
        mainDate = formattedDate;
        heartrate_sd_high = result['heartrate_sd_high'];
        heartrate_sd_low = result['heartrate_sd_low'];
      });
    } catch (e) {
      print('Error loading weekly data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> Month_Chart() async {
    setState(() => isLoading = true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    try {
      final result = await _Heartratecontroller.Month_Chart(
          user_id,
          DateFormat('yyyy-MM').format(selectedDate ?? DateTime.now())
      );

      final String? recentRaw = result['recent_datetime'];
      final String formattedDate = recentRaw != null
          ? formatDateTime(recentRaw)
          : 'No recent data';

      setState(() {
        chartData = result['chartData'];
        HeartateValue = result['weekhr'];
        target_HR = result['target_heart_rate'];
        mainDate = formattedDate;
        heartrate_sd_high = result['heartrate_sd_high'];
        heartrate_sd_low = result['heartrate_sd_low'];
      });
    } catch (e) {
      print('Error loading monthly data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> Year_Chart() async {
    setState(() => isLoading = true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    try {
      final result = await _Heartratecontroller.Year_Chart(
          user_id,
          DateFormat('yyyy-MM').format(selectedDate ?? DateTime.now())
      );

      final String? recentRaw = result['recent_datetime'];
      final String formattedDate = recentRaw != null
          ? formatDateTime(recentRaw)
          : 'No recent data';

      setState(() {
        chartData = result['chartData'];
        HeartateValue = result['weekhr'];
        target_HR = result['target_heart_rate'];
        mainDate = formattedDate;
        heartrate_sd_high = result['heartrate_sd_high'];
        heartrate_sd_low = result['heartrate_sd_low'];
      });
    } catch (e) {
      print('Error loading weekly data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> MultiYear_Chart() async {
    print('✅ chartData length: ${chartData.length}');
    for (var data in chartData) {
      print('📅 Year: ${data.Years}, HR: ${data.heartrate}');
    }
    setState(() {
      isLoading = true;
      //chartData = [];
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    if (toYear == null) {
      print('toYear is null. Cannot call API.');
      return;
    }

    try {
      final result = await _Heartratecontroller.MultiYear_Chart(
        user_id,
        toYear!,  // Only pass toYear
      );

      final String? recentRaw = result['recent_datetime'];
      final String formattedDate = recentRaw != null
          ? formatDateTime(recentRaw)
          : 'No recent data';

      setState(() {
        chartData = result['chartData'];
        HeartateValue = result['weekhr'];
        target_HR = result['target_heart_rate'];
        mainDate = formattedDate;
        heartrate_sd_high = result['heartrate_sd_high'];
        heartrate_sd_low = result['heartrate_sd_low'];
      });
    } catch (e) {
      print('Error loading weekly data: $e');
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
                    } else {
                     // Get.back();
                      Get.offAll(() => DashboardScreen(
                        deviceID: '', // pass params if needed
                      ));
                    }
                  },
                  icon: Icon(Icons.arrow_back_ios),
                ),
                backgroundColor: Color(0xFFffffff),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  physics: ScrollPhysics(),
                  child: Column(
                    children: [
                      Text(
                        AppText.hr_heading,
                        textAlign: TextAlign.center,
                        style: Apptextstyle.s18wbap,
                      ),
                      SizedBox(height: 10,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          width: double.infinity,
                          // height: 50, // give it a fixed height
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: (){
                                          setState(() {
                                            Reports = 'Day';
                                            //selectedPeriod = 'Day';
                                            currentTitle = "Daily Heart Rate Average";
                                          });
                                          simulateLoading(Day_Chart);
                                        },
                                        child: Text(AppText.day,style: Reports == 'Day' ? Apptextstyle.s16wncR: Apptextstyle.s16wncG),
                                      ),
                                      SizedBox(width: 20),
                                      InkWell(
                                        onTap: (){
                                          setState(() {
                                            Reports = 'Week';
                                            // selectedPeriod = 'Week';
                                            currentTitle = "Weekly Heart Rate Average";

                                          });
                                          simulateLoading(Week_Chart);
                                        },
                                        child: Text(AppText.week,style: Reports == 'Week' ? Apptextstyle.s16wncR: Apptextstyle.s16wncG),
                                      ),
                                      SizedBox(width: 20,),
                                      InkWell(
                                        onTap: (){
                                          setState(() {
                                            Reports ='Month';
                                            currentTitle = "Monthly Heart Rate Average";
                                            //selectedPeriod = 'Month';
                                          });
                                          simulateLoading(Month_Chart);
                                        },
                                        child: Text(AppText.month,style: Reports == 'Month' ? Apptextstyle.s16wncR: Apptextstyle.s16wncG),
                                      ),
                                      SizedBox(width: 20,),
                                      InkWell(
                                        onTap: (){
                                          setState(() {
                                            Reports = 'Year';
                                            //selectedPeriod = 'Year';
                                            currentTitle = "Yearly Heart Rate Average";

                                          });
                                          simulateLoading(Year_Chart);
                                        },
                                        child: Text(AppText.year,style: Reports == 'Year' ? Apptextstyle.s16wncR: Apptextstyle.s16wncG),
                                      ),
                                      SizedBox(width: 20,),
                                      InkWell(
                                        onTap: (){
                                          setState(() {
                                            Reports = 'Multi-Year';
                                            //selectedPeriod = 'Year';
                                            currentTitle = "Multi-Year Heart Rate Average";

                                            final now = DateTime.now();
                                            //fromYear = now.year;
                                            toYear = now.year;

                                            yearPickerLabel =
                                            "${DateFormat('yyyy').format(DateTime(toYear!))}";

                                          });
                                          simulateLoading(MultiYear_Chart);
                                        },
                                        child: Text(AppText.multiyear,style: Reports == 'Multi-Year' ? Apptextstyle.s16wncR: Apptextstyle.s16wncG),
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
                                          titleText: 'Select End Year',
                                          looping: false,
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
                                              currentTitle = 'Daily Heart Rate Average';
                                              mainDate =
                                                  DateFormat('MMMM dd, yyyy').format(
                                                      datePicked);
                                              simulateLoading(Day_Chart);
                                            } else if (Reports == 'Year') {
                                              // From Year to Month
                                              Reports = 'Month';
                                              currentTitle = 'Monthly Heart Rate Average';
                                              mainDate = DateFormat('MMMM-yyyy').format(
                                                  datePicked);
                                              simulateLoading(Month_Chart);
                                            } else {
                                              // Stay in current report type
                                              switch (Reports) {
                                                case 'Day':
                                                  currentTitle =
                                                  'Daily Heart Rate Average';
                                                  mainDate =
                                                      DateFormat('MMMM dd, yyyy').format(
                                                          datePicked);
                                                  simulateLoading(Day_Chart);
                                                  break;
                                                case 'Month':
                                                  currentTitle =
                                                  'Monthly Heart Rate Average';
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
                                  ),

                                ],
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
                            height: MediaQuery.of(context).size.height * 0.40,
                            color: Colors.white,
                          ),
                        )
                      else
                        if (Reports == "Day")
                          buildHeartRateChart(
                              context: context,
                              chartData: chartData,
                              xValueMapper: (HeartRateData data, _) => data.day,
                              targetHR: heartrateValue ?? 75,
                              sd_low: sd_low,
                              sd_high: sd_high,
                              title: 'Heart Rate for this Day',
                              Xaxistitle: 'Time of Day',
                              isMonth: false,
                              minY: 40,
                              maxY: 170,
                              interval: 20,
                              isDay: true
                          )
                        else
                          if (Reports == "Week")
                            buildHeartRateChart(
                                context: context,
                                chartData: chartData,
                                xValueMapper: (HeartRateData data, _) => data.day,
                                sd_low: sd_low,
                                sd_high: sd_high,
                                targetHR: target_HR ?? 75,
                                title: 'Avg Daily Heart Rate',
                                Xaxistitle: 'Days',
                                isMonth: false,
                                minY: 40,
                                maxY: 170,
                                interval: 20,
                                isDay: false
                            )

                          else if (Reports == "Month")
                            buildHeartRateChart(
                                context: context,
                                chartData: chartData,
                                xValueMapper: (HeartRateData data, _) => data.months,
                                sd_low: sd_low,
                                sd_high: sd_high,
                                targetHR: target_HR ?? 75,
                                title: 'Avg Weekly Heart Rate',
                                Xaxistitle: 'Weeks',
                                isMonth: false,
                                minY: 40,
                                maxY: 170,
                                interval: 20,
                                isDay: false
                            )
                          else
                            if (Reports == "Year")
                              buildHeartRateChart(
                                  context: context,
                                  chartData: chartData,
                                  xValueMapper: (HeartRateData data, _) => data.months,
                                  sd_low: sd_low,
                                  sd_high: sd_high,
                                  targetHR: target_HR ?? 75,
                                  title: 'Avg Monthly Heart Rate',
                                  Xaxistitle: 'Months',
                                  isMonth: true,
                                  minY: 40,
                                  maxY: 170,
                                  interval: 20,
                                  isDay: false
                              )
                            else
                              if (Reports == "Multi-Year")
                                buildHeartRateChart(
                                    context: context,
                                    chartData: chartData,
                                    targetHR: target_HR?.toInt() ?? 120,
                                    sd_low: sd_low,
                                    sd_high: sd_high,
                                    // targetDiastolic: target_dys?.toInt() ?? 80,
                                    xValueMapper: (data, _) => data.Years, // Or custom format like "08:00"
                                    minY: 40,
                                    maxY: 170,
                                    interval: 20,
                                    Xaxistitle: 'Years',
                                    title: 'Avg Yearly Heart Rate',
                                    isMonth: false,
                                    isDay: false
                                ),
                      // buildHeartRateChart(
                      //   context: context,
                      //   chartData: chartData,
                      //   xValueMapper: (HeartRateData data, _) => data.Years,
                      //   sd_low: sd_low,
                      //   sd_high: sd_high,
                      //   targetHR: target_HR ?? 75,
                      //   title: 'Avg Yearly Heart Rate',
                      //     Xaxistitle: 'Years',
                      //     isweek: false,
                      // ),
                      SizedBox(height: 5,),
                      Align(
                          alignment: Alignment.center,
                          child:
                          Text("Touch the bubble for more details",style: Apptextstyle.s13wbcB,)),
                      SizedBox(height: 30),
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
                          width: double.infinity, // Full width of parent
                          padding: EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center, // Center row contents
                            mainAxisSize: MainAxisSize.max, // Use full width but center contents
                            children: [
                              Container(
                                width:  size.width * 0.1, // Responsive box width
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  border: Border.all(color: Colors.red, width: 1),
                                ),
                              ),
                              SizedBox(width: 6), // spacing
                              Text(
                                AppText.std,
                                style: Apptextstyle.s11wbcB,
                              ),
                              SizedBox(width: 20),
                              Container(
                                width: size.width * 0.1, // Responsive box width
                                height: 10,
                                color: AppColors.target_color,
                              ),
                              SizedBox(width: 6),
                              Text(
                                AppText.target,
                                style: Apptextstyle.s11wbcB,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      weekhearrtrate == null ?
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
                                            AppText.HEART,
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
                                                    color: AppColors.Heartrate_color,
                                                    // Border color for Systolic
                                                    width: 1.0,
                                                  ),
                                                  borderRadius: BorderRadius.circular(
                                                      5), // Optional: Rounded corners
                                                ),
                                                child: Text(
                                                    weekhearrtrate != null
                                                        ? '$weekhearrtrate BPM'
                                                        : ' ',
                                                    style: Apptextstyle.s12wbcR
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
                                                      color: is_heart_rate ? AppColors.Heartrate_color : AppColors.info_changing,
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
                                            AppText.heart_info,
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
                                            color: AppColors.Heartrate_color,
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
                                                Appimages.Hr_logo),
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
                        height: size.height * 0.07,
                        fit: BoxFit.contain,
                      ),) :
                      Padding(
                        padding: EdgeInsets.only(left: 20, right:10, bottom: 10),
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
                                          color: AppColors.othersT, fontWeight: FontWeight.bold),
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
                                              color: AppColors.othersT),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          AppText.hr_bpm,
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
                                                    Reports == 'Month'
                                                        ? chartData[index].months
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
                                                    padding: const EdgeInsets.only(
                                                        right: 20),
                                                    child: Text(
                                                      '${chartData[index].heartrate}',
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
                    ],
                  ),
                ),
              ),
            )
        )
    );
  }

  Widget buildBloodPressureChart({
    required BuildContext context,
    required String title,
    required String Xaxistitle,
    required List<HeartRateData1> chartData,
    required int targetSystolic,
    // required int targetDiastolic,
    required String Function(HeartRateData1, int) xValueMapper,
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

    // final targetDiastolicPoints = [
    //   TargetLinePoint(xStart, targetDiastolic.toDouble()),
    //   TargetLinePoint(xEnd, targetDiastolic.toDouble()),
    // ];


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
          SplineRangeAreaSeries<HeartRateData1, String>(
            // dataSource: chartData.where((d) => d.date.isBefore(DateTime.now().add(Duration(days: 0)))).toList(),
            dataSource: chartData,
            xValueMapper:xValueMapper,
            highValueMapper: (data, _) => sd_high,
            lowValueMapper: (data, _) => sd_low,
            color: Color(0xFFd9d9ff).withOpacity(0.6),
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


          SplineSeries<HeartRateData1, String>(
            name: AppText.SYSTOLIC,
            dataSource: chartData,
            xValueMapper: xValueMapper,
            yValueMapper: (data, _) => data.systolic == 0 ? null : data.systolic,
            color: AppColors.systolic_color,
            markerSettings: MarkerSettings(isVisible: true, height: 12, width: 12),
          ),

        ],

      ),
    );
  }
  Widget buildHeartRateChart({
    required BuildContext context,
    required String title,
    required String Xaxistitle,
    required List<HeartRateData> chartData,
    required String Function(HeartRateData, int) xValueMapper,
    required int targetHR,
    double minY = 40,
    double maxY = 170,
    double interval = 20,
    required bool isMonth,
    required bool isDay,
    required double? sd_low,
    required double? sd_high,
  })
  {
    // Use MediaQuery to get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // Always use portrait height (the larger of height or width)
    final portraitHeight = screenSize.height > screenSize.width
        ? screenSize.height
        : screenSize.width;

    final chartHeight = portraitHeight * 0.4;
    return Container(
      width: double.infinity,
      height: chartHeight,
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
        plotAreaBorderColor: AppColors.greyshaded100,
        backgroundColor: AppColors.White,
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
        ):
        isDay == true ?CategoryAxis(
          title: AxisTitle(text: Xaxistitle),
          labelStyle: TextStyle(fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
          majorTickLines: MajorTickLines(width: 0),
          majorGridLines: MajorGridLines(width: 0),
          labelPlacement: LabelPlacement.onTicks,
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          minimum: 0,
          maximum: 23,
          interval: 2,
          axisLabelFormatter: (AxisLabelRenderDetails args) {
            final value = args.value.toInt();
            return ChartAxisLabel(
              value.toString(),
              TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            );
          },

        ):
        CategoryAxis(
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
          title: AxisTitle(text: AppText.BPM),
          axisLine: const AxisLine(width: 1, color: AppColors.Grey),
          majorGridLines: const MajorGridLines(width: 0),
          minorGridLines: const MinorGridLines(width: 0),
          majorTickLines: MajorTickLines(width: 0),
          labelStyle: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        series: <CartesianSeries>[
          if (sd_low != null && sd_high != null && chartData.length > 1)
            SplineRangeAreaSeries<HeartRateData, String>(
              //dataSource: chartData,
              dataSource: chartData.where((data) => data.heartrate > 0).toList(),
              xValueMapper: xValueMapper,
              highValueMapper: (data, _) => sd_high,
              lowValueMapper: (data, _) => sd_low,
              color: Colors.red.withOpacity(0.2),
              enableTooltip: false,
            ),
          LineSeries<HeartRateData, String>(
            name: '',
            dataSource: chartData,
            xValueMapper: xValueMapper,
            yValueMapper: (_, __) => targetHR.toDouble(),
            color: AppColors.target_color,
            width: 2,
            enableTooltip: false,
            markerSettings: MarkerSettings(
                isVisible: false
            ),
          ),
          SplineSeries<HeartRateData, String>(
            name: AppText.HEART,
            dataSource: chartData,
            xValueMapper: xValueMapper,
            yValueMapper: (data, _) => data.heartrate == 0 ? null :data.heartrate,
            color: AppColors.Heartrate_color,
            markerSettings: MarkerSettings(
              isVisible: true,
              height: 12,
              width: 12,
            ),
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