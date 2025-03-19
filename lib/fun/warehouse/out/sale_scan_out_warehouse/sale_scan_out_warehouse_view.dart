import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/scanner.dart';
import 'package:jd_flutter/widget/worker_check_widget.dart';

import 'sale_scan_out_warehouse_logic.dart';
import 'sale_scan_out_warehouse_state.dart';

class SaleScanOutWarehousePage extends StatefulWidget {
  const SaleScanOutWarehousePage({super.key});

  @override
  State<SaleScanOutWarehousePage> createState() =>
      _SaleScanOutWarehousePageState();
}

class _SaleScanOutWarehousePageState extends State<SaleScanOutWarehousePage> {
  final SaleScanOutWarehouseLogic logic = Get.put(SaleScanOutWarehouseLogic());
  final SaleScanOutWarehouseState state =
      Get.find<SaleScanOutWarehouseLogic>().state;
  var inputController = TextEditingController();
  var refreshController = EasyRefreshController(controlFinishRefresh: true);

  inputWorkerDialog({required Function(WorkerInfo) submit}) {
    WorkerInfo? worker;
    Get.dialog(
      PopScope(
        canPop: true,
        child: StatefulBuilder(builder: (context, dialogSetState) {
          return AlertDialog(
            title: Text('提交领料'),
            content: WorkerCheck(
              hint: '请输入领料员工号',
              init: spGet(spSaveSaleScanOutWarehouseWorker),
              onChanged: (v) => worker = v,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (worker == null) {
                    showSnackBar(message: '请输入领料员工号', isWarning: true);
                    return;
                  }
                  spSave(spSaveSaleScanOutWarehouseWorker, worker!.empCode ?? '');
                  Get.back();
                  submit.call(worker!);
                },
                child: Text('提交'),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'dialog_default_cancel'.tr,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  _item(BarCodeInfo item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            item.isUsed ? Colors.red.shade100 : Colors.blue.shade100,
            Colors.green.shade50
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        // color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: item.isUsed ? Colors.red : Colors.blue, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: item.isUsed
                ? textSpan(
                    hint: '已提交：',
                    hintColor: Colors.red,
                    text: item.code ?? '',
                    textColor: Colors.grey,
                  )
                : Text(
                    item.code ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
          ),
          IconButton(
            onPressed: () => askDialog(
              content: '确定要删除该条码吗？',
              confirm: () => logic.deleteItem(item),
            ),
            icon: const Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    pdaScanner(scan: (code) => logic.scanCode(code));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshController.callRefresh();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: TextField(
              controller: inputController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(
                  top: 0,
                  bottom: 0,
                  left: 10,
                  right: 10,
                ),
                filled: true,
                fillColor: Colors.white54,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                hintText: '手动录入登记',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: IconButton(
                    onPressed: () => inputController.clear(),
                    icon: const Icon(
                      Icons.replay_circle_filled,
                      color: Colors.red,
                    )),
                suffixIcon: IconButton(
                  onPressed: () {
                    var text = inputController.text;
                    if (text.trim().isEmpty) {
                      showSnackBar(message: '请输入条码');
                    } else {
                      FocusScope.of(context).requestFocus(FocusNode());
                      logic.scanCode(text);
                    }
                  },
                  icon: const Icon(
                    Icons.loupe_rounded,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () => EasyRefresh(
                controller: refreshController,
                header: const MaterialHeader(),
                onRefresh: () => logic.refreshBarCodeStatus(
                  refresh: () => refreshController.finishRefresh(),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.barCodeList.length,
                  itemBuilder: (c, i) => _item(state.barCodeList[i]),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Obx(() =>
                textSpan(hint: '已扫码：', text: '${state.barCodeList.length} 条')),
          ),
          Row(
            children: [
              Expanded(
                child: Obx(() => CombinationButton(
                      combination: Combination.left,
                      isEnabled: state.barCodeList.isNotEmpty,
                      text: '清空',
                      click: () => askDialog(
                        content: '确定要清空条码吗？',
                        confirm: () => logic.clearBarCodeList(),
                      ),
                    )),
              ),
              Expanded(
                child: Obx(() => CombinationButton(
                      combination: Combination.right,
                      isEnabled: state.barCodeList.isNotEmpty,
                      text: '提交',
                      click: () => inputWorkerDialog(
                        submit: (w) => logic.submit(worker: w),
                      ),
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<SaleScanOutWarehouseLogic>();
    super.dispose();
  }
}
