import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/temporary_order_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

testApplicationDialog({
  required String temporaryOrderNumber,
  required List<TemporaryOrderDetailReceiptInfo> selectedList,
}) {
  if (groupBy(selectedList, (v) => v.materialCode).length > 1) {
    errorDialog(content: 'temporary_order_dialog_different_material'.tr);
    return;
  }
  var businessUnit = ''.obs;
  var part = '';
  var inspectionQty = 0.0;
  var testStandardsList = <TestStandardsInfo>[].obs;
  var testStandards = '';
  var errorMsg = ''.obs;
  var isLoading = false.obs;
  success(List<TestStandardsInfo> list) {
    isLoading.value = false;
    testStandardsList.value = list;
    testStandards = testStandardsList.first.testStandardsNumber ?? '';
    errorMsg.value = '';
  }

  error(String msg) {
    isLoading.value = false;
    errorMsg.value = msg;
  }

  select(String business) {
    businessUnit.value = business;
    isLoading.value = true;
    testStandardsList.value = [];
    _getTestStandards(businessUnit: business, success: success, error: error);
  }

  var now = DateTime.now();
  var finishDate = DatePickerController(
    PickerType.date,
    buttonName: 'temporary_order_dialog_complete_date'.tr,
    firstDate: now,
    lastDate: DateTime(now.year, now.month + 3, now.day),
  );
  var line1 = Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('temporary_order_dialog_division'.tr),
          CheckBox(
            onChanged: (v) => select('001'),
            name: 'DHM',
            value: businessUnit.value == '001',
          ),
          CheckBox(
            onChanged: (v) => v ? select('002') : select('001'),
            name: 'PUMA',
            value: businessUnit.value == '002',
          ),
          CheckBox(
            onChanged: (v) => v ? select('003') : select('001'),
            name: 'Other',
            value: businessUnit.value == '003',
          ),
          Expanded(
            child: DatePicker(pickerController: finishDate),
          ),
        ],
      ));
  var line2 = Row(
    children: [
      Expanded(
        flex: 5,
        child: EditText(
          hint: 'temporary_order_dialog_part'.tr,
          onChanged: (v) => part = v,
        ),
      ),
      Expanded(
        flex: 3,
        child: NumberDecimalEditText(
          hint: 'temporary_order_dialog_inspection_qty'.tr,
          onChanged: (v) => inspectionQty = v,
        ),
      ),
    ],
  );
  var line3 = Container(
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.blue, width: 2),
      borderRadius: BorderRadius.circular(5),
    ),
    height: 130,
    child: Obx(() => Stack(
          children: [
            isLoading.value
                ? Container()
                : ConstrainedBox(
                    constraints: const BoxConstraints.expand(),
                    child: CupertinoPicker(
                      diameterRatio: 1.5,
                      magnification: 1.2,
                      squeeze: 1.2,
                      useMagnifier: true,
                      itemExtent: 32,
                      onSelectedItemChanged: (v) => testStandards =
                          testStandardsList[v].testStandardsNumber ?? '',
                      children: testStandardsList
                          .map((data) => Center(child: Text(data.toString())))
                          .toList(),
                    ),
                  ),
            Positioned(
              left: 0,
              top: 0,
              child: Text(
                isLoading.value
                    ? 'temporary_order_dialog_getting_standard'.tr
                    : testStandardsList.isEmpty
                        ? errorMsg.value
                        : 'temporary_order_dialog_standard'.tr,
                style: TextStyle(
                  color: isLoading.value
                      ? Colors.blue
                      : testStandardsList.isEmpty
                          ? Colors.red
                          : Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        )),
  );
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('temporary_order_dialog_test_application'.tr),
        content: SizedBox(
          width: 600,
          height: 240,
          child: ListView(children: [line1, line2, line3]),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (inspectionQty <= 0) {
                errorDialog(content: 'temporary_order_dialog_inspection_qty_error'.tr);
                return;
              }
              if (testStandardsList.isEmpty) {
                errorDialog(content: 'temporary_order_dialog_standard_error'.tr);
                return;
              }
              _createTestApplication(
                temporaryOrderNumber: temporaryOrderNumber,
                temporaryOrderLine: selectedList[0].temporaryLineNumber ?? '',
                inspectionQty: inspectionQty,
                businessUnit: businessUnit.value,
                completionDate: finishDate.getDateFormatYMD(),
                testStandards: testStandards,
                part: part,
                success: (msg) => successDialog(
                  content: msg,
                  back: () => Get.back(),
                ),
                error: (msg) => errorDialog(content: msg),
              );
            },
            child: Text(
              'temporary_order_dialog_application_test'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'dialog_default_cancel'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    ),
  );
  select('001');
}

//获取Sap测试标准
_getTestStandards({
  required String businessUnit,
  required Function(List<TestStandardsInfo>) success,
  required Function(String) error,
}) {
  sapPost(
    method: webApiSapGetTestStandards,
    body: {'DIVISION': businessUnit},
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      compute(
        parseJsonToList<TestStandardsInfo>,
        ParseJsonParams(
          response.data,
          TestStandardsInfo.fromJson,
        ),
      ).then((list) {
        success.call(list);
      });
    } else {
      error.call(response.message ?? '');
    }
  });
}

//暂收单提交测试申请
_createTestApplication({
  required String temporaryOrderNumber,
  required String temporaryOrderLine,
  required double inspectionQty,
  required String businessUnit,
  required String completionDate,
  required String testStandards,
  required String part,
  required Function(String) success,
  required Function(String) error,
}) {
  sapPost(
    method: webApiSapCreateTestApplication,
    body: {
      'IN_ZTEMPRENO': temporaryOrderNumber,
      'IN_ZTEMPRESEQ': temporaryOrderLine,
      'IN_PRNAM': userInfo?.name,
      'IN_SYQTY': inspectionQty,
      'IN_DIVISION': businessUnit,
      'IN_EINDT': completionDate,
      'IN_NONUMBER': testStandards,
      'IN_PART': part,
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success.call(response.message ?? '');
    } else {
      error.call(response.message ?? '');
    }
  });
}
