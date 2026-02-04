import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/pack_order_list_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/part_dispatch_label_manage/part_dispatch_label_list/part_dispatch_label_list_view.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
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

  Widget _item(PackOrderInfo data) => Container(
        margin: EdgeInsetsGeometry.only(bottom: 5),
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
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.to(() => PartDispatchLabelListPage(
                        packOrderId: data.packageId??0,
                      )),
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            expandedTextSpan(
                              flex: 3,
                              hint: '组织：',
                              text: data.organizeName ?? '',
                            ),
                            expandedTextSpan(
                              flex: 3,
                              hint: '包装清单号：',
                              text: data.packageNo ?? '',
                            ),
                            expandedTextSpan(
                              hint: '制单日期：',
                              text: data.date ?? '',
                            ),
                          ],
                        ),
                        textSpan(hint: '派工单号：', text: data.workCardNo ?? ''),
                        textSpan(hint: '指令：', text: data.billNO ?? ''),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            expandedTextSpan(
                              flex: 3,
                              hint: '型体：',
                              text: data.productName ?? '',
                            ),
                            expandedTextSpan(
                              flex: 3,
                              hint: '制程：',
                              text: data.processName ?? '',
                            ),
                            expandedTextSpan(
                              hint: '制单人：',
                              text: data.userName ?? '',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    logic.deletePackOrder(data: data, refresh: () => _query()),
                child: Container(
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(7),
                      bottomRight: Radius.circular(7),
                    ),
                    color: Colors.red,
                  ),
                  child: Center(
                    child: Icon(Icons.delete_forever, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      );

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
              contentPadding: const EdgeInsets.only(
                left: 10,
                right: 10,
              ),
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
              labelText: '派工单号',
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
                icon: Icon(Icons.qr_code_scanner, color: Colors.blue),
              ),
            ),
          ),
        ),
        EditText(
          controller: tecTypeBody,
          hint: '型体',
        ),
        DatePicker(pickerController: dpcStartDate),
        DatePicker(pickerController: dpcEndDate),
      ],
      query: () => _query(),
      body: Obx(() => ListView.builder(
            padding: EdgeInsetsGeometry.only(left: 5, right: 5, bottom: 5),
            itemCount: state.packOrderList.length,
            itemBuilder: (c, i) => _item(state.packOrderList[i]),
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<PackOrderListLogic>();
    super.dispose();
  }
}
