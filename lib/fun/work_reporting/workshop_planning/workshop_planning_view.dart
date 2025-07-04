import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  @override
  void initState() {
    opcDepartment = OptionsPickerController(
      PickerType.ghost,
      buttonName: '部门',
      dataList: ()=>getResponsibleDepartmentList(userInfo?.userID ?? 0),
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
