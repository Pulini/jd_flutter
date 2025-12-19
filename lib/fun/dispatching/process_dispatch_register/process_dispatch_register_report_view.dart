import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/process_dispatch_register_info.dart';
import 'package:jd_flutter/fun/dispatching/process_dispatch_register/process_dispatch_register_dialog.dart';
import 'package:jd_flutter/fun/dispatching/process_dispatch_register/process_dispatch_register_logic.dart';
import 'package:jd_flutter/fun/dispatching/process_dispatch_register/process_dispatch_register_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/scanner.dart';

class ProcessDispatchRegisterReportView extends StatefulWidget {
  const ProcessDispatchRegisterReportView({super.key});

  @override
  State<ProcessDispatchRegisterReportView> createState() =>
      _ProcessDispatchRegisterReportViewState();
}

class _ProcessDispatchRegisterReportViewState
    extends State<ProcessDispatchRegisterReportView> {
  final ProcessDispatchRegisterLogic logic =
      Get.find<ProcessDispatchRegisterLogic>();
  final ProcessDispatchRegisterState state =
      Get.find<ProcessDispatchRegisterLogic>().state;

  Widget _item(ProcessDispatchLabelInfo data) => GestureDetector(
        onTap: () => reportDialog(data, () => setState(() {})),
        onLongPress: () => askDialog(
          content: '确定要删除贴标吗？',
          confirm: () => state.barCodeList.remove(data),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey, width: 2),
            gradient: LinearGradient(
              colors: [
                data.isReported.value
                    ? Colors.red.shade100
                    : Colors.blue.shade50,
                Colors.white
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                  child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(data.instructions ?? '')),
                      Text('${data.empName}(${data.empNumber})')
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: Text(data.processName ?? '')),
                      Text(
                          '${data.qty.toString()}/${data.boxCapacity.toShowString()}')
                    ],
                  ),
                ],
              )),
              Checkbox(
                value: data.isSelected.value,
                onChanged: (v) => data.isSelected.value = v!,
              ),
            ],
          ),
        ),
      );

  @override
  void initState() {
    pdaScanner(scan: (code) => logic.scanCode(code));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '报工',
      actions: [TextButton(onPressed: () {}, child: Text('清空'))],
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: state.barCodeList.length,
                  itemBuilder: (c, i) => _item(state.barCodeList[i]),
                )),
          ),
          SizedBox(
            width: double.maxFinite,
            child: Obx(
              () => CombinationButton(
                isEnabled: state.barCodeList.isNotEmpty,
                text: '提交',
                click: () {
                  if (checkUserPermission('1052502')) {
                    logic.submitReport();
                  } else {
                    errorDialog(content: '缺少报工权限');
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
