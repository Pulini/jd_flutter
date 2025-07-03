import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_list_logic.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_list_state.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

class QualityInspectionColorListPage extends StatefulWidget {
  const QualityInspectionColorListPage({super.key});

  @override
  State<QualityInspectionColorListPage> createState() =>
      _QualityInspectionColorListPageState();
}

class _QualityInspectionColorListPageState
    extends State<QualityInspectionColorListPage> {
  final QualityInspectionListLogic logic =
      Get.find<QualityInspectionListLogic>();
  final QualityInspectionListState state =
      Get.find<QualityInspectionListLogic>().state;

  var dpcDate = DatePickerController(
    PickerType.date,
    buttonName: 'quality_inspection_date'.tr,
  );

  var lopcFactoryWarehouse = LinkOptionsPickerController(
    PickerType.sapFactoryWarehouse,
    saveKey: 'QualityInspectionColorListPageStoreLocation',
    buttonName: 'quality_inspection_store_location'.tr,
  );

  Widget _item(int index) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      expandedTextSpan(
                          hint: 'quality_inspection_label_color'.tr,
                          text: state.colorOrderList[index].batchNo ?? ''),
                      textSpan(
                        hint: 'quality_inspection_label_scanned'.tr,
                        text: state.colorOrderList[index].bindingLabels.length
                            .toString(),
                      ),
                    ],
                  ),
                  Obx(
                    () => Row(
                      children: [
                        Text(
                          'quality_inspection_label_scanned_material_qty'.tr,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: progressIndicator(
                            max: state.colorOrderList[index].qty ?? 0,
                            value: state.colorOrderList[index]
                                .getMaterialTotalQty(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          state.colorOrderList[index].unit ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            IconButton(
              onPressed: () => logic.toColorLabelBinding(index),
              icon: const Icon(Icons.chevron_right_outlined),
            )
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'quality_inspection_label_title'.tr,
      popTitle: 'quality_inspection_label_exit_tips'.tr,
      actions: [
        Obx(() => state.colorOrderList.isNotEmpty &&
                state.colorOrderList
                    .every((v) => v.getMaterialTotalQty() == v.qty)
            ? CombinationButton(
                text: 'quality_inspection_label_submit'.tr,
                click: () => logic.submitColorLabelBinding(
                  location: lopcFactoryWarehouse.getPickItem2().pickerId(),
                  postDate: dpcDate.getDateFormatSapYMD(),
                ),
              )
            : Container()),
      ],
      body: Column(
        children: [
          DatePicker(pickerController: dpcDate),
          LinkOptionsPicker(pickerController: lopcFactoryWarehouse),
          Expanded(
            child: Obx(() => ListView.builder(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  itemCount: state.colorOrderList.length,
                  itemBuilder: (c, i) => _item(i),
                )),
          ),
        ],
      ),
    );
  }
}
