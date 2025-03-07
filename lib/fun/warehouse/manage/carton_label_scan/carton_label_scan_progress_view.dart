import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/manage/carton_label_scan/carton_label_scan_state.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'carton_label_scan_logic.dart';

class CartonLabelScanProgressPage extends StatefulWidget {
  const CartonLabelScanProgressPage({super.key});

  @override
  State<CartonLabelScanProgressPage> createState() =>
      _CartonLabelScanProgressPageState();
}

class _CartonLabelScanProgressPageState
    extends State<CartonLabelScanProgressPage> {
  final CartonLabelScanLogic logic = Get.find<CartonLabelScanLogic>();
  final CartonLabelScanState state = Get.find<CartonLabelScanLogic>().state;

  String customerPO = Get.arguments['CustomerPO'];
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (customerPO.isNotEmpty) {
        controller.text = customerPO;
        logic.queryScanHistory(customerPO);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'carton_label_scan_progress_title'.tr,
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(5),
            height: 40,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 15, right: 10),
                filled: true,
                fillColor: Colors.white54,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                hintText: 'carton_label_scan_progress_input_sales_order_or_customer_po'.tr,
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: IconButton(
                  onPressed: () => controller.clear(),
                  icon: const Icon(
                    Icons.replay_circle_filled,
                    color: Colors.red,
                  ),
                ),
                suffixIcon: IconButton(
                  onPressed: () =>
                      logic.queryScanHistory(controller.text),
                  icon: const Icon(
                    Icons.loupe_rounded,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
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
                              hint: 'carton_label_scan_progress_sales_order_or_customer_order'.tr,
                              text:
                                  '${state.progress[index].salesOrder} / ${state.progress[index].custOrderNumber}',
                            ),
                            Row(
                              children: [
                                Text('carton_label_scan_progress_scan_state'.tr),
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
                    onTap: () => logic.getProgressDetail(state.progress[index]),
                  ),
                )),
          )
        ],
      ),
    );
  }

}
