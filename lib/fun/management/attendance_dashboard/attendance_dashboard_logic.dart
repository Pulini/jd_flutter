import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'attendance_dashboard_state.dart';

class AttendanceDashboardLogic extends GetxController {
  final AttendanceDashboardState state = AttendanceDashboardState();

  void refreshAttendanceData({required void Function() refresh}) {
    refresh.call();
  }

  void searchTeamMember(String text) {
    if (text.isEmpty) {
      state.teamMemberShowList.value = state.teamMemberDataList;
    } else {
      state.teamMemberShowList.value = state.teamMemberDataList
          .where((v) => v.empName!.toLowerCase().contains(text.toLowerCase()))
          .toList();
    }
  }

  void initData({
    required int organizeID,
    required String date,
    required Function() success,
    required Function() error,
  }) {
    getAttendanceDashboard(
      date: date,
      success: (){
        success.call();
        getTeamMemberList();
      },
      error: (){
        error.call();
        getTeamMemberList();
      },
    );
  }

  void getAttendanceDashboard({
    required String date,
    required Function() success,
    required Function() error,
  }) {
    state.getAttendanceDashboard(
      empId: userInfo?.empID ?? 0,
      // empId:4677,
      // empId:256395,
      date: date,
      success: (list) {
        state.attendanceDataList.value = list;
        success.call();
      },
      error: (msg) {
        state.attendanceDataList.value = [];
        errorDialog(content: msg);
        error.call();
      },
    );
  }

  void getTeamMemberList() {
    state.getTeamMemberList(
      empId: userInfo?.empID ?? 0,
      // empId:4677,
      // empId:256395,
      success: (list) {
        final index =
            list.indexWhere((member) => member.empID == (userInfo?.empID ?? 0));
        if (index > 0) {
          final employee = list[index];
          list.removeAt(index);
          list.insert(0, employee);
        }
        state.teamMemberDataList.value = list;
        state.teamMemberShowList.value = list;
      },
      error: (msg) {
        state.teamMemberShowList.value = [];
        errorDialog(content: msg);
      },
    );
  }
}
