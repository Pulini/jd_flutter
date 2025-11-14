import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/workshop_planning_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/dialogs.dart';

void materialDialog({
  required List<WorkshopPlanningMaterialInfo> addedList,
  required List<WorkshopPlanningMaterialInfo> materialList,
  required Function(List<WorkshopPlanningMaterialInfo>) addMaterial,
}) {
  var showList = <WorkshopPlanningMaterialInfo>[];
  var select = <bool>[].obs;
  for (var m in materialList) {
    if (addedList.none((v) => v.itemID == m.itemID)) {
      showList.add(m);
      select.add(false);
    }
  }
  if (showList.isEmpty){
    errorDialog(content: '没有可添加的物料');
    return;
  }
  Get.dialog(
    PopScope(
      canPop: false,
      child: StatefulBuilder(builder: (context, dialogSetState) {
        return AlertDialog(
          title: const Text('物料列表'),
          content: SizedBox(
            width: 400,
            height: 300,
            child: ListView.builder(
                itemCount: showList.length,
                itemBuilder: (c, i) => GestureDetector(
                  onTap: () =>
                      dialogSetState(() => select[i] = !select[i]),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: select[i] ? Colors.green : Colors.grey,
                        width: 2,
                      ),
                      color: select[i]
                          ? Colors.green.shade100
                          : Colors.grey.shade200,
                    ),
                    child: Text(
                      '(${showList[i].number}) ${showList[i].name}'
                          .allowWordTruncation(),
                      maxLines: 4,
                    ),
                  ),
                )),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (select.every((v) => !v)) {
                  errorDialog(content: '请选择要添加的物料');
                } else {
                  var newList=<WorkshopPlanningMaterialInfo>[];
                  for (var i = 0; i < select.length; ++i) {
                    if(select[i]){
                      newList.add(showList[i]);
                    }
                  }
                  Get.back();
                  addMaterial.call(newList);
                }
              },
              child: Text('dialog_default_confirm'.tr),
            ),
            TextButton(
              onPressed: () {
                Get.back();
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