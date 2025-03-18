import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/incoming_inspection_info.dart';
import 'package:jd_flutter/fun/warehouse/in/incoming_inspection/incoming_inspection_dialog.dart';
import 'package:jd_flutter/fun/warehouse/in/incoming_inspection/incoming_inspection_logic.dart';
import 'package:jd_flutter/fun/warehouse/in/incoming_inspection/incoming_inspection_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/view_photo.dart';

class OrderWaitInspectionPage extends StatefulWidget {
  const OrderWaitInspectionPage({super.key});

  @override
  State<OrderWaitInspectionPage> createState() =>
      _OrderWaitInspectionPageState();
}

class _OrderWaitInspectionPageState extends State<OrderWaitInspectionPage> {
  final IncomingInspectionLogic logic = Get.find<IncomingInspectionLogic>();
  final IncomingInspectionState state =
      Get.find<IncomingInspectionLogic>().state;

  Widget _photoItem(File f) => Stack(
        children: [
          GestureDetector(
            onTap: () {
              Get.to(() => ViewFilePhoto(
                    photos: state.inspectionPhotoList,
                  ));
            },
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Hero(tag: f.path, child: Image.file(f)),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              onPressed: () => logic.deleteInspectionPhoto(f),
              icon: const Icon(
                Icons.cancel_outlined,
                color: Colors.red,
                size: 35,
              ),
            ),
          )
        ],
      );

  Widget _addPhoto() => Padding(
        padding: const EdgeInsets.all(7),
        child: AspectRatio(
          aspectRatio: 1 / 1,
          child: GestureDetector(
            onTap: () => takePhoto(
              callback: (f) => state.inspectionPhotoList.add(f),
              title: 'incoming_inspection_order_inspection_site_photos'.tr,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade100, Colors.green.shade100],
                ),
              ),
              child: const Icon(
                Icons.add_a_photo_outlined,
                color: Colors.blue,
                size: 80,
              ),
            ),
          ),
        ),
      );

  _materialItem(InspectionMaterielInfo item) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textSpan(
                hint: 'incoming_inspection_order_material'.tr,
                hintColor: Colors.black54,
                text: '(${item.itemNumber}) ${item.itemName}'
                    .allowWordTruncation(),
                maxLines: 3),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textSpan(
                  hint: 'incoming_inspection_order_order_no'.tr,
                  hintColor: Colors.black54,
                  text: item.billNo ?? '',
                  textColor: Colors.black54,
                ),
                Text(
                  '${item.auxQty.toShowString()} ${item.unitName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                )
              ],
            )
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'incoming_inspection_order_inspection',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 130,
            margin: const EdgeInsets.only(left: 8, right: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Obx(() => ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (var f in state.inspectionPhotoList) _photoItem(f),
                    _addPhoto()
                  ],
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textSpan(
                  hint: 'incoming_inspection_order_suppler'.tr,
                  text: state.inspectionDetail?.supplier ?? '',
                  textColor: Colors.red,
                ),
                textSpan(
                  hint: 'incoming_inspection_order_delivery_qty'.tr,
                  text: state.inspectionDetail?.materielList
                          ?.map((v) => v.numPage ?? 0)
                          .reduce((a, b) => a + b)
                          .toString() ??
                      '',
                  textColor: Colors.red,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 8, right: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(5),
                itemCount: (state.inspectionDetail?.materielList ?? []).length,
                itemBuilder: (c, i) => _materialItem(
                    (state.inspectionDetail?.materielList ?? [])[i]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: textSpan(
              hint: 'incoming_inspection_order_application_info'.tr,
              text:
                  '${state.inspectionDetail?.billDate} ${state.inspectionDetail?.builder}',
              textColor: Colors.black54,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: CombinationButton(
              text: 'incoming_inspection_order_submit_inspection'.tr,
              click: () {
                if (state.inspectionPhotoList.isEmpty) {
                  showSnackBar(message: 'incoming_inspection_order_no_photos_tips'.tr, isWarning: true);
                } else {
                  submitInspectionDialog(
                    submit: (w, r) => logic.submitInspection(
                      inspector: w.empCode ?? '',
                      results: r,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    state.inspectionPhotoList.clear();
    super.dispose();
  }
}
