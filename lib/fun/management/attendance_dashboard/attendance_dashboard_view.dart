import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/attendance_dashboard_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

import 'attendance_dashboard_logic.dart';
import 'attendance_dashboard_state.dart';

class AttendanceDashboardPage extends StatefulWidget {
  const AttendanceDashboardPage({super.key});

  @override
  State<AttendanceDashboardPage> createState() =>
      _AttendanceDashboardPageState();
}

class _AttendanceDashboardPageState extends State<AttendanceDashboardPage>
    with TickerProviderStateMixin {
  final AttendanceDashboardLogic logic = Get.put(AttendanceDashboardLogic());
  final AttendanceDashboardState state =
      Get.find<AttendanceDashboardLogic>().state;

  var refreshController = EasyRefreshController(controlFinishRefresh: true);
  var opcOrganization = OptionsPickerController(PickerType.mesOrganization);
  var dpAttendanceDay =
      DatePickerController(PickerType.date, lastDate: DateTime.now());

  @override
  Widget build(BuildContext context) {
    return pageBody(
        actions: [
          SizedBox(
            width: 200,
            child: DatePicker(pickerController: dpAttendanceDay),
          ),
        ],
        body: Column(
          children: [
            OptionsPicker(pickerController: opcOrganization),
            Expanded(
              child: Obx(() => EasyRefresh(
                    controller: refreshController,
                    header: const MaterialHeader(),
                    onRefresh: () => logic.refreshAttendanceData(
                      refresh: () => refreshController.finishRefresh(),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: state.attendanceDataList.length,
                      itemBuilder: (c, i) => AttendanceDashboardItem(
                        data: state.attendanceDataList[i],
                      ),
                    ),
                  )),
            )
          ],
        ));
  }

  @override
  void dispose() {
    Get.delete<AttendanceDashboardLogic>();
    super.dispose();
  }
}

class AttendanceDashboardItem extends StatefulWidget {
  const AttendanceDashboardItem({super.key, required this.data});

  final AttendanceDashboardInfo data;

  @override
  State<AttendanceDashboardItem> createState() =>
      _AttendanceDashboardItemState();
}

class _AttendanceDashboardItemState extends State<AttendanceDashboardItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
    value: 0,
  );
  late final Animation<double> animation = Tween<double>(
    begin: 0.0,
    end: 0.5,
  ).animate(CurvedAnimation(
    parent: animationController,
    curve: Curves.easeInOut,
  ));

  var tsSmallLightGrey = const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: Colors.grey,
  );

  Widget _percentProgress({
    required double max,
    required double value,
  }) {
    var percent = (value.div(max).toStringAsFixed(3)).toDoubleTry();
    return Container(
      padding: EdgeInsetsGeometry.only(left: 5, right: 5),
      height: 15,
      child: Stack(
        children: [
          Positioned(
            top: 2,
            bottom: 2,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              borderRadius: const BorderRadius.all(Radius.circular(100)),
              value: percent,
              backgroundColor: Colors.grey.shade300,
              color: Colors.blue.shade200,
            ),
          ),
          Center(
            child: Text(
              '${percent.mul(100).toShowString()}%',
              style: TextStyle(
                height: 1,
                color: Colors.black87,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(String text1, String text2) => Expanded(
        child: Container(
          padding: EdgeInsetsGeometry.all(5),
          margin: EdgeInsetsGeometry.all(5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.blue.shade50],
            ),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(text1),
              Text(text2, style: tsSmallLightGrey),
            ],
          ),
        ),
      );
  late var cardList1 = SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: ReverseAnimation(animationController),
      curve: Curves.easeInOut,
    )),
    child: SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: ReverseAnimation(animationController),
        curve: Curves.easeInOut,
      ),
      axisAlignment: -1,
      axis: Axis.horizontal,
      child: Row(
        children: [
          _itemCard(
            widget.data.lateOrEarlyCount.toString(),
            '迟到',
          ),
          _itemCard(
            widget.data.leaveTotal.toShowString(),
            '请假',
          ),
          _itemCard(
            widget.data.publicHoliday.toShowString(),
            '公休',
          ),
        ],
      ),
    ),
  );

  late var cardList2 = SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    )),
    child: SizeTransition(
      sizeFactor:
          animationController.drive(CurveTween(curve: Curves.easeInOut)),
      axisAlignment: -1,
      axis: Axis.horizontal,
      child: Row(
        children: [
          _itemCard(
            widget.data.casualLeave.toShowString(),
            '事假',
          ),
          _itemCard(
            widget.data.sickLeave.toShowString(),
            '病假',
          ),
          _itemCard(
            widget.data.workInjury.toShowString(),
            '工伤',
          ),
          _itemCard(
            widget.data.marriageLeave.toShowString(),
            '婚假',
          ),
          _itemCard(
            widget.data.maternityLeave.toShowString(),
            '产假',
          ),
          _itemCard(
            widget.data.funeralLeave.toShowString(),
            '丧假',
          ),
        ],
      ),
    ),
  );

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.data.departmentName ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(children: [
                Text(
                  widget.data.totalEmployees.toString(),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text('总人数', style: tsSmallLightGrey),
                SizedBox(height: 2),
              ]),
              Expanded(
                child: _percentProgress(
                  max: widget.data.totalEmployees!.toDouble(),
                  value: widget.data.attendanceCount!.toDouble(),
                ),
              ),
              Column(children: [
                Text(
                  widget.data.attendanceCount.toString(),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text('出勤数', style: tsSmallLightGrey),
                SizedBox(height: 2),
              ])
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: ClipRect(
                  child: Stack(
                    children: [
                      cardList1,
                      cardList2,
                    ],
                  ),
                ),
              ),
              RotationTransition(
                turns: animation,
                child: IconButton(
                  onPressed: () {
                    if (animationController.status ==
                        AnimationStatus.completed) {
                      animationController.reverse();
                    } else {
                      animationController.forward();
                    }
                  },
                  icon: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
