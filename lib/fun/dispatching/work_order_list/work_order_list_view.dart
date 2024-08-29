import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/dispatching/work_order_list/part_pick_view.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

import '../../../bean/http/response/work_order_info.dart';
import '../../../utils.dart';
import '../../../widget/picker/picker_view.dart';
import '../../other/maintain_label/maintain_label_view.dart';
import 'work_order_list_logic.dart';

class WorkOrderListPage extends StatefulWidget {
  const WorkOrderListPage({super.key});

  @override
  State<WorkOrderListPage> createState() => _WorkOrderListPageState();
}

class _WorkOrderListPageState extends State<WorkOrderListPage> {
  final logic = Get.put(WorkOrderListLogic());
  final state = Get.find<WorkOrderListLogic>().state;

  _item(WorkOrderInfo data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              data.getStateName(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: data.getStateColor(),
              ),
            ),
            Row(
              children: [
                expandedTextSpan(
                  hint: '派工单号：',
                  text: data.orderBill ?? '',
                ),
                expandedTextSpan(
                  hint: '型体：',
                  text: data.plantBody ?? '',
                )
              ],
            ),
            Row(
              children: [
                expandedTextSpan(
                  hint: '派工日期：',
                  text: data.orderDate ?? '',
                ),
                expandedTextSpan(
                  hint: '总数：',
                  text: data.workNumberTotal.toDoubleTry().toShowString(),
                )
              ],
            ),
            Row(
              children: [
                expandedTextSpan(
                  hint: '制程：',
                  text: data.processFlowName ?? '',
                ),
                expandedTextSpan(
                  hint: '组别：',
                  text: data.group ?? '',
                )
              ],
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < data.mtonoInfos!.length; ++i)
              Row(
                children: [
                  expandedTextSpan(
                    hint: '销售订单号：',
                    text: data.mtonoInfos![i].planBill ?? '',
                    textColor: Colors.green,
                  ),
                  expandedTextSpan(
                    hint: '数量：',
                    text: data.mtonoInfos![i].workNumberTotal
                        .toDoubleTry()
                        .toShowString(),
                    textColor: Colors.green,
                  )
                ],
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (data.codeInfos != null && data.codeInfos!.isNotEmpty)
                  Expanded(
                    child: CombinationButton(
                      text: '已生成贴标',
                      click: () => _labelListDialog(data.codeInfos!),
                      combination: Combination.left,
                    ),
                  ),
                Expanded(
                  child: CombinationButton(
                    text: '末道贴标',
                    click: () {
                      if (checkUserPermission('1051105')) {
                        Get.to(const MaintainLabelPage(),arguments: {
                          'materialCode':data.materialCode,
                          'interID':data.interID,
                          'isMaterialLabel':false,
                        });
                      } else {
                        showSnackBar(
                          title: 'snack_bar_default_wrong'.tr,
                          message: '缺少末道贴标操作权限',
                          isWarning: true,
                        );
                      }
                    },
                    combination:
                        data.codeInfos != null && data.codeInfos!.isNotEmpty
                            ? Combination.middle
                            : Combination.left,
                  ),
                ),
                Expanded(
                  child: CombinationButton(
                    text: '个件贴标',
                    click: () {
                      state.orderId=data.orderBill??'';
                      Get.to(()=>const PartPickPage());
                      // if (checkUserPermission('1051107')) {
                      //   Get.to(const PartPickPage());
                      // } else {
                      //   showSnackBar(
                      //     title: 'snack_bar_default_wrong'.tr,
                      //     message: '缺少个件贴标操作权限',
                      //     isWarning: true,
                      //   );
                      // }
                    },
                    combination: Combination.right,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  _labelListDialog(List<CodeInfo> labels) {
    Get.dialog(
      PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text('已生成贴标'),
            content: SizedBox(
              width: MediaQuery.of(Get.overlayContext!).size.width * 0.8,
              height: MediaQuery.of(Get.overlayContext!).size.height * 0.8,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: labels.length,
                itemBuilder: (context, index) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(child: Text(labels[index].partNames ?? '')),
                        Text(labels[index].codeQty.toShowString())
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  '返回',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      queryWidgets: [
        EditText(hint: '工票条码', onChanged: (s) => state.workBarCode = s),
        EditText(hint: '计划跟踪单号', onChanged: (s) => state.planOrderNumber = s),
        OptionsPicker(pickerController: logic.pcGroup),
        DatePicker(pickerController: logic.pcStartDate),
        DatePicker(pickerController: logic.pcEndDate),
        SwitchButton(
          onChanged: (isSelect) {
            setState(() => state.isOutsourcing = isSelect);
            spSave('${Get.currentRoute}/isOutsourcing', isSelect);
          },
          name: '委外',
          value: state.isOutsourcing,
        ),
        SwitchButton(
          onChanged: (isSelect) {
            setState(() => state.isClosed = isSelect);
            spSave('${Get.currentRoute}/isClosed', isSelect);
          },
          name: '是否已关闭',
          value: state.isClosed,
        )
      ],
      query: () => logic.query(),
      body: Obx(() => ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: state.dataList.length,
            itemBuilder: (context, index) => _item(state.dataList[index]),
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<WorkOrderListLogic>();
    super.dispose();
  }
}
