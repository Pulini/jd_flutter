import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_sales_shipment/sap_sales_shipment_logic.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_sales_shipment/sap_sales_shipment_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class SapSalesShipmentPalletView extends StatefulWidget {
  const SapSalesShipmentPalletView({super.key});

  @override
  State<SapSalesShipmentPalletView> createState() =>
      _SapSalesShipmentPalletViewState();
}

class _SapSalesShipmentPalletViewState
    extends State<SapSalesShipmentPalletView> {
  final SapSalesShipmentLogic logic = Get.find<SapSalesShipmentLogic>();
  final SapSalesShipmentState state = Get.find<SapSalesShipmentLogic>().state;
  int index = Get.arguments['index'];

  _item(List<SapPalletDetailInfo> p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              expandedTextSpan(
                hint: '托盘号：',
                text: p[0].palletNumber ?? '',
                textColor: Colors.red,
              ),
              Checkbox(
                value: p.every((v) => v.pickQty == v.quantity),
                onChanged: (c) => setState(() {
                  for (var v in p) {
                    v.pickQty = c! ? v.quantity ?? 0 : 0;
                  }
                }),
              ),
            ],
          ),
          const Divider(height: 10, color: Colors.black),
          for (var item in p)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          textSpan(
                            hint: '标签号：',
                            text: item.labelCode ?? '',
                            isBold: false,
                            textColor: Colors.green,
                          ),
                          textSpan(
                            hint: '数量：',
                            isBold: false,
                            text: item.quantity.toShowString(),
                            textColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: item.pickQty == item.quantity,
                      onChanged: (c) => setState(
                          () => item.pickQty = c! ? item.quantity ?? 0 : 0),
                    ),
                  ],
                ),
                const Divider(height: 10, color: Colors.black),
              ],
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    pdaScanner(scan: (code) => logic.scanCode(code));
    WidgetsBinding.instance.addPostFrameCallback((_)  => logic.getPalletList(index));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        IconButton(
          onPressed: () => askDialog(
            content: '确定要重置标签状态吗？',
            confirm: () => logic.refreshPallet(index),
          ),
          icon: const Icon(Icons.refresh, color: Colors.blue),
        )
      ],
      title: '扫瞄或勾选对应标签',
      body: Obx(() => ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: state.palletList.length,
            itemBuilder: (c, i) => _item(state.palletList[i]),
          )),
    );
  }

  @override
  void dispose() {
    state.palletList.clear();
    super.dispose();
  }
}