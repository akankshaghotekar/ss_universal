class CompletedTaskModel {
  final String taskCompletedSrNo;
  final String clientName;
  final String userName;
  final String taskName;
  final String date;

  CompletedTaskModel({
    required this.taskCompletedSrNo,
    required this.clientName,
    required this.userName,
    required this.taskName,
    required this.date,
  });

  factory CompletedTaskModel.fromJson(Map<String, dynamic> json) {
    return CompletedTaskModel(
      taskCompletedSrNo: json['client_task_completed_srno']?.toString() ?? '',
      clientName: json['client_name'] ?? '',
      userName: json['user_name'] ?? '',
      taskName: json['client_task'] ?? '',
      date: json['date1'] ?? '',
    );
  }
}
