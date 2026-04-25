
import 'dart:async';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:azpire_new/Cling%20Connections/sync_data.dart';
import 'package:azpire_new/Controller/AdminController.dart';
import 'package:azpire_new/Controller/notifications_controller.dart';
import 'package:azpire_new/View/AdminScreen.dart';
import 'package:azpire_new/Cling%20Connections/clingchannelHandler.dart';
import 'package:azpire_new/Cling%20Connections/minute_data.dart';
import 'package:azpire_new/Cling%20Connections/sync_data.dart';
import 'package:azpire_new/Controller/dashboard_controller.dart';
import 'package:azpire_new/View/Dialy_steps.dart';
import 'package:azpire_new/View/Heart_rate.dart';
import 'package:azpire_new/View/Sleep_chart.dart';
import 'package:azpire_new/View/blood_oxygenpressure.dart';
import 'package:azpire_new/View/blood_pressure.dart';
import 'package:azpire_new/View/profile.dart';
import 'package:azpire_new/View/weight.dart';
import 'package:azpire_new/healthkit/HealthKit.dart';
import 'package:azpire_new/utils/app_color.dart';
import 'package:azpire_new/utils/appimages.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:azpire_new/widgets/CustomBottomNavBar.dart';
import 'package:azpire_new/widgets/charts/dashboard_blood_pressure.dart';
import 'package:azpire_new/widgets/charts/dashboard_daily_steps.dart';
import 'package:azpire_new/widgets/charts/dashboard_heart_rate.dart';
import 'package:azpire_new/widgets/charts/dashboard_sleep.dart';
import 'package:azpire_new/widgets/charts/dashboard_bloodoxygen.dart';
import 'package:azpire_new/widgets/charts/dashboard_weight_chart.dart';
import 'package:azpire_new/widgets/shimmer_effects.dart';
import 'package:azpire_new/widgets/text_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart'; // Import shimmer
import '../Cling Connections/health_data.dart';
import '../Controller/ToggleController.dart';
import '../menu/NavMneu.dart';
import '../utils/apptext.dart';
import '../widgets/custom_card.dart';
import '../widgets/disclaimers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required String deviceID});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  //final HealthDataController _healthDatacontroller = HealthDataController();
  List<Map<String, dynamic>> minuteDataList = [];
  //late MinuteDataController _minuteDatacontroller;
  final _advancedDrawerController = AdvancedDrawerController();
  final NotificationsController _notifycontroller = NotificationsController();
  final DashboardController _dashboardcontroller = DashboardController();
  final AdminController _toggleController = AdminController();
  String t1 = "";
  String t2 = "";
  String datetime = "";
  String heartRate = "";
  String spo2 = "";
  String steps = "";
  int weight = 0;
  String sleep = "";
  String bps = "";
  var profilephoto ;
  String bpd = "";
  String sys = "";
  String Dia = "";
  String weekdate = "";
  bool isLoggedIn = false;
  var user_id;
  var name;
  var mobile_no;
  var email;
  var pofileimage;
  var noti_count;
  String? deepPercentage;
  String? lightPercentage;
  String? middlePercentage;
  String oxygen = "";
  String formattedDateTime = " ";
  bool isLoading = true;
  List title = ["Blood Pressure", "Heart Rate", "Avg Daily Steps", "Sleep", "Weight"];
  static const platform = MethodChannel('cling_sdk');
  String notificationMessage = "Waiting for data...";
  Map<String, dynamic>? dailyData;
  Timer? _syncTimer;
  /// Controller to handle bottom nav bar and also handles initial page
  final NotchBottomBarController _controller = NotchBottomBarController(index: 0);
  late SyncService _syncService;
  Map<String, dynamic>? _dailyData;
  bool _hasNavigated = false;
  bool _hasLoadedOnce = false;
  Timer? _toggleRefreshTimer;
  bool _loading = true;




 // bool shouldSync = false;

  @override
  void initState() {
    super.initState();
    final clingHandler = ClingChannelHandler();
    clingHandler.initialize();
    _syncService = SyncService(
      updateMessage: (msg) {
        print("📝 Message: $msg");
        setState(() => notificationMessage = msg);
      },
      onDailyDataReceived: (data) {
        //print("📥 Daily Data from SyncService: $data");
        setState(() => _dailyData = data);
      },
      onDashboardRefresh: () {
        print("🔄 Refreshing dashboard after sync");
        loadDashboardData(); // 🔥 THIS FIXES YOUR ISSUE
      },
      onSyncComplete: () {
        print("✅ Sync complete");
      }, shouldSync:true ,
    );
    _syncService.startSync();
    loadDashboardData();
    checkSession();
    loaddata();
    _loadNotificationCount();
    _startToggleAutoRefresh();
    _initHealthKit();
    _showMedicalDisclaimer();
   // _healthDataService.startSyncTimer();
  }

  Future<void> _showMedicalDisclaimer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeenDisclaimer = prefs.getBool('hasSeenMedicalDisclaimer') ?? false;

    if (!hasSeenDisclaimer && mounted) {
      await Future.delayed(Duration(seconds: 1)); // Wait for build
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => MedicalDisclaimerDialog(),
      );
      await prefs.setBool('hasSeenMedicalDisclaimer', true);
    }
  }


  Future<void> _initHealthKit() async {
    try {
      final hk = HealthKitService();

      print("Requesting HealthKit Permission...");
      await hk.requestAuthorization();

      print("Fetching Heart Rate...");
      final List<Map<String, dynamic>> hr = await hk.fetchHeartRate();

      print("Heart Rate from HealthKit: $hr");

      if (mounted && hr != null) {
        setState(() {
          heartRate = hr.toString(); // update UI
        });
      }
    } catch (e) {
      print("HealthKit error: $e");
    }
  }

  // void _handleDailyDataReceived(Map<String, dynamic> dailyData) {
  //   setState(() {
  //     notificationMessage = "Received daily data";
  //     this.dailyData = dailyData;
  //   });
  //
  //   if (dailyData.containsKey('heartRate')) {
  //     int heartRate = dailyData['heartRate'];
  //     int totalSteps = dailyData['totalSteps'];
  //     int systolicBP = dailyData['systolicBP'];
  //     int diastolicBP = dailyData['diastolicBP'];
  //     int totalSleep = dailyData['totalSleep'];
  //     _healthDatacontroller.sendHeartRateToAPI(heartRate, totalSteps, systolicBP, diastolicBP, totalSleep);
  //   } else {
  //     print("Heart rate key not found in dailyData!");
  //   }
  // }

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

  @override
  void dispose() {
    //_healthDatacontroller.stopSyncTimer();
    //_minuteDatacontroller.stopSyncing();
    super.dispose();
  }

  Future<void> loadDashboardData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    print("user_id:$user_id");
    final data = await _dashboardcontroller.fetchDashboardload(user_id);
    if (data != null) {

      DateTime originalDateTime = DateFormat('yyyy-MM-dd hh:mm:ss a').parse(data['collection_date']);
      String formattedDateTime = DateFormat('MMMM d, yyyy, HH:mm').format(originalDateTime);

      // Initialize defaults
      String deep = '';
      String middle = '';
      String light = '';

      // Extract sleep_list
      List<dynamic> rawSleepList = data['sleep_list'] ?? [];

      for (var item in rawSleepList) {
        switch (item['sleep_value']) {
          // case 4:
          //   deep = item['percentage'];
          //   break;
          // case 3:
          //   middle = item['percentage'];
          //   break;
          // case 2:
          //   light = item['percentage'];
          //   break;

          case 3:
            deep = item['percentage'];
            break;
          case 4:
            middle = item['percentage'];
            break;
          case 2:
            light = item['percentage'];
            break;
        }
      }

      if (mounted)
      setState(() {
        profilephoto = data['profile_image'].toString();
        bps = data['blood_pressure_systolic'].toString();
        bpd = data['blood_pressure_diastolic'].toString();
        heartRate = data['heart_rate'].toString();
        steps = data['daily_steps'].toString();
        //weight = data['weight'].toString();
        weight = data['weight'] ?? 0; // weight as int
        sleep = data['sleep'].toString();
        oxygen = "${data['oxygen'] ?? 0}%";
        datetime = formattedDateTime;
        weekdate = data['week_range'].toString();
        deepPercentage = deep;
        middlePercentage = middle;
        lightPercentage = light;
      });
    }
  }


  Future<void> _loadNotificationCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    final count = await _notifycontroller.getNotificationCount(user_id);
    if (mounted) {
      setState(() {
        noti_count = count;
      });
    }
  }

  Future<void> checkSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
    print("isLoggedIn$isLoggedIn");
  }

  Future<void> loaddata() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      user_id = prefs.getString('user_id');
      name = prefs.getString('name');
      mobile_no = prefs.getString('mobile_no');
      email = prefs.getString('email');
      pofileimage = prefs.getString('pofile');
      isLoading = false;
    });

    if (prefs.getString("name") != null) {
      await prefs.setString("username", prefs.getString("name")!);
    }

  }

  void _startToggleAutoRefresh() {
    // Start timer that refreshes toggle states every 10 seconds
    _toggleRefreshTimer = Timer.periodic(Duration(seconds: 10), (Timer timer) {
      if (mounted) {
        _loadFromAPI();
      }
    });
  }

  Future<void> _loadFromAPI() async {
    setState(() => _loading = true);

    final result = await _toggleController.fetchAllToggles();

    if (result != null && result.data.isNotEmpty) {
      // Get ToggleService and update it
      final toggleService = Provider.of<ToggleService>(context, listen: false);

      // Create a map to store new values
      Map<String, bool> newValues = {
        'BloodPressure': false,
        'HeartRate': false,
        'Steps': false,
        'Sleep': false,
        'Spo2': false,
        'Weight': false,
      };

      // Update based on API response
      for (final toggle in result.data) {
        final isOn = toggle.toggleStatus.toUpperCase() == "ON";
        switch (toggle.tableType) {
          case "BloodPressure":
            newValues['BloodPressure'] = isOn;
            break;
          case "HeartRate":
            newValues['HeartRate'] = isOn;
            break;
          case "Steps":
            newValues['Steps'] = isOn;
            break;
          case "Sleep":
            newValues['Sleep'] = isOn;
            break;
          case "Spo2":
            newValues['Spo2'] = isOn;
            break;
          case "Weight":
            newValues['Weight'] = isOn;
            break;
        }
      }

      // Update the ToggleService with all values
      toggleService.updateToggleStates(
        bloodPressure: newValues['BloodPressure'],
        heartRate: newValues['HeartRate'],
        steps: newValues['Steps'],
        sleep: newValues['Sleep'],
        spo2: newValues['Spo2'],
        weight: newValues['Weight'],
      );
    }

    setState(() => _loading = false);
  }




  ExitAppDialog(){}
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      // onWillPop: () async {
      //   ExitAppDialog();
      //   return true;
      // },
      onWillPop: () async {
        bool shouldExit = await showExitConfirmationDialog(context);
        return shouldExit;
      },
      child: Container(
        width: kIsWeb ? 250 : MediaQuery.of(context).size.width * 0.7,
        child: AdvancedDrawer(
          controller: _advancedDrawerController,
          backdropColor: Colors.grey.shade100,
          drawer: NavMenu(name: name, email: email, profile: profilephoto, noti_count: noti_count),
          child: Scaffold(
            backgroundColor: AppColors.White,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.White,
              title: isLoading
                  ? ShimmerLoadingItem()
                  : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: (){
                      Get.to(()=>Profile());
                    },
                    child: profilephoto != null ? CircleAvatar(
                      backgroundImage: NetworkImage(profilephoto),
                      radius: 20,
                    ) : CircleAvatar(
                      backgroundImage: AssetImage(Appimages.profilelogo),
                      radius: 20,
                    ),
                  ),
                  SizedBox(width: 20),
                  TextTitle1(
                    title: "Hi, ${name.toString().capitalizeFirst}",
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
            ),
            body: Consumer<ToggleService>(
              builder: (context, toggleService, child) {
                return isLoading
                    ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            height: 24,
                            width: 100,
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      for (int i = 0; i < 4; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Daily Dashboard: $weekdate',
                            style: Apptextstyle.s18wbcB,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              if (toggleService.showBloodPressure)
                                CustomCard1(
                                  title: AppText.bp,
                                  t1: bps,
                                  t2: '$bpd',
                                  Bps: AppText.SYS,
                                  Bpd: AppText.DIA,
                                  bpunit: AppText.bp_unit,
                                  t2fontsize: 24,
                                  datetime: AppText.avg_bp,
                                  chart: BloodPressureChart(),
                                  press: () {
                                    Get.to(() => BloodPressureChartPage(name: name, email: email, profile: profilephoto, noti_count: noti_count));
                                  },
                                  color1: AppColors.color1,
                                  color2: AppColors.color2,
                                ),
                              if (toggleService.showHeartRate)
                                CustomCard(
                                  title: AppText.HR,
                                  t1: heartRate,
                                  t2: AppText.HR_unit,
                                  t2fontsize: 15,
                                  datetime: AppText.avg_hr,
                                  chart: HeartRateChartPage(),
                                  press: () {
                                    Get.to(() => HeartRateChart(name: name, email: email, profile: profilephoto, noti_count: noti_count));
                                  },
                                  color: Color(0xFFe13b4a),
                                  heading: 'heart',
                                ),
                              if (toggleService.showSteps)
                                CustomCard(
                                  title: AppText.dailysteps,
                                  t1: NumberFormat.decimalPattern('en_US').format(int.tryParse(steps) ?? 0),
                                  t2: AppText.D_Steps,
                                  t2fontsize: 15,
                                  datetime: AppText.avg_steps,
                                  chart: StepsChart(),
                                  press: () {
                                    Get.to(() => StepsChartPage(name: name, email: email, profile: profilephoto, noti_count: noti_count));
                                  },
                                  color: Color(0xFF9C53C7),
                                  heading: 'steps',
                                ),
                              if (toggleService.showSleep)
                                CustomCardsleep(
                                  title: AppText.dailysleep,
                                  t1: sleep,
                                  t2: "",
                                  t2fontsize: 15,
                                  datetime: AppText.avg_sleep,
                                  chart: SleepChart(),
                                  press: () {
                                    Get.to(() => SleepChartPage(name: name, email: email, profile: profilephoto, noti_count: noti_count));
                                  },
                                  color: AppColors.color3,
                                  deepPercentage: _formatPercentage(deepPercentage),
                                  middlePercentage: _formatPercentage(middlePercentage),
                                  lightPercentage: _formatPercentage(lightPercentage),
                                ),
                              if (toggleService.showSpo2)
                                CustomCardspo2(
                                  title: AppText.blood_oxygen,
                                  t1: oxygen,
                                  t2: "",
                                  t2fontsize: 15,
                                  datetime: AppText.avg,
                                  chart: BloodOxygenChartPage(),
                                  press: () {
                                    Get.to(() => BloodoxygenPressureChartPage(name: name, email: email, profile: profilephoto, noti_count: noti_count));
                                  },
                                  color: AppColors.color4,
                                ),
                              if (toggleService.showWeight)
                                CustomCard(
                                  title: AppText.weight,
                                  t1: weight.toString(),
                                  t2: AppText.pounds,
                                  t2fontsize: 15,
                                  datetime: AppText.avg,
                                  chart: WeightChartPage(),
                                  press: () {
                                    Get.to(() => WeightChart(name: name, email: email, profile: profilephoto, noti_count: noti_count));
                                  },
                                  color: Color(0xffF5B849),
                                  heading: 'weight',
                                ),
                              DisclaimerFooter(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            bottomNavigationBar: (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                ? CustomBottomNavBar(controller: _controller)
                : null,
          ),
        ),
      ),
    );
  }
}

/// Shows a confirmation dialog when the user presses the back button.
Future<bool> showExitConfirmationDialog(BuildContext context) async {
  bool exit = false;
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(AppText.exitapp, style: Apptextstyle.s15wbcothers,),
        content: Text(AppText.sure_exit, style: Apptextstyle.s13wbcgrey,),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pop(); // Dismiss dialog
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                    child: Row(
                      children: [
                        Text(
                            AppText.cancel,
                            style: Apptextstyle.s15wbcW
                        ),
                        SizedBox(width: 5,),
                        Icon(Icons.logout,color: Colors.white,)
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  exit = true;
                  SystemNavigator.pop();
                  //Navigator.of(context).pop(); // Dismiss dialog
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(25, 4, 20, 4),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,// 👈 THIS is required
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Center(
                            child: Text(
                              AppText.exit,
                              style: Apptextstyle.s15wbcW,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.arrow_right_alt_sharp,
                            color: Colors.white,
                          ),
                        ],
                      ),

                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      );
    },
  );
  return exit;
}