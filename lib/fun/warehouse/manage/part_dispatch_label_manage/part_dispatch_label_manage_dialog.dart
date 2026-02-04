import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/part_dispatch_label_manage_info.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/switch_button_widget.dart';
import 'package:jd_flutter/widget/worker_check_widget.dart';
import 'package:photo_view/photo_view_gallery.dart';

void selectInstructionsDialog({
  required List<PartDispatchOrderBatchGroupInfo> batchGroups,
  required Function(List<int>, bool) selected,
}) {
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
      margin: EdgeInsetsGeometry.only(left: 10, right: 10, bottom: 10),
      child: Column(
        children: [
          Row(children: [
            expandedFrameText(
              alignment: Alignment.center,
              text: '指令',
              borderColor: bkgColor,
              backgroundColor: Colors.orange.shade100,
              flex: 2,
            ),
            SizedBox(
              width: 60,
              child: frameText(
                alignment: Alignment.center,
                text: '部件数',
                borderColor: bkgColor,
                backgroundColor: Colors.orange.shade100,
              ),
            ),
            expandedFrameText(
              alignment: Alignment.center,
              text: '部件派工数',
              borderColor: bkgColor,
              backgroundColor: Colors.orange.shade100,
            ),
            expandedFrameText(
              alignment: Alignment.center,
              text: '合计派工数',
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
              child: Text('选择'),
            )
          ]),
          for (int i = 0; i < list.length; i++)
            Row(children: [
              expandedFrameText(
                text: list[i].dataList.first.seOrderNo ?? '',
                borderColor: bkgColor,
                flex: 2,
              ),
              SizedBox(
                width: 60,
                child: frameText(
                  alignment: Alignment.center,
                  text: list[i].dataList.length.toString(),
                  borderColor: bkgColor,
                ),
              ),
              expandedFrameText(
                text: list[i].dataList.first.workCardQty.toShowString(),
                borderColor: bkgColor,
                alignment: Alignment.centerRight,
              ),
              expandedFrameText(
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
          padding: EdgeInsetsGeometry.all(5),
          margin: EdgeInsetsGeometry.only(bottom: 10),
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
                          hint: '批次：',
                          text: data.batchNo,
                        ),
                        textSpan(
                          hint: '总数：',
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
    title: Text('型体：${batchGroups.first.typeBody}'),
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
        onPressed: () {
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
            errorDialog(content: '请选择指令');
          }
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
              hint: '部件：',
              text: data.materialName ?? '',
            ),
            textSpan(
              fontSize: 20,
              hint: '数量：',
              text:
                  '${data.remainingQty.toShowString()}/${data.dispatchQty.toShowString()}',
            ),
          ],
        ),
        IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.cancel, color: Colors.red),
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
      errorMsg += '尺码：< ${v.size()} >的装箱数不是部件数(${v.partCount})的倍数，请输入正确的装箱数！\n';
    }
  }
  if (errorMsg.isNotEmpty) {
    errorDialog(content: errorMsg);
    return;
  }
  WorkerInfo? worker;
  bool hasLastLabel = false;
  var avatar = ''.obs;
  var max = isSingleSize
      ? 0
      : selectedList
          .map((v) => v.maxLabelCount())
          .reduce((a, b) => a < b ? a : b);
  var controller = TextEditingController(text: max.toString());
  Get.dialog(AlertDialog(
    titlePadding: EdgeInsetsGeometry.all(5),
    contentPadding: EdgeInsetsGeometry.all(10),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsetsGeometry.only(left: 5),
          child: Text('创建贴标'),
        ),
        IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.cancel, color: Colors.red),
        )
      ],
    ),
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
                  hint: '创建人工号',
                  onChanged: (w) {
                    worker = w;
                    avatar.value = w?.picUrl ?? '';
                  },
                ),
                if (!isSingleSize)
                  Padding(
                    padding: EdgeInsetsGeometry.only(bottom: 10),
                    child: NumberEditText(
                      controller: controller,
                      hint: '创建标签数',
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SwitchButton(
                      value: hasLastLabel,
                      onChanged: (v) => hasLastLabel = v,
                      name: '附带尾标',
                    ),
                    CombinationButton(
                        text: '创建',
                        click: () {
                          if (worker == null) {
                            errorDialog(content: '请输入创建人工号');
                            return;
                          }
                          if (!isSingleSize && controller.text.isEmpty) {
                            errorDialog(content: '请输入创建标签数');
                            return;
                          }
                          _createLabel(
                            worker: worker!,
                            count: controller.text.toIntTry(),
                            batchNo: batchNo,
                            isSingleSize: isSingleSize,
                            isSingleInstruction: isSingleInstruction,
                            createLastLabel: hasLastLabel,
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
                        }),
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
  required bool createLastLabel,
  required List<CreateLabelInfo> list,
  required Function(String) success,
  required Function(String) error,
}) {
  var instructionList = <Map>[];
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
        instructionList.add({
          'WorkCardEntryFID': item.workCardEntryFID,
        });
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
        instructionList.add({
          'WorkCardEntryFID': item.workCardEntryFID,
        });
      }
    }
  }

  httpPost(
    method: webApiCreatePartProductionDispatchLabels,
    loading: '正在创建贴标...',
    body: {
      'EmpID': worker.empID,
      'CreateCount': count,
      'SeOrderType': isSingleInstruction ? '1' : '2',
      'PackageType': isSingleSize ? 478 : 479,
      'BatchNo': batchNo,
      'IsCreateTailLabel': createLastLabel,
      'SeOrderList': instructionList,
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
