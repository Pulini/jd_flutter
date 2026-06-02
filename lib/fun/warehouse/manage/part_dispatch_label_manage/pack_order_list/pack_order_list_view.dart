import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/pack_order_list_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/part_dispatch_label_manage/part_dispatch_label_list/part_dispatch_label_list_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/part_dispatch_label_manage/part_dispatch_label_manage_dialog.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'pack_order_list_logic.dart';
import 'pack_order_list_state.dart';

class PackOrderListPage extends StatefulWidget {
  const PackOrderListPage({super.key});

  @override
  State<PackOrderListPage> createState() => _PackOrderListPageState();
}

class _PackOrderListPageState extends State<PackOrderListPage> {
  final PackOrderListLogic logic = Get.put(PackOrderListLogic());
  final PackOrderListState state = Get.find<PackOrderListLogic>().state;
  var tecDispatchOrderNo = TextEditingController();

  var tecTypeBody = TextEditingController(text: 'PNS26312586-01');

  var dpcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.productionDispatch.name}${PickerType.startDate}',
  );
  var dpcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.productionDispatch.name}${PickerType.endDate}',
  );

  void _query() {
    logic.queryPackOrders(
      dispatchOrderNo: tecDispatchOrderNo.text,
      typeBody: tecTypeBody.text,
      startDate: dpcStartDate.getDateFormatYMD(),
      endDate: dpcEndDate.getDateFormatYMD(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      queryWidgets: [
        Container(
          margin: const EdgeInsets.all(5),
          height: 40,
          child: TextField(
            controller: tecDispatchOrderNo,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(left: 10, right: 10),
              filled: true,
              fillColor: Colors.grey[300],
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: Colors.transparent,
                ),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              labelText: 'part_dispatch_pack_order_input_dispatch_order_no'.tr,
              labelStyle: const TextStyle(color: Colors.black54),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => tecDispatchOrderNo.clear(),
              ),
              prefixIcon: IconButton(
                onPressed: () => scannerDialog(
                  detect: (code) {
                    tecDispatchOrderNo.text = code;
                    _query();
                  },
                ),
                icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
              ),
            ),
          ),
        ),
        EditText(
          controller: tecTypeBody,
          hint: 'part_dispatch_pack_order_input_type_body'.tr,
        ),
        DatePicker(pickerController: dpcStartDate),
        DatePicker(pickerController: dpcEndDate),
      ],
      query: () => _query(),
      body: Obx(() => ListView.builder(
            padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
            itemCount: state.packOrderList.length,
            itemBuilder: (c, i) => _PackOrderItem(
              data: state.packOrderList[i],
              state: state,
              logic: logic,
              onQuery: () => _query(),
            ),
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<PackOrderListLogic>();
    super.dispose();
  }
}

class _PackOrderItem extends StatelessWidget {
  final OrderPackageInfo data;
  final PackOrderListState state;
  final PackOrderListLogic logic;
  final VoidCallback onQuery;
  const _PackOrderItem({
    required this.data,
    required this.state,
    required this.logic,
    required this.onQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2),
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            GestureDetector(
              onTap: () => selectPackProfileDialog(
                orderPackProfileID: data.packProfileID ?? 0,
                capacityQty: data.capacityQty ?? 0,
                packProfileList: state.packProfileList,
                callback: (int packProfileID, double capacityQty) =>
                    logic.modifyOrderPackProfile(
                  packOrderID: data.packProfileID ?? 0,
                  packProfileID: packProfileID,
                  capacityQty: capacityQty,
                  refresh: () => onQuery(),
                ),
              ),
              child: Container(
                width: 40,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(7),
                    bottomLeft: Radius.circular(7),
                  ),
                  color: Colors.green,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/ic_box.png',
                    color: Colors.white,
                    width: 25,
                    height: 25,
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (checkUserPermission('601080111')) {
                    Get.to(() => PartDispatchLabelListPage(
                          packOrderId: data.packageId ?? 0,
                        ));
                  } else {
                    errorDialog(
                        content:
                            'part_dispatch_pack_order_no_print_permission'.tr);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          expandedTextSpan(
                            flex: 5,
                            hint: 'part_dispatch_pack_order_organization'.tr,
                            text: data.organizeName ?? '',
                            textColor: Colors.black54,
                          ),
                          expandedTextSpan(
                            flex: 5,
                            hint: 'part_dispatch_pack_order_pack_order_no'.tr,
                            text: data.packageNo ?? '',
                            textColor: Colors.black54,
                          ),
                          expandedTextSpan(
                            flex: 2,
                            hint: 'part_dispatch_pack_order_make_date'.tr,
                            text: data.date ?? '',
                            textColor: Colors.black54,
                          ),
                        ],
                      ),
                      textSpan(
                        hint: 'part_dispatch_pack_order_dispatch_order_no'.tr,
                        text: data.workCardNo ?? '',
                        textColor: Colors.black54,
                      ),
                      textSpan(
                        hint: 'part_dispatch_pack_order_instruction'.tr,
                        text: data.billNO ?? '',
                        textColor: Colors.black54,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          expandedTextSpan(
                            flex: 5,
                            hint:
                                'part_dispatch_pack_order_type_body_tips'.tr,
                            text: data.productName ?? '',
                            textColor: Colors.black54,
                          ),
                          expandedTextSpan(
                            flex: 5,
                            hint: 'part_dispatch_pack_order_process'.tr,
                            text: data.processName ?? '',
                            textColor: Colors.black54,
                          ),
                          expandedTextSpan(
                            flex: 2,
                            hint: 'part_dispatch_pack_order_maker'.tr,
                            text: data.userName ?? '',
                            textColor: Colors.black54,
                          ),
                        ],
                      ),
                      Text(
                        'part_dispatch_pack_order_pack_profile'.trArgs([
                          logic.getOrderPackProfile(data.packProfileID),
                          data.capacityQty.toShowString()
                        ]),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () =>
                  logic.deletePackOrder(data: data, refresh: () => onQuery()),
              child: Container(
                width: 40,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                  ),
                  color: Colors.red,
                ),
                child: const Center(
                  child: Icon(Icons.delete_forever, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
