import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/production_tasks_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'production_tasks_logic.dart';
import 'production_tasks_state.dart';

class ProductionTasksDetailPage extends StatefulWidget {
  const ProductionTasksDetailPage({super.key});

  @override
  State<ProductionTasksDetailPage> createState() =>
      _ProductionTasksDetailPageState();
}

class _ProductionTasksDetailPageState extends State<ProductionTasksDetailPage> {
  final ProductionTasksLogic logic = Get.find<ProductionTasksLogic>();
  final ProductionTasksState state = Get.find<ProductionTasksLogic>().state;
  bool isInstruction = Get.arguments['isInstruction'];
  String imageUrl = Get.arguments['imageUrl'];

  Widget productionTasksTableItem({
    ProductionTasksDetailItemInfo? data,
    int? type,
  }) =>
      _ProductionTasksDetailTableItem(data: data, type: type, logic: logic);

  Column _packetWay() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Text(
            'production_tasks_packing_method'.tr,
            style: TextStyle(
                color: Colors.blue.shade700, fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              // color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (var i in state.detailPacketWay) Text(i)],
            ),
          )
        ],
      );

  Column _specificRequirements() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Text(
            'production_tasks_guests_special_requests'.tr,
            style: TextStyle(
                color: Colors.blue.shade700, fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              // color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i in state.detailSpecificRequirements) Text(i)
              ],
            ),
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: isInstruction
          ? 'production_tasks_detail_instruction_no'.trArgs([
              state.detailInstructionNo.value,
            ])
          : 'production_tasks_detail_customer_po'.trArgs([
              state.detailCustomerPO.value,
            ]),
      body: Padding(
        padding: const EdgeInsets.only(left: 7, right: 7, bottom: 7),
        child: Column(
          children: [
            SizedBox(
              height: (getScreenSize().width * 0.5) / 16 * 9,
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.green.shade100,
                          Colors.blue.shade100,
                        ],
                      ),
                      border: Border.all(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                    child: Hero(
                      tag: 'ProductionTasksDetailImage-$imageUrl',
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.fill,
                            errorWidget: (ctx, err, stackTrace) => Image.asset(
                              'assets/images/ic_logo.png',
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.green.shade100,
                                  Colors.blue.shade100,
                                ],
                              ),
                              border: Border.all(
                                color: Colors.blueAccent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.blue.shade100,
                                    border: Border.all(
                                      color: Colors.blueAccent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      isInstruction
                                          ? 'production_tasks_detail_customer_po_tips'
                                              .tr
                                          : 'production_tasks_detail_instruction_no_tips'
                                              .tr,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Row(children: [
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          isInstruction
                                              ? state.detailCustomerPO.value
                                              : state.detailInstructionNo.value,
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: QrImageView(
                                        data: '',
                                        padding: const EdgeInsets.all(5),
                                        version: QrVersions.auto,
                                      ),
                                    )
                                  ]),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          margin: const EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.green.shade100,
                                Colors.blue.shade100,
                              ],
                            ),
                            border: Border.all(
                              color: Colors.blueAccent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'production_tasks_detail_packing_progress'
                                        .tr,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: PercentIndicator(
                                    max: state.detailShouldPackQty.value.toDouble(),
                                    value: state.detailPackagedQty.value.toDouble(),
                                  ))
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  textSpan(
                                    hint:
                                        'production_tasks_detail_should_packing'
                                            .tr,
                                    text: state.detailShouldPackQty.value
                                        .toString(),
                                  ),
                                  textSpan(
                                    hint: 'production_tasks_detail_packaged'.tr,
                                    text: state.detailPackagedQty.value
                                        .toString(),
                                  ),
                                  textSpan(
                                    hint:
                                        'production_tasks_detail_unpackaged'.tr,
                                    text: (state.detailShouldPackQty.value - state.detailPackagedQty.value).toString(),
                                  )
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            productionTasksTableItem(type: 1),
            Expanded(
              child: Obx(() => ListView(
                    children: [
                      for (var item in state.detailTableInfo)
                        productionTasksTableItem(data: item),
                      if (state.detailTableInfo.isNotEmpty)
                        productionTasksTableItem(type: 2),
                      if (state.detailPacketWay.isNotEmpty) _packetWay(),
                      if (state.detailSpecificRequirements.isNotEmpty)
                        _specificRequirements()
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductionTasksDetailTableItem extends StatelessWidget {
  final ProductionTasksDetailItemInfo? data;
  final int? type;
  final ProductionTasksLogic logic;

  const _ProductionTasksDetailTableItem({
    this.data,
    this.type,
    required this.logic,
  });

  @override
  Widget build(BuildContext context) {
    var effectiveData = data;
    var size = '';
    var qty = '';
    var productScannedQty = '';
    var manualScannedQty = '';
    var scannedQty = '';
    var owe = '';
    var completionRate = '';
    var installedQty = '';
    var scannedNotInstalled = '';
    var bkgColor = type != null && type == 1
        ? Colors.blueAccent
        : type == 2
            ? Colors.green.shade100
            : Colors.white;
    var textColor = type != null && type == 1 ? Colors.white : Colors.black87;
    if (type != null && type == 1) {
      size = 'production_tasks_detail_size'.tr;
      qty = 'production_tasks_detail_production_qty'.tr;
      productScannedQty = 'production_tasks_detail_auto_scan'.tr;
      manualScannedQty = 'production_tasks_detail_manual_scan'.tr;
      scannedQty = 'production_tasks_detail_total_scan'.tr;
      owe = 'production_tasks_detail_owing_qty'.tr;
      completionRate = 'production_tasks_detail_completion_rate'.tr;
      installedQty = 'production_tasks_detail_packaged_qty'.tr;
      scannedNotInstalled = 'production_tasks_detail_scanned_unpackaged'.tr;
    } else {
      if (type != null && type == 2) {
        effectiveData = logic.getDetailTotalItem();
      }
      size = effectiveData!.size ?? '';
      qty = effectiveData.qty.toShowString();
      productScannedQty = effectiveData.productScannedQty.toShowString();
      manualScannedQty = effectiveData.manualScannedQty.toShowString();
      scannedQty = effectiveData.scannedQty.toShowString();
      owe = effectiveData.getOwe().toShowString();
      completionRate = effectiveData.getCompletionRate();
      installedQty = effectiveData.installedQty.toShowString();
      scannedNotInstalled = effectiveData.scannedNotInstalled().toShowString();
    }
    return Row(
      children: [
        ExpandedFrameText(
          text: size,
          backgroundColor: bkgColor,
          textColor: textColor,
          isBold: true,
          alignment: Alignment.center,
        ),
        ExpandedFrameText(
          text: qty,
          backgroundColor: bkgColor,
          textColor: textColor,
          isBold: true,
          alignment: Alignment.center,
        ),
        ExpandedFrameText(
          text: productScannedQty,
          backgroundColor: bkgColor,
          textColor: textColor,
          isBold: true,
          alignment: Alignment.center,
        ),
        ExpandedFrameText(
          text: manualScannedQty,
          backgroundColor: bkgColor,
          textColor: textColor,
          isBold: true,
          alignment: Alignment.center,
        ),
        ExpandedFrameText(
          text: scannedQty,
          backgroundColor: bkgColor,
          textColor: textColor,
          isBold: true,
          alignment: Alignment.center,
        ),
        ExpandedFrameText(
          text: owe,
          backgroundColor: bkgColor,
          textColor: textColor,
          isBold: true,
          alignment: Alignment.center,
        ),
        ExpandedFrameText(
          text: completionRate,
          backgroundColor: bkgColor,
          textColor: textColor,
          isBold: true,
          alignment: Alignment.center,
        ),
        ExpandedFrameText(
          text: installedQty,
          backgroundColor: bkgColor,
          textColor: textColor,
          isBold: true,
          alignment: Alignment.center,
        ),
        ExpandedFrameText(
          text: scannedNotInstalled,
          backgroundColor: bkgColor,
          textColor: textColor,
          isBold: true,
          alignment: Alignment.center,
        ),
      ],
    );
  }
}
