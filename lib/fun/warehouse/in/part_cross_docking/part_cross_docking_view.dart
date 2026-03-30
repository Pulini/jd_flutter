import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/fun/warehouse/in/part_cross_docking/part_cross_docking_dialog.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'part_cross_docking_logic.dart';
import 'part_cross_docking_state.dart';

class PartCrossDockingPage extends StatefulWidget {
  const PartCrossDockingPage({super.key});

  @override
  State<PartCrossDockingPage> createState() => _PartCrossDockingPageState();
}

class _PartCrossDockingPageState extends State<PartCrossDockingPage> {
  final PartCrossDockingLogic logic = Get.put(PartCrossDockingLogic());
  final PartCrossDockingState state = Get.find<PartCrossDockingLogic>().state;
  var inputController = TextEditingController();
  var refreshController = EasyRefreshController(controlFinishRefresh: true);

  void manuallyAdd() {
    if (inputController.text.isNotEmpty) {
      logic.scanCode(inputController.text);
    } else {
      msgDialog(content: '请输入标签号');
    }
  }

  Widget _item(BarCodeInfo item) => Container(
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
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: item.isUsed ? Colors.red : Colors.blue,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: item.isUsed
                  ? textSpan(
                      hint: '已提交',
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
                content: '确定要删除该条码吗?',
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

  @override
  void initState() {
    pdaScanner(scan: (code) => logic.scanCode(code));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      body: Padding(
        padding: EdgeInsetsGeometry.only(left: 10, right: 10),
        child: Column(
          children: [
            TextField(
              onSubmitted: (value) => manuallyAdd(),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
              ],
              controller: inputController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(
                  top: 0,
                  bottom: 0,
                  left: 15,
                  right: 10,
                ),
                label: Text('请输入标签号'),
                filled: true,
                fillColor: Colors.grey.shade200,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                hintStyle: const TextStyle(color: Colors.white),
                prefixIcon: IconButton(
                  onPressed: () => inputController.clear(),
                  icon: const Icon(
                    Icons.replay_circle_filled,
                    color: Colors.red,
                  ),
                ),
                suffixIcon: IconButton(
                  onPressed: () => manuallyAdd(),
                  icon: Icon(
                    Icons.add_circle,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            Expanded(
              child: EasyRefresh(
                controller: refreshController,
                header: const MaterialHeader(),
                onRefresh: () => logic.refreshBarCodeStatus(
                  refresh: () => refreshController.finishRefresh(),
                ),
                child: ListView.builder(
                  itemCount: state.barCodeList.length,
                  itemBuilder: (c, i) => _item(state.barCodeList[i]),
                ),
              ),
            ),
            Obx(() => Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      textSpan(
                        hint: '已扫描',
                        text: state.barCodeList.length.toString(),
                      ),
                      textSpan(
                        hint: '托盘号',
                        text: state.palletNumber.value,
                      ),
                    ],
                  ),
                )),
            Row(
              children: [
                Expanded(
                  child: Obx(() => CombinationButton(
                        isEnabled: state.barCodeList.isNotEmpty,
                        text: '清空',
                        combination: Combination.left,
                        click: () => askDialog(
                          content: '确定要清除所有以扫标签吗？',
                          confirm: () => logic.clearBarCodeList(),
                        ),
                      )),
                ),
                Expanded(
                  child: Obx(
                    () => CombinationButton(
                      isEnabled: state.barCodeList.isNotEmpty,
                      text: '提交',
                      combination: Combination.right,
                      click: () => logic.submit(
                        (msg) => checkWorkerDialog(
                          msg: msg,
                          success: (worker) => logic.getReport(worker: worker),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<PartCrossDockingLogic>();
    super.dispose();
  }
}
