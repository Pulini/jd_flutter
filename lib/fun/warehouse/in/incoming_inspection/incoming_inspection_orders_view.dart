import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/incoming_inspection_info.dart';
import 'package:jd_flutter/fun/warehouse/in/incoming_inspection/incoming_inspection_logic.dart';
import 'package:jd_flutter/fun/warehouse/in/incoming_inspection/incoming_inspection_order_closed_view.dart';
import 'package:jd_flutter/fun/warehouse/in/incoming_inspection/incoming_inspection_order_exception_close_view.dart';
import 'package:jd_flutter/fun/warehouse/in/incoming_inspection/incoming_inspection_order_exception_handling_view.dart';
import 'package:jd_flutter/fun/warehouse/in/incoming_inspection/incoming_inspection_order_signed_view.dart';
import 'package:jd_flutter/fun/warehouse/in/incoming_inspection/incoming_inspection_order_wait_inspection_view.dart';
import 'package:jd_flutter/fun/warehouse/in/incoming_inspection/incoming_inspection_order_wait_processing_view.dart';
import 'package:jd_flutter/fun/warehouse/in/incoming_inspection/incoming_inspection_state.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

class IncomingInspectionOrdersPage extends StatefulWidget {
  const IncomingInspectionOrdersPage({super.key});

  @override
  State<IncomingInspectionOrdersPage> createState() =>
      _IncomingInspectionOrdersPageState();
}

class _IncomingInspectionOrdersPageState
    extends State<IncomingInspectionOrdersPage> {
  final IncomingInspectionLogic logic = Get.find<IncomingInspectionLogic>();
  final IncomingInspectionState state =
      Get.find<IncomingInspectionLogic>().state;

  var dpcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.incomingInspection.name}${PickerType.startDate}',
  )..firstDate = DateTime(
      DateTime.now().year - 4, DateTime.now().month, DateTime.now().day);
  var dpcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.incomingInspection.name}${PickerType.endDate}',
  );

  Widget _item(InspectionOrderInfo item) {
    return GestureDetector(
      onTap: () {
        logic.getInspectionOrderDetail(
          interID: item.interID ?? '',
          success: () {
            switch (item.status) {
              case '1':
                Get.to(() => const OrderWaitInspectionPage())?.then((refresh) {
                  if (refresh) _query(true);
                });
                break;
              case '2':
                Get.to(() => const OrderWaitProcessingPage())?.then((refresh) {
                  if (refresh) _query(true);
                });
                break;
              case '3':
                Get.to(() => const OrderSignedPage())?.then((refresh) {
                  if (refresh) _query(true);
                });
                break;
              case '4':
                Get.to(() => const OrderExceptionHandlingPage())
                    ?.then((refresh) {
                  if (refresh) _query(true);
                });
                break;
              case '5':
                Get.to(() => const OrderExceptionClosePage())?.then((refresh) {
                  if (refresh) _query(true);
                });
                break;
              case '6':
                Get.to(() => const OrderClosedPage())?.then((refresh) {
                  if (refresh) _query(true);
                });
                break;
            }
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              item.status == '1' || item.status == '2'
                  ? Colors.orange.shade100
                  : item.status == '3'
                      ? Colors.green.shade100
                      : item.status == '4' || item.status == '5'
                          ? Colors.red.shade100
                          : Colors.blue.shade100,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          // color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: item.status == '1' || item.status == '2'
                ? Colors.orange
                : item.status == '3'
                    ? Colors.green
                    : item.status == '4' || item.status == '5'
                        ? Colors.red
                        : Colors.blue,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                expandedTextSpan(
                  hint: 'incoming_inspection_order_order_no'.tr,
                  text: item.number ?? '',
                  textColor: Colors.green,
                ),
                SizedBox(
                  width: 120,
                  child: textSpan(
                      hint: 'incoming_inspection_order_applicant'.tr,
                      text: item.empName ?? ''),
                ),
              ],
            ),
            textSpan(
              hint: 'incoming_inspection_order_suppler'.tr,
              text: item.supplier ?? '',
              textColor: Colors.black54,
            ),
            textSpan(
              hint: 'incoming_inspection_order_modify_date'.tr,
              text: item.applicationDate ?? '',
              textColor: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  Widget _radio({required String text, required String value}) {
    return Expanded(
      child: InkWell(
        onTap: () => state.inspectionType.value = value,
        child: Row(
          children: [
            Obx(() => Radio(
                  value: value,
                  onChanged: (v) => state.inspectionType.value = v!,
                  groupValue: state.inspectionType.value,
                )),
            Text(text),
          ],
        ),
      ),
    );
  }

  _showSearch() {
    showSheet(
      bodyPadding: const EdgeInsets.all(0),
      context: context,
      body: Container(
        height: MediaQuery.of(context).size.height * 0.35,
        padding:
            const EdgeInsets.only(left: 10, top: 20, right: 10, bottom: 20),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          gradient: LinearGradient(
            colors: [Colors.grey.shade100, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _radio(
                  text: 'incoming_inspection_order_wait_inspection'.tr,
                  value: '1',
                ),
                _radio(
                  text: 'incoming_inspection_order_wait_processing'.tr,
                  value: '2',
                ),
                _radio(
                  text: 'incoming_inspection_order_signed'.tr,
                  value: '3',
                ),
              ],
            ),
            Row(
              children: [
                _radio(
                  text:
                      'incoming_inspection_order_exception_wait_processing'.tr,
                  value: '4',
                ),
                _radio(
                  text: 'incoming_inspection_order_exception_processed'.tr,
                  value: '5',
                ),
                _radio(
                  text: 'incoming_inspection_order_closed'.tr,
                  value: '6',
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: DatePicker(pickerController: dpcStartDate)),
                Expanded(child: DatePicker(pickerController: dpcEndDate)),
              ],
            ),
            EditText(
              hint: 'incoming_inspection_order_suppler_query_tips'.tr,
              initStr: state.inspectionSuppler.value,
              onChanged: (s) => state.inspectionSuppler.value = s,
            ),
            Expanded(child: Container()),
            SizedBox(
              width: double.infinity,
              child: CombinationButton(
                text: 'incoming_inspection_order_query'.tr,
                click: _query(false),
              ),
            ),
          ],
        ),
      ),
      scrollControlled: true,
    );
  }

  _query(bool isRefresh) {
    logic.queryInspectionOrders(
      startDate: dpcStartDate.getDateFormatYMD(),
      endDate: dpcEndDate.getDateFormatYMD(),
      success: () =>isRefresh?null: Navigator.pop(context),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logic.queryInspectionOrders(
        startDate: dpcStartDate.getDateFormatYMD(),
        endDate: dpcEndDate.getDateFormatYMD(),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'incoming_inspection_order_inspection_list'.tr,
      actions: [
        IconButton(
          onPressed: _showSearch,
          icon: const Icon(Icons.search),
        ),
      ],
      body: Obx(
        () => ListView.builder(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
            itemCount: state.inspectionOrderList.length,
            itemBuilder: (c, i) => _item(state.inspectionOrderList[i])),
      ),
    );
  }
}
