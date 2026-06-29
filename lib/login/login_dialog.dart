import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/login/login_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';

void changeBaseUrlDialog() {
  var mesList = BaseUrl.values.where((v) => v.type == 'MES').toList();
  var sapList = BaseUrl.values.where((v) => v.type == 'SAP').toList();
  var initMes = mesList.indexWhere((v) => v.value == mesBaseUrl);
  var initSap = sapList.indexWhere((v) => v.value == sapBaseUrl);
  var mesInputController = TextEditingController(
    text: mesList[initMes].value,
  );
  var sapInputController = TextEditingController(
    text: sapList[initSap].value,
  );
  var mesScrollController = FixedExtentScrollController(
    initialItem: initMes == -1 ? 0 : initMes,
  );
  var sapScrollController = FixedExtentScrollController(
    initialItem: initSap == -1 ? 0 : initSap,
  );
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        content: SizedBox(
          width: 450,
          height: 400,
          child: ListView(
            children: [
              EditText(
                controller: mesInputController,
                hint: 'MES url',
              ),
              SelectView(
                controller: mesScrollController,
                list: mesList.map((v) => v.name).toList(),
                select: (i) => mesInputController.text = mesList[i].value,
                errorMsg: '',
                hint: 'MES BaseUrl :',
              ),
              const SizedBox(height: 40),
              EditText(
                controller: sapInputController,
                hint: 'SAP url',
              ),
              SelectView(
                controller: sapScrollController,
                list: sapList.map((v) => v.name).toList(),
                select: (i) => sapInputController.text = sapList[i].value,
                errorMsg: '',
                hint: 'SAP BaseUrl :',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              var mes = mesInputController.text;
              var sap = sapInputController.text;
              if (mes.isNotEmpty && sap.isNotEmpty) {
                mesBaseUrl = mes;
                sapBaseUrl = sap;
                spSave(spSaveMesBaseUrl, mes);
                spSave(spSaveSapBaseUrl, sap);
                Get.offAll(() => const LoginPage());
              } else {
                errorDialog(content: 'URL 不能为空');
              }
            },
            child: Text('dialog_default_confirm'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'dialog_default_back'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    ),
  );
}
