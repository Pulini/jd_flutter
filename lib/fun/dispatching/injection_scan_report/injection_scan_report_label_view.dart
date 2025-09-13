import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/show_process_barcode_info.dart';
import 'package:jd_flutter/fun/dispatching/injection_scan_report/injection_scan_report_logic.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

class InjectionScanReportLabelPage extends StatefulWidget {
  const InjectionScanReportLabelPage({super.key});

  @override
  State<InjectionScanReportLabelPage> createState() => _InjectionScanReportLabelPageState();
}

class _InjectionScanReportLabelPageState extends State<InjectionScanReportLabelPage> {

  final logic = Get.find<InjectionScanReportLogic>();
  final state = Get
      .find<InjectionScanReportLogic>()
      .state;

  _item(ShowProcessBarcodeInfo data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade200, Colors.green.shade50],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('外箱条码：${data.barCode}',style: const TextStyle(  fontWeight: FontWeight.bold,),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              textSpan(
                hint: 'injection_scan_label_size'.tr,
                text: data.size ?? '',
                textColor: Colors.black,
              ),
              textSpan(
                hint: 'injection_scan_label_capacity'.tr,
                text: '${data.qty}<${data.unit}>序列号：${data.num}',
                textColor: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        title: 'injection_scan_label_list_title'.tr,
        body: Container(padding:const EdgeInsets.all(10), child: Column(
          children: [
            Row(
              children: [
                expandedTextSpan(
                  hint: 'injection_scan_dispatch_no'.tr,
                  hintColor: Colors.blueAccent.shade200,
                  text: state.dataBean.dispatchNumber ?? '',
                  textColor: Colors.green.shade700,
                ),
                expandedTextSpan(
                  hint: 'injection_scan_dispatch_date'.tr,
                  hintColor: Colors.blueAccent.shade200,
                  text: state.dataBean.startDate ?? '',
                  textColor: Colors.green.shade700,
                ),
              ],
            ),
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: state.showBarCodeList.length,
                itemBuilder: (context, index) =>
                    _item(state.showBarCodeList[index]),
              )),
            ),
          ],
        ),));
  }
}
