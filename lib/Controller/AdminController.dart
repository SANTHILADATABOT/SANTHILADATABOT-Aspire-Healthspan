import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/Adminmodel.dart';
import '../root/root.dart';

// class ToggleStatusController {
//  // final String _baseUrl = "https://app.aspirehealthspan.ai/aspire_api/";
//
//   Future<ToggleStatusModel?> updateToggleStatus({
//     required String tableType,
//     required String toggleStatus,
//   }) async {
//     final Uri url = Uri.parse("$root/toggle_status");
//
//     try {
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "table_type": tableType,
//           "toggle_status": toggleStatus,
//         }),
//       );
//
//       print("togggle:${response.body}");
//
//       if (response.statusCode == 200) {
//         print("togglevalues:${response.body}");
//         final data = jsonDecode(response.body);
//         return ToggleStatusModel.fromJson(data);
//       } else {
//         print("Server Error: ${response.statusCode}");
//         return null;
//       }
//     } catch (e) {
//       print("Error updating status: $e");
//       return null;
//     }
//   }
// }


// class AdminController {
//   //final String root = "https://app.aspirehealthspan.ai/aspire_api";
//
//   Future<AdminModel?> updateOrFetchStatus({
//     required String tableType,
//     String? toggleStatus, // null = fetch mode
//   }) async {
//     final Uri url = Uri.parse("$root/toggle_status");
//
//     try {
//       // Build body dynamically
//       final Map<String, dynamic> body = {
//         "table_type": tableType,
//       };
//
//       if (toggleStatus != null &&
//           (toggleStatus.toUpperCase() == "ON" || toggleStatus.toUpperCase() == "OFF")) {
//         body["toggle_status"] = toggleStatus;
//       }
//
//       print("📤 Sending body for $tableType → $body");
//
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(body),
//       );
//
//       print("🔄 API Response ($tableType): ${response.body}");
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data["status"] == "SUCCESS") {
//           return AdminModel.fromJson(data);
//         } else {
//           print("⚠️ ${data["message"]}");
//         }
//       } else {
//         print("❌ HTTP ${response.statusCode}");
//       }
//       return null;
//     } catch (e) {
//       print("⚠️ Error for $tableType: $e");
//       return null;
//     }
//   }
//
//   Future<AdminModel?> fetchAllToggles() async {
//     final Uri url = Uri.parse("$root/get_all_toggles");
//
//     print("Fetching all toggle statuses...");
//
//     try {
//       final response = await http.get(
//         url,
//         headers: {"Content-Type": "application/json"},
//       );
//
//       print("🔄 API Response (All Toggles): ${response.body}");
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//
//         if (data["status"] == "SUCCESS") {
//           return AdminModel.fromJson(data);
//         } else {
//           print("Fetch failed: ${data["message"]}");
//         }
//       } else {
//         print("HTTP ${response.statusCode}");
//       }
//
//       return null;
//     } catch (e) {
//       print("Error fetching all toggles: $e");
//       return null;
//     }
//   }
//
//
//
// }




class AdminController {
  //final String root = "https://app.aspirehealthspan.ai/aspire_api";

  Future<AdminModel?> updateOrFetchStatus({
    required String tableType,
    String? toggleStatus, // null = fetch mode
  }) async {
    final Uri url = Uri.parse("$root/toggle_status");

    try {
      final Map<String, dynamic> body = {
        "table_type": tableType,
      };

      if (toggleStatus != null &&
          (toggleStatus.toUpperCase() == "ON" || toggleStatus.toUpperCase() == "OFF")) {
        body["toggle_status"] = toggleStatus;
      }

      print("📤 Sending body for $tableType → $body");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("🔄 API Response ($tableType): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["status"] == "SUCCESS") {
          return AdminModel.fromJson(data);
        } else {
          print("⚠️ ${data["message"]}");
        }
      } else {
        print("❌ HTTP ${response.statusCode}");
      }
      return null;
    } catch (e) {
      print("⚠️ Error for $tableType: $e");
      return null;
    }
  }

  /// 🔵 Fetch ALL toggle statuses from server
  Future<AdminModel?> fetchAllToggles() async {
    final Uri url = Uri.parse("$root/get_all_toggles");

    print("Fetching all toggle statuses...");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
      );

      print("API Response (All Toggles): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["status"] == "SUCCESS") {
          return AdminModel.fromJson(data);
        } else {
          print("Fetch failed: ${data["message"]}");
        }
      } else {
        print("HTTP ${response.statusCode}");
      }

      return null;
    } catch (e) {
      print("Error fetching all toggles: $e");
      return null;
    }
  }
}


