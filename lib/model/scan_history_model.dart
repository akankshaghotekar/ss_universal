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
      locationSrNo: json['location_srno'],
      clientName: json['client_name'],
      userName: json['user_name'],
      dateTime: DateTime.parse(json['date_time']),
    );
  }
}
