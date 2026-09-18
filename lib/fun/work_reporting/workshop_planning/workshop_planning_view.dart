import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/workshop_planning_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_last_process_view.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_salary_count_view.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/scanner.dart';
import 'workshop_planning_logic.dart';
import 'workshop_planning_state.dart';

class WorkshopPlanningPage extends StatefulWidget {
  const WorkshopPlanningPage({super.key});

  @override
  State<WorkshopPlanningPage> createState() => _WorkshopPlanningPageState();
}

class _WorkshopPlanningPageState extends State<WorkshopPlanningPage> {
  final WorkshopPlanningLogic logic = Get.put(WorkshopPlanningLogic());
  final WorkshopPlanningState state = Get.find<WorkshopPlanningLogic>().state;

  String saveDepartment = spGet(spSaveWorkshopPlanningDepartment) ?? '';
  late OptionsPickerController opcDepartment;
  var tecProductionOrderNo = TextEditingController();
  var tecProcessName = TextEditingController();

  dynamic _query() => logic.queryProcessPlan(
        productionOrderNo: tecProductionOrderNo.text,
        processName: tecProcessName.text,
      );

  void _querySheet() {
    showSheet(
      context: context,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EditText(
            hint: 'workshop_planning_hint_production_order'.tr,
            controller: tecProductionOrderNo,
          ),
          EditText(
            hint: 'workshop_planning_hint_process_name'.tr,
            controller: tecProcessName,
          ),
          Row(
            children: [
              Expanded(
                child: CombinationButton(
                  combination: Combination.left,
                  text: 'workshop_planning_scan'.tr,
                  click: () => Get.to(() => const Scanner())?.then(
                    (code) => logic.scanCode(
                      code.toString(),
                      tecProductionOrderNo,
                      tecProcessName,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: CombinationButton(
                  combination: Combination.right,
                  text: 'workshop_planning_query_process_plan'.tr,
                  click: () => _query(),
                ),
              ),
            ],
          )
        ],
      ),
      scrollControlled: true,
    );
  }

  @override
  void initState() {
    opcDepartment = OptionsPickerController(
      PickerType.ghost,
      buttonName: 'workshop_planning_department'.tr,
      dataList: () => getResponsibleDepartmentList(userInfo?.userID ?? 0),
      initId: saveDepartment,
      onSelected: (pick) {
        state.departmentID = pick.pickerId();
        state.groupName = pick.pickerName();
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        CombinationButton(
          combination: Combination.left,
          text: 'workshop_planning_last_process'.tr,
          click: () => Get.to(() => const WorkshopPlanningLastProcessPage()),
        ),
        CombinationButton(
          combination: Combination.right,
          text: 'workshop_planning_query'.tr,
          click: () => _querySheet(),
        )
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: OptionsPicker(pickerController: opcDepartment),
          ),
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: state.planList.length,
                  itemBuilder: (c, i) => _WorkshopPlanningItem(
                    data: state.planList[i],
                    logic: logic,
                    state: state,
                    onQuery: _query,
                  ),
                )),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<WorkshopPlanningLogic>();
    super.dispose();
  }
}

class _WorkshopPlanningItem extends StatelessWidget {
  final WorkshopPlanningInfo data;
  final WorkshopPlanningLogic logic;
  final WorkshopPlanningState state;
  final VoidCallback onQuery;

  const _WorkshopPlanningItem({
    required this.data,
    required this.logic,
    required this.state,
    required this.onQuery,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        state.planInfo = data.deepCopy();
        Get.to(() => const WorkshopPlanningSalaryCountPage())?.then((v) {
          state.planInfo = null;
          state.workersCache.clear();
          if (v != null && v as bool) {
            if (state.scanJson != null) {
              logic.refreshProcessPlan();
            } else {
              onQuery();
            }
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            textSpan(hint: 'workshop_planning_production_no'.tr, text: data.planTrackingNumber ?? ''),
            textSpan(
              hint: 'workshop_planning_material_colon'.tr,
              text: data.materialName ?? '',
              maxLines: 3,
              textColor: Colors.green.shade900,
            ),
            Row(
              children: [
                expandedTextSpan(
                  hint: 'workshop_planning_process_colon'.tr,
                  text: data.processName ?? '',
                  textColor: Colors.blue.shade900,
                ),
                textSpan(
                  hint: 'workshop_planning_order_qty_colon'.tr,
                  text: data.processQty.toShowString(),
                  textColor: Colors.blue.shade900,
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ExpandedFrameText(
                  flex: 1,
                  text: 'workshop_planning_size'.tr,
                  backgroundColor: Colors.green.shade100,
                  alignment: Alignment.center,
                  isBold: true,
                ),
                ExpandedFrameText(
                  flex: 2,
                  text: 'workshop_planning_order_quantity'.tr,
                  backgroundColor: Colors.green.shade100,
                  alignment: Alignment.center,
                  isBold: true,
                ),
                ExpandedFrameText(
                  flex: 2,
                  text: 'workshop_planning_cumulative_report'.tr,
                  backgroundColor: Colors.green.shade100,
                  alignment: Alignment.center,
                  isBold: true,
                ),
                ExpandedFrameText(
                  flex: 2,
                  text: 'workshop_planning_unreported'.tr,
                  backgroundColor: Colors.green.shade100,
                  alignment: Alignment.center,
                  isBold: true,
                ),
              ],
            ),
            for (var sub in data.sizeLists!)
              Row(
                children: [
                  ExpandedFrameText(
                    flex: 1,
                    text: sub.size ?? '',
                    alignment: Alignment.center,
                  ),
                  ExpandedFrameText(
                    flex: 2,
                    text: sub.processQty.toShowString(),
                    alignment: Alignment.center,
                  ),
                  ExpandedFrameText(
                    flex: 2,
                    text: sub.finishQty.toShowString(),
                    alignment: Alignment.center,
                  ),
                  ExpandedFrameText(
                    flex: 2,
                    text: sub.unFinishQty.toShowString(),
                    alignment: Alignment.center,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
