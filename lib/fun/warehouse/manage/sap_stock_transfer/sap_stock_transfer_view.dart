import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'sap_stock_transfer_logic.dart';
import 'sap_stock_transfer_state.dart';

class SapStockTransferPage extends StatefulWidget {
  const SapStockTransferPage({super.key});

  @override
  State<SapStockTransferPage> createState() => _SapStockTransferPageState();
}

class _SapStockTransferPageState extends State<SapStockTransferPage> {
  final SapStockTransferLogic logic = Get.put(SapStockTransferLogic());
  final SapStockTransferState state = Get.find<SapStockTransferLogic>().state;
  var factoryWarehouseController = LinkOptionsPickerController(
    PickerType.sapFactoryWarehouse,
    saveKey:
        '${RouteConfig.sapStockTransfer.name}${PickerType.sapFactoryWarehouse}',
  );

  GestureDetector _item(PalletDetailItem1Info label) {
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
            AutoSizeText(
              label.sizeMaterialName ?? '',
              style: const TextStyle(color: Colors.red),
              maxLines: 2,
              minFontSize: 8,
              maxFontSize: 18,
            ),
            Row(
              children: [
                expandedTextSpan(
                  hint: 'sap_stock_transfer_label'.tr,
                  text: label.labelNumber ?? '',
                  isBold: false,
                  textColor: Colors.grey,
                ),
                Text('${label.quantity.toShowString()}${label.unit}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    pdaScanner(
      scan: (code) => logic.scanCode(
        warehouse: factoryWarehouseController.getPickItem2().pickerId(),
        code: code,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinkOptionsPicker(pickerController: factoryWarehouseController),
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Obx(
              () => textSpan(
                hint: 'sap_stock_transfer_pallet'.tr,
                text: state.palletNumber.value,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Obx(
              () => textSpan(
                hint: 'sap_stock_transfer_storage_location'.tr,
                text: state.location.value,
              ),
            ),
          ),
          EditText(
            hint: 'sap_stock_transfer_scan_storage_location_or_pallet_tips'.tr,
            controller: logic.locationOrPalletController,
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: state.labelList.length,
                itemBuilder: (c, i) => _item(state.labelList[i]),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: CombinationButton(
              text: 'sap_stock_transfer_transfer'.tr,
              click: () => logic.transfer(
                factoryWarehouseController.getPickItem2().pickerId(),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<SapStockTransferLogic>();
    super.dispose();
  }
}
