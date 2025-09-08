import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/production_tasks_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

import 'production_tasks_logic.dart';
import 'production_tasks_state.dart';

class ProductionTasksPackMaterialPage extends StatefulWidget {
  const ProductionTasksPackMaterialPage({super.key});

  @override
  State<ProductionTasksPackMaterialPage> createState() =>
      _ProductionTasksPackMaterialPageState();
}

class _ProductionTasksPackMaterialPageState
    extends State<ProductionTasksPackMaterialPage> {
  final ProductionTasksLogic logic = Get.find<ProductionTasksLogic>();
  final ProductionTasksState state = Get.find<ProductionTasksLogic>().state;
  String instruction = Get.arguments['instruction'];
  var controller = TextEditingController();

  Widget _item(ProductionTasksPackMaterialInfo data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade100,
            Colors.green.shade100,
          ],
        ),
        border: Border.all(
          color: Colors.blueAccent,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textSpan(
            hint: 'production_tasks_pack_material_material_and_unit'.tr,
            text:
                '(${data.materialCode})${data.materialName}  < ${data.unit} >',
            textColor: Colors.green.shade700,
            fontSize: 16,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              expandedTextSpan(
                flex: 2,
                hint: 'production_tasks_pack_material_customer_po'.tr,
                text: '${data.customerPo}',
                textColor: Colors.black54,
              ),
              expandedTextSpan(
                flex: 2,
                hint: 'production_tasks_pack_material_customer_goods_no'.tr,
                text: '${data.customerGoodsNo}',
                textColor: Colors.black54,
              ),
              expandedTextSpan(
                hint: 'production_tasks_pack_material_purchase_type'.tr,
                text: '${data.purchaseType}',
                textColor: Colors.black54,
              ),
            ],
          ),
          Row(
            children: [
              expandedTextSpan(
                flex: 2,
                hint: 'production_tasks_pack_material_demand_qty'.tr,
                text: data.demandQty.toShowString(),
                textColor: Colors.black54,
              ),
              expandedTextSpan(
                flex: 2,
                hint: 'production_tasks_pack_material_inventory_qty'.tr,
                text: data.inventoryQty.toShowString(),
                textColor: Colors.black54,
              ),
              expandedTextSpan(
                hint: 'production_tasks_pack_material_received_qty'.tr,
                text: data.receivedQty.toShowString(),
                textColor: Colors.black54,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'production_tasks_pack_material_packing_list'.tr,
      actions: [
        Container(
          width: 240,
          margin: const EdgeInsets.only(right: 10),
          child: CupertinoSearchTextField(
            decoration: BoxDecoration(
              color: Colors.white54,
              borderRadius: BorderRadius.circular(20),
            ),
            placeholder: 'production_tasks_pack_material_quick_filter'.tr,
            onChanged: (v) => logic.searchPackMaterial(v),
          ),
        )
      ],
      body: Obx(() => ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: state.packMaterialShowList.length,
            itemBuilder: (c, i) => _item(state.packMaterialShowList[i]),
          )),
    );
  }

  @override
  void dispose() {
    state.packMaterialList.clear();
    state.packMaterialShowList.clear();
    super.dispose();
  }
}
