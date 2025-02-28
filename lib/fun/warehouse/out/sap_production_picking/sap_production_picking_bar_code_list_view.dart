import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_production_picking/sap_production_picking_logic.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_production_picking/sap_production_picking_state.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

class BarCodeListPage extends StatefulWidget {
  const BarCodeListPage({super.key});

  @override
  State<BarCodeListPage> createState() => _BarCodeListPageState();
}

class _BarCodeListPageState extends State<BarCodeListPage> {
  final SapProductionPickingLogic logic = Get.find<SapProductionPickingLogic>();
  final SapProductionPickingState state =
      Get.find<SapProductionPickingLogic>().state;

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'sap_production_picking_barcode_list_scanned_barcode_list'.tr,
      body: Obx(() => ListView.builder(
            itemCount: state.barCodeList.where((v) => v.scanned).length,
            itemBuilder: (c, i) {
              var data = state.barCodeList.where((v) => v.scanned).toList()[i];
              return Card(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          textSpan(
                              hint:
                                  'sap_production_picking_barcode_list_barcode'
                                      .tr,
                              text: data.barCode ?? ''),
                          textSpan(
                            hint: 'sap_production_picking_barcode_list_material'
                                .tr,
                            text:
                                '${data.materialName}<${data.materialNumber}>',
                          ),
                        ],
                      ),
                    ),
                    Text('${data.qty}${data.unitName}'),
                    IconButton(
                      onPressed: () {
                        data.scanned = false;
                      },
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                    )
                  ],
                ),
              );
            },
          )),
    );
  }
}
