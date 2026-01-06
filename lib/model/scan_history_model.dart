class ScanHistoryModel {
  final String locationSrNo;
  final String clientName;
  final String userName;
  final DateTime dateTime;

  ScanHistoryModel({
    required this.locationSrNo,
    required this.clientName,
    required this.userName,
    required this.dateTime,
  });

  factory ScanHistoryModel.fromJson(Map<String, dynamic> json) {
    return ScanHistoryModel(
      locationSrNo: json['location_srno']?.toString() ?? '',
      clientName: json['client_name']?.toString() ?? 'Unknown Client',
      userName: json['user_name']?.toString() ?? 'Unknown User',
      dateTime: json['date_time'] != null
          ? DateTime.parse(json['date_time'])
          : DateTime.now(),
    );
  }
}
