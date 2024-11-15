import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_purchase_stock_in_info.dart';
import 'package:jd_flutter/fun/warehouse/sap_purchase_stock_in/sap_purchase_stock_in_dialog.dart';
import 'package:jd_flutter/fun/warehouse/sap_purchase_stock_in/sap_purchase_stock_in_logic.dart';
import 'package:jd_flutter/fun/warehouse/sap_purchase_stock_in/sap_purchase_stock_in_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

class SapPurchaseStockInCheckPage extends StatefulWidget {
  const SapPurchaseStockInCheckPage({super.key});

  @override
  State<SapPurchaseStockInCheckPage> createState() =>
      _SapPurchaseStockInCheckPageState();
}

class _SapPurchaseStockInCheckPageState
    extends State<SapPurchaseStockInCheckPage> {
  final SapPurchaseStockInLogic logic = Get.find<SapPurchaseStockInLogic>();
  final SapPurchaseStockInState state =
      Get.find<SapPurchaseStockInLogic>().state;
  int index = Get.arguments['index'];

  _item(SapPurchaseStockInInfo info) {
    var controller = TextEditingController(text: info.editQty.toShowString());
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textSpan(
            hint: '物料：',
            text: '(${info.materialCode})${info.materialDescription}',
            textColor: Colors.red,
          ),
          const SizedBox(height: 10),
          textSpan(
            hint: '采购单号：',
            text: '${info.purchaseOrder}-${info.purchaseOrderLineItem}',
            isBold: false,
            hintColor: Colors.grey.shade700,
          ),
          Row(
            children: [
              expandedTextSpan(
                hint: '送货数：',
                isBold: false,
                hintColor: Colors.grey.shade700,
                text: info.qty.toShowString(),
              ),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      '核查数：',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    SizedBox(
                      width: 80,
                      height: 35,
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                        ],
                        onChanged: (v) => info.editQty = v.toDoubleTry(),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(
                            top: 0,
                            bottom: 0,
                            left: 10,
                            right: 10,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              textSpan(
                hint: '件数：',
                isBold: false,
                hintColor: Colors.grey.shade700,
                text: info.numPage.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var data = state.orderList[index];
    return Obx(() => pageBody(
          title: '送货单核查',
          actions: [
            TextButton(
              onPressed: () => checkSaveDialog(
                factoryNumber: data[0].factory ?? '',
                location: data[0].location ?? '',
                callback: (location, inspector) {
                  logic.saveDeliveryCheck(
                    location: location,
                    inspector: inspector,
                    list: data,
                  );
                },
              ),
              child: Text('提交'),
            )
          ],
          body: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: data.length,
            itemBuilder: (c, i) => _item(data[i]),
          ),
        ));
  }
}
