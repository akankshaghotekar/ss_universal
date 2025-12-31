class TaskModel {
  final String taskSrNo;
  final String taskName;

  TaskModel({required this.taskSrNo, required this.taskName});

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      taskSrNo: json['client_task_srno']?.toString() ?? '',
      taskName: json['client_task'] ?? '',
    );
  }
}
