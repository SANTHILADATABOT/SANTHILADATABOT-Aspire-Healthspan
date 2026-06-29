class PairDeviceResponse {
  final String status;
  final String message;

  PairDeviceResponse({
    required this.status,
    required this.message,
  });

  factory PairDeviceResponse.fromJson(Map<String, dynamic> json) {
    return PairDeviceResponse(
      status: json['status'],
      message: json['message'],
    );
  }
}