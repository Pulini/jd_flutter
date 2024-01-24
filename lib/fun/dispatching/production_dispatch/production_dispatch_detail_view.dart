import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../route.dart';
import '../../../utils.dart';
import 'production_dispatch_logic.dart';

class ProductionDispatchDetailPage extends StatefulWidget {
  const ProductionDispatchDetailPage({super.key});

  @override
  State<ProductionDispatchDetailPage> createState() =>
      _ProductionDispatchDetailPageState();
}

class _ProductionDispatchDetailPageState
    extends State<ProductionDispatchDetailPage> {
  final logic = Get.find<ProductionDispatchLogic>();
  final state = Get.find<ProductionDispatchLogic>().state;

  _bottomButtons() {
    var buttonsTextStyle = TextStyle(
        color: state.orderList.any((e) => e.select)
            ? Colors.blueAccent
            : Colors.red);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.green.shade100],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'production_dispatch_bt_material_list'.tr,
                    style: buttonsTextStyle,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'production_dispatch_bt_instruction'.tr,
                    style: buttonsTextStyle,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'production_dispatch_bt_color_matching'.tr,
                    style: buttonsTextStyle,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'production_dispatch_bt_process_instruction'.tr,
                    style: buttonsTextStyle,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'production_dispatch_bt_process_open'.tr,
                    style: buttonsTextStyle,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'production_dispatch_bt_delete_downstream'.tr,
                    style: buttonsTextStyle,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'production_dispatch_bt_delete_last_report'.tr,
                    style: buttonsTextStyle,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'production_dispatch_bt_label_maintenance'.tr,
                    style: buttonsTextStyle,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'production_dispatch_bt_update_sap'.tr,
                    style: buttonsTextStyle,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'production_dispatch_bt_print_material_head'.tr,
                    style: buttonsTextStyle,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'production_dispatch_bt_report_sap'.tr,
                    style: buttonsTextStyle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: state.orderList.any((e) => e.select)
                  ? Colors.blueAccent
                  : Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: () {
              logic.push();
            },
            child: Text(
              'production_dispatch_bt_push'.tr,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: getFunctionTitle(),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => logic.switchControllerMergeOrder.isChecked.value
                  ? ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: state.orderGroupList.length,
                      itemBuilder: (BuildContext context, int index) =>
                          Text('data'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: state.orderList.length,
                      itemBuilder: (BuildContext context, int index) =>
                          Text('data'),
                    ),
            ),
          ),
          Obx(() => logic.switchControllerMergeOrder.isChecked.value
              ? Container()
              : _bottomButtons())
        ],
      ),
    );
  }

}
