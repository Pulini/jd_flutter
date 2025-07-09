import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/workshop_planning_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'workshop_planning_logic.dart';
import 'workshop_planning_state.dart';

class WorkshopPlanningPage extends StatefulWidget {
  const WorkshopPlanningPage({super.key});

  @override
  State<WorkshopPlanningPage> createState() => _WorkshopPlanningPageState();
}

//权限码 1051321
class _WorkshopPlanningPageState extends State<WorkshopPlanningPage> {
  final WorkshopPlanningLogic logic = Get.put(WorkshopPlanningLogic());
  final WorkshopPlanningState state = Get.find<WorkshopPlanningLogic>().state;

  String saveDepartment = spGet(spSaveWorkshopPlanningDepartment) ?? '';
  late OptionsPickerController opcDepartment;
  var tecProductionOrderNo = TextEditingController();
  var tecProcessName = TextEditingController();

  _querySheet() {
    showSheet(
      context: context,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EditText(
            hint: '生产订单',
            controller: tecProductionOrderNo,
          ),
          EditText(
            hint: '工序名称',
            controller: tecProcessName,
          ),
          Row(
            children: [
              Expanded(
                child: CombinationButton(
                  combination: Combination.left,
                  text: '扫码',
                  click: () {},
                ),
              ),
              Expanded(
                child: CombinationButton(
                  combination: Combination.right,
                  text: '查询工序计划',
                  click: () => logic.queryProcessPlan(
                    productionOrderNo: tecProductionOrderNo.text,
                    processName: tecProcessName.text,
                    callback: () => Get.back(),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      scrollControlled: true,
    );
  }

  Widget _item(WorkshopPlanningInfo data) => GestureDetector(
        onTap: () => Get.to(()),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade100, Colors.green.shade50],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              textSpan(hint: '生产单号：', text: data.planTrackingNumber ?? ''),
              textSpan(
                hint: '物料：',
                text: data.materialName ?? '',
                maxLines: 3,
                textColor: Colors.green.shade900,
              ),
              Row(
                children: [
                  expandedTextSpan(
                    hint: '工序：',
                    text: data.processName ?? '',
                    textColor: Colors.blue.shade900,
                  ),
                  textSpan(
                    hint: '订单数量：',
                    text: data.processQty.toShowString(),
                    textColor: Colors.blue.shade900,
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  expandedFrameText(
                    flex: 1,
                    text: '尺码',
                    backgroundColor: Colors.green.shade100,
                    alignment: Alignment.center,
                    isBold: true,
                  ),
                  expandedFrameText(
                    flex: 2,
                    text: '订单数量',
                    backgroundColor: Colors.green.shade100,
                    alignment: Alignment.center,
                    isBold: true,
                  ),
                  expandedFrameText(
                    flex: 2,
                    text: '累计报工数',
                    backgroundColor: Colors.green.shade100,
                    alignment: Alignment.center,
                    isBold: true,
                  ),
                  expandedFrameText(
                    flex: 2,
                    text: '未报工数',
                    backgroundColor: Colors.green.shade100,
                    alignment: Alignment.center,
                    isBold: true,
                  ),
                ],
              ),
              for (var sub in data.sizeLists!)
                Row(
                  children: [
                    expandedFrameText(
                      flex: 1,
                      text: sub.size ?? '',
                      alignment: Alignment.center,
                    ),
                    expandedFrameText(
                      flex: 2,
                      text: sub.processQty.toShowString(),
                      alignment: Alignment.center,
                    ),
                    expandedFrameText(
                      flex: 2,
                      text: sub.finishQty.toShowString(),
                      alignment: Alignment.center,
                    ),
                    expandedFrameText(
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

  @override
  void initState() {
    opcDepartment = OptionsPickerController(
      PickerType.ghost,
      buttonName: '部门',
      dataList: () => getResponsibleDepartmentList(userInfo?.userID ?? 0),
      initId: saveDepartment,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        CombinationButton(
          combination: Combination.left,
          text: '末道计工',
          click: () {},
        ),
        CombinationButton(
          combination: Combination.right,
          text: '查询',
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
                  itemBuilder: (c, i) => _item(state.planList[i]),
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
