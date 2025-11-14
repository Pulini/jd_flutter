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
                  Container(
                    height: 20,
                    padding: const EdgeInsets.only(left: 3, right: 3),
                    margin: const EdgeInsets.only(right: 5),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.blueAccent,
                    ),
                    child: Center(
                      child: Text(
                        list[0].cartonNo ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
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
                    child: progressIndicator(
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
                          Container(
                            height: 20,
                            padding: const EdgeInsets.only(left: 3, right: 3),
                            margin: const EdgeInsets.only(right: 5),
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Colors.green,
                            ),
                            child: Center(
                              child: Text(
                                item.cartonNo ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          expandedTextSpan(
                            hint:
                                'carton_label_scan_progress_detail_outside_label'
                                    .tr,
                            text: item.outBoxBarCode ?? '',
                            textColor: item.stateColor(),
                          ),
                        ],
                      ),
                    ),
                  )
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'carton_label_scan_progress_detail_title'.tr,
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: state.progressDetail.length,
        itemBuilder: (context, index) => _item(state.progressDetail[index]),
      ),
    );
  }
}
