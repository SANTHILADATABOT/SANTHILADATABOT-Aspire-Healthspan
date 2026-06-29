// toggle_service.dart
import 'package:azpire_new/Controller/AdminController.dart';
import 'package:flutter/foundation.dart';

// class ToggleService with ChangeNotifier {
//   static final ToggleService _instance = ToggleService._internal();
//   factory ToggleService() => _instance;
//   ToggleService._internal();
//
//   final AdminController _adminController = AdminController();
//
//   bool _showBloodPressure = true;
//   bool _showHeartRate = true;
//   bool _showSteps = true;
//   bool _showSleep = true;
//   bool _showSpo2 = true;
//   bool _showWeight = true;
//
//   // Getters
//   bool get showBloodPressure => _showBloodPressure;
//   bool get showHeartRate => _showHeartRate;
//   bool get showSteps => _showSteps;
//   bool get showSleep => _showSleep;
//   bool get showSpo2 => _showSpo2;
//   bool get showWeight => _showWeight;
//
//   // Load toggle states from API
//   Future<void> loadToggleStates() async {
//     try {
//       final result = await _adminController.fetchAllToggles();
//
//       if (result != null && result.data.isNotEmpty) {
//         for (final toggle in result.data) {
//           final isOn = toggle.toggleStatus.toUpperCase() == "ON";
//
//           switch (toggle.tableType) {
//             case "BloodPressure":
//               _showBloodPressure = isOn;
//               break;
//             case "HeartRate":
//               _showHeartRate = isOn;
//               break;
//             case "Steps":
//               _showSteps = isOn;
//               break;
//             case "Sleep":
//               _showSleep = isOn;
//               break;
//             case "Spo2":
//               _showSpo2 = isOn;
//               break;
//             case "Weight":
//               _showWeight = isOn;
//               break;
//           }
//         }
//         notifyListeners();
//       }
//     } catch (e) {
//       print("Error loading toggle states: $e");
//     }
//   }
//
//   // Update toggle states (used by AdminScreen)
//   void updateToggleStates({
//     bool? bloodPressure,
//     bool? heartRate,
//     bool? steps,
//     bool? sleep,
//     bool? spo2,
//     bool? weight,
//   }) {
//     _showBloodPressure = bloodPressure ?? _showBloodPressure;
//     _showHeartRate = heartRate ?? _showHeartRate;
//     _showSteps = steps ?? _showSteps;
//     _showSleep = sleep ?? _showSleep;
//     _showSpo2 = spo2 ?? _showSpo2;
//     _showWeight = weight ?? _showWeight;
//     notifyListeners();
//   }
// }


class ToggleService with ChangeNotifier {
  ToggleService();
  // Note: do NOT call loadToggleStates() here in the constructor.
  // notifyListeners() called from an async constructor fires before any
  // Consumer/Provider listener is attached, which causes the
  // "deactivated widget's ancestor" crash.
  // Instead, the Dashboard explicitly calls loadToggleStates() (via _loadFromAPI)
  // only when it is safely mounted.

  bool _disposed = false;

  final AdminController _adminController = AdminController();

  bool _showBloodPressure = false;
  bool _showHeartRate = true;
  bool _showSteps = true;
  bool _showSleep = true;
  bool _showSpo2 = false;
  bool _showWeight = true;

  // Getters
  bool get showBloodPressure => _showBloodPressure;
  bool get showHeartRate => _showHeartRate;
  bool get showSteps => _showSteps;
  bool get showSleep => _showSleep;
  bool get showSpo2 => _showSpo2;
  bool get showWeight => _showWeight;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
  // Load toggle states from API
  Future<void> loadToggleStates() async {
    // ✅ Don't notify after ChangeNotifier is disposed
    if (_disposed) return;
    try {
      final result = await _adminController.fetchAllToggles();

      // ✅ Guard again after await
      if (_disposed) return;

      if (result != null && result.data.isNotEmpty) {
        bool changed = false;

        for (final toggle in result.data) {
          final isOn = toggle.toggleStatus.toUpperCase() == "ON";

          switch (toggle.tableType) {
            case "BloodPressure":
              if (_showBloodPressure != isOn) {
                _showBloodPressure = isOn;
                changed = true;
              }
              break;
            case "HeartRate":
              if (_showHeartRate != isOn) {
                _showHeartRate = isOn;
                changed = true;
              }
              break;
            case "Steps":
              if (_showSteps != isOn) {
                _showSteps = isOn;
                changed = true;
              }
              break;
            case "Sleep":
              if (_showSleep != isOn) {
                _showSleep = isOn;
                changed = true;
              }
              break;
            case "Spo2":
              if (_showSpo2 != isOn) {
                _showSpo2 = isOn;
                changed = true;
              }
              break;
            case "Weight":
              if (_showWeight != isOn) {
                _showWeight = isOn;
                changed = true;
              }
              break;
          }
        }

        if (changed) {
          notifyListeners();
          print("Toggle states updated and listeners notified");
        }
      }
    } catch (e) {
      print("Error loading toggle states: $e");
    }
  }

  // Update toggle states (used by AdminScreen and Dashboard auto-refresh)
  void updateToggleStates({
    bool? bloodPressure,
    bool? heartRate,
    bool? steps,
    bool? sleep,
    bool? spo2,
    bool? weight,
  }) {
    // ✅ Don't notify after ChangeNotifier is disposed
    if (_disposed) return;

    bool changed = false;

    if (bloodPressure != null && _showBloodPressure != bloodPressure) {
      _showBloodPressure = bloodPressure;
      changed = true;
    }
    if (heartRate != null && _showHeartRate != heartRate) {
      _showHeartRate = heartRate;
      changed = true;
    }
    if (steps != null && _showSteps != steps) {
      _showSteps = steps;
      changed = true;
    }
    if (sleep != null && _showSleep != sleep) {
      _showSleep = sleep;
      changed = true;
    }
    if (spo2 != null && _showSpo2 != spo2) {
      _showSpo2 = spo2;
      changed = true;
    }
    if (weight != null && _showWeight != weight) {
      _showWeight = weight;
      changed = true;
    }

    if (changed) {
      notifyListeners();
    }
  }
}