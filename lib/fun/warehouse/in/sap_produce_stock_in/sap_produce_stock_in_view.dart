import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_forming_scan_label_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'sap_produce_stock_in_logic.dart';
import 'sap_produce_stock_in_state.dart';

class SapProduceStockInPage extends StatefulWidget {
  const SapProduceStockInPage({super.key});

  @override
  State<SapProduceStockInPage> createState() => _SapProduceStockInPageState();
}

class _SapProduceStockInPageState extends State<SapProduceStockInPage> {
  final SapProduceStockInLogic logic = Get.put(SapProduceStockInLogic());
  final SapProduceStockInState state = Get.find<SapProduceStockInLogic>().state;

  var factoryWarehouseController = LinkOptionsPickerController(
    PickerType.sapFactoryWarehouse,
    saveKey:
        '${RouteConfig.sapProductionPicking.name}${PickerType.sapFactoryWarehouse}',
    onSelected: (w, f) =>
        Get.find<SapProduceStockInLogic>().state.factoryId.value = f.pickerId(),
  );

  Container item(SapProduceStockInLabelInfo data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(left: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [Colors.blue.shade200, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Expanded(child: Text(data.labelCode ?? '')),
          Text(
            data.scanProgress(),
            style: const TextStyle(color: Colors.green),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () => askDialog(
              content: 'sap_produce_stock_in_delete_group_tips'.tr,
              confirm: () => state.barCodeList.remove(data),
            ),
          ),
        ],
      ),
    );
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
          onPressed: () => askDialog(
            content: 'sap_produce_stock_in_clean_tips'.tr,
            confirm: () => state.barCodeList.clear(),
          ),
          child: Text('sap_produce_stock_in_clean'.tr),
        ),
      ],
      body: Column(
        children: [
          LinkOptionsPicker(pickerController: factoryWarehouseController),
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount:
                      state.barCodeList.where((v) => v.scanQty > 0).length,
                  itemBuilder: (c, i) => item(state.barCodeList[i]),
                )),
          ),
          Row(
            children: [
              Expanded(
                child: CombinationButton(
                  text: 'sap_produce_stock_in_submit'.tr,
                  click: () {
                  },
                  combination: Combination.left,
                ),
              ),
              Expanded(
                child: CombinationButton(
                  text: 'sap_produce_stock_in_reverse'.tr,
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
    Get.delete<SapProduceStockInLogic>();
    super.dispose();
  }
}
