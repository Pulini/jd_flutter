import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/fun/dispatching/process_dispatch_register/process_dispatch_register_dialog.dart';
import 'package:jd_flutter/fun/dispatching/process_dispatch_register/process_dispatch_register_logic.dart';
import 'package:jd_flutter/fun/dispatching/process_dispatch_register/process_dispatch_register_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

class ModifyLabelWorkerPage extends StatefulWidget {
  const ModifyLabelWorkerPage({super.key});

  @override
  State<ModifyLabelWorkerPage> createState() => _ModifyLabelWorkerPageState();
}

class _ModifyLabelWorkerPageState extends State<ModifyLabelWorkerPage> {
  final ProcessDispatchRegisterLogic logic =
      Get.find<ProcessDispatchRegisterLogic>();
  final ProcessDispatchRegisterState state =
      Get.find<ProcessDispatchRegisterLogic>().state;

  _item(WorkerInfo wi, int index) {
    return Obx(() => GestureDetector(
          onTap: () {
            state.select.value = index;
          },
          child: Card(
            color: state.select.value == index
                ? Colors.greenAccent.shade100
                : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                children: [
                  avatarPhoto(wi.picUrl),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          wi.empCode ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          wi.empName ?? '',
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    pdaScanner(scan: (code) => logic.getLabelInfo(code));
    getWorkerInfo(
      department: userInfo?.departmentID.toString(),
      workers: (list) => state.workerList.value = list,
      error: (msg) => showSnackBar(
        title: 'process_dispatch_register_modify_query_failed',
        message: msg,
        isWarning: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'process_dispatch_register_modify_change_operator',
      actions: [
        IconButton(
          icon: const Icon(
            Icons.add,
            size: 30,
            color: Colors.blueAccent,
          ),
          onPressed: () {
            addNewWorkerDialog(state.workerList, (wi) {
              state.workerList.add(wi);
            });
          },
        ),
      ],
      body: Obx(
        () => Column(
          children: [
            textSpan(
              hint: 'process_dispatch_register_modify_tips'.tr,
              text: 'process_dispatch_register_modify_tips_msg'.tr,
              hintColor: Colors.redAccent,
              textColor: Colors.redAccent,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 5, top: 10),
              child: Row(
                children: [
                  expandedTextSpan(
                    hint: 'process_dispatch_register_modify_ins_number'.tr,
                    text: state.instructions.value,
                  ),
                  expandedTextSpan(
                    hint: 'process_dispatch_register_modify_process'.tr,
                    text: state.processName.value,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 5),
              child: Row(
                children: [
                  expandedTextSpan(
                    hint: 'process_dispatch_register_modify_operator'.tr,
                    text: state.worker.value,
                  ),
                  expandedTextSpan(
                    hint:
                        'process_dispatch_register_modify_quantity_or_box_capacity'
                            .tr,
                    text: state.qty.value,
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                itemCount: state.workerList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2 / 1,
                ),
                itemBuilder: (context, index) =>
                    _item(state.workerList[index], index),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: CombinationButton(
                text: 'process_dispatch_register_modify_submit_modify'.tr,
                click: () => logic.modifyLabelWorker(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    state.select.value = -1;
    state.labelInfo == null;
    state.instructions.value = '';
    state.worker.value = '';
    state.processName.value = '';
    state.qty.value = '';
    super.dispose();
  }
}
