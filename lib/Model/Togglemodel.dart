class ToggleStatusModel {
  final String status;
  final String message;
  final String tableType;
  final String toggleStatus;

  ToggleStatusModel({
    required this.status,
    required this.message,
    required this.tableType,
    required this.toggleStatus,
  });

  factory ToggleStatusModel.fromJson(Map<String, dynamic> json) {
    return ToggleStatusModel(
      status: json["status"] ?? "",
      message: json["message"] ?? "",
      tableType: json["table_type"] ?? "",
      toggleStatus: json["toggle_status"] ?? "",
    );
  }
}
