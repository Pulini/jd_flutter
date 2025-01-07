import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_wms_reprint_label_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

import 'sap_wms_split_label_logic.dart';
import 'sap_wms_split_label_state.dart';

class SapWmsSplitLabelPage extends StatefulWidget {
  const SapWmsSplitLabelPage({super.key});

  @override
  State<SapWmsSplitLabelPage> createState() => _SapWmsSplitLabelPageState();
}

class _SapWmsSplitLabelPageState extends State<SapWmsSplitLabelPage> {
  final SapWmsSplitLabelLogic logic = Get.put(SapWmsSplitLabelLogic());
  final SapWmsSplitLabelState state = Get.find<SapWmsSplitLabelLogic>().state;

  var factoryWarehouseController = LinkOptionsPickerController(
    PickerType.sapFactoryWarehouse,
    saveKey:
        '${RouteConfig.sapWmsSplitLabel.name}${PickerType.sapFactoryWarehouse}',
  );

  Widget _item(ReprintLabelInfo label) {
    return GestureDetector(
        onTap: () => setState(() => label.select = !label.select),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: label.select ? Colors.blue.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: label.select
                ? Border.all(color: Colors.green, width: 2)
                : Border.all(color: Colors.white, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textSpan(
                hint: '物料：',
                text: '(${label.materialCode})${label.materialName}',
                textColor: Colors.green.shade900,
                maxLines: 2,
              ),
              textSpan(hint: '型体：', text: label.typeBody ?? ''),

            ],
          ),
        ));
  }

  @override
  void initState() {
    pdaScanner(scan: (code) => logic.scanCode(code));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        TextButton(
          onPressed: () {},
          child: Text('提交'),
        ),
      ],
      body: Column(
        children: [
          LinkOptionsPicker(pickerController: factoryWarehouseController),
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  itemCount: state.labelList.length,
                  itemBuilder: (c, i) => _item(state.labelList[i]),
                )),
          ),
          Row(
            children: [
              Expanded(
                child: CombinationButton(
                  text: '删除贴标',
                  click: () {},
                  combination: Combination.left,
                ),
              ),
              Expanded(
                child: CombinationButton(
                  text: '重打贴标',
                  click: () {
                    logic.scanCode('97F79C0A-EF67-471B-943E-AB256B1CC192');
                  },
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
    Get.delete<SapWmsSplitLabelLogic>();
    super.dispose();
  }
}
