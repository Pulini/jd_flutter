import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/carton_label_scan_progress_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/carton_label_scan/carton_label_scan_logic.dart';
import 'package:jd_flutter/fun/warehouse/manage/carton_label_scan/carton_label_scan_state.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

class CartonLabelScanProgressDetailView extends StatefulWidget {
  const CartonLabelScanProgressDetailView({super.key});

  @override
  State<CartonLabelScanProgressDetailView> createState() =>
      _CartonLabelScanProgressDetailViewState();
}

class _CartonLabelScanProgressDetailViewState
    extends State<CartonLabelScanProgressDetailView> {
  final CartonLabelScanLogic logic = Get.find<CartonLabelScanLogic>();
  final CartonLabelScanState state = Get.find<CartonLabelScanLogic>().state;

  Card _item(List<CartonLabelScanProgressDetailInfo> list) {
    return Card(
      child: list.length == 1
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  cartonNo(list.first.isOnlyOne, list.first.cartonNo ?? ''),
                  expandedTextSpan(
                    hint: 'carton_label_scan_progress_detail_outside_label'.tr,
                    text: list[0].outBoxBarCode ?? '',
                    textColor: list[0].stateColor(),
                  ),
                  Text(
                    list[0].size ?? '',
                    style: TextStyle(
                      color: list[0].stateColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            )
          : ExpansionTile(
              backgroundColor: Colors.blue.shade200,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  textSpan(
                    hint: 'carton_label_scan_progress_detail_size'.tr,
                    text: list[0].size ?? '',
                  ),
                  SizedBox(
                    width: 120,
                    child: CustomProgressIndicator(
                      max: list.length.toDouble(),
                      value: list
                          .where((v) =>
                              v.sendCustomSystemState == 1 ||
                              v.sendCustomSystemState == 2)
                          .length
                          .toDouble(),
                    ),
                  ),
                ],
              ),
              children: [
                for (var item in list)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          cartonNo(item.isOnlyOne, item.cartonNo ?? ''),
                          expandedTextSpan(
                            hint:
                                'carton_label_scan_progress_detail_outside_label'
                                    .tr,
                            text: item.outBoxBarCode ?? '',
                            textColor: item.stateColor(),
                          ),
                          Text(item.getScanProgress()),
                        ],
                      ),
                    ),
                  )
              ],
            ),
    );
  }

  Widget cartonNo(bool isOnlyOne, String no) => Container(
        height: 25,
        padding: const EdgeInsets.only(left: 3, right: 3),
        margin: const EdgeInsets.only(right: 5),
        constraints: const BoxConstraints(minWidth: 25),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          color: isOnlyOne ? Colors.blue : Colors.green,
        ),
        child: Center(
          child: Text(
            no,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'carton_label_scan_progress_detail_title'.tr,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    cartonNo(true, '99'),
                    Text('carton_label_scan_progress_detail_label_type_only'.tr),
                  ],
                ),
                Row(
                  children: [
                    cartonNo(false, '1'),
                    Text('carton_label_scan_progress_detail_label_type_not_only'.tr),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.progressDetail.length,
              itemBuilder: (context, index) =>
                  _item(state.progressDetail[index]),
            ),
          ),
        ],
      ),
    );
  }
}
