

import 'dart:convert';

import 'package:azpire_new/Model/pairdevice_model.dart';
import 'package:azpire_new/root/root.dart';
import 'package:http/http.dart' as http;


// Future<Map<String, dynamic>?> pairDevice(String userId, String deviceId) async {
//   final String url = "http://192.168.1.48:8000/aspire_api/pair_device";
//   print('URL: $url');
//
//   final Map<String, dynamic> requestBody = {
//     'user_id': userId,
//     'device_id': deviceId,
//   };
//
//   try {
//     final response = await http.post(
//       Uri.parse(url),
//       body: requestBody,
//     );
//
//     print('userId: $userId');
//     print('deviceId: $deviceId');
//     print('pair_device_api: ${response.body}');
//
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> jsonResponse = json.decode(response.body);
//       print('JsonResponse: $jsonResponse');
//
//       if (jsonResponse['status'] == "SUCCESS") {
//         return jsonResponse;
//       } else {
//         throw Exception(jsonResponse['message'] ?? 'Pairing failed');
//       }
//     } else {
//       throw Exception('HTTP Error: ${response.statusCode}');
//     }
//   } catch (e) {
//     print('Error pairing device: $e');
//     return null;
//   }
// }

Future<Map<String, dynamic>?> pairDevice(String userId, String deviceId) async {
  final String url = "$root/pair_device";

  try {
    final response = await http.post(
      Uri.parse(url),
      body: {
        'user_id': userId,
        'device_id': deviceId,
      },
    );

    print('pair_device_api: ${response.body}');

    final jsonResponse = json.decode(response.body);

    // ✅ attach statusCode also
    jsonResponse['statusCode'] = response.statusCode;

    return jsonResponse;

  } catch (e) {
    print('Error pairing device: $e');
    return null;
  }
}


Future<Map<String, dynamic>?> deregisterDevice(
    String userId, String deviceId) async {

  final String url = "$root/deregister_device";

  print('URL: $url');

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json", // ✅ IMPORTANT
      },
      body: json.encode({
        'user_id': userId,
        'device_id': deviceId,
      }),
    );

    print('deviceId: $deviceId');
    print('userId: $userId');
    print('deregister_device_api: ${response.body}');

    final jsonResponse = json.decode(response.body);

    // ✅ attach statusCode
    jsonResponse['statusCode'] = response.statusCode;

    return jsonResponse;

  } catch (e) {
    print('Error deregistering device: $e');
    return null;
  }
}




// Future<PairDeviceResponse?> pairDevice(String userId, String deviceId) async {
//   const String url = "http://192.168.1.48:8000/aspire_api/pair_device";
//
//   try {
//     final response = await http.post(
//       Uri.parse(url),
//       body: {
//         'user_id': userId,
//         'device_id': deviceId,
//       },
//     );
//
//     print('pair_device_api: ${response.body}');
//
//     if (response.statusCode == 200) {
//       print("Paired_device:${response.body}");
//       final jsonResponse = json.decode(response.body);
//       return PairDeviceResponse.fromJson(jsonResponse);
//     } else {
//       throw Exception('HTTP Error: ${response.statusCode} ${response.body}');
//     }
//   } catch (e) {
//     print('Error pairing device: $e');
//     return null;
//   }
// }