import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/forming_scan_info.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

import 'forming_barcode_collection_logic.dart';

class FormingBarcodeCollectionHistoryPage extends StatefulWidget {
  const FormingBarcodeCollectionHistoryPage({super.key});

  @override
  State<FormingBarcodeCollectionHistoryPage> createState() =>
      _FormingBarcodeCollectionHistoryPageState();
}

class _FormingBarcodeCollectionHistoryPageState
    extends State<FormingBarcodeCollectionHistoryPage> {
  final logic = Get.find<FormingBarcodeCollectionLogic>();
  final state = Get.find<FormingBarcodeCollectionLogic>().state;

  GestureDetector _item(FormingScanInfo data) {
    return GestureDetector(
      onTap: () {
        logic.getMoNoReport(commandNumber: data.commandNumber ?? '', goPage: true);
      },
      child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: Colors.greenAccent,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  expandedTextSpan(
                    flex: 3,
                      hint: 'forming_code_collection_history_body'.tr,
                      text: data.factoryType ?? ''),
                  expandedTextSpan(
                    flex: 4,
                      hint: 'forming_code_collection_history_first_time'.tr,
                      text: data.billDate ?? ''),
                ],
              ),
              Row(
                children: [
                  expandedTextSpan(
                    flex: 3,
                      hint: 'forming_code_collection_history_instruction_number'
                          .tr,
                      text: data.commandNumber ?? ''),
                  expandedTextSpan(
                    flex: 4,
                      hint: 'forming_code_collection_history_last_time'.tr,
                      text: data.lastActivationTime ?? ''),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  expandedTextSpan(
                      hint: 'forming_code_collection_history_state'.tr,
                      text: data.isClose ?? ''),
                ],
              ),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        title: 'forming_code_collection_historical_records'.tr,
        body: Column(
          children: [
            Text(state.historyMes),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: state.scanInfoDataList.length,
                  itemBuilder: (context, index) =>
                      _item(state.scanInfoDataList[index]),
                ),
              ),
            ),
          ],
        ));
  }
}
