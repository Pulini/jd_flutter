import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/attendance_dashboard_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

import 'attendance_dashboard_logic.dart';
import 'attendance_dashboard_state.dart';


///1、需要给除厂长及人资和生管外的管理人员发送飞书考勤信息卡片，点击卡片进入考勤明细，展示当天组员出勤情况和月出勤率
///2、给厂长及人资和生管单独开发网页版考勤界面，查看全厂考勤情况，通过层级依次进入到考勤明细，最终定位到组员出勤明细，且需要展示每个层级的月出勤率
///3、重新开发当前app端考勤模块，以网页版考勤内容做界面减法，实现厂长及人资和生管的对全长考勤的掌控
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
  var dpcAttendanceDay = DatePickerController(
    PickerType.date,
    lastDate: DateTime.now(),
  );

  Widget _teamMemberInfoItem(TeamMemberInfo data) => _TeamMemberInfoCard(data: data);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ever(state.searchTeamMemberText, (v) => logic.searchTeamMember(v));
      dpcAttendanceDay.onSelected = (v) => logic.getAttendanceDashboard(
        date: getDateYMD(time: v),
        success: () => refreshController.finishRefresh(),
        error: () => refreshController.finishRefresh(),
      );
      refreshController.callRefresh();
    });
    super.initState();
  }

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
            tabs: [
              Tab(text: 'attendance_dashboard_tab_attendance'.tr),
              Tab(text: 'attendance_dashboard_tab_team'.tr),
            ],
            onTap: (i) => pageController.jumpToPage(i),
          ),
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: (i) {
                tabController.animateTo(i);
                if (pageController.page == 1 &&
                    state.teamMemberDataList.isEmpty) {
                  logic.getTeamMemberList();
                }
              },
              scrollDirection: Axis.horizontal,
              children: [
                Column(
                  children: [
                    DatePicker(pickerController: dpcAttendanceDay),
                    Expanded(
                      child: Obx(() => EasyRefresh(
                        controller: refreshController,
                        header: const MaterialHeader(),
                        onRefresh: () => logic.getAttendanceDashboard(
                          date: dpcAttendanceDay.getDateFormatYMD(),
                          success: () => refreshController.finishRefresh(),
                          error: () => refreshController.finishRefresh(),
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
                      padding: EdgeInsets.all(10),
                      child: CupertinoSearchTextField(
                        prefixIcon: const SizedBox.shrink(),
                        suffixIcon: const Icon(CupertinoIcons.search),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onChanged: (text) =>
                        state.searchTeamMemberText.value = text,
                        placeholder: 'attendance_dashboard_search_hint'.tr,
                      ),
                    ),
                    Expanded(
                      child: Obx(() => ListView.builder(
                        itemCount: state.teamMemberShowList.length,
                        itemBuilder: (c, i) => _teamMemberInfoItem(
                            state.teamMemberShowList[i]),
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
    tabController.dispose();
    pageController.dispose();
    refreshController.dispose();
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
    duration: const Duration(milliseconds: 200),
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
  }) =>
      _AttendancePercentProgress(max: max, value: value);

  Widget _itemCard(String text1, String text2) =>
      _AttendanceItemCard(text1: text1, text2: text2);



  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
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
            mainAxisSize: MainAxisSize.min,
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
                    Text('attendance_dashboard_total'.tr,
                        style: tsSmallLightGrey),
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
                    Text('attendance_dashboard_attendance'.tr,
                        style: tsSmallLightGrey),
                    SizedBox(height: 2),
                  ])
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            _itemCard(
                              widget.data.lateOrEarlyCount.toString(),
                              'attendance_dashboard_late'.tr,
                            ),
                            _itemCard(
                              widget.data.leaveTotal.toShowString(),
                              'attendance_dashboard_leave'.tr,
                            ),
                            _itemCard(
                              widget.data.publicHoliday.toShowString(),
                              'attendance_dashboard_day_off'.tr,
                            ),
                          ],
                        ),
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, -0.5),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animationController,
                            curve: Curves.easeInOut,
                          )),
                          child: SizeTransition(
                            sizeFactor:
                            animationController.drive(CurveTween(curve: Curves.easeInOut)),
                            alignment: Alignment.topCenter,
                            axis: Axis.vertical,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    _itemCard(
                                      widget.data.casualLeave.toShowString(),
                                      'attendance_dashboard_personal_leave'.tr,
                                    ),
                                    _itemCard(
                                      widget.data.sickLeave.toShowString(),
                                      'attendance_dashboard_sick_leave'.tr,
                                    ),
                                    _itemCard(
                                      widget.data.workInjury.toShowString(),
                                      'attendance_dashboard_work_injury'.tr,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _itemCard(
                                      widget.data.marriageLeave.toShowString(),
                                      'attendance_dashboard_marriage_leave'.tr,
                                    ),
                                    _itemCard(
                                      widget.data.maternityLeave.toShowString(),
                                      'attendance_dashboard_maternity_leave'.tr,
                                    ),
                                    _itemCard(
                                      widget.data.funeralLeave.toShowString(),
                                      'attendance_dashboard_bereavement_leave'.tr,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}

class _TeamMemberInfoCard extends StatelessWidget {
  final TeamMemberInfo data;

  const _TeamMemberInfoCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(100),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(100),
          bottomRight: Radius.circular(100),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: avatarPhoto(data.photo, borderRadius: 100),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 35),
                        child: AutoSizeText(
                          '(${data.empNumber}) ${data.empName}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                          maxLines: 1,
                          minFontSize: 8,
                          maxFontSize: 18,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 35),
                        child: textSpan(
                          hintColor: Colors.grey,
                          textColor: Colors.black54,
                          hint: 'attendance_dashboard_team_item_dept'.tr,
                          text: data.deptName ?? '',
                          maxLines: 2,
                          isBold: false,
                        ),
                      ),
                      textSpan(
                        hintColor: Colors.grey,
                        textColor: Colors.black54,
                        hint: 'attendance_dashboard_team_item_duty'.tr,
                        text: data.dutyName ?? '',
                        isBold: false,
                      ),
                      textSpan(
                        hintColor: Colors.grey,
                        textColor: Colors.black54,
                        hint: 'attendance_dashboard_team_item_begin_data'.tr,
                        text: data.beginHireDate ?? '',
                        isBold: false,
                      ),
                      textSpan(
                        hintColor: Colors.grey,
                        hint: 'attendance_dashboard_team_item_phone'.tr,
                        text: data.phone ?? '',
                        isBold: false,
                      ),
                    ],
                  ),
                  if (!data.phone.isNullOrEmpty())
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        onPressed: () => makePhoneCall(data.phone!),
                        icon: const Icon(
                          Icons.phone_forwarded_rounded,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendancePercentProgress extends StatelessWidget {
  final double max;
  final double value;

  const _AttendancePercentProgress({
    required this.max,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    var percent = (value.div(max).toStringAsFixed(3)).toDoubleTry();
    return Container(
      padding: const EdgeInsets.only(left: 5, right: 5),
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
              style: const TextStyle(
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
}

class _AttendanceItemCard extends StatelessWidget {
  static const _textStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: Colors.grey,
  );

  final String text1;
  final String text2;

  const _AttendanceItemCard({
    required this.text1,
    required this.text2,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(5),
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
            Text(text2, style: _textStyle),
          ],
        ),
      ),
    );
  }
}
