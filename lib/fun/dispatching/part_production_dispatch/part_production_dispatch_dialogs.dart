import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/worker_check_widget.dart';

void selectInstructionDialog({
  required List<Map> sizeList,
  required Function callback,
}) {
  if (sizeList.isEmpty) {
    errorDialog(content: '请勾选要创建的尺码行，并填写箱容。');
    return;
  }
  var controller = TextEditingController(text: '1');
  WorkerInfo? worker;
  void createLabel(bool isSingle) {
    if (worker == null) {
      errorDialog(content: '请填写创建人');
      return;
    }
    var count = controller.text.toIntTry();
    if (count <= 0) {
      errorDialog(content: '请填写正确的生成贴标数');
      return;
    }
    var map={
      'EmpID': worker!.empID,
      'CreateCount': count,
      'PackageType': isSingle?'478':'479',
      'SizeList': sizeList,
    };
    logger.f(map);
  }

  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        contentPadding: EdgeInsetsGeometry.all(5),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('创建贴标'),
            IconButton(
              onPressed: () => Get.back(),
              icon: Icon(
                Icons.cancel_outlined,
                color: Colors.redAccent,
              ),
            )
          ],
        ),
        content: SizedBox(
          width: 200,
          height: 220,
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              WorkerCheck(
                hint: '创建人工号',
                onChanged: (w) => worker = w,
              ),
              NumberEditText(
                controller: controller,
                hint: '生成贴标数',
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CombinationButton(
                      text: '创建单码',
                      combination: Combination.left,
                      backgroundColor: Colors.green,
                      click: () =>createLabel(true),
                    ),
                  ),
                  Expanded(
                    child: CombinationButton(
                      text: '创建混码',
                      combination: Combination.right,
                      click: () =>createLabel(false),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: false, //拦截dialog外部点击
  );
}
