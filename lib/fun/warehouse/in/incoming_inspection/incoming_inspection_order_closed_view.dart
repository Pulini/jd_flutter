import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/incoming_inspection_info.dart';
import 'package:jd_flutter/bean/http/response/photo_bean.dart';
import 'package:jd_flutter/fun/warehouse/in/incoming_inspection/incoming_inspection_logic.dart';
import 'package:jd_flutter/fun/warehouse/in/incoming_inspection/incoming_inspection_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/view_photo.dart';

class OrderClosedPage extends StatefulWidget {
  const OrderClosedPage({super.key});

  @override
  State<OrderClosedPage> createState() => _OrderClosedPageState();
}

class _OrderClosedPageState extends State<OrderClosedPage> {
  final IncomingInspectionLogic logic = Get.find<IncomingInspectionLogic>();
  final IncomingInspectionState state =
      Get.find<IncomingInspectionLogic>().state;

  Widget _photoItem(PhotoBean item) => GestureDetector(
        onTap: () {
          Get.to(() => ViewNetPhoto(
                photos: [
                  for (PhotoBean f in state.inspectionDetail?.pictureList ?? [])
                    f.photo ?? ''
                ],
              ));
        },
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Hero(
              tag: item.photo ?? '',
              child: Image.network(
                item.photo ?? '',
                fit: BoxFit.cover,
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
      title: 'incoming_inspection_order_closed'.tr,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: getScreenSize().height * 0.25,
            child: Swiper(
              itemBuilder: (c, i) =>
                  _photoItem((state.inspectionDetail?.pictureList ?? [])[i]),
              itemCount: (state.inspectionDetail?.pictureList ?? []).length,
              pagination: const SwiperPagination(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: textSpan(
              hint: 'incoming_inspection_order_delivery_qty'.tr,
              text: state.inspectionDetail?.materielList
                      ?.map((v) => v.numPage ?? 0)
                      .reduce((a, b) => a + b)
                      .toString() ??
                  '',
              textColor: Colors.red,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textSpan(
                  hint: 'incoming_inspection_order_application_info'.tr,
                  text:
                      '${state.inspectionDetail?.billDate} ${state.inspectionDetail?.builder}',
                  textColor: Colors.black54,
                ),
                textSpan(
                  hint: 'incoming_inspection_order_inspection_info'.tr,
                  text:
                      '${state.inspectionDetail?.inspectionDate} ${state.inspectionDetail?.inspector}',
                  textColor: Colors.black54,
                ),
                textSpan(
                  hint: 'incoming_inspection_order_inspection_result'.tr,
                  text: state.inspectionDetail?.inspectionResult ?? '',
                  textColor: Colors.black54,
                ),
                textSpan(
                  hint: 'incoming_inspection_order_exception_info'.tr,
                  text:
                      '${state.inspectionDetail?.exceptionDate} ${state.inspectionDetail?.exception}',
                  textColor: Colors.black54,
                ),
                textSpan(
                  hint: 'incoming_inspection_order_exception_reason'.tr,
                  text: state.inspectionDetail?.exceptionInformation ?? '',
                  textColor: Colors.black54,
                ),
                textSpan(
                  hint: 'incoming_inspection_order_exception_disposed_info'.tr,
                  text:
                      '${state.inspectionDetail?.exceptionProcessingTime} ${state.inspectionDetail?.exceptionHandler}',
                  textColor: Colors.black54,
                ),
                textSpan(
                  hint:
                      'incoming_inspection_order_exception_disposed_result'.tr,
                  text: state.inspectionDetail?.exceptionHandling ?? '',
                  textColor: Colors.black54,
                ),
                textSpan(
                  hint: 'incoming_inspection_order_close_case_info'.tr,
                  text:
                      '${state.inspectionDetail?.closerDate} ${state.inspectionDetail?.closer}',
                  textColor: Colors.black54,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
