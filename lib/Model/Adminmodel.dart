// class AdminModel {
//   final String status;
//   final String message;
//   final String tableType;
//   final String toggleStatus;
//
//   AdminModel({
//     required this.status,
//     required this.message,
//     required this.tableType,
//     required this.toggleStatus,
//   });
//
//   factory AdminModel.fromJson(Map<String, dynamic> json) {
//     return AdminModel(
//       status: json["status"] ?? "",
//       message: json["message"] ?? "",
//       tableType: json["table_type"] ?? "",
//       toggleStatus: json["toggle_status"] ?? "",
//     );
//   }
// }

// Model for individual toggle
class ToggleItem {
  final int id;
  final String tableType;
  final String toggleStatus;

  ToggleItem({
    required this.id,
    required this.tableType,
    required this.toggleStatus,
  });

  factory ToggleItem.fromJson(Map<String, dynamic> json) {
    return ToggleItem(
      id: json["id"] ?? 0,
      tableType: json["table_type"] ?? "",
      toggleStatus: (json["toggle_status"] ?? "").trim(), // Trim the spaces
    );
  }
}

// Model for the API response
class AdminModel {
  final String status;
  final String message;
  final List<ToggleItem> data;

  AdminModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    List<ToggleItem> data = [];
    if (json["data"] != null && json["data"] is List) {
      data = (json["data"] as List)
          .map((item) => ToggleItem.fromJson(item))
          .toList();
    }

    return AdminModel(
      status: json["status"] ?? "",
      message: json["message"] ?? "",
      data: data,
    );
  }
}