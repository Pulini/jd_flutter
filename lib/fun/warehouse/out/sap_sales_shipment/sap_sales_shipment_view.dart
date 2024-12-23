import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_sales_shipment_info.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_sales_shipment/sap_sales_shipment_pallet_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

import 'sap_sales_shipment_logic.dart';
import 'sap_sales_shipment_state.dart';

class SapSalesShipmentPage extends StatefulWidget {
  const SapSalesShipmentPage({super.key});

  @override
  State<SapSalesShipmentPage> createState() => _SapSalesShipmentPageState();
}

class _SapSalesShipmentPageState extends State<SapSalesShipmentPage> {
  final SapSalesShipmentLogic logic = Get.put(SapSalesShipmentLogic());
  final SapSalesShipmentState state = Get.find<SapSalesShipmentLogic>().state;
  var insController = TextEditingController();
  var dpcDate = DatePickerController(PickerType.date, buttonName: '交货日期');

  _item(int index) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => const SapSalesShipmentPalletView(),
          arguments: {'index': index},
        )?.then((v) {
          setState(() {});
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 5, bottom: 10),
        padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            textSpan(
              hint: '指令：',
              text:
                  '${state.orderList[index].instructionList[0].instructionNo}',
              hintColor: Colors.grey.shade700,
              textColor: Colors.red,
            ),
            textSpan(
              hint: '型体：',
              text: '${state.orderList[index].instructionList[0].typeBody}',
              hintColor: Colors.grey.shade700,
              textColor: Colors.red,
            ),
            const Divider(height: 10, color: Colors.black),
            for (var item in state.orderList[index].instructionList)
              _subItem(item, index),
          ],
        ),
      ),
    );
  }

  _subItem(SapSalesShipmentInfo item, int index) {
    var pickQty =
        state.orderList[index].materialPickQty(item.materialCode ?? '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AutoSizeText(
          '(${item.materialCode})${item.materialName}',
          style: TextStyle(
            color: Colors.blue.shade700,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          minFontSize: 8,
          maxFontSize: 16,
        ),
        Row(
          children: [
            expandedTextSpan(
              hint: '交货日期：',
              isBold: false,
              text: item.deliveryDate ?? '',
              hintColor: Colors.grey.shade700,
              textColor: Colors.black,
            ),
            expandedTextSpan(
              hint: '订单数：',
              isBold: false,
              text: item.orderQty.toShowString(),
              hintColor: Colors.grey.shade700,
              textColor: Colors.black,
            ),
          ],
        ),
        Row(
          children: [
            expandedTextSpan(
              hint: '已交货数：',
              isBold: false,
              text: item.deliveredQty.toShowString(),
              hintColor: Colors.grey.shade700,
              textColor: Colors.black,
            ),
            expandedTextSpan(
              hint: '交货数：',
              isBold: pickQty > 0,
              text: pickQty.toShowString(),
              hintColor: pickQty > 0 ? Colors.black : Colors.grey.shade700,
              textColor: pickQty > 0 ? Colors.green : Colors.red,
            ),
          ],
        ),
        const Divider(height: 10, color: Colors.black),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithBottomSheet(
      bottomSheet: [
        EditText(
          hint: '指令号',
          controller: insController,
        ),
        DatePicker(pickerController: dpcDate),
      ],
      query: () => logic.query(
        insController.text,
        dpcDate.getDateFormatSapYMD(),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: state.orderList.length,
                itemBuilder: (c, i) => _item(i),
              ),
            ),
          ),
          if (state.orderList
              .any((v) => v.palletList.any((v2) => v2.pickQty > 0)))
            SizedBox(
              width: double.infinity,
              child: CombinationButton(
                text: '提交出库',
                click: () => logic.postingShipment(
                  refresh: () => logic.query(
                    insController.text,
                    dpcDate.getDateFormatSapYMD(),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<SapSalesShipmentLogic>();
    super.dispose();
  }
}
