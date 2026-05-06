import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/http/response/attendance_dashboard_info.dart';
import 'package:jd_flutter/utils/web_api.dart';

class AttendanceDashboardState {

  var attendanceDataList = <AttendanceDashboardInfo>[].obs;
  var teamMemberDataList = <TeamMemberInfo>[].obs;
  var teamMemberShowList = <TeamMemberInfo>[].obs;
  var searchTeamMemberText=''.obs;


  void getAttendanceDashboard({
    required int empId,
    required String date,
    required Function(List<AttendanceDashboardInfo>) success,
    required Function(String msg) error,
  }) async {
    springBootGet(
      method: webApiGetAttendanceRecord,
      loading: 'attendance_dashboard_getting_attendance_record'.tr,
      params: {
        'empId': empId,
        'date': date,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call([
          for (var json in response.data) AttendanceDashboardInfo.fromJson(json)
        ]);
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  void getTeamMemberList({
    required int empId,
    required Function(List<TeamMemberInfo>) success,
    required Function(String msg) error,
  }) {
    springBootGet(
      method: webApiGetTeamMemberInfo,
      loading: 'attendance_dashboard_getting_team_member_list'.tr,
      params: {'empId': empId},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call([
          for (var json in response.data) TeamMemberInfo.fromJson(json)
        ]);
      }else {
        error.call(response.message ?? '');
      }
    });
  }
}
