import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_posting_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

void semiFinishedProductDetailsDialog(SapPickingPostingGroup groupData) {
  Get.dialog(AlertDialog(
    title: Text('sap_picking_posting_semi_material_detail'.tr),
    content: SizedBox(
      width: MediaQuery.of(Get.overlayContext!).size.width * 0.8,
      height: MediaQuery.of(Get.overlayContext!).size.height * 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textSpan(
            hint: 'sap_picking_posting_material_code_colon'.tr,
            text: groupData.dataList.first.materialCode ?? '',
            fontSize: 18,
          ),
          textSpan(
            hint: 'sap_picking_posting_material_desc_colon'.tr,
            text: groupData.dataList.first.materialName ?? '',
            maxLines: 3,
            fontSize: 18,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: groupData.dataList.length,
              itemBuilder: (c, i) => Container(
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.green,
                      ),
                      child: Center(
                        child: Text(
                          (i + 1).toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: textSpan(
                        hint: 'sap_picking_posting_qty_colon'.tr,
                        text: groupData.dataList[i].quantity.toShowString(),
                      ),
                    ),
                  ],
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
  ));
}

void addSemiFinishedProductMaterialDialog(
    RxList<SapPickingPostingGroup> existsList) {
  var tecSemiFinishedProduct = TextEditingController();
  var tecSemiFinishedProductQty = TextEditingController();
  var materialCode = '';
  var materialName = ''.obs;
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('sap_picking_posting_add_semi_material'.tr),
        content: SizedBox(
          width: MediaQuery.of(Get.overlayContext!).size.width * 0.8,
          height: MediaQuery.of(Get.overlayContext!).size.height * 0.6,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Obx(() => textSpan(
                          hint: 'sap_picking_posting_material_colon'.tr,
                          text: materialName.value,
                          maxLines: 3,
                        )),
                    const SizedBox(height: 10),
                    TextField(
                      controller: tecSemiFinishedProduct,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(
                          top: 0,
                          bottom: 0,
                          left: 15,
                          right: 10,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        hintText: 'sap_picking_posting_input_material_code'.tr,
                        hintStyle: const TextStyle(color: Colors.grey),
                        suffixIcon: IconButton(
                          onPressed: () => tecSemiFinishedProduct.clear(),
                          icon: const Icon(Icons.clear),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: tecSemiFinishedProductQty,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(
                          top: 0,
                          bottom: 0,
                          left: 15,
                          right: 10,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        hintText: 'sap_picking_posting_input_material_qty'.tr,
                        hintStyle: const TextStyle(color: Colors.grey),
                        suffixIcon: IconButton(
                          onPressed: () => tecSemiFinishedProductQty.clear(),
                          icon: const Icon(Icons.clear),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: CombinationButton(
                      text: 'sap_picking_posting_back'.tr,
                      combination: Combination.left,
                      backgroundColor: Colors.grey,
                      click: () => Get.back(),
                    ),
                  ),
                  Expanded(
                    child: CombinationButton(
                      text: 'sap_picking_posting_query_material'.tr,
                      combination: Combination.middle,
                      backgroundColor: Colors.green,
                      click: () {
                        var code = tecSemiFinishedProduct.text;
                        if (existsList.any(
                            (v) => v.dataList.first.materialCode == code)) {
                          errorDialog(content: "sap_picking_posting_material_exists".tr);
                          return;
                        }
                        getPickingMaterialName(
                          code: code,
                          success: (name) {
                            materialCode = code;
                            materialName.value = name;
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          error: (msg) {
                            materialCode = '';
                            materialName.value = '';
                            errorDialog(content: msg);
                          },
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: CombinationButton(
                      text: 'sap_picking_posting_add'.tr,
                      combination: Combination.right,
                      click: () {
                        var qty = tecSemiFinishedProductQty.text.toDoubleTry();
                        if (materialName.isEmpty) {
                          errorDialog(content: 'sap_picking_posting_query_material_first'.tr);
                          return;
                        }
                        if (qty <= 0) {
                          errorDialog(content: 'sap_picking_posting_input_correct_qty'.tr);
                          return;
                        }
                        existsList.add(SapPickingPostingGroup()
                          ..dataList.add(SapPickingPostingInfo(
                            rowType: 'I',
                            materialCode: materialCode,
                            materialName: materialName.value,
                            salesOrder: null,
                            salesOrderItem: null,
                            quantity: qty,
                          )));
                        Get.back();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void pickingCacheDialog({
  required Function(String, List<SapPickingPostingInfo>) refresh,
}) {
  RxInt selectIndex = (-1).obs;
  var cache = <SapPickingPostingCacheInfo>[].obs;
  item(SapPickingPostingCacheInfo data,int index) => Obx(() => GestureDetector(
        onTap: () {
          selectIndex.value=index;
          debugPrint('index:$index');
        },
        child: Container(
          padding: const EdgeInsets.all(7),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            border: selectIndex.value==index
                ? Border.all(color: Colors.blue, width: 4)
                : Border.all(color: Colors.white, width: 4),
            borderRadius: BorderRadius.circular(7),
            color: selectIndex.value==index ? Colors.blue.shade50 : Colors.white,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  textSpan(
                    hint: 'sap_picking_posting_picking_order_no_colon'.tr,
                    text: data.orderNum ?? '',
                  ),
                  IconButton(
                    onPressed: () => askDialog(
                      content: 'sap_picking_posting_confirm_delete_temp_record'.trArgs([data.orderNum.toString()]),
                      confirm: () => deletePickingPostingCache(
                        orderNum: data.orderNum ?? '',
                        success: (msg) => successDialog(
                          content: msg,
                          back: () => getPickingGetCacheList(
                            success: (list) {
                              cache.value = list;
                            },
                            error: (msg) {
                              cache.clear();
                              errorDialog(content: msg);
                            },
                          ),
                        ),
                        error: (msg) => errorDialog(content: msg),
                      ),
                    ),
                    icon: const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                    ),
                  )
                ],
              ),
              if (!data.materialCode.isNullOrEmpty())
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: Colors.green.shade50,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '(${data.materialCode})${data.materialName}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          textSpan(
                            hint: 'sap_picking_posting_order_no_colon'.tr,
                            text: data.salesOrder ?? '',
                            isBold: false,
                          ),
                          textSpan(
                            hint: 'sap_picking_posting_qty_colon'.tr,
                            text: data.quantity.toShowString(),
                            isBold: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),
      ));
  var dialog = PopScope(
    canPop: false,
    child: AlertDialog(
      title: Text('sap_picking_posting_temp_record'.tr),
      contentPadding: const EdgeInsets.all(10),
      content: SizedBox(
        width: MediaQuery.of(Get.overlayContext!).size.width * 0.8,
        height: MediaQuery.of(Get.overlayContext!).size.height * 0.6,
        child: Column(
          children: [
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: cache.length,
                    itemBuilder: (c, i) => item(cache[i],i),
                  )),
            ),
            Row(
              children: [
                Expanded(
                  child: CombinationButton(
                    text: 'sap_picking_posting_continue_operation'.tr,
                    combination: Combination.left,
                    click: () {
                      if(selectIndex.value==-1){
                        errorDialog(content: 'sap_picking_posting_please_select_order'.tr);
                      }else{
                        getPickingGetCacheDetail(
                          orderNum: cache[selectIndex.value].orderNum ?? '',
                          success: (labels) {
                            Get.back();
                            refresh.call(cache[selectIndex.value].orderNum ?? '', labels);
                          },
                          error: (msg) => errorDialog(content: msg),
                        );
                      }
                    },
                  ),
                ),
                Expanded(
                  child: CombinationButton(
                    text: 'sap_picking_posting_back'.tr,
                    combination: Combination.right,
                    backgroundColor: Colors.grey,
                    click: () => Get.back(),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    ),
  );
  getPickingGetCacheList(
    success: (list) {
      cache.value = list;
      Get.dialog(dialog);
    },
    error: (msg) {
      errorDialog(content: msg);
    },
  );
}

void getPickingMaterialName({
  required String code,
  required Function(String) success,
  required Function(String) error,
}) {
  if (code.isEmpty) {
    errorDialog(content: "sap_picking_posting_scan_semi_barcode".tr);
    return;
  }
  sapPost(
    loading: 'sap_picking_posting_loading_material_info'.tr,
    method: webApiSapGetPickingMaterial,
    body: {'MATNR': code},
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success.call(response.data['MAKTX']);
    } else {
      error.call(response.message ?? 'query_default_error'.tr);
    }
  });
}

void getPickingGetCacheDetail({
  required String orderNum,
  required Function(List<SapPickingPostingInfo>) success,
  required Function(String) error,
}) {
  sapPost(
    loading: 'sap_picking_posting_loading_get_order_detail'.tr,
    method: webApiSapGetCacheDetail,
    body: {'ORDER_NUM': orderNum},
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success.call([
        for (var item in response.data['BQ']) SapPickingPostingInfo.fromJson(item)
      ]);
    } else {
      error.call(response.message ?? 'query_default_error'.tr);
    }
  });
}

void getPickingGetCacheList({
  required Function(RxList<SapPickingPostingCacheInfo>) success,
  required Function(String) error,
}) {
  sapPost(
    loading: 'sap_picking_posting_loading_query_temp_list'.tr,
    method: webApiSapGetCacheList,
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success.call([
        for (var item in response.data)
          SapPickingPostingCacheInfo.fromJson(item)
      ].obs);
    } else {
      error.call(response.message ?? 'query_default_error'.tr);
    }
  });
}

void deletePickingPostingCache({
  required String orderNum,
  required Function(String) success,
  required Function(String) error,
}) {
  sapPost(
    loading: 'sap_picking_posting_loading_delete_temp_order'.tr,
    method: webApiSapSubmitPickingOrder,
    body: {
      "ORDER_NUM": orderNum,
      "ORDER_STATUS": "09",
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success.call(response.message ?? '');
    } else {
      error.call(response.message ?? 'query_default_error'.tr);
    }
  });
}
