import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';

import 'carton_label_scan_logic.dart';
import 'carton_label_scan_state.dart';

class CartonLabelScanPage extends StatefulWidget {
  const CartonLabelScanPage({super.key});

  @override
  State<CartonLabelScanPage> createState() => _CartonLabelScanPageState();
}

class _CartonLabelScanPageState extends State<CartonLabelScanPage> {
  final CartonLabelScanLogic logic = Get.put(CartonLabelScanLogic());
  final CartonLabelScanState state = Get.find<CartonLabelScanLogic>().state;

  TextEditingController controller = TextEditingController();

  _item(String data) {}

  @override
  Widget build(BuildContext context) {
    return pageBody(
      body: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: EditText(
                      hint: '请扫描或手动输入外箱贴标',
                      controller: controller,
                      onChanged: (v) {
                        state.cartonLabel.value = v;
                      },
                    ),
                  ),
                  if (state.cartonLabel.value.isNotEmpty)
                    IconButton(
                      onPressed: () => logic.queryCartonLabelInfo(),
                      icon: const Icon(Icons.search, color: Colors.blue),
                    )
                ],
              ),
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade200, Colors.green.shade50],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  // border: Border.all(color: Colors.blue.shade200, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    textSpan(hint: '外箱条码：', text: state.cartonLabel.value),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: progressIndicator(
                            max: 100,
                            value: 50,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '100',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.cartonInsideLabelList.length,
                  itemBuilder: (c, i) => _item(state.cartonInsideLabelList[i]),
                ),
              ),
            ],
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<CartonLabelScanLogic>();
    super.dispose();
  }
}
