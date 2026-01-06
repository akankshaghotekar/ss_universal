import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ss_universal/model/completed_task_model.dart';
import 'package:ss_universal/model/scan_history_model.dart';
import 'package:ss_universal/model/task_model.dart';
import 'api_config.dart';
import '../model/client_model.dart';

class ApiService {
  /// GENERIC POST REQUEST
  static Future<Map<String, dynamic>> _postRequest(
    String url,
    Map<String, String> params,
  ) async {
    try {
      final response = await http.post(Uri.parse(url), body: params);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'status': 1, 'message': 'Server error'};
      }
    } catch (e) {
      return {'status': 1, 'message': 'Network error'};
    }
  }

  /// SEND OTP
  static Future<Map<String, dynamic>> sendOtp(String mobile) async {
    return await _postRequest(ApiConfig.sendOtpUrl, {'mobile': mobile});
  }

  /// LOGIN WITH OTP
  static Future<Map<String, dynamic>> login({
    required String mobile,
    required String otp,
  }) async {
    return await _postRequest(ApiConfig.loginUrl, {
      'mobile': mobile,
      'otp_entered': otp,
    });
  }

  /// GET CLIENT LIST (POST ONLY)
  static Future<List<ClientModel>> getClientList() async {
    final res = await _postRequest(
      ApiConfig.getClientListUrl,
      {}, // no params but still POST
    );

    if (res['status'] == 0 && res['data'] != null) {
      return (res['data'] as List).map((e) => ClientModel.fromJson(e)).toList();
    }

    return [];
  }

  /// GET TASK LIST BY CLIENT
  static Future<List<TaskModel>> getTaskList({
    required String clientSrNo,
  }) async {
    final res = await _postRequest(ApiConfig.getTaskListUrl, {
      'clientsrno': clientSrNo,
    });

    if (res['status'] == 0 && res['data'] != null) {
      return (res['data'] as List).map((e) => TaskModel.fromJson(e)).toList();
    }

    return [];
  }

  /// GET COMPLETED TASK LIST
  static Future<List<CompletedTaskModel>> getCompletedTaskList({
    required String userSrNo,
    required String date,
  }) async {
    final res = await _postRequest(ApiConfig.getTaskListCompletedUrl, {
      'usersrno': userSrNo,
      'date1': date,
    });

    if (res['status'] == 0 && res['data'] != null) {
      return (res['data'] as List)
          .map((e) => CompletedTaskModel.fromJson(e))
          .toList();
    }

    return [];
  }

  /// MARK ATTENDANCE
  static Future<Map<String, dynamic>> markAttendance({
    required String userSrNo,
  }) async {
    return await _postRequest(ApiConfig.markAttendanceUrl, {
      'usersrno': userSrNo,
    });
  }

  /// DAY LOG OFF
  static Future<Map<String, dynamic>> dayLogOff({
    required String userSrNo,
  }) async {
    return await _postRequest(ApiConfig.dayLogOffUrl, {'usersrno': userSrNo});
  }

  /// SEND LIVE LOCATION
  static Future<Map<String, dynamic>> sendLiveLocation({
    required String userSrNo,
    required String lat,
    required String lng,
    required String batteryPercentage,
  }) async {
    return await _postRequest(ApiConfig.addBdeLocationUrl, {
      'usersrno': userSrNo,
      'lat': lat,
      'lng': lng,
      'battery_percentage': batteryPercentage,
    });
  }

  static Future<Map<String, dynamic>> addCompletedTask({
    required String clientSrNo,
    required String userSrNo,
    required String taskSrNos,
    required File image,
  }) async {
    try {
      final request = http.MultipartRequest(
        "POST",
        Uri.parse(ApiConfig.addCompletedTaskUrl),
      );

      request.fields['clientsrno'] = clientSrNo;
      request.fields['usersrno'] = userSrNo;
      request.fields['client_task_srno'] = taskSrNos;

      request.files.add(await http.MultipartFile.fromPath('img1', image.path));

      final response = await request.send();
      final res = await http.Response.fromStream(response);

      return jsonDecode(res.body);
    } catch (e) {
      return {'status': 1, 'message': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> addBdeLocationQRWithImage({
    required String userSrNo,
    required String clientLocationSrNo,
    required String lat,
    required String lng,
    required String batteryPercentage,
    required File image,
  }) async {
    try {
      final request = http.MultipartRequest(
        "POST",
        Uri.parse(ApiConfig.addBdeLocationQRUrl),
      );

      request.fields['usersrno'] = userSrNo;
      request.fields['client_location_srno'] = clientLocationSrNo;
      request.fields['lat'] = lat;
      request.fields['lng'] = lng;
      request.fields['battery_percentage'] = batteryPercentage;

      request.files.add(await http.MultipartFile.fromPath('img1', image.path));

      final response = await request.send();
      final res = await http.Response.fromStream(response);

      return jsonDecode(res.body);
    } catch (e) {
      return {'status': 1, 'message': 'Network error'};
    }
  }

  static Future<List<ScanHistoryModel>> getScanHistory({
    required String userSrNo,
    required String date,
  }) async {
    final res = await _postRequest(ApiConfig.getBdeLocationQRUrl, {
      'usersrno': userSrNo,
      'date1': date,
    });

    if (res['status'] == 0 && res['data'] != null) {
      return (res['data'] as List)
          .map((e) => ScanHistoryModel.fromJson(e))
          .toList();
    }

    return [];
  }
}
