
import 'package:azpire_new/Controller/AdminController.dart';
import 'package:azpire_new/Controller/ToggleController.dart';
import 'package:azpire_new/View/Dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_color.dart';
import '../utils/appimages.dart';
import '../utils/apptext.dart';
import '../utils/apptextstyle.dart';
import '../widgets/custom_button/My_Button.dart';


// class AdminSettings {
//   static final AdminSettings _instance = AdminSettings._internal();
//   factory AdminSettings() => _instance;
//   AdminSettings._internal();
//
//   final ValueNotifier<bool> showBloodPressure = ValueNotifier(true);
//   final ValueNotifier<bool> showHeartRate = ValueNotifier(true);
//   final ValueNotifier<bool> showSteps = ValueNotifier(true);
//   final ValueNotifier<bool> showSleep = ValueNotifier(true);
//   final ValueNotifier<bool> showSpo2 = ValueNotifier(true);
//   final ValueNotifier<bool> showWeight = ValueNotifier(true);
// }

class Adminscreen extends StatefulWidget {
  const Adminscreen({super.key});

  @override
  State<Adminscreen> createState() => _AdminscreenState();
}

class _AdminscreenState extends State<Adminscreen> {
  //final settings = AdminSettings();
  final AdminController _controller = AdminController();
  bool _loading = true;
  bool _submitting = false;
  final ToggleService _toggleService = ToggleService();

  // Local state for each toggle
  bool _bloodPressure = false;
  bool _heartRate = false;
  bool _steps = false;
  bool _sleep = false;
  bool _spo2 = false;
  bool _weight = false;

  @override
  void initState() {
    super.initState();
    _loadFromAPI();
  }

  // Future<void> _loadFromAPI() async {
  //   setState(() => _loading = true);
  //   final result = await _controller.fetchAllToggles();
  //
  //   if (result != null && result.data.isNotEmpty) {
  //     for (final toggle in result.data) {
  //       final isOn = toggle.toggleStatus.toUpperCase() == "ON";
  //       switch (toggle.tableType) {
  //         case "BloodPressure":
  //           settings.showBloodPressure.value = isOn;
  //           _bloodPressure = isOn;
  //           break;
  //         case "HeartRate":
  //           settings.showHeartRate.value = isOn;
  //           _heartRate = isOn;
  //           break;
  //         case "Steps":
  //           settings.showSteps.value = isOn;
  //           _steps = isOn;
  //           break;
  //         case "Sleep":
  //           settings.showSleep.value = isOn;
  //           _sleep = isOn;
  //           break;
  //         case "Spo2":
  //           settings.showSpo2.value = isOn;
  //           _spo2 = isOn;
  //           break;
  //         case "Weight":
  //           settings.showWeight.value = isOn;
  //           _weight = isOn;
  //           break;
  //       }
  //     }
  //   }
  //   setState(() => _loading = false);
  // }

  Future<void> _loadFromAPI() async {
    setState(() => _loading = true);
    final result = await _controller.fetchAllToggles();

    if (result != null && result.data.isNotEmpty) {
      for (final toggle in result.data) {
        final isOn = toggle.toggleStatus.toUpperCase() == "ON";
        switch (toggle.tableType) {
          case "BloodPressure":
            _bloodPressure = isOn;
            break;
          case "HeartRate":
            _heartRate = isOn;
            break;
          case "Steps":
            _steps = isOn;
            break;
          case "Sleep":
            _sleep = isOn;
            break;
          case "Spo2":
            _spo2 = isOn;
            break;
          case "Weight":
            _weight = isOn;
            break;
        }
      }
    }
    setState(() => _loading = false);
  }


  // Future<void> _submitAllToggles() async {
  //   if (!mounted) return;
  //   setState(() => _submitting = true);
  //
  //   final Map<String, bool> allToggleValues = {
  //     "BloodPressure": _bloodPressure,
  //     "HeartRate": _heartRate,
  //     "Steps": _steps,
  //     "Sleep": _sleep,
  //     "Spo2": _spo2,
  //     "Weight": _weight,
  //   };
  //
  //   bool allSuccessful = true;
  //
  //   for (final entry in allToggleValues.entries) {
  //     final result = await _controller.updateOrFetchStatus(
  //       tableType: entry.key,
  //       toggleStatus: entry.value ? "ON" : "OFF",
  //     );
  //
  //     if (result == null || result.status != "SUCCESS") {
  //       allSuccessful = false;
  //       print("Failed to update ${entry.key}");
  //     } else {
  //       print("Updated ${entry.key} → ${entry.value ? "ON" : "OFF"}");
  //       // Update the settings only after successful API call
  //       switch (entry.key) {
  //         case "BloodPressure": settings.showBloodPressure.value = entry.value; break;
  //         case "HeartRate": settings.showHeartRate.value = entry.value; break;
  //         case "Steps": settings.showSteps.value = entry.value; break;
  //         case "Sleep": settings.showSleep.value = entry.value; break;
  //         case "Spo2": settings.showSpo2.value = entry.value; break;
  //         case "Weight": settings.showWeight.value = entry.value; break;
  //       }
  //     }
  //   }
  //
  //   if (!mounted) return;
  //   setState(() => _submitting = false);
  //
  //   if (allSuccessful) {
  //     // Fluttertoast.showToast(
  //     //   msg: "Successfully updated Vitals",
  //     //   toastLength: Toast.LENGTH_SHORT,
  //     //   gravity: ToastGravity.BOTTOM,
  //     //   backgroundColor: Colors.black,
  //     //   textColor: Colors.white,
  //     // );
  //
  //     // Notify ToggleService to update all listeners
  //     _toggleService.updateToggleStates(
  //       bloodPressure: _bloodPressure,
  //       heartRate: _heartRate,
  //       steps: _steps,
  //       sleep: _sleep,
  //       spo2: _spo2,
  //       weight: _weight,
  //     );
  //
  //     Get.to(() => DashboardScreen(deviceID: ''));
  //   } else {
  //     Fluttertoast.showToast(
  //       msg: "updates failed. Please try again.",
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.BOTTOM,
  //       backgroundColor: Colors.red,
  //       textColor: Colors.white,
  //     );
  //   }
  // }

  Future<void> _submitAllToggles() async {
    if (!mounted) return;
    setState(() => _submitting = true);

    final Map<String, bool> allToggleValues = {
      "BloodPressure": _bloodPressure,
      "HeartRate": _heartRate,
      "Steps": _steps,
      "Sleep": _sleep,
      "Spo2": _spo2,
      "Weight": _weight,
    };

    bool allSuccessful = true;

    for (final entry in allToggleValues.entries) {
      final result = await _controller.updateOrFetchStatus(
        tableType: entry.key,
        toggleStatus: entry.value ? "ON" : "OFF",
      );

      if (result == null || result.status != "SUCCESS") {
        allSuccessful = false;
        print("Failed to update ${entry.key}");
      } else {
        print("Updated ${entry.key} → ${entry.value ? "ON" : "OFF"}");
      }
    }

    if (!mounted) return;
    setState(() => _submitting = false);

    if (allSuccessful) {
      // Get ToggleService from context and update it
      final toggleService = Provider.of<ToggleService>(context, listen: false);
      toggleService.updateToggleStates(
        bloodPressure: _bloodPressure,
        heartRate: _heartRate,
        steps: _steps,
        sleep: _sleep,
        spo2: _spo2,
        weight: _weight,
      );
      // Show success message
      Get.to(() => DashboardScreen(deviceID: ''));
    } else {
      Fluttertoast.showToast(
        msg: "updates failed. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Widget _buildToggle({
    required String title,
    required String tableType,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value ? "ON" : "OFF",
            style: TextStyle(
              color: value ? Colors.green : Colors.red,
              // fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: _submitting ? null : onChanged, // Disable during submission
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xFFffffff),
      appBar: AppBar(
        title: const Text("Admin Settings"),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: Color(0xFFffffff),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildToggle(
                  title: "Blood Pressure",
                  tableType: "BloodPressure",
                  value: _bloodPressure,
                  onChanged: (val) => setState(() => _bloodPressure = val),
                ),
                _buildToggle(
                  title: "Heart Rate",
                  tableType: "HeartRate",
                  value: _heartRate,
                  onChanged: (val) => setState(() => _heartRate = val),
                ),
                _buildToggle(
                  title: "Steps",
                  tableType: "Steps",
                  value: _steps,
                  onChanged: (val) => setState(() => _steps = val),
                ),
                _buildToggle(
                  title: "Sleep",
                  tableType: "Sleep",
                  value: _sleep,
                  onChanged: (val) => setState(() => _sleep = val),
                ),
                _buildToggle(
                  title: "Blood Oxygen",
                  tableType: "Spo2",
                  value: _spo2,
                  onChanged: (val) => setState(() => _spo2 = val),
                ),
                _buildToggle(
                  title: "Weight",
                  tableType: "Weight",
                  value: _weight,
                  onChanged: (val) => setState(() => _weight = val),
                ),
                SizedBox(height: 20),
                _submitting
                    ? Center(
                  child: Image.asset(
                    Appimages.applogo,
                    height: size.height * 0.07,
                    fit: BoxFit.contain,
                  ),
                )
                    : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MyButton(
                      press: _submitAllToggles,
                      text: AppText.SUBMIT,
                    )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}








