import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/dispatching/machine_dispatch/machine_dispatch_logic.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class MachineDispatchHistoryPage extends StatefulWidget {
  const MachineDispatchHistoryPage({super.key});

  @override
  State<MachineDispatchHistoryPage> createState() =>
      _MachineDispatchHistoryPageState();
}

class _MachineDispatchHistoryPageState
    extends State<MachineDispatchHistoryPage> {
  final logic = Get.find<MachineDispatchLogic>();
  final state = Get.find<MachineDispatchLogic>().state;

  @override
  Widget build(BuildContext context) {
    return pageBody(
      body: ListView.builder(
        itemCount: state.historyInfo.length,
        itemBuilder: (c, i) => GestureDetector(
          child: Container(
            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
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
            child: Row(
              children: [
                expandedTextSpan(
                  hint: 'machine_dispatch_dispatch_no_colon'.tr,
                  text: state.historyInfo[i].dispatchNumber ?? '',
                ),
                expandedTextSpan(
                  hint: 'machine_dispatch_machine_colon'.tr,
                  text: state.historyInfo[i].machine ?? '',
                ),
                expandedTextSpan(
                  hint: 'machine_dispatch_shift_colon'.tr,
                  text: state.historyInfo[i].shift ?? '',
                ),
              ],
            ),
          ),
          onTap: () => logic.getHistoryStockInLabelInfo(i),
        ),
      ),
    );
  }

  @override
  void dispose() {
    state.historyInfo.value = [];
    super.dispose();
  }
}

class MachineDispatchHistoryDetailPage extends StatefulWidget {
  const MachineDispatchHistoryDetailPage({super.key});

  @override
  State<MachineDispatchHistoryDetailPage> createState() =>
      _MachineDispatchHistoryDetailPageState();
}

class _MachineDispatchHistoryDetailPageState
    extends State<MachineDispatchHistoryDetailPage> {
  final logic = Get.find<MachineDispatchLogic>();
  final state = Get.find<MachineDispatchLogic>().state;
  final index = Get.arguments['index'];

  @override
  Widget build(BuildContext context) {
    return pageBody(
      body: ListView.builder(
        itemCount: state.historyLabelInfo.length,
        itemBuilder: (c, i) => GestureDetector(
          child: Container(
              margin: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
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
                children: [
                  Row(
                    children: [
                      expandedTextSpan(
                        flex: 2,
                        hint: 'machine_dispatch_material_name_colon'.tr,
                        text: state.historyLabelInfo[i].materialName,
                      ),
                      expandedTextSpan(
                        hint: 'machine_dispatch_dispatch_date_colon'.tr,
                        text: state.historyLabelInfo[i].date,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      expandedTextSpan(
                        hint: 'machine_dispatch_type_body_colon'.tr,
                        text: state.historyLabelInfo[i].factoryType,
                      ),
                      expandedTextSpan(
                        hint: 'machine_dispatch_size_colon'.tr,
                        text: state.historyLabelInfo[i].size,
                      ),
                      expandedTextSpan(
                        hint: 'machine_dispatch_qty_colon'.tr,
                        text: state.historyLabelInfo[i].qty.toShowString(),
                      ),
                      expandedTextSpan(
                        hint: 'machine_dispatch_number_colon'.tr,
                        text: state.historyLabelInfo[i].number,
                      ),
                    ],
                  ),
                ],
              )),
          onTap: () => askDialog(
            content: 'machine_dispatch_confirm_print_label'.tr,
            confirm: () => logic.printHistoryLabel(i),
          ),
        ),
      ),
    );
  }
}
