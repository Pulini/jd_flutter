import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/fun/warehouse/in/sap_put_on_shelves/sap_put_on_shelves_logic.dart';
import 'package:jd_flutter/fun/warehouse/in/sap_put_on_shelves/sap_put_on_shelves_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';

class SapPutOnShelvesScanPage extends StatefulWidget {
  const SapPutOnShelvesScanPage({super.key});

  @override
  State<SapPutOnShelvesScanPage> createState() =>
      _SapPutOnShelvesScanPageState();
}

class _SapPutOnShelvesScanPageState extends State<SapPutOnShelvesScanPage> {
  final SapPutOnShelvesLogic logic = Get.find<SapPutOnShelvesLogic>();
  final SapPutOnShelvesState state = Get.find<SapPutOnShelvesLogic>().state;
  int index = Get.arguments['index'];
  String warehouse = Get.arguments['warehouse'];
  var controller = TextEditingController();

  _item(PalletDetailItem1Info label) {
    return Container(
      margin: const EdgeInsets.only(left: 4, right: 4, bottom: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            label.sizeMaterialName ?? '',
            style: const TextStyle(color: Colors.red),
            maxLines: 2,
            minFontSize: 8,
            maxFontSize: 18,
          ),
          Row(
            children: [
              expandedTextSpan(
                hint: 'sap_put_on_shelves_scan_label'.tr,
                text: label.labelNumber ?? '',
                textColor: Colors.green,
              ),
              Text('${label.quantity.toShowString()}${label.unit}')
            ],
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => logic.initLabelList(
        index: index,
        location: (l) => controller.text = l,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => pageBody(
          actions: [
            TextButton(
              onPressed: () => logic.puttingOnShelves(
                location: controller.text,
                warehouse: warehouse,
                refresh: () {
                  Get.back(result: true);
                },
              ),
              child: Text('sap_put_on_shelves_scan_put_on_shelves'.tr),
            )
          ],
          title: 'sap_put_on_shelves_scan_pallet'.trArgs([
            state.palletNumber.value,
          ]),
          body: Column(
            children: [
              EditText(
                hint: 'sap_put_on_shelves_scan_storage_location'.tr,
                controller: controller,
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(5),
                  itemCount: state.scanLabelList.length,
                  itemBuilder: (c, i) => _item(state.scanLabelList[i]),
                ),
              ),
            ],
          ),
        ));
  }
}
