import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/fun/warehouse/in/delivery_order/delivery_order_logic.dart';
import 'package:jd_flutter/fun/warehouse/in/delivery_order/delivery_order_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

class LabelDetailPage extends StatefulWidget {
  const LabelDetailPage({super.key});

  @override
  State<LabelDetailPage> createState() => LabelDetailPageState();
}

class LabelDetailPageState extends State<LabelDetailPage> {
  final DeliveryOrderLogic logic = Get.find<DeliveryOrderLogic>();
  final DeliveryOrderState state = Get.find<DeliveryOrderLogic>().state;
  String saveLocation = spGet(spSaveDeliveryOrderBindingLabelLocation) ?? '';
  String saveUserNumber =
      spGet(spSaveDeliveryOrderBindingLabelUserNumber) ?? '';
  late OptionsPickerController locationController;
  late TextEditingController workerNumberController;

  _submit() {
    spSave(
      spSaveDeliveryOrderBindingLabelLocation,
      locationController.selectedId.value,
    );
    spSave(
      spSaveDeliveryOrderBindingLabelUserNumber,
      workerNumberController.text,
    );
    Get.back(result: [
      locationController.selectedId.value,
      workerNumberController.text,
    ]);
  }

  @override
  void initState() {
    state.canSubmitLabelBinding.value = saveUserNumber.isNotEmpty;
    locationController = OptionsPickerController(
      PickerType.ghost,
      buttonName: 'delivery_order_dialog_location'.tr,
      dataList:()=> getStorageLocationList(state.orderItemInfo[0].factoryNO ?? ''),
      initId: saveLocation,
    );
    workerNumberController = TextEditingController(text: saveUserNumber);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var materialList = logic.getScannedMaterialsInfo();
    return pageBody(
      title: 'delivery_order_label_check_detail_title'.tr,
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OptionsPicker(pickerController: locationController),
              ),
              Container(
                margin: const EdgeInsets.all(5),
                width: 240,
                height: 40,
                child: TextField(
                  controller: workerNumberController,
                  onChanged: (v) =>
                  state.canSubmitLabelBinding.value = v.isNotEmpty,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(
                      top: 0,
                      bottom: 0,
                      left: 15,
                      right: 10,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade300,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    labelText: 'delivery_order_label_check_detail_inspector'.tr,
                    prefixIcon: IconButton(
                      onPressed: () {
                        workerNumberController.clear();
                        state.canSubmitLabelBinding.value = false;
                      },
                      icon: const Icon(
                        Icons.replay_circle_filled,
                        color: Colors.red,
                      ),
                    ),
                    suffixIcon: Obx(() => CombinationButton(
                      text: 'delivery_order_label_check_detail_confirm_submit'.tr,
                      isEnabled: state.canSubmitLabelBinding.value,
                      click: () => askDialog(
                        content: 'delivery_order_label_check_detail_confirm_checked_tips'.tr,
                        confirm: () => _submit(),
                      ),
                    )),
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              color: Colors.blue,
              border: Border.all(color: Colors.black54),
            ),
            child: Row(
              children: [
                expandedFrameText(
                  text: 'delivery_order_label_check_detail_material'.tr,
                  isBold: true,
                  textColor: Colors.white,
                ),
                SizedBox(
                  width: 100,
                  child: frameText(
                    text: 'delivery_order_label_check_detail_quantity'.tr,
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
