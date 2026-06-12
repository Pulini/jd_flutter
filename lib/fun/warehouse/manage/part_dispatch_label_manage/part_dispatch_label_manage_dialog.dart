import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/part_dispatch_label_manage_info.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/utils/click_debounce.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/worker_check_widget.dart';
import 'package:photo_view/photo_view_gallery.dart';

void selectPackProfileDialog({
  required int orderPackProfileID,
  required double capacityQty,
  required List<List> packProfileList,
  required Function(int, double) callback,
}) {
  final debouncer = ClickDebouncer();
  var tecQty=TextEditingController(text: capacityQty.toShowString());
  var selectIndex = (-1).obs;
  selectIndex.value =
      packProfileList.indexWhere((v) => v[0] == orderPackProfileID);

  item(int i) => Obx(() => GestureDetector(
        onTap: () {
          selectIndex.value = i;
          tecQty.text=(packProfileList[i][2] as double).toShowString();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 5),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(
              color: selectIndex.value == i ? Colors.green : Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [
                selectIndex.value == i
                    ? Colors.green.shade100
                    : Colors.blue.shade50,
                Colors.white
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Text(
            packProfileList[i][1] ?? '',
            style: TextStyle(
              color: selectIndex.value == i ? Colors.green : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ));

  Get.dialog(AlertDialog(
    title: Row(
      children: [
        Text('part_dispatch_select_pack_profile_dialog_title'.tr),
        Expanded(child: Container()),
        SizedBox(
          width: 130,
          child:NumberDecimalEditText(
            hint: 'part_dispatch_select_pack_profile_dialog_capacity_qty'.tr,
            controller: tecQty,
          ),
        ),
      ],
    ),
    content: SizedBox(
      width: 400,
      height: 200,
      child: ListView.builder(
          itemCount: packProfileList.length, itemBuilder: (c, i) => item(i)),
    ),
    actions: [
      TextButton(
        onPressed: () => debouncer.run(() {
          var qty=tecQty.text.toDoubleTry();
          if (packProfileList[selectIndex.value][0] != orderPackProfileID ||
              (qty != capacityQty && qty > 0)) {
            askDialog(
                content:
                    'part_dispatch_select_pack_profile_dialog_modify_tips'.tr,
                confirm: () {
                  Get.back();
                  callback.call(
                    packProfileList[selectIndex.value][0],
                    qty,
                  );
                });
          } else {
            errorDialog(
                content:
                    'part_dispatch_select_pack_profile_dialog_no_change'.tr);
          }
        }),
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
  ));
}

void selectInstructionsDialog({
  required List<PartDispatchOrderBatchGroupInfo> batchGroups,
  required Function(List<int>, bool) selected,
}) {
  final debouncer = ClickDebouncer();
  var selectIndex = (-1).obs;

  void clearOtherItem(int index) {
    for (var i = 0; i < batchGroups.length; ++i) {
      if (i != index) {
        for (var ins in batchGroups[i].insList) {
          ins.isSelected.value = false;
        }
      }
    }
  }

  Widget itemTable(
    List<PartDispatchOrderInstructionGroupInfo> list,
    int index,
  ) {
    var bkgColor =
        list.any((v) => v.isSelected.value) ? Colors.green : Colors.grey;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: bkgColor),
        color: Colors.white,
      ),
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Column(
        children: [
          Row(children: [
            ExpandedFrameText(
              alignment: Alignment.center,
              text: 'part_dispatch_select_instruction_dialog_instruction'.tr,
              borderColor: bkgColor,
              backgroundColor: Colors.orange.shade100,
              flex: 2,
            ),
            SizedBox(
              width: 60,
              child: FrameText(
                alignment: Alignment.center,
                text: 'part_dispatch_select_instruction_dialog_part_qty'.tr,
                borderColor: bkgColor,
                backgroundColor: Colors.orange.shade100,
              ),
            ),
            ExpandedFrameText(
              alignment: Alignment.center,
              text: 'part_dispatch_select_instruction_dialog_dispatch_qty'.tr,
              borderColor: bkgColor,
              backgroundColor: Colors.orange.shade100,
            ),
            ExpandedFrameText(
              alignment: Alignment.center,
              text: 'part_dispatch_select_instruction_dialog_total_dispatch_qty'
                  .tr,
              borderColor: bkgColor,
              backgroundColor: Colors.orange.shade100,
            ),
            Container(
              width: 60,
              height: 35,
              decoration: BoxDecoration(
                border: Border.all(color: bkgColor),
                color: Colors.orange.shade100,
              ),
              alignment: Alignment.center,
              child: Text('part_dispatch_select_instruction_dialog_select'.tr),
            )
          ]),
          for (int i = 0; i < list.length; i++)
            Row(children: [
              ExpandedFrameText(
                text: list[i].dataList.first.seOrderNo ?? '',
                borderColor: bkgColor,
                flex: 2,
              ),
              SizedBox(
                width: 60,
                child: FrameText(
                  alignment: Alignment.center,
                  text: list[i].dataList.length.toString(),
                  borderColor: bkgColor,
                ),
              ),
              ExpandedFrameText(
                text: list[i].dataList.first.workCardQty.toShowString(),
                borderColor: bkgColor,
                alignment: Alignment.centerRight,
              ),
              ExpandedFrameText(
                text: list[i].totalQty.toShowString(),
                borderColor: bkgColor,
                alignment: Alignment.centerRight,
              ),
              Container(
                width: 60,
                height: 35,
                decoration: BoxDecoration(
                  border: Border.all(color: bkgColor),
                ),
                child: Checkbox(
                    value: list[i].isSelected.value,
                    activeColor: Colors.green,
                    onChanged: (v) {
                      selectIndex.value = v!
                          ? index
                          : list.any((v) => v.isSelected.value)
                              ? index
                              : -1;
                      list[i].isSelected.value = v;
                      clearOtherItem(index);
                    }),
              )
            ])
        ],
      ),
    );
  }

  Widget itemWidget(int index) {
    var data = batchGroups[index];
    return Obx(() => Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: selectIndex.value == index ? Colors.green : Colors.grey,
              width: 2,
            ),
            gradient: LinearGradient(
              colors: selectIndex.value == index
                  ? [Colors.blue.shade50, Colors.green.shade50]
                  : [Colors.grey.shade100, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        textSpan(
                          hint:
                              'part_dispatch_select_instruction_dialog_batch_qty'
                                  .tr,
                          text: data.batchNo,
                        ),
                        textSpan(
                          hint:
                              'part_dispatch_select_instruction_dialog_total_qty'
                                  .tr,
                          text: data.totalQty.toShowString(),
                        ),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: selectIndex.value == index,
                    activeColor: Colors.green,
                    onChanged: (v) {
                      selectIndex.value = v! ? index : -1;
                      for (var ins in data.insList) {
                        ins.isSelected.value = v;
                      }
                      clearOtherItem(index);
                    },
                  )
                ],
              ),
              itemTable(data.insList, index)
            ],
          ),
        ));
  }

  Get.dialog(AlertDialog(
    title: Text('part_dispatch_select_instruction_dialog_type_body'
        .trArgs([batchGroups.first.typeBody])),
    content: SizedBox(
      width: getScreenWidth() * 0.7,
      height: getScreenHeight() * 0.7,
      child: ListView.builder(
        itemCount: batchGroups.length,
        itemBuilder: (c, i) => itemWidget(i),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => debouncer.run(() {
          if (selectIndex.value >= 0) {
            Get.back();
            selected.call(
              batchGroups[selectIndex.value].getIds(),
              batchGroups[selectIndex.value]
                      .insList
                      .where((v) => v.isSelected.value)
                      .length ==
                  1,
            );
          } else {
            errorDialog(
                content:
                    'part_dispatch_select_instruction_dialog_no_select_instruction'
                        .tr);
          }
        }),
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
  ));
}

void viewPartDetailDialog(PartDispatchOrderPartInfo data) {
  Get.dialog(AlertDialog(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textSpan(
              fontSize: 24,
              hint: 'part_dispatch_create_label_dialog_part'.tr,
              text: data.materialName ?? '',
            ),
            textSpan(
              fontSize: 20,
              hint: 'part_dispatch_create_label_dialog_qty'.tr,
              text:
                  '${data.remainingQty.toShowString()}/${data.dispatchQty.toShowString()}',
            ),
          ],
        ),
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.cancel, color: Colors.red),
        )
      ],
    ),
    content: SizedBox(
      width: getScreenWidth() * 0.7,
      height: getScreenHeight() * 0.7,
      child: PhotoViewGallery.builder(
        backgroundDecoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        scrollPhysics: const BouncingScrollPhysics(),
        itemCount: data.picItems!.length,
        builder: (c, i) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(data.picItems![i].pictureUrl ?? ''),
          );
        },
        loadingBuilder: (context, event) {
          if (event == null) {
            return const Center(
              child: Text("Loading"),
            );
          }
          final value = event.cumulativeBytesLoaded /
              (event.expectedTotalBytes ?? event.cumulativeBytesLoaded);
          final percentage = (100 * value).floor();
          return Center(
            child: Text("$percentage%"),
          );
        },
      ),
    ),
  ));
}

void createLabelDialog({
  required List<CreateLabelInfo> selectedList,
  required String batchNo,
  required bool isSingleSize,
  required bool isSingleInstruction,
  required Function() refresh,
}) {
  var errorMsg = '';
  for (var v in selectedList) {
    if (!v.isLegal()) {
      errorMsg += 'part_dispatch_create_label_dialog_msg'
          .trArgs([v.size(), v.partCount.toString()]);
    }
  }
  if (errorMsg.isNotEmpty) {
    errorDialog(content: errorMsg);
    return;
  }
  WorkerInfo? worker;
  var avatar = ''.obs;
  var max = isSingleSize
      ? 0
      : selectedList
          .map((v) => v.maxLabelCount())
          .reduce((a, b) => a < b ? a : b);
  var controller = TextEditingController(text: max.toString());
  Get.dialog(AlertDialog(
    titlePadding: const EdgeInsets.all(5),
    contentPadding: const EdgeInsets.all(10),
    title: Padding(
        padding: const EdgeInsets.all(5),
        child: Text('part_dispatch_create_label_dialog_create_label'.tr)),
    content: SizedBox(
      width: 150,
      height: isSingleSize ? 270 : 330,
      child: Obx(
        () => ListView(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: avatar.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: avatar.value, fit: BoxFit.fill)
                          : Icon(
                              Icons.account_circle,
                              size: 150,
                              color: Colors.grey.shade300,
                            ),
                    ),
                  ),
                ),
                WorkerCheck(
                  hint: 'part_dispatch_create_label_dialog_input_create_worker'
                      .tr,
                  onChanged: (w) {
                    worker = w;
                    avatar.value = w?.picUrl ?? '';
                  },
                ),
                if (!isSingleSize)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: NumberEditText(
                      controller: controller,
                      hint: 'part_dispatch_create_label_dialog_input_create_qty'
                          .tr,
                      onChanged: (s) {
                        var labelCount = s.toIntTry();
                        if (labelCount > max) {
                          controller.text = max.toString();
                          controller.selection = TextSelection.fromPosition(
                            TextPosition(offset: controller.text.length),
                          );
                        }
                      },
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: CombinationButton(
                        text: 'part_dispatch_create_label_dialog_cancel'.tr,
                        backgroundColor: Colors.grey,
                        combination: Combination.left,
                        click: () => Get.back(),
                      ),
                    ),
                    Expanded(
                      child: CombinationButton(
                        text: 'part_dispatch_create_label_dialog_create'.tr,
                        combination: Combination.right,
                        click: () {
                          if (worker == null) {
                            errorDialog(
                                content:
                                    'part_dispatch_create_label_dialog_input_create_worker_tips'
                                        .tr);
                            return;
                          }
                          if (!isSingleSize && controller.text.isEmpty) {
                            errorDialog(
                                content:
                                    'part_dispatch_create_label_dialog_input_create_qty_tips'
                                        .tr);
                            return;
                          }
                          _createLabel(
                            worker: worker!,
                            count: controller.text.toIntTry(),
                            batchNo: batchNo,
                            isSingleSize: isSingleSize,
                            isSingleInstruction: isSingleInstruction,
                            list: selectedList,
                            success: (msg) => successDialog(
                              content: msg,
                              back: () {
                                Get.back();
                                refresh.call();
                              },
                            ),
                            error: (msg) => errorDialog(content: msg),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    ),
  ));
}

void _createLabel({
  required WorkerInfo worker,
  required int count,
  required String batchNo,
  required bool isSingleSize,
  required bool isSingleInstruction,
  required List<CreateLabelInfo> list,
  required Function(String) success,
  required Function(String) error,
}) {
  var instructionList = <int>[];
  var sizeList = <Map>[];

  for (var group in list) {
    //单指令单码 sizeList给所有item明细，其他3种每种尺码只给一条item，且装箱数要除于部件数量
    if (isSingleInstruction && isSingleSize) {
      for (var item in group.sizeList) {
        sizeList.add({
          'WorkCardEntryFID': item.workCardEntryFID,
          'Size': item.size,
          'PackingQty': (group.packageQty.value / group.partCount).toInt(),
          'DispatchedQty': item.dispatchedQty,
          'CreateCount': isSingleSize ? group.labelCount.value : count,
          'RemainingQty': item.remainingQty,
        });
        instructionList.add(item.workCardEntryFID ?? 0);
      }
    } else {
      sizeList.add({
        'WorkCardEntryFID': 0,
        'Size': group.sizeList.first.size,
        'PackingQty': (group.packageQty.value / group.partCount).toInt(),
        'DispatchedQty': 0,
        'CreateCount': isSingleSize ? group.labelCount.value : count,
        'RemainingQty': 0,
      });
      for (var item in group.sizeList) {
        instructionList.add(item.workCardEntryFID ?? 0);
      }
    }
  }

  httpPost(
    method: webApiCreatePartProductionDispatchLabels,
    loading: 'part_dispatch_create_label_dialog_creating_label'.tr,
    body: {
      'EmpID': worker.empID,
      'CreateCount': count,
      'SeOrderType': isSingleInstruction ? '1' : '2',
      'PackageType': isSingleSize ? 478 : 479,
      'BatchNo': batchNo,
      'IsCreateTailLabel': true,
      'SeOrderList': instructionList.isNotEmpty
          ? instructionList.toSet().map((v) => {'WorkCardEntryFID': v}).toList()
          : [],
      'SizeList': sizeList,
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success.call(response.message ?? '');
    } else {
      error.call(response.message ?? '');
    }
  });
}
