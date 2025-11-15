
import 'package:azpire_new/Controller/ToggleController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminSettings {
  static final AdminSettings _instance = AdminSettings._internal();
  factory AdminSettings() => _instance;
  AdminSettings._internal();

  final ValueNotifier<bool> showBloodPressure = ValueNotifier(false);
  final ValueNotifier<bool> showHeartRate = ValueNotifier(false);
  final ValueNotifier<bool> showSteps = ValueNotifier(false);
  final ValueNotifier<bool> showSleep = ValueNotifier(false);
  final ValueNotifier<bool> showSpo2 = ValueNotifier(false);
  final ValueNotifier<bool> showWeight = ValueNotifier(false);
}

// ✅ MAIN SCREEN
class Adminscreen extends StatefulWidget {
  const Adminscreen({super.key});

  @override
  State<Adminscreen> createState() => _AdminscreenState();
}

class _AdminscreenState extends State<Adminscreen> {
  final settings = AdminSettings();
  final ToggleStatusController _controller = ToggleStatusController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAllStatuses();
  }

  Future<void> saveToggle(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<bool> loadToggle(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  /// 🟡 Fetch all toggle states on startup
  Future<void> _loadAllStatuses() async {
    setState(() => _loading = true);

    List<Map<String, dynamic>> toggles = [
      {"key": settings.showBloodPressure, "name": "BloodPressure"},
      {"key": settings.showHeartRate, "name": "HeartRate"},
      {"key": settings.showSteps, "name": "Steps"},
      {"key": settings.showSleep, "name": "Sleep"},
      {"key": settings.showSpo2, "name": "SPO2"},
      {"key": settings.showWeight, "name": "Weight"},
    ];

    for (var t in toggles) {
      final saved = await loadToggle(t["name"]);
      (t["key"] as ValueNotifier<bool>).value = saved;
    }

    setState(() => _loading = false);
  }




  /// 🟢 Update toggle when switched
  /// When user toggles ON/OFF
  Future<void> _updateStatus(String tableType, bool value) async {
    final toggleStatus = value ? "ON" : "OFF";

    final result = await _controller.updateOrFetchStatus(
      tableType: tableType,
      toggleStatus: toggleStatus, // 👈 update mode
    );

    // if (result != null && result.status == "SUCCESS") {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text("${result.tableType} → ${result.toggleStatus}"),
    //       backgroundColor: Colors.green,
    //     ),
    //   );
    // }
    //
    if (result != null && result.status == "SUCCESS") {
      await saveToggle(tableType, value);
      print("Datavitals:$value");
      print("tablevalues:$tableType");
    }
    else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text("Failed to update $tableType"),
      //     backgroundColor: Colors.red,
      //   ),
      // );
      print("Error to fetch tablevalues:$tableType");
    }
  }


  Widget _buildToggle({
    required String title,
    required String tableType,
    required ValueNotifier<bool> valueNotifier,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: valueNotifier,
      builder: (context, value, _) {
        return ListTile(
          title: Text(title),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value ? "ON" : "OFF",
                style: TextStyle(
                  color: value ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: value,
                onChanged: (val) async {
                  valueNotifier.value = val;
                  await _updateStatus(tableType, val);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
          : ListView(
        children: [
          _buildToggle(
            title: "Blood Pressure",
            tableType: "BloodPressure",
            valueNotifier: settings.showBloodPressure,
          ),
          _buildToggle(
            title: "Heart Rate",
            tableType: "HeartRate",
            valueNotifier: settings.showHeartRate,
          ),
          _buildToggle(
            title: "Steps",
            tableType: "Steps",
            valueNotifier: settings.showSteps,
          ),
          _buildToggle(
            title: "Sleep",
            tableType: "Sleep",
            valueNotifier: settings.showSleep,
          ),
          _buildToggle(
            title: "Blood Oxygen",
            tableType: "SPO2",
            valueNotifier: settings.showSpo2,
          ),
          _buildToggle(
            title: "Weight",
            tableType: "Weight",
            valueNotifier: settings.showWeight,
          ),
        ],
      ),
    );
  }
}


// class _AdminscreenState extends State<Adminscreen> {
//   final settings = AdminSettings();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           title: const Text("Admin Settings"),
//         leading:IconButton(
//           onPressed: (){
//             Get.back();
//           },
//           icon: Icon(Icons.arrow_back_ios),
//         ),
//       ),
//       body: ListView(
//         children: [
//           SwitchListTile(
//             title: const Text("Blood Pressure"),
//             value: settings.showBloodPressure.value,
//             onChanged: (val) {
//               setState(() {
//                 settings.showBloodPressure.value = val;
//               });
//             },
//           ),
//           SwitchListTile(
//             title: const Text("Heart Rate"),
//             value: settings.showHeartRate.value,
//             onChanged: (val) {
//               setState(() {
//                 settings.showHeartRate.value = val;
//               });
//             },
//           ),
//           SwitchListTile(
//             title: const Text("Steps"),
//             value: settings.showSteps.value,
//             onChanged: (val) {
//               setState(() {
//                 settings.showSteps.value = val;
//               });
//             },
//           ),
//           SwitchListTile(
//             title: const Text("Sleep"),
//             value: settings.showSleep.value,
//             onChanged: (val) {
//               setState(() {
//                 settings.showSleep.value = val;
//               });
//             },
//           ),
//           SwitchListTile(
//             title: const Text("SpO2"),
//             value: settings.showSpo2.value,
//             onChanged: (val) {
//               setState(() {
//                 settings.showSpo2.value = val;
//               });
//             },
//           ),
//           SwitchListTile(
//             title: const Text("weight"),
//             value: settings.showweight.value,
//             onChanged: (val) {
//               setState(() {
//                 settings.showweight.value = val;
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }


// class Adminscreen extends StatefulWidget {
//   const Adminscreen({super.key});
//
//   @override
//   State<Adminscreen> createState() => _AdminscreenState();
// }
//
// class _AdminscreenState extends State<Adminscreen> {
//   final settings = AdminSettings();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Admin Settings")),
//       body: ListView(
//         children: [
//           SwitchListTile(
//             title: const Text("Blood Pressure"),
//             value: settings.showBloodPressure.value,
//             onChanged: (val) {
//               settings.showBloodPressure.value = val;
//             },
//           ),
//           SwitchListTile(
//             title: const Text("Heart Rate"),
//             value: settings.showHeartRate.value,
//             onChanged: (val) {
//               setState(() {
//                 settings.showHeartRate.value = val;
//               });
//             },
//           ),
//           SwitchListTile(
//             title: const Text("Steps"),
//             value: settings.showSteps.value,
//             onChanged: (val) {
//               setState(() {
//                 settings.showSteps.value = val;
//
//               });
//             },
//           ),
//           SwitchListTile(
//             title: const Text("Sleep"),
//             value: settings.showSleep.value,
//             onChanged: (val) {
//               setState(() {
//                 settings.showSleep.value = val;
//
//               });
//             },
//           ),
//           SwitchListTile(
//             title: const Text("SpO2"),
//             value: settings.showSpo2.value,
//             onChanged: (val) {
//               setState(() {
//                 settings.showSpo2.value= val;
//
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }






