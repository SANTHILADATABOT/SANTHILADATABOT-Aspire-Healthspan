import 'dart:convert';
import 'package:azpire_new/Controller/sleep_controller.dart';
import 'package:azpire_new/Model/sleep_model.dart';
import 'package:azpire_new/View/profile.dart';
import 'package:azpire_new/menu/NavMneu.dart';
import 'package:azpire_new/root/root.dart';
import 'package:azpire_new/utils/app_color.dart';
import 'package:azpire_new/utils/apptext.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:azpire_new/widgets/Appexithelper.dart';
import 'package:azpire_new/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../utils/appimages.dart';
import '../widgets/shimmer_effects.dart';
import 'package:azpire_new/widgets/disclaimers.dart';
import 'Dashboard_screen.dart';


class SleepChartPage extends StatefulWidget {
  var name;

  var email, profile, noti_count;

  SleepChartPage({Key? key, required this.name, required this.email, required this.profile, required this.noti_count,}) : super(key: key);
  @override
  State<SleepChartPage> createState() => _SleepChartPageState();
}

class _SleepChartPageState extends State<SleepChartPage> with SingleTickerProviderStateMixin {

  List<SleepData> sleepDataList = [];
  List<SleepDataChart>? sleepDataChartList;
  final List<String> daysOfWeek = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
  late Animation<double> _opacityAnimation;
  late AnimationController _controller;
  final _advancedDrawerController = AdvancedDrawerController();
  String Reports = 'Day';
  String currentTitle = 'Daily Sleep Average';
  List<SleepDataChart1> _sleepsData = [];
  bool _isLoading = false;
  bool isLoading = false;
  bool is_steps = false;
  String? mainDate;
  String? deepsleep; // Variable to store the systolic value
  String? lightsleep;
  String? remsleep;
  String? totalsleep;
  String? awake;
  bool _isTextVisibleblue = false;
  bool _isTextVisibleorange = false;
  bool _isTextVisiblered = false;
  bool _isTextVisibleaccent = false;
  DateTime? selectedDate;
  var time;
  List<SleepBarData> _daySleepBars = [];
  List<SleepBarData> _weekSleepBars = [];
  List<SleepBarData> _monthSleepBars = [];
  List<SleepBarData> _yearsleepBars = [];
  List<SleepBarData> _multiYearSleepBars = [];
  String?  totalSleepRaw ;
  double _getHourValue(DateTime dt) => dt.hour + dt.minute / 60.0;
  final SleepController _sleepcontroller = Get.put(SleepController());
  String? deepPercentage;
  String? lightPercentage;
  String? middlePercentage;
  String? totalPercentage;
  double yAxisMax = 0;
  int? fromYear;
  int? toYear;
  String yearPickerLabel = "Pick Years";
  String? Upto;
  String? target_sleep;
  String? day_target_sleep;
  double? targetSleepValue;
  bool target_visible = false;
  late Map<String, Map<String, String>> daySummaries = {};
  late TooltipBehavior _tooltipBehavior;
  String? username;
  var name;
  var email;
  var pofileimage;
  var noti_count;

  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        username = prefs.getString("name"); // or "username"
      });
    }
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

  double parseTargetSleep(String targetSleepString) {
    final regex = RegExp(r'(\d+)\s*h(?:rs?)?\s*(\d+)?\s*m(?:ins?)?', caseSensitive: false);
    final match = regex.firstMatch(targetSleepString);
    if (match != null) {
      final hours = double.tryParse(match.group(1) ?? '0') ?? 0;
      final minutes = double.tryParse(match.group(2) ?? '0') ?? 0;
      return hours + (minutes / 60.0);
    }
    return 0;
  }

  String? _formatPercentage(dynamic value) {
    if (value is String) {
      final stripped = value.replaceAll('%', '');
      final parsed = double.tryParse(stripped);
      return parsed != null ? '${parsed.toStringAsFixed(1)}%' : null;
    } else if (value is num) {
      return '${value.toDouble().toStringAsFixed(1)}%';
    }
    return null;
  }

  void simulateLoading(Future<void> Function() chartFunction) async {
    if (mounted) setState(() {
      isLoading = true;
    });

    // Allow UI to refresh before starting the heavy work
    //await Future.delayed(const Duration(milliseconds: 100));

    try {
      await chartFunction(); // Call the passed chart function
    } catch (e) {
      print('Chart loading error: $e'); // Optional: error logging
    } finally {
      if (mounted) setState(() {
        isLoading = false;
      });

    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUsername();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Speed of blinking
    )..repeat(reverse: true); // Repeats the animation in reverse
    _opacityAnimation = Tween<double>(
      begin: 1.0, // Fully visible
      end: 0.7,   // Semi-transparent
    ).animate(_controller);
    Day_Chart();
    mainDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    selectedDate = DateTime.now(); // To show today's date initially
  }
  Color _getColor(int value) {
    switch (value) {
    //case 1: return Color(0xFFffd000); // Awake
      case 2: return Color(0xFFa4bce7); // Light (bottom)
      case 4: return Color(0xFFef989e); // REM/Middle (middle)
      case 3: return Color(0xFFb5e78c); //
      case 5: return Colors.green;
      default: return Colors.white; // Unknown or filler
    }
  }

  String _getTextBasedOnCondition() {
    if (_isTextVisibleblue) {
      return 'Deep Sleep Level refers to the restorative sleep stage essential for body repair, muscle growth, overall recovery.';
    } else if (_isTextVisibleorange) {
      return 'Light Sleep refers to the sleep stage where the body begins to relax, heart rate slows, and muscle activity decreases.';
    } else if (_isTextVisiblered) {
      return 'Middle Sleep refers to the stage where the body relaxes, heart rate slows, and memory consolidation begins. It bridges light and deep sleep.';
    } else if (_isTextVisibleaccent) {
      return 'Total Sleep refers to the overall duration of time spent sleeping, encompassing all sleep stages.';
    }
    return '';
  }

  @override
  final Map<String, String> daysOfWeekMap = {
    'sunday': 'Su',
    'monday': 'Mo',
    'tuesday': 'Tu',
    'wednesday': 'We',
    'thursday': 'Th',
    'friday': 'Fr',
    'saturday': 'Sa',
  };
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> Day_Chart() async {
    if (mounted) setState(() => _isLoading = true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    try {
      final result = await _sleepcontroller.Day_Chart(
        userId: user_id,
        date: DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now()),
        type: 'daily',
      );

      // final String? recentRaw = result['recent_datetime'];
      // final String formattedDate = recentRaw != null
      //     ? formatDateTime(recentRaw)
      //     : result['mainDate'];

      // setState(() {
      //   _daySleepBars = result['chartData'] ?? [];
      //   _sleepsData = result['summaryData'] ?? [];
      //   mainDate = result['mainDate']?.toString() ?? "";
      //   deepsleep = result['recent_deep']?.toString();
      //   lightsleep = result['recent_light']?.toString();
      //   remsleep = result['recent_rem']?.toString();
      //   deepPercentage = _formatPercentage(result['recent_deep_percent']?.toString() ?? "0");
      //   lightPercentage = _formatPercentage(result['recent_light_percent']?.toString() ?? "0");
      //   middlePercentage = _formatPercentage(result['recent_rem_percent']?.toString() ?? "0");
      //   yAxisMax = double.tryParse(result['y_axis_max']?.toString() ?? "0") ?? 0;
      //   totalsleep = result['recent_total']?.toString();
      //   totalPercentage = result['recent_total_percent']?.toString();
      //   day_target_sleep = result['target_sleep']?.toString();
      //   targetSleepValue = parseTargetSleep(day_target_sleep ?? "0");
      //   target_visible = true;
      // });


      if (mounted) {
        setState(() {
          _daySleepBars = result['chartData'];
          _sleepsData = result['summaryData'];
          mainDate = result['mainDate'];
          deepsleep = result['recent_deep'];
          lightsleep = result['recent_light'];
          remsleep = result['recent_rem'];
          deepPercentage = _formatPercentage(result['recent_deep_percent']);
          lightPercentage = _formatPercentage(result['recent_light_percent']);
          middlePercentage = _formatPercentage(result['recent_rem_percent']);
          yAxisMax = result['y_axis_max'];
          totalsleep = result['recent_total'];
          totalPercentage = result['recent_total_percent'];
          day_target_sleep = result['target_sleep']; // Original String
          targetSleepValue = parseTargetSleep(day_target_sleep!);
          target_visible = true;
        });
      }

      print("✅ Sleep Chart Data Loaded");
    } catch (e) {
      print('❌ Error loading sleep chart: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> Week_Chart() async {
    setState(() => _isLoading = true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    try {
      final result = await _sleepcontroller.Week_Chart(
        userId: user_id,
        date: DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now()),
        type: 'weekly',
      );
      deepsleep = result['recent_deep'];
      lightsleep = result['recent_light'];
      remsleep = result['recent_rem'];
      deepPercentage = _formatPercentage(result['recent_deep_percent']);
      lightPercentage = _formatPercentage(result['recent_light_percent']);
      middlePercentage = _formatPercentage(result['recent_rem_percent']);
      totalsleep = result['recent_total'];
      totalPercentage = result['recent_total_percent'];
      totalsleep = result['daily_avg_sleep'];
      if (mounted) {
        setState(() {
          _weekSleepBars = result['chartData'];
          _sleepsData = result['summaryData'];
          yAxisMax = (result['y_axis_max'] as num).toDouble();
          mainDate = result['mainDate'];
          target_sleep = result['target_sleep'];
          targetSleepValue = parseTargetSleep(target_sleep!);
          // target_sleep = result['target_sleep']?.toString();
          // targetSleepValue = parseTargetSleep(target_sleep ?? "0");
          target_visible = true;
        });
      }

      print("✅ Weekly Sleep Chart Data Loaded");
    } catch (e) {
      print('❌ Error loading weekly sleep chart: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Future<void> Month_Chart() async {
  //   setState(() => _isLoading = true);
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var user_id = prefs.getString('user_id') ?? "";
  //   try {
  //     final result = await _sleepcontroller.Month_Chart(
  //       userId: user_id,
  //       date: DateFormat('yyyy-MM').format(selectedDate ?? DateTime.now()),
  //       type: 'monthly',
  //     );
  //
  //     // final String? recentRaw = result['recent_datetime'];
  //     // final String formattedDate = recentRaw != null
  //     //     ? formatDateTime(recentRaw)
  //     //     : result['mainDate'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
  //
  //     deepPercentage = _formatPercentage(result['recent_deep_percent']);
  //     lightPercentage = _formatPercentage(result['recent_light_percent']);
  //     middlePercentage = _formatPercentage(result['recent_rem_percent']);
  //     totalsleep = result['daily_avg_sleep'];
  //
  //    // totalsleep = result['recent_total'];
  //     totalPercentage = result['recent_total_percent'];
  //
  //     setState(() {
  //       _monthSleepBars = result['chartData'] ?? [];
  //       _sleepsData = result['summaryData'];
  //       mainDate = result['mainDate'];
  //       yAxisMax = (result['y_axis_max'] as num).toDouble();
  //       target_sleep = result['target_sleep'];
  //       targetSleepValue = parseTargetSleep(target_sleep!);
  //       target_visible = true;
  //
  //     });
  //
  //     print("✅ Monthly Sleep Chart Data Loaded");
  //   } catch (e) {
  //     print('❌ Error loading Monthly sleep chart: $e');
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  // Future<void> Month_Chart() async {
  //   setState(() => _isLoading = true);
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var user_id = prefs.getString('user_id') ?? "";
  //
  //   try {
  //     final result = await _sleepcontroller.Month_Chart(
  //       userId: user_id,
  //       date: DateFormat('yyyy-MM').format(selectedDate ?? DateTime.now()),
  //       type: 'monthly',
  //     );
  //
  //     if (result == null) {
  //       print('❌ API returned null');
  //       return;
  //     }
  //
  //     print("📊 Month_Chart response: $result");
  //
  //     // // Safe parsing with null-aware operators
  //     // deepPercentage = _formatPercentage(result['recent_deep_percent'] ?? 0);
  //     // lightPercentage = _formatPercentage(result['recent_light_percent'] ?? 0);
  //     // middlePercentage = _formatPercentage(result['recent_rem_percent'] ?? 0);
  //     // totalsleep = result['daily_avg_sleep'] ?? 0;
  //     // totalPercentage = result['recent_total_percent'] ?? 0;
  //
  //     deepPercentage = _formatPercentage(result['recent_deep_percent']?.toString() ?? "0");
  //     lightPercentage = _formatPercentage(result['recent_light_percent']?.toString() ?? "0");
  //     middlePercentage = _formatPercentage(result['recent_rem_percent']?.toString() ?? "0");
  //     totalsleep = result['daily_avg_sleep']?.toString() ?? "0";
  //     totalPercentage = result['recent_total_percent']?.toString() ?? "0";
  //
  //
  //     setState(() {
  //       _monthSleepBars = result['chartData'] ?? [];
  //       _sleepsData = result['summaryData'] ?? [];
  //       mainDate = result['mainDate'] ?? "";
  //       yAxisMax = (result['y_axis_max'] as num?)?.toDouble() ?? 0;
  //       target_sleep = result['target_sleep'];
  //       targetSleepValue = parseTargetSleep(target_sleep ?? "0");
  //       target_visible = true;
  //     });
  //
  //     print("Monthly Sleep Chart Data Loaded");
  //   } catch (e, stackTrace) {
  //     print('❌ Error loading Monthly sleep chart: $e');
  //     print('🪵 StackTrace: $stackTrace');
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  Future<void> Month_Chart() async {
    setState(() => _isLoading = true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";

    try {
      final result = await _sleepcontroller.Month_Chart(
        userId: user_id,
        date: DateFormat('yyyy-MM').format(selectedDate ?? DateTime.now()),
        type: 'monthly',
      );

      // if (result == null) {
      //   print('❌ API returned null');
      //   return;
      // }
      //
      // print("📊 Month_Chart response: $result");

      // 🛠 Debug type check
      print("🔍 mainDate type: ${result['mainDate']?.runtimeType}");
      print("🔍 target_sleep type: ${result['target_sleep']?.runtimeType}");
      print("🔍 y_axis_max type: ${result['y_axis_max']?.runtimeType}");

      // ✅ Ensure percentages are always strings
      deepPercentage = _formatPercentage(result['recent_deep_percent']?.toString() ?? "0");
      lightPercentage = _formatPercentage(result['recent_light_percent']?.toString() ?? "0");
      middlePercentage = _formatPercentage(result['recent_rem_percent']?.toString() ?? "0");
      totalsleep = result['daily_avg_sleep']?.toString() ?? "0";
      totalPercentage = result['recent_total_percent']?.toString() ?? "0";

      if (mounted) {
        setState(() {
          _monthSleepBars = result['chartData'] ?? [];
          _sleepsData = result['summaryData'] ?? [];
          mainDate = result['mainDate']?.toString() ?? "";
          yAxisMax = double.tryParse(result['y_axis_max']?.toString() ?? "0") ?? 0;
          target_sleep = result['target_sleep']?.toString();
          targetSleepValue = parseTargetSleep(target_sleep ?? "0");
          target_visible = true;
        });
      }

      print("Monthly Sleep Chart Data Loaded");
    } catch (e, stackTrace) {
      print('❌ Error loading Monthly sleep chart: $e');
      print('🪵 StackTrace: $stackTrace');
    } finally {
      setState(() => _isLoading = false);
    }
  }



  Future<void> Year_Chart() async {

    setState(() => _isLoading = true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    try {
      final result = await _sleepcontroller.Year_Chart(
        userId: user_id,
        date: DateFormat('yyyy-MM').format(selectedDate ?? DateTime.now()),
        type: 'yearly',
      );

      // final String? recentRaw = result['recent_datetime'];
      // final String formattedDate = recentRaw != null
      //     ? formatDateTime(recentRaw)
      //     : result['mainDate'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

      deepPercentage = _formatPercentage(result['recent_deep_percent']);
      lightPercentage = _formatPercentage(result['recent_light_percent']);
      middlePercentage = _formatPercentage(result['recent_rem_percent']);
      totalsleep = result['daily_avg_sleep'];




      if (mounted) {
        setState(() {
          _yearsleepBars = result['chartData'] ;
          _sleepsData = result['summaryData'];
          mainDate = result['mainDate'];
          yAxisMax = (result['y_axis_max'] as num).toDouble();
          target_sleep = result['target_sleep']?.toString();
          targetSleepValue = parseTargetSleep(target_sleep!);
          target_visible = true;

        });
      }

      print("✅ yearly Sleep Chart Data Loaded");
    } catch (e) {
      print('❌ Error loading Yearly sleep chart: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> MultiYear_Chart() async {

    setState(() => _isLoading = true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    try {
      final result = await _sleepcontroller.MultiYear_Chart(
        userId: user_id,
        //fromYear: fromYear!,
        toYear: toYear!
      );

      // final String? recentRaw = result['recent_datetime'];
      // final String formattedDate = recentRaw != null
      //     ? formatDateTime(recentRaw)
      //     : result['mainDate'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

      deepPercentage = _formatPercentage(result['recent_deep_percent']);
      lightPercentage = _formatPercentage(result['recent_light_percent']);
      middlePercentage = _formatPercentage(result['recent_rem_percent']);
      totalsleep = result['daily_avg_sleep'];


      setState(() {
        _multiYearSleepBars = result['chartData'] ;
        _sleepsData = result['summaryData'];
        mainDate = result['mainDate'];
        yAxisMax = (result['y_axis_max'] as num).toDouble();
        target_sleep = result['target_sleep'];
        targetSleepValue = parseTargetSleep(target_sleep!);
        target_visible = true;

      });

      print("✅ Multiyear Sleep Chart Data Loaded");
    } catch (e) {
      print('❌ Error loading MultiYear sleep chart: $e');
    } finally {
      setState(() => _isLoading = false);
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
    Size size = MediaQuery.of(context).size;
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
    child:  Scaffold(
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
               Get.back();
                //Get.offAll(() => DashboardScreen(
                //  deviceID: '', // pass params if needed
                //));
              }
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
          backgroundColor: Color(0xFFffffff),
        ),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppText.sleep_heading,
                    textAlign: TextAlign.center,
                    style: Apptextstyle.s18wbap,
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
                          // SizedBox(
                          //   height: 10,
                          // ),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    child: Text(
                                      AppText.day,
                                      style:
                                      Reports == 'Day' ?  Apptextstyle.s16wncR
                                          : Apptextstyle.s16wncG,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        Reports = "Day";
                                        currentTitle = 'Daily Sleep Average';
        
                                      });
                                      simulateLoading(Day_Chart);
                                    },
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  GestureDetector(
                                    child: Text(
                                      AppText.week,
                                      style:  Reports == 'Week' ?  Apptextstyle.s16wncR
                                          : Apptextstyle.s16wncG,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        Reports = "Week";
                                        currentTitle = 'Weekly Sleep Average';
                                      });
                                      simulateLoading(Week_Chart);
                                    },
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  GestureDetector(
                                    child: Text(
                                      AppText.month,
                                      style:Reports == 'Month' ?  Apptextstyle.s16wncR
                                          : Apptextstyle.s16wncG,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        Reports = "Month";
                                        currentTitle = 'Monthly Sleep Average';
                                      });
                                      simulateLoading(Month_Chart);
                                    },
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  GestureDetector(
                                    child: Text(
                                     AppText.year,
                                      style: Reports == 'Year' ?  Apptextstyle.s16wncR
                                          : Apptextstyle.s16wncG,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        Reports = "Year";
                                        currentTitle = 'Yearly Sleep Average';
                                      });
                                      simulateLoading(Year_Chart);
                                    },
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  GestureDetector(
                                    child: Text(
                                      AppText.multiyear,
                                      style: Reports == 'Multi-Year' ?  Apptextstyle.s16wncR
                                          : Apptextstyle.s16wncG,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        Reports = "Multi-Year";
                                        currentTitle = 'Multi-Year Sleep Average';
        
                                        final now = DateTime.now();
                                        //fromYear = now.year;
                                        toYear = now.year;
        
                                        yearPickerLabel =
                                            "${DateFormat('yyyy').format(DateTime(toYear!))}";
                                      });
                                      simulateLoading(MultiYear_Chart);
                                    },
                                  )
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
                                          currentTitle = 'Daily Sleep Average';
                                          mainDate =
                                              DateFormat('MMMM dd, yyyy').format(
                                                  datePicked);
                                          simulateLoading(Day_Chart);
                                        } else if (Reports == 'Year') {
                                          // From Year to Month
                                          Reports = 'Month';
                                          currentTitle = 'Monthly Sleep Average';
                                          mainDate =
                                              DateFormat('MMMM-yyyy').format(
                                                  datePicked);
                                          simulateLoading(Month_Chart);
                                        } else {
                                          // Stay in current report type
                                          switch (Reports) {
                                            case 'Day':
                                              currentTitle =
                                              'Daily Sleep Average';
                                              mainDate =
                                                  DateFormat('MMMM dd, yyyy')
                                                      .format(datePicked);
                                              simulateLoading(Day_Chart);
                                              break;
                                            case 'Month':
                                              currentTitle =
                                              'Monthly Sleep Average';
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
                  SizedBox(
                    height: 25,
                  ),
                  if (_isLoading)
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: double.infinity,
                        height: size.height * 0.3,
                        color: Colors.white,
                      ),
                    )
                  else if (Reports == "Day")
                    buildSleepChart(
                      context: context,
                      title: "Sleep for this Day",
                      xAxisTitle: selectedDate != null
                                  ? DateFormat('MMM dd, yyyy').format(selectedDate!)
                                  : '',
                      chartData: _daySleepBars,
                      fullSleepData: _sleepsData,
                      yAxisMax: yAxisMax,
                      yAxisInterval: 1,
                      targetSleepValue: targetSleepValue,
                      onTooltipRenderCustom: (TooltipArgs args) {
                        args.header = 'Sleep';
                        final summary = _sleepsData.isNotEmpty ? _sleepsData.first : null;
                        if (summary != null) {
                          args.text = 'Deep : ${summary.totalDeep}\n'
                              'Middle : ${summary.totalMiddle}\n'
                              'Light : ${summary.totalLight}';
                        }
                      },
                      ismonth: true,
                      xAxisInterval: 1,
                        isyears: false

                    )
                     else if (Reports == "Week")
                      buildSleepChart(
                        context: context,
                        title: "Avg Daily Sleep",
                        xAxisTitle: 'Day',
                        chartData: _weekSleepBars,
                        fullSleepData: _sleepsData,
                        yAxisMax: yAxisMax,
                        yAxisInterval: 1,
                        targetSleepValue: targetSleepValue,
                        onTooltipRenderCustom: (TooltipArgs args) {
                          args.header = "Sleep";
                          final dayLabel = args.dataPoints![args.pointIndex!.toInt()].x;
                          final summary = _sleepsData.firstWhere(
                                (e) => e.day_name == dayLabel,
                            orElse: () => SleepDataChart1(
                              day_name: '',
                              totalLight: '0h 0m',
                              totalDeep: '0h 0m',
                              totalMiddle: '0h 0m',
                              total_sleep: '0h 0m',
                              light2: 0,
                              week_names: '',
                              awake_s: 0,
                              lightSleep_s: 0,
                              deepSleep_s: 0,
                              remSleep_s: 0,
                              awake_s1: 0,
                              lightSleep_s1: 0,
                              remSleep_s1: 0,
                              time_s: DateTime.now(),
                              month_name: '',
                              years: '',
                            ),
                          );
                          args.text =
                          'Deep : ${summary.totalDeep}\n'
                              'Middle : ${summary.totalMiddle}\n'
                              'Light : ${summary.totalLight}';
                        },
                        ismonth: true,
                        xAxisInterval: 1,
                          isyears: false
                      )
                    else if (Reports == "Month")
                        buildSleepChart(
                          context: context,
                          title: "Avg Daily Sleep",
                          xAxisTitle: 'Days',
                          chartData: _monthSleepBars,
                          fullSleepData: _sleepsData,
                          yAxisMax: yAxisMax,
                          yAxisInterval: 1,
                          targetSleepValue: targetSleepValue,
                              onTooltipRenderCustom: (TooltipArgs args) {
                                args.header = 'Sleep';
                                final label = args.dataPoints![args.pointIndex!.toInt()].x;
                                final summary = _sleepsData.firstWhere(
                                      (e) => e.time_s.day.toString() == label,
                                  orElse: () => SleepDataChart1(
                                    time_s: DateTime.now(),
                                    day_name: '',
                                    month_name: '',
                                    years: '',
                                    awake_s: 0,
                                    lightSleep_s: 0,
                                    deepSleep_s: 0,
                                    remSleep_s: 0,
                                    awake_s1: 0,
                                    lightSleep_s1: 0,
                                    remSleep_s1: 0,
                                    total_sleep: '',
                                    totalLight: '0h 0m',
                                    totalMiddle: '0h 0m',
                                    totalDeep: '0h 0m',
                                    light2: 0,
                                    week_names: '',
                                  ),
                                );

                                args.text =
                                'Deep : ${summary.totalDeep}\n'
                                    'Middle : ${summary.totalMiddle}\n'
                                    'Light : ${summary.totalLight}';
                              },
                          ismonth: true,
                          xAxisInterval: 2,
                            isyears: false

                        )
                      else if (Reports == "Year")
                          buildSleepChart(
                            context: context,
                            title: "Avg Monthly Sleep",
                            xAxisTitle: 'Months',
                            chartData: _yearsleepBars,
                            fullSleepData: _sleepsData,
                            yAxisMax: yAxisMax,
                            yAxisInterval: 1,
                            targetSleepValue: targetSleepValue,
                            onTooltipRenderCustom: (TooltipArgs args) {
                              args.header = 'Sleep';
                              final label = args.dataPoints![args.pointIndex!.toInt()].x;

                              final summary = _sleepsData.firstWhere(
                                    (e) => e.month_name == label,
                                orElse: () => SleepDataChart1(
                                  time_s: DateTime.now(),
                                  day_name: '',
                                  month_name: '',
                                  years: '',
                                  awake_s: 0,
                                  lightSleep_s: 0,
                                  deepSleep_s: 0,
                                  remSleep_s: 0,
                                  awake_s1: 0,
                                  lightSleep_s1: 0,
                                  remSleep_s1: 0,
                                  total_sleep: '',
                                  totalLight: '0h 0m',
                                  totalMiddle: '0h 0m',
                                  totalDeep: '0h 0m',
                                  light2: 0,
                                  week_names: '',
                                ),
                              );

                              args.text =
                              'Deep : ${summary.totalDeep}\n'
                                  'Middle : ${summary.totalMiddle}\n'
                                  'Light : ${summary.totalLight}';
                            },
                            ismonth: false,
                            xAxisInterval: 1,
                              isyears: false

                          )
                     else if (Reports == "Multi-Year")
                  buildSleepChart(
                    context: context,
                    title: "Avg Yearly Sleep",
                    xAxisTitle: 'Years',
                    chartData: _multiYearSleepBars,
                    fullSleepData: _sleepsData,
                    yAxisMax: yAxisMax,
                     yAxisInterval: 1,
                    targetSleepValue: targetSleepValue,
                    onTooltipRenderCustom: (TooltipArgs args) {
                      args.header = 'Sleep';
                      final label = args.dataPoints![args.pointIndex!.toInt()].x;

                      final summary = _sleepsData.firstWhere(
                            (e) => e.years == label,
                        orElse: () => SleepDataChart1(
                          time_s: DateTime.now(),
                          day_name: '',
                          month_name: '',
                          years: '',
                          awake_s: 0,
                          lightSleep_s: 0,
                          deepSleep_s: 0,
                          remSleep_s: 0,
                          awake_s1: 0,
                          lightSleep_s1: 0,
                          remSleep_s1: 0,
                          total_sleep: '',
                          totalLight: '0h 0m',
                          totalMiddle: '0h 0m',
                          totalDeep: '0h 0m',
                          light2: 0,
                          week_names: '',
                        ),
                      );

                      args.text =
                      'Deep : ${summary.totalDeep}\n'
                          'Middle : ${summary.totalMiddle}\n'
                          'Light : ${summary.totalLight}';
                    },
                    ismonth: false,
                    xAxisInterval: 1,
                      isyears: true
                  ),
                      SizedBox(height: 20,),
                      deepPercentage == null ?
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 10, 20, 10),
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
                                  children: [
                                    SizedBox(height: 30),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: AppColors.others_D,
                                                    border: Border.all(color: AppColors.others_D, width: 1.0),
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text(
                                                      deepPercentage != null ? '$deepPercentage' : '',
                                                      overflow: TextOverflow.ellipsis,
                                                      style: Apptextstyle.s10wbcB,
                                                    ),
                                                  ),),
                                                SizedBox(width: 5,),
                                                Text(
                                                  AppText.deepsleep,
                                                  style: Apptextstyle.s10wbcB,
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 7,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color:AppColors.others_M,
                                                    border: Border.all(color: AppColors.others_M, width: 1.0),
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
        
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text(
                                                      middlePercentage != null ? '$middlePercentage' : '',
                                                      overflow: TextOverflow.ellipsis,
                                                      style: Apptextstyle.s10wbcB,
                                                    ),
                                                  ),),
                                                SizedBox(width: 5,),
                                                Text(
                                                  AppText.middlesleep,
                                                  style: Apptextstyle.s10wbcB,
                                                ),
                                                //Text("Middle"),
                                              ],
                                            ),
                                            SizedBox(height: 7,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: AppColors.others_L,
                                                    border: Border.all(color: AppColors.others_L, width: 1.0),
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text(
                                                      lightPercentage != null ? '$lightPercentage' : '',
                                                      overflow: TextOverflow.ellipsis,
                                                      style: Apptextstyle.s10wbcB,
                                                    ),
                                                  ),),
                                                SizedBox(width: 5,),
                                                Text(
                                                  AppText.lightsleep,
                                                  style: Apptextstyle.s10wbcB,
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 7,),
                                            if(target_visible)
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  child: Text(
                                                    'Target Daily Sleep is $day_target_sleep',
                                                      style: Apptextstyle.s12wbcG
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 7,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  child: Text(
                                                      'Current Actual Daily Average Sleep is $totalsleep',
                                                      style: Apptextstyle.s12wbcG
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    // Optional animated description
                                    Column(
                                      children: [
                                        AnimatedSize(
                                          duration: Duration(milliseconds: 300),
                                          curve: Curves.easeInCubic,
                                          child: AnimatedOpacity(
                                            opacity: is_steps ? 1.0 : 0.0,
                                            duration: Duration(milliseconds: 300),
                                            child: is_steps
                                                ? Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Text(
                                                _getTextBasedOnCondition(),
                                                style: TextStyle(fontSize: 12.0),
                                                textAlign: TextAlign.left,
                                              ),
                                            )
                                                : SizedBox.shrink(),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 15),
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
                                            //color: Color(0xFF367588),
                                             color: Color(0xFF008080),
                                            shape: BoxShape.rectangle, // Optional: make it circular
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 45,
                                        height: 45,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(Appimages.sleep_logo),
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
                      ), _isLoading ?
                      Center(child: Image.asset(
                        Appimages.applogo,
                        height: size.height * 0.07,
                        fit: BoxFit.contain,
                      ),) :
                      Padding(
                        padding:  EdgeInsets.only(left: 20,right: 10, bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,// Card background color
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.grey, // Border color
                              width: 1.0, // Border width
                            ),
                          ),
                          child:  Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 10,),
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
                                  padding: const EdgeInsets.fromLTRB(10, 8, 0, 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    // Spreads children evenly
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Date",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.othersT,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.left, // Centers the text within its space
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          AppText.deep,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.othersT,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
        
                                      Expanded(
                                        child: Text(
                                          AppText.middle,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.othersT,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          AppText.light,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.othersT,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          AppText.total_s1,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.othersT,
                                          ),
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
                                    itemCount: _sleepsData.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.fromLTRB(0,8,0,0),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    Reports == 'Month'
                                                        ? _sleepsData[index].month_name
                                                        : Reports == 'Year'
                                                        ? DateFormat("MMM").format(_sleepsData[index].time_s )
                                                        : Reports == 'Multi-Year'
                                                        ? DateFormat("yyyy").format(_sleepsData[index].time_s )
                                                        : Reports == 'Week'? _sleepsData[index].day_name :DateFormat('MMM dd, yyyy').format(_sleepsData[index].time_s ),
                                                    style: TextStyle(
                                                      fontSize: 12
                                                    ),
                                                    //overflow: TextOverflow.ellipsis,
                                                    // textAlign: TextAlign.left,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Center(
                                                    child: Text(
                                                      '${_sleepsData[index].totalDeep}',
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
                                                      '${_sleepsData[index].totalMiddle}',
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
                                                      '${_sleepsData[index].totalLight}',
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
                                                      '${_sleepsData[index].total_sleep}',
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
                                DisclaimerFooter(),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
          ),
    )
    )
        )
      );
  }

  Widget buildSleepChart({
    required BuildContext context,
    required String title,
    required String xAxisTitle,
    required List<SleepBarData> chartData,
    required List<SleepDataChart1> fullSleepData,
    required double yAxisMax,
    double yAxisInterval = 1,
    required double? targetSleepValue,
    required bool ismonth,
    required bool isyears,
    required double xAxisInterval,
    //required bool ischarts,
    required void Function(TooltipArgs) onTooltipRenderCustom,
  }) {

    print("🟩 Chart Data Length: ${_multiYearSleepBars.length}");
    _multiYearSleepBars.forEach((e) {
      print('▶ ${e.label}: start ${e.startHour}, end ${e.endHour}, value ${e.value}');
    });
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
        tooltipBehavior: TooltipBehavior(
          enable: true,
          canShowMarker: false,
            textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
            )
        ),
        onTooltipRender: onTooltipRenderCustom,
        title: ChartTitle(text: title),
        backgroundColor: AppColors.White,
        plotAreaBorderWidth: 0.0,
        plotAreaBorderColor: AppColors.greyshaded100,
        primaryXAxis: ismonth == true ? CategoryAxis(
          majorGridLines: MajorGridLines(width: 0),
          majorTickLines: MajorTickLines(width: 0),
          axisLine: AxisLine(width: 1, color: AppColors.Grey),
          labelStyle: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          title: AxisTitle(
            text: xAxisTitle
          ),
          interval: xAxisInterval,
        ):
        isyears == true ?CategoryAxis(
          title: AxisTitle(text: xAxisTitle),
          labelStyle: TextStyle(fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
          majorTickLines: MajorTickLines(width: 0),
          majorGridLines: MajorGridLines(width: 0),
          // labelPlacement: LabelPlacement.onTicks,
          // edgeLabelPlacement: EdgeLabelPlacement.shift,
        ):
        CategoryAxis(
          majorGridLines: MajorGridLines(width: 0),
          majorTickLines: MajorTickLines(width: 0),
          axisLine: AxisLine(width: 1, color: AppColors.Grey),
          labelStyle: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          title: AxisTitle(
              text: xAxisTitle
          ),
          labelIntersectAction: AxisLabelIntersectAction.none, // ✅ Prevents skipping
          maximumLabels: 12,
        ),
        primaryYAxis: NumericAxis(
          minimum: 0,
          maximum: yAxisMax,
          interval: yAxisInterval,
          title: const AxisTitle(text: 'Hours'),
          labelStyle: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          majorGridLines: MajorGridLines(width: 0),
          minorGridLines: MinorGridLines(width: 0),
          majorTickLines: MajorTickLines(width: 0),
          plotBands: [
            if (targetSleepValue != null && targetSleepValue > 0)
              PlotBand(
                isVisible: true,
                start: targetSleepValue,
                end: targetSleepValue,
                borderColor:AppColors.target_color,
                borderWidth: 2,
                text: '',
                horizontalTextAlignment: TextAnchor.end,
                verticalTextAlignment: TextAnchor.middle,
              ),
          ],
        ),
        series: <RangeColumnSeries<SleepBarData, String>>[
          RangeColumnSeries<SleepBarData, String>(
            dataSource: chartData,
            xValueMapper: (d, _) => d.label,
            lowValueMapper: (d, _) => d.startHour,
            highValueMapper: (d, _) => d.endHour,
            pointColorMapper: (d, _) => _getColor(d.value),
           //emptyPointSettings: EmptyPointSettings(mode: EmptyPointMode.zero),
            //name: 'Sleep',
          )
        ],
      ),
    );
  }



}

class SleepDataChart1 {
  final DateTime time_s;
  final String day_name;
  final String month_name;
  final String years;
  final double awake_s;
  final double lightSleep_s;
  final double deepSleep_s;
  final double remSleep_s;
  final double awake_s1;
  final String total_sleep;
  final double lightSleep_s1;
  final double remSleep_s1;
  final String totalLight;
  final String totalMiddle;
  final String totalDeep;
  final double light2;

  final String week_names;

  SleepDataChart1( {
    required this.light2,
    required this.totalLight,
    required this.totalMiddle,
    required this.totalDeep,
    required this.total_sleep,
    required this.month_name,
    required this.years,
    required this.day_name,
    required this.time_s,
    required this.awake_s,
    required this.lightSleep_s,
    required this.deepSleep_s,
    required this.remSleep_s,
    required this.awake_s1,
    required this.lightSleep_s1,
    required this.remSleep_s1,
    required this.week_names,
  });
}
