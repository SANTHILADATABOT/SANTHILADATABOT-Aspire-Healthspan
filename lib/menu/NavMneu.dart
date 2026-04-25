import 'dart:convert';
import 'package:azpire_new/Controller/pairedevice_controller.dart';
import 'package:azpire_new/View/AdminScreen.dart';
import 'package:azpire_new/View/Dashboard_screen.dart';
import 'package:azpire_new/View/Dialy_steps.dart';
import 'package:azpire_new/View/Heart_rate.dart';
import 'package:azpire_new/View/Sleep_chart.dart';
import 'package:azpire_new/View/blood_oxygenpressure.dart';
import 'package:azpire_new/View/blood_pressure.dart';
import 'package:azpire_new/View/profile.dart';
import 'package:azpire_new/View/weight.dart';
import 'package:azpire_new/View/Notifications.dart';
import 'package:azpire_new/View/login_Screen.dart';
import 'package:azpire_new/cling_ble_service.dart';
import 'package:azpire_new/menu/goal_settings.dart';
import 'package:azpire_new/minutedata/minutedata.dart';
import 'package:azpire_new/View/bluetoothscreen.dart';
import 'package:azpire_new/utils/app_color.dart';
import 'package:azpire_new/utils/appimages.dart';
import 'package:azpire_new/utils/apptext.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:azpire_new/root/root.dart';
import '../Controller/ToggleController.dart';
import 'dart:async';
import 'dart:io';
import 'package:azpire_new/cling_ble_service.dart';
import 'package:oktoast/oktoast.dart';



class NavMenu extends StatefulWidget {
  var name;

  var email, profile, noti_count;

   NavMenu({Key? key, required this.name, required this.email, required this.profile, required this.noti_count,}) : super(key: key);

  @override
  State<NavMenu> createState() => _NavMenuState();
}

class _NavMenuState extends State<NavMenu> {
  String notificationMessage = "Waiting for data...";
  static const platform = MethodChannel('cling_sdk');
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  bool is_loading = false;
  //String? _registeredDevice;
  var name;
  var email;
  var pofileimage;
  var noti_count;
  var userType;
  String? user_id;
  String? Deviceid;
  bool _loadingToggles = true;

  @override
  void initState(){
    super.initState();
    print("Hello");
    _loadUserType();
    // _loadToggleStates();
  }

  Future<void> _deregisterDevice() async {


    setState(() {
      notificationMessage = "Deregistering device...";
    });

    try {
      await platform.invokeMethod('deregisterDevice'); // Call native iOS method
      setState(() {
        notificationMessage = "Device Deregistered Successfully!";
      });

      final prefs = await SharedPreferences.getInstance();

      String deviceId = prefs.getString('DeviceId') ?? "";
      String user_id = prefs.getString('user_id') ?? "";

      print("Stored DeviceId: $deviceId");
      print("Stored user_id: $user_id");


      if (deviceId.isEmpty || user_id.isEmpty) {
        throw Exception("Missing device or user info");
      }

      final response = await deregisterDevice(user_id, deviceId);

      if (response == null) {
        throw Exception("No response from API");
      }

      String status = response['status'] ?? "";
      String message = response['message'] ?? "";
      String apiDeviceId =
      (response['device_id'] ?? "").toString().trim();
      String apiUserId =
      (response['user_id'] ?? "").toString().trim();

      print("API Status: $status | Message: $message");

      // ❌ FAIL CASE
      if (status != "SUCCESS" ||
          apiDeviceId != deviceId.trim() ||
          apiUserId != user_id.trim()) {

        // _scaffoldMessengerKey.currentState?.showSnackBar(
        //   SnackBar(content: Text(message)),
        // );

        showCustomToast(message);

        return;
      }

      // ✅ SUCCESS CASE
      // _scaffoldMessengerKey.currentState?.showSnackBar(
      //   SnackBar(content: Text(message)), // "Device deregistered successfully"
      // );

      showCustomToast(message);

      // Navigate back to pairing screen after deregistering
      Navigator.push(context, MaterialPageRoute(builder: (context) => BluetoothPair()));

    } on PlatformException catch (e) {
      setState(() {
        notificationMessage = "Failed to deregister device: ${e.message}";
      });
    }
  }

  Future<void> _loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString('user_type') ?? 'Unknown';
    });
    print("Retrieved user_type in NavMenu: $userType");
  }

  @override
  Widget build(BuildContext context) {
    //final toggleService = Provider.of<ToggleService>(context, listen: true);
    return Consumer<ToggleService>(
        builder: (context, toggleService, child) {
          print("NavMenu rebuilding with toggle states:");
          print("BP: ${toggleService.showBloodPressure}, HR: ${toggleService.showHeartRate},"
              "Steps: ${toggleService.showSteps},Sleep: ${toggleService.showSleep}, "
              "Spo2: ${toggleService.showSpo2},weight: ${toggleService.showWeight}");
          return Drawer(
            backgroundColor: Colors.white,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  height: kIsWeb
                      ? ((MediaQuery.of(context).size.height * 0.12) < 85
                      ? 85
                      : (MediaQuery.of(context).size.height * 0.12))
                      : 85, // Constant height for Android & iOS
                  width: kIsWeb ? 250 : MediaQuery
                      .of(context)
                      .size
                      .width * 0.7,
                  child: DrawerHeader(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 25),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.asset(Appimages.applogo, height: 40),
                                  Text(AppText.splashAppname,
                                      style: Apptextstyle.s18wbco),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      if (userType == 'Admin')
                        ListTile(
                          leading: Icon(
                              Icons.person, color: Color(0xFF254a6c), size: 25),
                          title: Text('Admin',
                              style: TextStyle(fontFamily: "Inter", color: Color(
                                  0xFF505970))),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => Adminscreen()));
                          },
                        ),
                      ListTile(
                        leading: Icon(
                            Icons.home, color: AppColors.C_others, size: 25),
                        title: Text(
                            AppText.dashboard_m, style: Apptextstyle.s14wnco),
                        onTap: () => Get.to(() => DashboardScreen(deviceID: '')),
                      ),
                      ListTile(
                        leading: Icon(
                            Icons.settings, color: AppColors.C_others, size: 25),
                        title: Text(
                            AppText.set_target, style: Apptextstyle.s14wnco),
                        onTap: () =>
                            Navigator.push(context, MaterialPageRoute(builder: (
                                context) => TargetSetting())),
                      ),

                      // Conditionally show vital ListTiles based on toggle states - USE toggleService from Provider
                      if (toggleService.showBloodPressure)
                        ListTile(
                          leading: Icon(
                              Icons.bloodtype, color: AppColors.C_others, size: 25),
                          title: Text(
                              AppText.BP_heading, style: Apptextstyle.s14wnco),
                          onTap: () =>
                              Get.to(() =>
                                  BloodPressureChartPage(name: widget.name,
                                      email: widget.email,
                                      profile: widget.profile,
                                      noti_count: noti_count)),
                        ),

                      if (toggleService.showHeartRate)
                        ListTile(
                          leading: Icon(
                              Icons.heart_broken, color: AppColors.C_others,
                              size: 25),
                          title: Text(
                              AppText.hr_heading, style: Apptextstyle.s14wnco),
                          onTap: () =>
                              Get.to(() =>
                                  HeartRateChart(name: widget.name,
                                      email: widget.email,
                                      profile: widget.profile,
                                      noti_count: noti_count)),
                        ),

                      if (toggleService.showSteps)
                        ListTile(
                          leading: Icon(Icons.show_chart, color: AppColors.C_others,
                              size: 25),
                          title: Text(
                              AppText.stepscount, style: Apptextstyle.s14wnco),
                          onTap: () =>
                              Get.to(() =>
                                  StepsChartPage(name: widget.name,
                                      email: widget.email,
                                      profile: widget.profile,
                                      noti_count: noti_count)),
                        ),

                      if (toggleService.showSleep)
                        ListTile(
                          leading: Icon(
                              Icons.nightlight_round, color: AppColors.C_others,
                              size: 25),
                          title: Text(AppText.sleep, style: Apptextstyle.s14wnco),
                          onTap: () =>
                              Get.to(() =>
                                  SleepChartPage(name: widget.name,
                                      email: widget.email,
                                      profile: widget.profile,
                                      noti_count: noti_count)),
                        ),

                      if (toggleService.showSpo2)
                        ListTile(
                          leading: Image.asset(
                              Appimages.o2_blood, height: 25, width: 25),
                          title: Text(
                              AppText.spo2_heading, style: Apptextstyle.s14wnco),
                          onTap: () =>
                              Get.to(() =>
                                  BloodoxygenPressureChartPage(name: widget.name,
                                      email: widget.email,
                                      profile: widget.profile,
                                      noti_count: noti_count)),
                        ),

                      if (toggleService.showWeight)
                        ListTile(
                          leading: Icon(Icons.monitor_weight_outlined,
                              color: AppColors.C_others, size: 25),
                          title: Text(
                              AppText.weight_heading, style: Apptextstyle.s14wnco),
                          onTap: () =>
                              Get.to(() =>
                                  WeightChart(name: widget.name,
                                      email: widget.email,
                                      profile: widget.profile,
                                      noti_count: noti_count)),
                        ),

                      ListTile(
                  leading: Icon(Icons.bluetooth_connected,color: AppColors.C_others,size: 25,),
                  title: Text(AppText.unpaired_device,
                    style: Apptextstyle.s14wnco,
                  //   style: TextStyle(
                  //     fontFamily: "Inter",
                  //     color: Color(0xFF505970)
                  // ),
                  ),
                  onTap: () async{

                    if (Platform.isAndroid) {
                      try {

                        final prefs = await SharedPreferences.getInstance();

                        String deviceId = prefs.getString('DeviceId') ?? "";
                        String user_id = prefs.getString('user_id') ?? "";

                        print("Stored DeviceId: $deviceId");
                        print("Stored user_id: $user_id");

                        await ClingBleService.deregisterDevice();


                        await Future.delayed(const Duration(milliseconds: 500));

                        if (deviceId.isEmpty || user_id.isEmpty) {
                          throw Exception("Missing device or user info");
                        }

                        final response = await deregisterDevice(user_id, deviceId);

                        if (response == null) {
                          throw Exception("No response from API");
                        }

                        String status = response['status'] ?? "";
                        String message = response['message'] ?? "";
                        String apiDeviceId =
                        (response['device_id'] ?? "").toString().trim();
                        String apiUserId =
                        (response['user_id'] ?? "").toString().trim();

                        print("API Status: $status | Message: $message");

                        // ❌ FAIL CASE
                        if (status != "SUCCESS" ||
                            apiDeviceId != deviceId.trim() ||
                            apiUserId != user_id.trim()) {

                          // _scaffoldMessengerKey.currentState?.showSnackBar(
                          //   SnackBar(content: Text(message)),
                          // );

                          showCustomToast(message);

                          return;
                        }

                        // // ✅ SUCCESS CASE
                        // _scaffoldMessengerKey.currentState?.showSnackBar(
                        //   SnackBar(content: Text(message)), // "Device deregistered successfully"
                        // );

                        showCustomToast(message);

                        // 🚀 Navigate to pairing screen
                        Get.offAll(() => BluetoothPair());

                        // 🔥 Disconnect BLE
                      } catch (e) {
                        print("Error: $e");

                        // _scaffoldMessengerKey.currentState?.showSnackBar(
                        //   const SnackBar(content: Text("Failed to deregister device")),
                        // );
                        showCustomToast("Failed to deregister device");
                      }
                    }
                  else{
                     _deregisterDevice();
                   }
                  },
                ),
                      ListTile(
                        leading: Icon(
                            Icons.notifications, color: AppColors.C_others,
                            size: 25),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppText.notification_heading, style: Apptextstyle
                                .s14wnco),
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Color(0xFFFF472E),
                              child: Text(widget.noti_count.toString(),
                                  style: TextStyle(
                                      fontFamily: "Inter", color: Colors.white)),
                            )
                          ],
                        ),
                        onTap: () => Get.to(() => Notifications_Screen()),
                      ),

                      ListTile(
                        leading: Icon(
                            Icons.person_4, color: AppColors.C_others, size: 25),
                        title: Text(AppText.profile, style: Apptextstyle.s14wnco),
                        onTap: () => Get.to(() => Profile()),
                      ),

                      ListTile(
                        leading: Icon(
                            Icons.exit_to_app, color: AppColors.C_others, size: 25),
                        title: Text(AppText.logout, style: Apptextstyle.s14wnco),
                        onTap: logoutdialog,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Row(
                      children: [
                        widget.profile == null || widget.profile == " " ||
                            widget.profile == "None" ?
                        GestureDetector(
                          onTap: () => Get.to(() => Profile()),
                          child: CircleAvatar(backgroundImage: AssetImage(
                              Appimages.profilelogo), radius: 25),
                        )
                            : CircleAvatar(
                            backgroundImage: NetworkImage(widget.profile),
                            radius: 20),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${widget.name}",
                                  style: TextStyle(fontFamily: "Inter")),
                              Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.4,
                                child: Text("${widget.email}",
                                    style: TextStyle(fontFamily: "Inter")),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  logoutdialog(){
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              actions: <Widget>[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.20,
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                            child: Center(
                              child: Text("Logout", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Do you want to Logout?", style: TextStyle(fontSize: 17.0, color: Colors.black)),
                                  SizedBox(width: 5),
                                ],
                              ),
                            ),
                          ),
                          Center(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: is_loading
                                  ? const CircularProgressIndicator(color: Colors.red)
                                  : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      setState(() => is_loading = true);
                                      logout_api();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(5.0),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.fromLTRB(20, 4, 20, 4),
                                          child: Row(
                                            children: [
                                              Text("Logout", style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold)),
                                              SizedBox(width: 5),
                                              Icon(Icons.logout, color: Colors.white),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => Get.back(),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          //color: Colors.white,
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(5.0),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.fromLTRB(20, 4, 20, 4),
                                          child: Row(
                                            children: [
                                              Text("Cancel", style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold)),
                                              SizedBox(width: 5),
                                              Icon(Icons.arrow_right_alt_sharp, color: Colors.white),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> logout_api() async {

    await ClingBleService.stopScan();
    // Simulate an app uninstall natively so auto-reconnect breaks securely
    await ClingBleService.clearNativeCache();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    final String Url = "$root/logout";

    final Map<String, dynamic> userData = {'user_id': user_id};
    try {
      final response = await http.post(Uri.parse(Url), body: userData);
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      print("logout_api$jsonResponse");

      if (response.statusCode == 200) {
        if (jsonResponse['status'] == "SUCCESS") {
          print(response.body);
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('isLoggedIn');
          await prefs.remove('DeviceId'); // Clear last stored device ID
          Get.offAll(() => LoginScreen());
          setState(() => is_loading = false);
        } else {
          setState(() => is_loading = false);
          throw Exception('Failed to load Profile');
        }
      }
    } catch (e) {
      print('Error fetching Profile: $e');
    }
  }
}

void showCustomToast(String msg) {
  showToast(
    msg,
    duration: Duration(seconds: 2),
    position: kIsWeb ? ToastPosition.top : ToastPosition.bottom,
    backgroundColor: Colors.black,
    radius: 8.0,
    textPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
    textStyle: TextStyle(
      fontSize: 16.0,
      color: Colors.white,
    ),
    textAlign: TextAlign.center,
    animationCurve: kIsWeb ? Curves.easeInOut : Curves.easeIn,
    animationDuration: const Duration(milliseconds: 400),
    animationBuilder: kIsWeb ? _slideFromRight : null,
  );
}

Widget _slideFromRight(
    BuildContext context,
    Widget child,
    AnimationController controller,
    double percent,
    ) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: Offset(1.2, 0.0), // far right
      end: Offset(-1.2, 0.0),  // f // Slide to original position
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    )),
    child: child,
  );
}