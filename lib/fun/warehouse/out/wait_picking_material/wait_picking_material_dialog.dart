import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/wait_picking_material_info.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/worker_check_widget.dart';

modifyDetailPickingQtyDialog({
  required WaitPickingMaterialOrderInfo order,
  required List<WaitPickingMaterialOrderModelInfo> data,
}) {
  double proportion = order.getProportion();
  String basicUnit = order.basicUnit ?? '';
  String commonUnits = order.commonUnits ?? '';
  bool canTakeMore = order.multiCollarLogo == 'X';
  var max = canTakeMore
      ? double.infinity
      : data.map((v) => v.getUnreceivedQty()).reduce((a, b) => a.add(b));
  var initQty =
      data.map((v) => v.actPickingQuantity ?? 0).reduce((a, b) => a.add(b));
  var basicQty = initQty;
  var commonQty = basicQty.div(proportion).toFixed(3);
  var basicController = TextEditingController(text: basicQty.toShowString());
  var commonController = TextEditingController(text: commonQty.toShowString());

  Get.dialog(
    PopScope(
      canPop: false,
      child: StatefulBuilder(builder: (context, dialogSetState) {
        return AlertDialog(
          title: Text(
            max == double.infinity
                ? 'picking_material_order_dialog_pick_title_can_tack_more'.tr
                : 'picking_material_order_dialog_pick_title_cant_tack_more'.tr,
          ),
          content: SizedBox(
            width: 300,
            height: 100,
            child: ListView(
              children: [
                Row(
                  children: [
                    Text('picking_material_order_dialog_picking_qty'.tr),
                    Expanded(
                      child: NumberDecimalEditText(
                        controller: basicController,
                        max: max,
                        hasFocus: true,
                        onChanged: (d) => dialogSetState(() {
                          basicQty = d;
                          commonQty = basicQty.div(proportion);
                          commonController.text =
                              commonQty.toFixed(3).toShowString();
                        }),
                      ),
                    ),
                    SizedBox(width: 40, child: Text(basicUnit))
                  ],
                ),
                if (basicUnit != commonUnits)
                  Row(
                    children: [
                      Text('picking_material_order_dialog_picking_qty'.tr),
                      Expanded(
                        child: NumberDecimalEditText(
                          controller: commonController,
                          max: max.div(proportion).toFixed(3),
                          onChanged: (d) => dialogSetState(() {
                            commonQty = d;
                            basicQty = commonQty.mul(proportion);
                            basicController.text =
                                basicQty.toFixed(3).toShowString();
                          }),
                        ),
                      ),
                      SizedBox(width: 40, child: Text(commonUnits))
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                var qty = basicQty;
                for (var v in data) {
                  var unreceivedQty = v.getUnreceivedQty();
                  if (unreceivedQty < 0) unreceivedQty = 0;
                  if (qty == 0) {
                    v.pickingQty.value = 0;
                  } else {
                    if (qty >= unreceivedQty) {
                      qty = qty.sub(unreceivedQty);
                      v.pickingQty.value = unreceivedQty;
                    } else {
                      v.pickingQty.value = qty;
                      qty = 0;
                    }
                  }
                }
                //分配完后还有多余的数量则累加给本物料最后一行选中行
                if (qty > 0) {
                  data.last.pickingQty.value =
                      data.last.pickingQty.value.add(qty);
                }
                Get.back();
              },
              child: Text('dialog_default_confirm'.tr),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'dialog_default_cancel'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      }),
    ),
  );
}

batchAndColorSystemDialog({
  required List<WaitPickingMaterialOrderModelInfo> data,
}) {
  var isShowBatch = true;
  Get.dialog(
    PopScope(
      canPop: true,
      child: StatefulBuilder(builder: (context, dialogSetState) {
        var list = groupBy(data, (v) => isShowBatch ? v.batch : v.colorSystem)
            .values
            .toList();
        return AlertDialog(
          title: Text(
            isShowBatch
                ? 'picking_material_order_dialog_title_instruction_detail'.tr
                : 'picking_material_order_dialog_title_color_detail'.tr,
          ),
          content: SizedBox(
            width: 300,
            height: 240,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue,
                      width: 2,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CheckBox(
                        onChanged: (c) => dialogSetState(() => isShowBatch = c),
                        name: 'picking_material_order_dialog_instruction'.tr,
                        value: isShowBatch,
                      ),
                      CheckBox(
                        onChanged: (c) =>
                            dialogSetState(() => isShowBatch = !c),
                        name: 'picking_material_order_dialog_color_system'.tr,
                        value: !isShowBatch,
                      )
                    ],
                  ),
                ),
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(
                      color: Colors.blue,
                      width: 2,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (c, i) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.green.shade200,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              isShowBatch
                                  ? list[i][0].batch ?? ''
                                  : list[i][0].colorSystem ?? '',
                            ),
                          ),
                          Text(
                            list[i]
                                .map((v) => v.actPickingQuantity ?? 0)
                                .reduce((a, b) => a.add(b))
                                .toFixed(3)
                                .toShowString(),
                          )
                        ],
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'dialog_default_back'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      }),
    ),
  );
}

realTimeInventoryDialog({
  required List<ImmediateInventoryInfo> list,
}) {
  var titleTextStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  var itemTextStyle = const TextStyle(
    color: Colors.black87,
  );
  Get.dialog(
    PopScope(
      canPop: true,
      child: StatefulBuilder(builder: (context, dialogSetState) {
        return AlertDialog(
          title: Text(
              'picking_material_order_dialog_title_real_time_inventory'.tr),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  padding: const EdgeInsets.only(
                      left: 10, top: 5, right: 10, bottom: 5),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue,
                      width: 2,
                    ),
                    color: Colors.blue,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Text(
                          'picking_material_order_dialog_warehouse'.tr,
                          style: titleTextStyle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'picking_material_order_dialog_qty'.tr,
                          style: titleTextStyle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'picking_material_order_dialog_batch'.tr,
                          style: titleTextStyle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'picking_material_order_dialog_sales_order'.tr,
                          style: titleTextStyle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'picking_material_order_dialog_line_number'.tr,
                          style: titleTextStyle,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border.all(
                        color: Colors.blue,
                        width: 2,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (c, i) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.green.shade200,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                list[i].locationDescription ?? '',
                                style: itemTextStyle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                list[i].realTimeInventory ?? '',
                                style: itemTextStyle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                list[i].batch ?? '',
                                style: itemTextStyle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                list[i].salesAndDistributionVoucherNumber ?? '',
                                style: itemTextStyle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                list[i].productionOrderItemNumber ?? '',
                                style: itemTextStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'dialog_default_back'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      }),
    ),
  );
}

checkPickerDialog({required Function(WorkerInfo) confirm}) {
  WorkerInfo? worker;
  var avatar = ''.obs;
  Get.dialog(
    PopScope(
      canPop: false,
      child: StatefulBuilder(builder: (context, dialogSetState) {
        return AlertDialog(
          title: Text('picking_material_order_dialog_title_picker_check'.tr),
          content: SizedBox(
            width: 200,
            height: 240,
            child: Obx(() => ListView(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: ClipOval(
                          child: avatar.isNotEmpty
                              ? Image.network(avatar.value, fit: BoxFit.fill)
                              : Icon(
                                  Icons.account_circle,
                                  size: 150,
                                  color: Colors.grey.shade300,
                                ),
                        ),
                      ),
                    ),
                    WorkerCheck(
                      hint: 'picking_material_order_dialog_picker_number'.tr,
                      onChanged: (w) {
                        worker = w;
                        avatar.value = w?.picUrl ?? '';
                      },
                    ),
                  ],
                )),
          ),
          contentPadding: const EdgeInsets.all(10),
          actions: [
            TextButton(
              onPressed: () {
                if (worker == null) {
                  showSnackBar(
                    message: 'picking_material_order_dialog_number_error'.tr,
                    isWarning: true,
                  );
                } else {
                  if (worker!.picUrl == null || worker!.picUrl!.isEmpty) {
                    msgDialog(
                      content:
                          'picking_material_order_dialog_picker_avatar_not_upload_tips'
                              .tr,
                    );
                  } else {
                    Get.back();
                    confirm.call(worker!);
                  }
                }
              },
              child: Text(
                'dialog_default_confirm'.tr,
              ),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'dialog_default_back'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      }),
    ),
  );
}

Widget _modifyContextEditText(WaitPickingMaterialOrderInfo info) {
  var controller = TextEditingController(text: info.location ?? '');
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.all(5),
    height: 40,
    child: TextField(
      controller: controller,
      onChanged: (v) => info.modifyLocation = v,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(
          top: 0,
          bottom: 0,
          left: 15,
          right: 10,
        ),
        filled: true,
        fillColor: Colors.grey[300],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Colors.transparent,
          ),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        labelText: info.location ?? '',
        labelStyle: const TextStyle(color: Colors.blueAccent),
        prefixIcon: IconButton(
          onPressed: () {
            controller.text = info.location ?? '';
          },
          icon: const Icon(
            Icons.replay_circle_filled,
          ),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => controller.clear(),
        ),
      ),
    ),
  );
}

modifyLocationDialog({
  required List<WaitPickingMaterialOrderInfo> list,
  required Function() back,
}) {
  Get.dialog(
    PopScope(
      canPop: false,
      child: StatefulBuilder(builder: (context, dialogSetState) {
        return AlertDialog(
          title: Text('picking_material_order_dialog_title_modify_location'.tr),
          content: SizedBox(
            width: 400,
            height: 300,
            child: ListView(children: [
              for (var v in list) _modifyContextEditText(v),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _modifyLocation(
                  materialList: list,
                  success: () {
                    successDialog(
                      content:
                          'picking_material_order_dialog_modify_success'.tr,
                      back: () {
                        Get.back();
                        back.call();
                      },
                    );
                  },
                  error: (msg) => errorDialog(content: msg),
                );
              },
              child: Text('dialog_default_confirm'.tr),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                back.call();
              },
              child: Text(
                'dialog_default_cancel'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      }),
    ),
  );
}

_modifyLocation({
  required List<WaitPickingMaterialOrderInfo> materialList,
  required Function() success,
  required Function(String) error,
}) {
  sapPost(
    loading: 'picking_material_order_dialog_submitting_picking'.tr,
    method: webApiSapModifyLocation,
    body: {
      'GT_REQITEMS': [
        for (var item in materialList
            .where((v) => (v.location ?? '') != v.modifyLocation))
          {
            'WERKS': item.factoryNumber,
            'LGORT': item.pickingWarehouse,
            'MATNR': item.rawMaterialCode,
            'ZLOCAL_OLD': item.location,
            'ZLOCAL_NEW': item.modifyLocation,
          }
      ],
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success.call();
    } else {
      error.call(response.message ?? 'query_default_error'.tr);
    }
  });
}
