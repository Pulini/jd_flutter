import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/fun/warehouse/in/purchase_order_warehousing/purchase_order_warehousing_logic.dart';
import 'package:jd_flutter/fun/warehouse/in/purchase_order_warehousing/purchase_order_warehousing_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';


class PurchaseOrderWarehousingBindingLabelDetailPage extends StatefulWidget {
  const PurchaseOrderWarehousingBindingLabelDetailPage({super.key});

  @override
  State<PurchaseOrderWarehousingBindingLabelDetailPage> createState() =>
      _PurchaseOrderWarehousingBindingLabelDetailPageState();
}

class _PurchaseOrderWarehousingBindingLabelDetailPageState
    extends State<PurchaseOrderWarehousingBindingLabelDetailPage> {
  final PurchaseOrderWarehousingLogic logic =
      Get.find<PurchaseOrderWarehousingLogic>();
  final PurchaseOrderWarehousingState state =
      Get.find<PurchaseOrderWarehousingLogic>().state;

  String saveLocation =
      spGet(spSavePurchaseOrderWarehousingBindingLabelLocation) ?? '';
  late OptionsPickerController locationController;
  var postDate = DatePickerController(PickerType.date,
      buttonName: 'delivery_order_dialog_post_date'.tr);

  @override
  Widget build(BuildContext context) {
    var materialList = logic.getScannedMaterialsInfo();
    return pageBody(
      title: '标签详情',
      actions: [
        CombinationButton(
          text: '确定提交',
          click: () => askDialog(
            content: '确定检查完标签要提交了吗？',
            confirm: () => Get.back(result: true),
          ),
        )
      ],
      body: Column(
        children: [
          OptionsPicker(pickerController: locationController),
          DatePicker(pickerController: postDate),
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              color: Colors.blue,
              border: Border.all(color: Colors.black54),
            ),
            child: Row(
              children: [
                expandedFrameText(
                  text: '物料',
                  isBold: true,
                  textColor: Colors.white,
                ),
                SizedBox(
                  width: 100,
                  child: frameText(
                    text: '数量',
                    isBold: true,
                    textColor: Colors.white,
                    alignment: Alignment.centerRight,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 10, right: 10),
              itemCount: materialList.length,
              itemBuilder: (c, i) => _item(materialList[i], Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(List<String> item, Color bkg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black54),
      ),
      child: Row(
        children: [
          expandedFrameText(text: item[0]),
          SizedBox(
            width: 100,
            child: frameText(text: item[1], alignment: Alignment.centerRight),
          )
        ],
      ),
    );
  }
}
