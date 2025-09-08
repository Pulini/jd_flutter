import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_scan_info.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_packing_scan/sap_packing_scan_logic.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_packing_scan/sap_packing_scan_state.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';


class SapPackingDeliveryOrderListPage extends StatefulWidget {
  const SapPackingDeliveryOrderListPage({super.key});

  @override
  State<SapPackingDeliveryOrderListPage> createState() =>
      _SapPackingDeliveryOrderListPageState();
}

class _SapPackingDeliveryOrderListPageState
    extends State<SapPackingDeliveryOrderListPage> {
  final SapPackingScanLogic logic = Get.find<SapPackingScanLogic>();
  final SapPackingScanState state = Get.find<SapPackingScanLogic>().state;

  _modifyDateDialog(PickingScanDeliveryOrderInfo data) {
    var postingDate = DateTime.parse(data.orderDate ?? '');
    var epcDate = DatePickerController(
      PickerType.date,
      initDate: postingDate.millisecondsSinceEpoch,
      firstDate: postingDate,
      lastDate:
          DateTime(postingDate.year, postingDate.month + 1, postingDate.day),
      buttonName: '过账日期',
    );
    Get.dialog(
      PopScope(
          canPop: true,
          child: AlertDialog(
            contentPadding: const EdgeInsets.only(left: 10, right: 10),
            title: const Text('修改交货日期'),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, top: 20, bottom: 10),
                    child: textSpan(hint: '交货单号：', text: data.orderNo ?? ''),
                  ),
                  DatePicker(pickerController: epcDate),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => logic.modifyDeliveryOrderDate(
                  deliveryOrderNo: data.orderNo ?? '',
                  modifyDate: epcDate.getDateFormatYMD(),
                  callback: () => Get.back(),
                ),
                child: const Text('提交修改'),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'dialog_default_cancel'.tr,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '交货单列表',
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(children: [
          CupertinoSearchTextField(
            decoration: BoxDecoration(
              color: Colors.white54,
              borderRadius: BorderRadius.circular(20),
            ),
            placeholder: '请输入交货单号或过账日期进行筛选',
            onChanged: (v) => state.deliveryOrderSearchText.value = v,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(() {
              var showData = logic.getDeliveryOrders();
              return ListView.builder(
                itemCount: showData.length,
                itemBuilder: (c, i) => GestureDetector(
                  onTap: () => _modifyDateDialog(showData[i]),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.all(7),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        expandedTextSpan(
                          hint: '交货单号：',
                          text: showData[i].orderNo ?? '',
                        ),
                        textSpan(
                          hint: '过账日期：',
                          text: showData[i].orderDate ?? '',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          )
        ]),
      ),
    );
  }
}
