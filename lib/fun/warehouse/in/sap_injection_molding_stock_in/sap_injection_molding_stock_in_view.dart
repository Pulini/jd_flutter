import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'sap_injection_molding_stock_in_logic.dart';
import 'sap_injection_molding_stock_in_state.dart';

class SapInjectionMoldingStockInPage extends StatefulWidget {
  const SapInjectionMoldingStockInPage({super.key});

  @override
  State<SapInjectionMoldingStockInPage> createState() =>
      _SapInjectionMoldingStockInPageState();
}

class _SapInjectionMoldingStockInPageState
    extends State<SapInjectionMoldingStockInPage> {
  final SapInjectionMoldingStockInLogic logic =
      Get.put(SapInjectionMoldingStockInLogic());
  final SapInjectionMoldingStockInState state =
      Get.find<SapInjectionMoldingStockInLogic>().state;
  var controller = EasyRefreshController(controlFinishRefresh: true);

  _item(BarCodeInfo bci) {
    var barCode = Text(
      bci.code ?? '',
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
    );
    return Container(
      margin: const EdgeInsets.only(left: 4, right: 4, bottom: 10),
      padding: const EdgeInsets.only(left: 4, right: 4),
      decoration: BoxDecoration(
        color: bci.isUsed ? Colors.grey.shade300 : Colors.blue.shade100,
        borderRadius: BorderRadius.circular(10),
        border: bci.isUsed
            ? Border.all(color: Colors.red, width: 2)
            : Border.all(color: Colors.blue.shade300, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: bci.palletNo?.isNotEmpty == true
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      barCode,
                      Text(bci.palletNo ?? ''),
                    ],
                  )
                : barCode,
          ),
          if (bci.isUsed)
            Text(
              'sap_injection_molding_stock_in_submitted'.tr,
              style: const TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    pdaScanner(scan: (code) => logic.scanCode(code));
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => logic.refreshBarCodeStatus(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        TextButton(
          onPressed: () => logic.clearBarCodeList(),
          child: Text('sap_injection_molding_stock_in_clear'.tr),
        )
      ],
      body: Obx(() => Column(
            children: [
              Expanded(
                child: EasyRefresh(
                  controller: controller,
                  header: const MaterialHeader(),
                  onRefresh: () => logic.refreshBarCodeStatus(
                    refresh: () => controller.finishRefresh(),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: state.barCodeList.length,
                    itemBuilder: (c, i) => Slidable(
                      key: ValueKey(i),
                      child: _item(state.barCodeList[i]),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            flex: 2,
                            onPressed: (c) =>
                                logic.deleteItem(state.barCodeList[i]),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete_forever,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    textSpan(
                      hint: 'sap_injection_molding_stock_in_scanned'.tr,
                      text: state.barCodeList.length.toString(),
                    ),
                    textSpan(
                      hint: 'sap_injection_molding_stock_in_pallet_no'.tr,
                      text: state.palletNumber.value,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: CombinationButton(
                  text: 'sap_injection_molding_stock_in_stock_in'.tr,
                  click: () => logic.goStockInReport(),
                ),
              )
            ],
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<SapInjectionMoldingStockInLogic>();
    super.dispose();
  }
}
