import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/dispatching/process_dispatch_register/process_dispatch_register_dialog.dart';
import 'package:jd_flutter/fun/dispatching/process_dispatch_register/process_dispatch_register_logic.dart';
import 'package:jd_flutter/fun/dispatching/process_dispatch_register/process_dispatch_register_state.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

import '../../../bean/http/response/worker_info.dart';
import '../../../constant.dart';
import '../../../utils/utils.dart';
import '../../../widget/combination_button_widget.dart';

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

  _methodChannel() {
    debugPrint('注册监听');
    const MethodChannel(channelScanFlutterToAndroid).setMethodCallHandler((call) {
      switch (call.method) {
        case 'PdaScanner':
          {
            logic.getLabelInfo(call.arguments);
          }
          break;
      }
      return Future.value(call);
    });
  }

  _item(WorkerInfo wi, int index) {
    return Obx(() => GestureDetector(
          onTap: () {
            state.select.value = index;
          },
          child: Card(
            color: state.select == index
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
    _methodChannel();
    getWorkerInfo(
      department: userInfo?.departmentID.toString(),
      workers: (list) => state.workerList.value = list,
      error: (msg) =>
          showSnackBar(title: '查询失败', message: msg, isWarning: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '修改操作员',
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
              hint: '温馨提示：',
              text: '扫描标签进行人员修改！',
              hintColor: Colors.redAccent,
              textColor: Colors.redAccent,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 5, top: 10),
              child: Row(
                children: [
                  expandedTextSpan(
                    hint: '指令号：',
                    text: state.instructions.value,
                  ),
                  expandedTextSpan(
                    hint: '工序：',
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
                    hint: '操作员：',
                    text: state.worker.value,
                  ),
                  expandedTextSpan(
                    hint: '数量/箱容：',
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
            Row(
              children: [
                Expanded(
                    child: CombinationButton(
                  text: '提交修改',
                  click: () => logic.modifyLabelWorker(),
                ))
              ],
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
