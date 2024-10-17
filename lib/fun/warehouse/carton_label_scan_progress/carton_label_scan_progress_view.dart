import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

import '../../../widget/edit_text_widget.dart';
import 'carton_label_scan_progress_logic.dart';
import 'carton_label_scan_progress_state.dart';

class CartonLabelScanProgressPage extends StatefulWidget {
  const CartonLabelScanProgressPage({super.key});

  @override
  State<CartonLabelScanProgressPage> createState() =>
      _CartonLabelScanProgressPageState();
}

class _CartonLabelScanProgressPageState
    extends State<CartonLabelScanProgressPage> {
  final CartonLabelScanProgressLogic logic =
      Get.put(CartonLabelScanProgressLogic());
  final CartonLabelScanProgressState state =
      Get.find<CartonLabelScanProgressLogic>().state;

  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return pageBody(
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: EditText(
                  hint: '请输入销售订单或客户PO查询',
                  controller: controller,
                ),
              ),
              IconButton(
                onPressed: () => logic.queryScanHistory(controller.text),
                icon: const Icon(Icons.search, color: Colors.blue),
              )
            ],
          ),
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.progress.length,
                  itemBuilder: (context, index) => InkWell(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            textSpan(
                              hint: '销售/客户订单：',
                              text:
                                  '${state.progress[index].salesOrder} / ${state.progress[index].custOrderNumber}',
                            ),
                            Row(
                              children: [
                                Text('扫码情况：'),
                                Expanded(
                                  child: progressIndicator(
                                    max: state.progress[index].totalPiece ?? 0,
                                    value: state.progress[index].scanned,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    onTap: () => logic.getProgressDetail(
                      state.progress[index],
                      (detail) => Get.dialog(
                        pageBody(
                          title: '订单扫码明细',
                          body: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: detail.length,
                            itemBuilder: (context, index) => Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    expandedTextSpan(
                                      hint: '外箱标：',
                                      text: detail[index].outBoxBarCode ?? '',
                                      textColor: detail[index].stateColor(),
                                    ),
                                    textSpan(
                                      hint: '尺码：',
                                      text: detail[index].size ?? '',
                                      textColor: detail[index].stateColor(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<CartonLabelScanProgressLogic>();
    super.dispose();
  }
}
