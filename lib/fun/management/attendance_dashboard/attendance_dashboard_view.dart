import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
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

  late var tabController = TabController(length: 2, vsync: this);
  var pageController = PageController();
  var refreshController = EasyRefreshController(controlFinishRefresh: true);
  var opcOrganization = OptionsPickerController(PickerType.mesOrganization);
  var dpAttendanceDay = DatePickerController(
    PickerType.date,
    lastDate: DateTime.now(),
  );
  var controller = TextEditingController();

  Widget _teamMemberInfoItem(TeamMemberInfo data) => Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(100),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(100),
            bottomRight: Radius.circular(100),
          ),
        ),
        child: Row(
          children: [
            Expanded(
                flex: 2, child: avatarPhoto(data.photo, borderRadius: 100)),
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '(${data.empNumber}) ${data.empName}',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    textSpan(
                      hintColor: Colors.grey,
                      textColor: Colors.black54,
                      hint: '部门：',
                      text: data.deptName ?? '',
                      isBold: false,
                    ),
                    textSpan(
                      hintColor: Colors.grey,
                      textColor: Colors.black54,
                      hint: '职务：',
                      text: data.dutyName ?? '',
                      isBold: false,
                    ),
                    textSpan(
                      hintColor: Colors.grey,
                      textColor: Colors.black54,
                      hint: '入职日期：',
                      text: data.beginHireDate ?? '',
                      isBold: false,
                    ),
                    textSpan(
                      hintColor: Colors.grey,
                      hint: '联系电话：',
                      text: data.phone ?? '',
                      isBold: false,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return pageBody(
      body: Column(
        children: [
          TabBar(
            dividerColor: Colors.blueAccent,
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            controller: tabController,
            tabs: const [Tab(text: '考勤'), Tab(text: '信息')],
            onTap: (i) => pageController.jumpToPage(i),
          ),
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: (i) => tabController.animateTo(i),
              scrollDirection: Axis.horizontal,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child:
                              OptionsPicker(pickerController: opcOrganization),
                        ),
                        DatePicker(pickerController: dpAttendanceDay),
                      ],
                    ),
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
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: CupertinoSearchTextField(
                        controller: controller,
                        prefixIcon: const SizedBox.shrink(),
                        suffixIcon: const Icon(CupertinoIcons.search),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onSuffixTap: () {
                          // logic.getMoNoReport(commandNumber: controller.text, goPage: false);
                        },
                        placeholder: '请输入员工姓名',
                      ),
                    ),
                    Expanded(
                      child: Obx(() => ListView.builder(
                            itemCount: state.teamMemberDataList.length,
                            itemBuilder: (c, i) => _teamMemberInfoItem(
                                state.teamMemberDataList[i]),
                          )),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
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
      padding: EdgeInsets.only(left: 5, right: 5),
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
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(5),
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
