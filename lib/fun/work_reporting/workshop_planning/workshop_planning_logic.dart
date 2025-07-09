import 'package:get/get.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'workshop_planning_state.dart';

class WorkshopPlanningLogic extends GetxController {
  final WorkshopPlanningState state = WorkshopPlanningState();

  queryProcessPlan({
    required String productionOrderNo,
    required String processName,
    required Function() callback,
  }) {
    state.getProcessPlanInfo(
      productionOrderNo: productionOrderNo,
      processName: processName,
      success: callback,
      error:(msg)=>errorDialog(content: msg),
    );
    // if(productionOrderNo.isEmpty && processName.isEmpty){
    //   errorDialog(content: '请输入工单号或物料名称');
    // }else{
    //   state.getProcessPlanInfo(
    //     productionOrderNo: productionOrderNo,
    //     processName: processName,
    //     error:(msg)=>errorDialog(content: msg),
    //   );
    // }
  }
}
