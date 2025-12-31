class ApiConfig {
  static const String baseUrl = "https://digitalspaceinc.com/ssuniversal/ws/";

  static String get sendOtpUrl => "${baseUrl}sendotp.php";
  static String get loginUrl => "${baseUrl}login.php";
  static String get getClientListUrl => "${baseUrl}getClientList.php";
  static String get getTaskListUrl => "${baseUrl}getTaskList.php";
  static String get getTaskListCompletedUrl =>
      "${baseUrl}getTaskListCompleted.php";
  static String get markAttendanceUrl => "${baseUrl}markAttendance.php";

  static String get dayLogOffUrl => "${baseUrl}dayLogOff.php";

  static String get addBdeLocationUrl => "${baseUrl}addBdeLocation.php";
  static String get addCompletedTaskUrl => "${baseUrl}addCompletedTask.php";
}
