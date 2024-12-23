import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

import 'sap_put_on_shelves_logic.dart';
import 'sap_put_on_shelves_state.dart';

class SapPutOnShelvesPage extends StatefulWidget {
  const SapPutOnShelvesPage({super.key});

  @override
  State<SapPutOnShelvesPage> createState() => _SapPutOnShelvesPageState();
}

class _SapPutOnShelvesPageState extends State<SapPutOnShelvesPage> {
  final SapPutOnShelvesLogic logic = Get.put(SapPutOnShelvesLogic());
  final SapPutOnShelvesState state = Get.find<SapPutOnShelvesLogic>().state;
  var refreshController = EasyRefreshController(controlFinishRefresh: true);
  late LinkOptionsPickerController factoryWarehouseController;

  _item(List<List<PalletDetailItem1Info>> pallet) {
    return GestureDetector(
      onTap: () => logic.scanCode(
        code: pallet[0][0].palletNumber ?? '',
        warehouse: factoryWarehouseController.getOptionsPicker2().pickerId(),
        refresh: () {
          refreshController.finishRefresh();
          refreshController.resetFooter();
        },
      ),
      child: Container(
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
              hint: '托盘号：',
              text: pallet[0][0].palletNumber ?? '',
              textColor: Colors.red,
            ),
            const Divider(height: 10, color: Colors.black),
            for (var material in pallet) ...[
              Row(
                children: [
                  expandedTextSpan(
                    hint: '物料：',
                    text: material[0].materialName ?? '',
                    isBold: false,
                    textColor: Colors.blue.shade900,
                  ),
                  Text(
                    '${material.map((v) => v.quantity ?? 0).reduce((a, b) => a.add(b)).toShowString()}${material[0].unit}',
                    style: TextStyle(color: Colors.green.shade700),
                  )
                ],
              ),
              Divider(height: 5, color: Colors.grey.shade300),
            ]
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    pdaScanner(
      scan: (code) => logic.scanCode(
        code: code,
        warehouse: factoryWarehouseController.getOptionsPicker2().pickerId(),
        refresh: () {
          refreshController.finishRefresh();
          refreshController.resetFooter();
        },
      ),
    );
    factoryWarehouseController = LinkOptionsPickerController(
        PickerType.sapFactoryWarehouse,
        saveKey:
            '${RouteConfig.sapPutOnShelves.name}${PickerType.sapFactoryWarehouse}',
        onSelected: (pi1, pi2) {
      refreshController.callRefresh();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      body: Column(
        children: [
          LinkOptionsPicker(pickerController: factoryWarehouseController),
          Expanded(
            child: EasyRefresh(
              controller: refreshController,
              header: const MaterialHeader(),
              onRefresh: () => logic.refreshLabelList(
                warehouse:
                    factoryWarehouseController.getOptionsPicker2().pickerId(),
                refresh: () {
                  refreshController.finishRefresh();
                  refreshController.resetFooter();
                },
              ),
              child: Obx(() => ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: state.labelList.length,
                    itemBuilder: (context, index) =>
                        _item(state.labelList[index]),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<SapPutOnShelvesLogic>();
    super.dispose();
  }
}
