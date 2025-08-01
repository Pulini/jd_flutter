import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/forming_collection_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'forming_barcode_collection_logic.dart';

class FormingBarcodeCollectionSwitchPage extends StatefulWidget {
  const FormingBarcodeCollectionSwitchPage({super.key});

  @override
  State<FormingBarcodeCollectionSwitchPage> createState() =>
      _FormingBarcodeCollectionSwitchPageState();
}

class _FormingBarcodeCollectionSwitchPageState
    extends State<FormingBarcodeCollectionSwitchPage> {
  final logic = Get.find<FormingBarcodeCollectionLogic>();
  final state = Get.find<FormingBarcodeCollectionLogic>().state;
var tecInstruction=TextEditingController();

  _item(FormingCollectionInfo data, int position) {
    String? allQty = '';
    String? scanAllQty = '';

    allQty = data.scWorkCardSizeInfos
        ?.where((data) => data.size != '合计')
        .toList()
        .map((v) => v.qty ?? 0)
        .reduce((a, b) => a.add(b))
        .toShowString();

    scanAllQty = data.scWorkCardSizeInfos
        ?.where((data) => data.size != '合计')
        .toList()
        .map((v) => ((v.qty ?? 0) - (v.scannedQty ?? 0)))
        .reduce((a, b) => a.add(b))
        .toShowString();

    return Obx(() => GestureDetector(
          onTap: () {
            logic.selectSwitch(position);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: data.isSelect.value ? Colors.blue.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: data.isSelect.value
                  ? Border.all(color: Colors.green, width: 2)
                  : Border.all(color: Colors.white, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    expandedTextSpan(
                        hint: 'forming_code_collection_factory'.tr,
                        text: data.productName ?? ''),
                    expandedTextSpan(
                        hint: 'forming_code_collection_sale_order'.tr,
                        text: data.mtoNo ?? '')
                  ],
                ),
                Row(
                  children: [
                    expandedTextSpan(
                        hint: 'forming_code_collection_order_quantity'.tr,
                        text: allQty ?? '0'),
                    expandedTextSpan(
                        hint: 'forming_code_collection_scan_quantity'.tr,
                        text: scanAllQty ?? '0')
                  ],
                ),
                Row(
                  children: [
                    expandedTextSpan(
                        hint: 'forming_code_collection_customer_orders'.tr,
                        text: data.clientOrderNumber ?? ''),
                    expandedTextSpan(
                        hint: 'forming_code_collection_order_type'.tr,
                        text: data.isClose == true ? '已关闭' : '未关闭')
                  ],
                )
              ],
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        body: Column(
      children: [
        EditText(
          hint: 'forming_code_collection_instruction_or_po'.tr,
          controller: tecInstruction,
          onChanged: (c) {
            logic.searchData(c);
          },
        ),
        Expanded(
          child: Obx(
            () => ListView.builder(
              itemCount: state.dataList.length,
              itemBuilder: (context, index) =>
                  _item(state.dataList[index], index),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
                child: CombinationButton(
              //切换订单
              text: 'forming_code_collection_switch'.tr,
              click: () => {
                if (state.dataList.none((data) => data.isSelect.value == true))
                  showSnackBar(message: '请选择要切换的订单')
                else
                  Get.back(result: logic.getSelect())
              },
              combination: Combination.intact,
            )),
          ],
        )
      ],
    ));
  }



  @override
  void initState() {
    pdaScanner(scan: (barCode) {
      if (state.dataList.none((data) => data.mtoNo == barCode)) {
        showSnackBar(message: 'forming_code_collection_no_search'.tr);
      } else {
        for (var data in state.dataList) {
          if (data.mtoNo == barCode) {
            Get.back(result: data.entryFID);
            break;
          }
        }
      }
    });
    logic.copyData();
    super.initState();
  }
}
