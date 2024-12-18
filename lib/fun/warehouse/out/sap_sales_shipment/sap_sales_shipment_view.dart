import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

import 'sap_sales_shipment_logic.dart';
import 'sap_sales_shipment_state.dart';

class SapSalesShipmentPage extends StatefulWidget {
  const SapSalesShipmentPage({super.key});

  @override
  State<SapSalesShipmentPage> createState() => _SapSalesShipmentPageState();
}

class _SapSalesShipmentPageState extends State<SapSalesShipmentPage> {
  final SapSalesShipmentLogic logic = Get.put(SapSalesShipmentLogic());
  final SapSalesShipmentState state = Get.find<SapSalesShipmentLogic>().state;
  var insController = TextEditingController();
  var dpcDate = DatePickerController(PickerType.date, buttonName: '交货日期');

  _item(String orderList) {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithBottomSheet(
      bottomSheet: [
        EditText(
          hint: '指令号',
          controller: insController,
        ),
        DatePicker(pickerController: dpcDate),
      ],
      query: () => logic.query(
        insController.text,
        dpcDate.getDateFormatSapYMD(),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: state.orderList.length,
              itemBuilder: (c, i) => _item(state.orderList[i]),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: CombinationButton(
              text: '提交出库',
              click: () {},
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<SapSalesShipmentLogic>();
    super.dispose();
  }
}
