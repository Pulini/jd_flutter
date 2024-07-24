import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import '../../../widget/custom_widget.dart';
import 'part_process_scan_logic.dart';

class PartProcessScanPage extends StatefulWidget {
  const PartProcessScanPage({super.key});

  @override
  State<PartProcessScanPage> createState() => _PartProcessScanPageState();
}

class _PartProcessScanPageState extends State<PartProcessScanPage> {
  final logic = Get.put(PartProcessScanLogic());
  final state = Get.find<PartProcessScanLogic>().state;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return pageBody(
      
      actions: [
        TextButton(
          onPressed: () => askDialog(
            content: '确定要清空条码吗？',
            confirm: () => state.barCodeList.clear(),
          ),
          child: Text(
            '清空',
            style: TextStyle(color: Colors.blueAccent),
          ),
        ),
      ],
      body: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.qr_code_scanner,
                  size: 40,
                ),
              ),
              Expanded(child: EditText(controller: controller)),
              IconButton(
                onPressed: () => logic.addBarCode(
                  controller.text,
                  () => controller.clear(),
                ),
                icon: const Icon(
                  Icons.add_box_rounded,
                  size: 40,
                ),
              )
            ],
          ),
          Expanded(
              child: Obx(() => ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: state.barCodeList.length,
                    itemBuilder: (context, index) => Card(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(state.barCodeList[index]),
                      ),
                    ),
                  ))),
          Row(
            children: [
              Expanded(
                  child: CombinationButton(
                text: '修改',
                click: () =>logic.barCodeModify(),
                combination: Combination.left,
              )),
              Expanded(
                child: CombinationButton(
                  text: '提交',
                  click: () {},
                  combination: Combination.right,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<PartProcessScanLogic>();
    super.dispose();
  }
}
