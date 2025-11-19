import 'package:azpire_new/Controller/ToggleController.dart';
import 'package:azpire_new/Controller/target_controller.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:oktoast/oktoast.dart';
import '../utils/appimages.dart';

class TargetSetting extends StatefulWidget {
  const TargetSetting({super.key});

  @override
  State<TargetSetting> createState() => _TargetSettingState();
}

class _TargetSettingState extends State<TargetSetting> {
  final TextEditingController systolicController = TextEditingController();
  final TextEditingController diastolicController = TextEditingController();
  final TextEditingController heartRateController = TextEditingController();
  final TextEditingController stepTargetController = TextEditingController();
  final TextEditingController spo2lowcontroller = TextEditingController();
  final TextEditingController spo2highcontroller = TextEditingController();
  final TextEditingController sleepHourController = TextEditingController();
  final TextEditingController sleepMinuteController = TextEditingController();
  final TextEditingController strideController = TextEditingController();
  final TextEditingController sleepTargetController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();

  Duration sleepDuration = Duration.zero;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _viewtarget();
  }

  void _showSleepDurationPicker() {
    Duration tempDuration = sleepDuration;

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          height: 300,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            children: [
              Expanded(
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  initialTimerDuration: sleepDuration,
                  onTimerDurationChanged: (duration) {
                    tempDuration = duration;
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text("Cancel"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    child: const Text("OK"),
                    onPressed: () {
                      setState(() {
                        sleepDuration = tempDuration;
                        sleepTargetController.text =
                        "${tempDuration.inHours} hr ${tempDuration.inMinutes.remainder(60)} mins";
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _targetsave() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    setState(() => _isSaving = true);

    final parsedSleep = sleepDuration; // You already track this in state

    final targetSleepString =
        "${parsedSleep.inHours} hr ${parsedSleep.inMinutes.remainder(60)} mins";

    final success = await TargetController.saveTarget(
      systolic: systolicController.text,
      diastolic: diastolicController.text,
      heartRate: heartRateController.text,
      steps: stepTargetController.text,
      userId: user_id,
      strideLength: strideController.text,
      targetSleep: targetSleepString,
      targetweight: weightController.text,
      targetBmi: bmiController.text, // ✅ pass here
    );
    setState(() => _isSaving = false);

  }

  Future<void> _viewtarget() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    final response = await TargetController.viewTargetData(userId: user_id);

    if (response != null) {
      final sleepText = response['sleep_target']?.toString() ?? '';

      // Parse duration from the string (e.g., "7 hr 30 mins")
      final regex = RegExp(r'(\d+)\s*hr\s*(\d+)\s*mins');
      final match = regex.firstMatch(sleepText);

      Duration parsedDuration = Duration.zero;
      if (match != null) {
        final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
        final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
        parsedDuration = Duration(hours: hours, minutes: minutes);
      }

      setState(() {
        systolicController.text = response['high_bp_target']?.toString() ?? '';
        diastolicController.text = response['low_bp_target']?.toString() ?? '';
        heartRateController.text = response['hr_target']?.toString() ?? '';
        stepTargetController.text = response['step_target']?.toString() ?? '';
        strideController.text = response['stride_length']?.toString() ?? '';
        weightController.text = response['weight_target']?.toString() ?? '';
        bmiController.text = response['bmi_target']?.toString() ?? '';
        sleepTargetController.text = sleepText;
        sleepDuration = parsedDuration;
        _isLoading = false;
      });
    } else {
      showToast("Unable to fetch target data.");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xff275176);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Set Target",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        foregroundColor: themeColor,
        elevation: 0.5,
      ),
      body: Consumer<ToggleService>(
        builder: (context, toggleService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? Column(
              children: List.generate(4, (index) => _buildShimmerCard()),
            )
                : Form(
              key: _formKey,
              child: Column(
                children: [
                  // Blood Pressure Target (only if enabled)
                  if (toggleService.showBloodPressure)
                    _buildTargetCard(
                      title: "Set Target Blood Pressure",
                      description: "Systolic / Diastolic (mmHg)",
                      children: [
                        Expanded(
                          child: _buildInputField("Systolic", systolicController),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInputField("Diastolic", diastolicController),
                        ),
                      ],
                    ),

                  if (toggleService.showBloodPressure) const SizedBox(height: 16),

                  // Heart Rate Target (only if enabled)
                  if (toggleService.showHeartRate)
                    _buildTargetCard(
                      title: "Set Target Heart Rate",
                      description: "Resting Heart Rate (BPM)",
                      children: [
                        Expanded(
                          child: _buildInputField("Heart Rate", heartRateController),
                        ),
                      ],
                    ),

                  if (toggleService.showHeartRate) const SizedBox(height: 16),

                  // Steps Target (only if enabled)
                  if (toggleService.showSteps)
                    _buildTargetCard(
                      title: "Set Target Steps",
                      description: "Target Steps (nos)",
                      children: [
                        Expanded(
                          child: _buildInputField("Steps", stepTargetController),
                        ),
                      ],
                    ),

                  if (toggleService.showSteps) const SizedBox(height: 16),

                  // Stride Length (always show if steps are enabled, or show separately)
                  if (toggleService.showSteps)
                    _buildTargetCard(
                      title: "Walking Stride Length",
                      description: "Stride Length (In Inches)",
                      children: [
                        Expanded(
                          child: _buildInputField("Stride Length", strideController),
                        ),
                      ],
                    ),

                  if (toggleService.showSteps) const SizedBox(height: 16),

                  // Sleep Target (only if enabled)
                  if (toggleService.showSleep)
                    _buildTargetCard(
                      title: "Set Sleep Target",
                      description: "Duration in Hours and Minutes",
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _showSleepDurationPicker,
                            child: AbsorbPointer(
                              child: TextFormField(
                                controller: sleepTargetController,
                                style: const TextStyle(fontSize: 12),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please select sleep duration';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: "",
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                  contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  suffixIcon: Icon(Icons.access_time),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  if (toggleService.showSleep) const SizedBox(height: 16),

                  // Weight Target (only if enabled)
                  if (toggleService.showWeight)
                    _buildTargetCard(
                      title: "Set Target Weight",
                      description: "Weight in lbs",
                      children: [
                        Expanded(
                          child: _buildInputField("Weight", weightController),
                        ),
                      ],
                    ),

                  if (toggleService.showWeight) const SizedBox(height: 16),

                  // BMI Target (only if enabled)
                  if (toggleService.showWeight)
                    _buildTargetCard(
                      title: "Set Target BMI",
                      description: "BMI (lbs/in²)",
                      children: [
                        Expanded(
                          child: _buildInputField("BMI", bmiController),
                        ),
                      ],
                    ),
                  // Save Button (only show if at least one target is enabled)
                  if (toggleService.showBloodPressure ||
                      toggleService.showHeartRate ||
                      toggleService.showSteps ||
                      toggleService.showSleep ||
                      toggleService.showWeight) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: _isSaving == true
                          ? Center(
                        child: Image.asset(
                          Appimages.applogo,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      )
                          : ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _targetsave();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Save Settings",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTargetCard({
    required String title,
    required String description,
    required List<Widget> children,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xff275176),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Row(children: children),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 12),
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'Please enter a target number';
        }
        if (num.tryParse(val.trim()) == null) {
          return 'Invalid number';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500]),
        contentPadding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

Widget _buildShimmerCard() {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.only(bottom: 16),
    child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 14, width: 120, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Container(height: 10, width: 180, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Container(height: 40, color: Colors.grey[300])),
                const SizedBox(width: 12),
                Expanded(child: Container(height: 40, color: Colors.grey[300])),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

// class _TargetSettingState extends State<TargetSetting> {
//
//   final TextEditingController systolicController = TextEditingController();
//   final TextEditingController diastolicController = TextEditingController();
//   final TextEditingController heartRateController = TextEditingController();
//   final TextEditingController stepTargetController = TextEditingController();
//   final TextEditingController spo2lowcontroller = TextEditingController();
//   final TextEditingController spo2highcontroller = TextEditingController();
//   final TextEditingController sleepHourController = TextEditingController();
//   final TextEditingController sleepMinuteController = TextEditingController();
//   final TextEditingController strideController = TextEditingController();
//   final TextEditingController sleepTargetController = TextEditingController();
//   final TextEditingController weightController = TextEditingController();
//   final TextEditingController BmiController = TextEditingController();
//  // Duration sleepDuration = const Duration(hours: 1, minutes: 0);
//   Duration sleepDuration = Duration.zero;
//
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   bool _isLoading = true;
//   bool _isSaving = false;
//
//
//   @override
//   void initState() {
//     super.initState();
//     _viewtarget();
//
//   }
//
//
//
//   // void _showSleepDurationPicker() async {
//   //   final picked = await showDurationPicker(
//   //     context: context,
//   //     initialTime: sleepDuration,
//   //     //snapToMins: 5,
//   //   );
//   //
//   //   if (picked != null) {
//   //     setState(() {
//   //       sleepDuration = picked;
//   //       sleepTargetController.text =
//   //       "${picked.inHours} hr ${picked.inMinutes.remainder(60)} mins";
//   //     });
//   //   }
//   // }
//
//   void _showSleepDurationPicker() {
//     Duration tempDuration = sleepDuration;
//
//     showModalBottomSheet(
//       context: context,
//       builder: (_) {
//         return Container(
//           height: 300,
//           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//           child: Column(
//             children: [
//               Expanded(
//                 child: CupertinoTimerPicker(
//                   mode: CupertinoTimerPickerMode.hm,
//                   initialTimerDuration: sleepDuration,
//                   onTimerDurationChanged: (duration) {
//                     // ✅ Do NOT setState or update sleepDuration here
//                     debugPrint("Picker changed: $duration");
//                     tempDuration = duration;
//                   },
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   TextButton(
//                     child: const Text("Cancel"),
//                     onPressed: () {
//                       Navigator.pop(context); // just close
//                     },
//                   ),
//                   const SizedBox(width: 10),
//                   ElevatedButton(
//                     child: const Text("OK"),
//                     onPressed: () {
//                       setState(() {
//                         // ✅ Only update when user presses OK
//                         sleepDuration = tempDuration;
//                         sleepTargetController.text =
//                         "${tempDuration.inHours} hr ${tempDuration.inMinutes.remainder(60)} mins";
//                       });
//                       Navigator.pop(context); // close picker
//                     },
//                   ),
//                 ],
//               )
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//
//
//   Future<void> _targetsave() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     var user_id = prefs.getString('user_id') ?? "";
//     setState(() => _isSaving = true);
//
//     final parsedSleep = sleepDuration; // You already track this in state
//
//     final targetSleepString =
//         "${parsedSleep.inHours} hr ${parsedSleep.inMinutes.remainder(60)} mins";
//
//     final success = await TargetController.saveTarget(
//       systolic: systolicController.text,
//       diastolic: diastolicController.text,
//       heartRate: heartRateController.text,
//       steps: stepTargetController.text,
//       userId: user_id,
//       strideLength: strideController.text,
//       targetSleep: targetSleepString,
//       targetweight: weightController.text,
//       targetBmi: BmiController.text, // ✅ pass here
//     );
//     setState(() => _isSaving = false);
//
//   }
//
//   Future<void> _viewtarget() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     var user_id = prefs.getString('user_id') ?? "";
//     final response = await TargetController.viewTargetData(userId: user_id);
//
//     if (response != null) {
//       final sleepText = response['sleep_target']?.toString() ?? '';
//
//       // Parse duration from the string (e.g., "7 hr 30 mins")
//       final regex = RegExp(r'(\d+)\s*hr\s*(\d+)\s*mins');
//       final match = regex.firstMatch(sleepText);
//
//       Duration parsedDuration = Duration.zero;
//       if (match != null) {
//         final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
//         final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
//         parsedDuration = Duration(hours: hours, minutes: minutes);
//       }
//
//       setState(() {
//         systolicController.text = response['high_bp_target']?.toString() ?? '';
//         diastolicController.text = response['low_bp_target']?.toString() ?? '';
//         heartRateController.text = response['hr_target']?.toString() ?? '';
//         stepTargetController.text = response['step_target']?.toString() ?? '';
//         strideController.text = response['stride_length']?.toString() ?? '';
//         weightController.text = response['weight_target']?.toString() ?? '';
//         BmiController.text = response['bmi_target']?.toString() ?? '';
//         sleepTargetController.text = sleepText;
//         stepTargetController.text = response['step_target']?.toString() ?? '';
//         sleepDuration = parsedDuration; // ✅ assign parsed duration
//         _isLoading = false;
//       });
//     } else {
//       showToast("Unable to fetch target data.");
//       setState(() => _isLoading = false);
//     }
//   }
//
//
//   // Future<void> _viewtarget() async {
//   //   final response = await TargetController.viewTargetData(userId: '102');
//   //
//   //   if (response != null) {
//   //     setState(() {
//   //       systolicController.text = response['high_bp_target']?.toString() ?? '';
//   //       diastolicController.text = response['low_bp_target']?.toString() ?? '';
//   //       heartRateController.text = response['hr_target']?.toString() ?? '';
//   //       stepTargetController.text = response['step_target']?.toString() ?? '';
//   //       strideController.text = response['stride_length']?.toString() ?? '';
//   //       sleepTargetController.text = response['sleep_target']?.toString() ?? '';
//   //       _isLoading = false; // ✅ Done loading
//   //     });
//   //   } else {
//   //     showToast("Unable to fetch target data.");
//   //     setState(() => _isLoading = false); // Still stop shimmer
//   //   }
//   // }
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     final themeColor = const Color(0xff275176);
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//       title:  Text(
//           "Set Target",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios),
//           onPressed: () => Get.back(),
//         ),
//         backgroundColor: Colors.white,
//         foregroundColor: themeColor,
//         elevation: 0.5,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child:_isLoading
//             ? Column(
//           children: List.generate(4, (index) => _buildShimmerCard()),
//         )
//           : Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 _buildTargetCard(
//                   title: "Set Target Blood Pressure",
//                   description: "Systolic / Diastolic (mmHg)",
//                   children: [
//                     Expanded(
//                       child: _buildInputField("Systolic", systolicController),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: _buildInputField("Diastolic", diastolicController),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 _buildTargetCard(
//                   title: "Set Target Heart Rate",
//                   description: "Resting Heart Rate (BPM)",
//                   children: [
//                     Expanded(
//                       child: _buildInputField("Heart Rate", heartRateController),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 _buildTargetCard(
//                   title: "Set Target Steps",
//                   description: "Target Steps (nos)",
//                   children: [
//                     Expanded(
//                       child: _buildInputField("Steps", stepTargetController),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 _buildTargetCard(
//                   title: "Walking Stride Length",
//                   description: " Stride Length (In Inches)",
//                   children: [
//                     Expanded(
//                       child: _buildInputField("Stride Length", strideController),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 _buildTargetCard(
//                   title: "Set Sleep Target",
//                   description: "Duration in Hours and Minutes",
//                   children: [
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: _showSleepDurationPicker,
//                         child: AbsorbPointer(
//                           child: TextFormField(
//                             controller: sleepTargetController,
//                             style: const TextStyle(fontSize: 12),
//                             validator: (val) {
//                               if (val == null || val.trim().isEmpty) {
//                                 return 'Please select sleep duration';
//                               }
//                               return null;
//                             },
//                             decoration: InputDecoration(
//                               hintText: "",
//                               hintStyle: TextStyle(color: Colors.grey[500]),
//                               contentPadding:
//                               const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
//                               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                               suffixIcon: Icon(Icons.access_time),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 _buildTargetCard(
//                   title: "Set Target Weight",
//                   description: "Weight in lbs",
//                   children: [
//                     Expanded(
//                       child: _buildInputField("Weight", weightController),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 _buildTargetCard(
//                   title: "Set Target BMI",
//                   description: "BMI (lbs/in\u00b2)",
//                   children: [
//                     Expanded(
//                       child: _buildInputField("BMI", BmiController),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//                 SizedBox(
//                   width: double.infinity,
//                   child:_isSaving == true? Center(child: Image.asset(
//                     Appimages.applogo,
//                     height: 50,
//                     fit: BoxFit.contain,
//                   ),) : ElevatedButton(
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         _targetsave();
//                       }
//                       // } else {
//                       //   //Get.snackbar("Invalid Input", "Please correct the highlighted fields.");
//                       // }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: themeColor,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text("Save Settings", style: TextStyle(fontSize: 16, color: Colors.white)),
//
//                   ),
//                 )
//
//               ],
//             ),
//           ),
//         ),
//       );
//   }
//
//   Widget _buildTargetCard({
//     required String title,
//     required String description,
//     required List<Widget> children,
//   }) {
//     return Card(
//       color: Colors.white,
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text(title,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xff275176))),
//           const SizedBox(height: 6),
//           Text(description, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
//           const SizedBox(height: 12),
//           Row(children: children),
//         ]),
//       ),
//     );
//   }
//
//   Widget _buildInputField(String hint, TextEditingController controller) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: TextInputType.number,
//       style: const TextStyle(fontSize: 12),
//       validator: (val) {
//         if (val == null || val.trim().isEmpty) {
//           return 'Please enter a target number';
//         }
//         if (num.tryParse(val.trim()) == null) {
//           return 'Invalid number';
//         }
//         return null;
//       },
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: TextStyle(color: Colors.grey[500]),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     );
//   }
// }
//
// Widget _buildShimmerCard() {
//   return Card(
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     margin: const EdgeInsets.only(bottom: 16),
//     child: Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Container(height: 14, width: 120, color: Colors.grey[300]),
//           const SizedBox(height: 8),
//           Container(height: 10, width: 180, color: Colors.grey[300]),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(child: Container(height: 40, color: Colors.grey[300])),
//               const SizedBox(width: 12),
//               Expanded(child: Container(height: 40, color: Colors.grey[300])),
//             ],
//           ),
//         ]),
//       ),
//     ),
//   );
// }


