
import 'package:flutter/material.dart';

class AdminSettings {
  static final AdminSettings _instance = AdminSettings._internal();

  factory AdminSettings() => _instance;

  AdminSettings._internal();

  // Change to ValueNotifier<bool>
  final ValueNotifier<bool> showBloodPressure = ValueNotifier(true);
  final ValueNotifier<bool> showHeartRate = ValueNotifier(true);
  final ValueNotifier<bool> showSteps = ValueNotifier(true);
  final ValueNotifier<bool> showSleep = ValueNotifier(true);
  final ValueNotifier<bool> showSpo2 = ValueNotifier(true);
}






class VitalsData {
  static String bloodPressure = '120/80';
  static String heartRate = '80';
  static String steps = '100';
  static String sleep = '2000';
  static String spo2 = '92';
}

class Adminscreen extends StatefulWidget {
  const Adminscreen({super.key});

  @override
  State<Adminscreen> createState() => _AdminscreenState();
}

class _AdminscreenState extends State<Adminscreen> {
  final settings = AdminSettings();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Settings")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Blood Pressure"),
            value: settings.showBloodPressure.value,
            onChanged: (val) {
              setState(() {
                settings.showBloodPressure.value = val;
              });
            },
          ),
          SwitchListTile(
            title: const Text("Heart Rate"),
            value: settings.showHeartRate.value,
            onChanged: (val) {
              setState(() {
                settings.showHeartRate.value = val;
              });
            },
          ),
          SwitchListTile(
            title: const Text("Steps"),
            value: settings.showSteps.value,
            onChanged: (val) {
              setState(() {
                settings.showSteps.value = val;
              });
            },
          ),
          SwitchListTile(
            title: const Text("Sleep"),
            value: settings.showSleep.value,
            onChanged: (val) {
              setState(() {
                settings.showSleep.value = val;
              });
            },
          ),
          SwitchListTile(
            title: const Text("SpO2"),
            value: settings.showSpo2.value,
            onChanged: (val) {
              setState(() {
                settings.showSpo2.value = val;
              });
            },
          ),
        ],
      ),
    );
  }
}


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






