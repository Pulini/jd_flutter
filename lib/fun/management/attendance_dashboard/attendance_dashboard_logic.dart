import 'package:get/get.dart';

import 'attendance_dashboard_state.dart';

class AttendanceDashboardLogic extends GetxController {
  final AttendanceDashboardState state = AttendanceDashboardState();

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  void refreshAttendanceData({required void Function() refresh}) {
    refresh.call();
  }
}
