import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hand_signature/signature.dart';
import 'package:jd_flutter/bean/http/response/machine_dispatch_info.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/worker_check_widget.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

import 'machine_dispatch_logic.dart';

showWorkCardListDialog(
  List<MachineDispatchInfo> list,
  Function(MachineDispatchInfo) callback,
) {
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('选择派工单'),
        content: SizedBox(
          width: 300,
          height: 200,
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: list.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Get.back();
                  callback.call(list[index]);
                },
                child: Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                        '${list[index].shift}/${list[index].materialName}'),
                  ),
                ),
              );
            },
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
      ),
    ),
  );
}

showSurplusMaterialListDialog(
  BuildContext context, {
  required Function(Map<String, String>) print,
}) {
  final state = Get.find<MachineDispatchLogic>().state;
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('料头信息'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          height: MediaQuery.of(context).size.height * 0.5,
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: state.surplusMaterialList.length,
            itemBuilder: (context, index) {
              var stuBarCode =
                  state.surplusMaterialList[index]['StuBarCode'] ?? '';
              var stuBarName =
                  state.surplusMaterialList[index]['StuBarName'] ?? '';
              // var stuBarNumber = list[index]['StuBarNumber'] ?? '';
              return Card(
                color: stuBarCode.startsWith('4605')
                    ? Colors.red.shade100
                    : Colors.blue.shade50,
                child: ListTile(
                  title: Text(
                    stuBarCode,
                    style: TextStyle(
                      color: stuBarCode.startsWith('4605')
                          ? Colors.red
                          : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    stuBarName,
                    style: TextStyle(
                      color: stuBarCode.startsWith('4605')
                          ? Colors.red
                          : Colors.black87,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () => askDialog(
                      content: '确定要打印料头 < $stuBarName > 吗?',
                      confirm: () =>
                          print.call(state.surplusMaterialList[index]),
                    ),
                    icon: const Icon(
                      Icons.print,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              );
            },
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
      ),
    ),
  );
}

showLabelListDialog(BuildContext context) {
  final state = Get.find<MachineDispatchLogic>().state;
  var notScan = state.labelList.where((v) => !v.isScanned).toList();
  var notScanLabelList = <String>[
    for (var i = 0; i < notScan.length; ++i) notScan[i].number ?? ''
  ];
  var lastAndNotScan = notScan.where((v) => v.isLastLabel).toList();
  var lastLabelList = <String>[
    for (var i = 0; i < lastAndNotScan.length; ++i) lastAndNotScan[i].size ?? ''
  ];
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('标签列表'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (notScanLabelList.isEmpty && lastLabelList.isNotEmpty)
                textSpan(
                  hint: '含有以下尺码的尾标未扫：',
                  text: lastLabelList.join(','),
                  textColor: Colors.red,
                  fontSize: 20,
                ),
              if (notScanLabelList.isNotEmpty && lastLabelList.isEmpty)
                textSpan(
                  hint: '含有以下序号的整箱未扫：',
                  text: notScanLabelList.join(','),
                  textColor: Colors.red,
                  fontSize: 20,
                ),
              Expanded(
                child: Obx(
                  () => ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: state.labelList.length,
                    itemBuilder: (_, i) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: state.labelList[i].isLastLabel
                            ? Colors.green.shade100
                            : Colors.blue.shade50,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      foregroundDecoration: RotatedCornerDecoration.withColor(
                        color: state.labelList[i].isScanned
                            ? Colors.green
                            : Colors.red,
                        badgeCornerRadius: const Radius.circular(8),
                        badgeSize: const Size(45, 45),
                        textSpan: TextSpan(
                          text: state.labelList[i].isScanned ? '已扫' : '未扫',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      child: ListTile(
                        title: Row(
                          children: [
                            expandedTextSpan(
                              flex: 8,
                              hint: '物料名称：',
                              text: state.detailsInfo?.materialName ?? '',
                            ),
                            expandedTextSpan(
                              hint: '制程：',
                              text: state.detailsInfo?.processflow ?? '',
                            ),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            expandedTextSpan(
                              flex: 3,
                              hint: '派工日期：',
                              text: state.detailsInfo?.startDate ?? '',
                              textColor: Colors.black54,
                            ),
                            expandedTextSpan(
                              flex: 3,
                              hint: '型体：',
                              text: state.detailsInfo?.factoryType ?? '',
                              textColor: Colors.black54,
                            ),
                            expandedTextSpan(
                              flex: 2,
                              hint: '尺码/数量：',
                              text:
                                  '${state.labelList[i].size}码 / ${state.labelList[i].qty.toShowString()}${state.labelList[i].unit}${state.labelList[i].isLastLabel ? '尾标' : ''}',
                              textColor: state.labelList[i].isLastLabel
                                  ? Colors.red
                                  : Colors.black54,
                            ),
                            expandedTextSpan(
                              hint: '序号：',
                              text: state.labelList[i].number ?? '',
                              textColor: Colors.black54,
                            ),
                          ],
                        ),
                        leading: IconButton(
                          onPressed: () => askDialog(
                            content: '确定要打印标签吗?',
                            confirm: () {},
                          ),
                          icon: const Icon(
                            Icons.print,
                            color: Colors.blueAccent,
                          ),
                        ),
                        trailing: state.leaderVerify.value
                            ? IconButton(
                                onPressed: () {
                                  if (state.labelList[i].isScanned) {
                                    errorDialog(content: '已产量汇报到MES,无法删除贴标！');
                                  } else {
                                    askDialog(
                                      content: '确定要删除标签吗?',
                                      confirm: () => _deleteLabel(
                                        state.labelList[i].subLabelID ?? '',
                                        () {
                                          state.labelList.removeAt(i);
                                          state.sizeItemList
                                              .firstWhere((v1) =>
                                                  v1.size ==
                                                  state.labelList[i].size)
                                              .labelQty -= 1;
                                          state.sizeItemList.refresh();
                                        },
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.delete_forever_rounded,
                                  color: Colors.red,
                                ),
                              )
                            : null,
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
      ),
    ),
  );
}

_deleteLabel(
  String labelId,
  Function() callback,
) {
  sapPost(
    loading: '正在删除贴标....',
    method: webApiSapMaterialDispatchLabelMaintain,
    body: [
      {
        'ZUSNAM': userInfo?.number,
        'optype': '2', //维护类型   2是删除
        'BQID': labelId
      }
    ].toList(),
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      successDialog(content: response.message, back: () => callback.call());
    } else {
      errorDialog(content: response.message ?? 'query_default_error'.tr);
    }
  });
}

teamLeaderVerifyDialog() {
  final state = Get.find<MachineDispatchLogic>().state;
  var buttonName = 'get_verify_code'.tr.obs;
  var countDown = 0;
  var workerNumber = '';
  var verificationCode = '';
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('班组长身份验证'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              WorkerCheck(onChanged: (worker) {
                workerNumber = worker?.empCode ?? '';
              }),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: EditText(
                      hint: '验证码',
                      onChanged: (c) => verificationCode = c,
                    ),
                  ),
                  Obx(
                    () => CombinationButton(
                      text: buttonName.value,
                      isEnabled: buttonName.value == 'get_verify_code'.tr,
                      click: () => _sendManagerCode(
                        workerNumber,
                        () => Timer.periodic(
                          const Duration(milliseconds: 1000),
                          (timer) {
                            countDown++;
                            if (countDown == 60) {
                              timer.cancel();
                              countDown = 0;
                              buttonName.value = 'get_verify_code'.tr;
                            } else {
                              buttonName.value = (60 - countDown).toString();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _checkManagerByCode(
              verificationCode,
              workerNumber,
              () => state.leaderVerify.value = true,
            ),
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
      ),
    ),
  );
}

_sendManagerCode(
  String workerNumber,
  Function() callback,
) {
  if (workerNumber.isEmpty) {
    showSnackBar(
      title: 'get_verify_code'.tr,
      message: '请输入工号',
      isWarning: true,
    );
  } else {
    httpGet(
      loading: '正在发送验证码....',
      method: webApiSendManagerCode,
      params: {
        'ManagerCode': workerNumber,
        'MatchineCode': userInfo?.number,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        showSnackBar(
          title: 'get_verify_code'.tr,
          message: 'phone_login_get_verify_code_success'.tr,
        );
        callback.call();
      } else {
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }
}

_checkManagerByCode(
  String verificationCode,
  String workerNumber,
  Function() callback,
) {
  if (workerNumber.isEmpty) {
    showSnackBar(
      title: 'get_verify_code'.tr,
      message: '请输入工号',
      isWarning: true,
    );
    return;
  }
  if (verificationCode.isEmpty) {
    showSnackBar(
      title: 'get_verify_code'.tr,
      message: '请输入验证码',
      isWarning: true,
    );
    return;
  }
  httpGet(
    loading: '正在校验班组长....',
    method: webApiCheckManagerByCode,
    params: {
      'IdentifyingCode': verificationCode,
      'ManagerCode': workerNumber,
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      Get.back();
      callback.call();
    } else {
      errorDialog(content: response.message ?? 'query_default_error'.tr);
    }
  });
}

showWorkerAvatar(Widget workerAvatar) {
  Get.dialog(
    AlertDialog(
      title: Text('员工照片'),
      content: workerAvatar,
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'dialog_default_back'.tr,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    ),
  );
}

workerSignature(
  BuildContext context,
  DispatchInfo data,
  Function() refresh,
) {
  final control = HandSignatureControl(
    threshold: 3.0,
    smoothRatio: 0.65,
    velocityRange: 2.0,
  );
  RxBool reSignature;
  if (data.signature == null) {
    reSignature = true.obs;
  } else {
    reSignature = false.obs;
  }
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Row(
          children: [
            Text(
              '请在以下空白处签名',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.blue.shade700,
              ),
            ),
            Expanded(child: Container()),
            IconButton(
              onPressed: () {
                if (!reSignature.value) {
                  reSignature.value = true;
                } else {
                  control.clear();
                }
              },
              icon: const Icon(
                Icons.refresh,
                color: Colors.red,
                size: 40,
              ),
            ),
          ],
        ),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          height: MediaQuery.of(context).size.height * 0.5,
          color: Colors.grey.shade200,
          child: Obx(
            () => Stack(
              children: [
                Center(
                  child: Text(
                    data.workerName ?? '',
                    style: TextStyle(
                      fontSize: 180,
                      color: Colors.black87.withOpacity(0.1),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints.expand(),
                  child: reSignature.value || data.signature == null
                      ? HandSignature(
                          control: control,
                          color: Colors.blueGrey,
                          width: 1.0,
                          maxWidth: 10.0,
                          type: SignatureDrawType.shape,
                        )
                      : Image.memory(
                          fit: BoxFit.cover,
                          data.signature!.buffer.asUint8List(),
                        ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              control.toImage(border: 0).then((image) {
                if (image == null && data.signature == null) {
                  showSnackBar(
                    title: 'snack_bar_default_wrong'.tr,
                    message: '请在空白处签名',
                    isWarning: true,
                  );
                } else {
                  if (image != null) data.signature = image;
                  Get.back();
                  refresh.call();
                }
              });
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
      ),
    ),
  );
}

addDispatchWorker(DispatchProcessInfo data, Function() refresh) {
  WorkerInfo? worker;
  var surplusQty = data.totalProduction.sub(
    data.dispatchList.isEmpty
        ? 0
        : data.dispatchList
            .map((v) => v.dispatchQty ?? 0)
            .reduce((v1, v2) => v1.add(v2)),
  );
  var max = surplusQty < 0 ? 0.0 : surplusQty;
  var avatar = ''.obs;
  var dispatchQty = max;
  var controller = TextEditingController(text: max.toShowString());
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('添加员工'),
        content: SizedBox(
          width: 200,
          child: Obx(
            () => Column(
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
                WorkerCheck(onChanged: (w) {
                  worker = w;
                  avatar.value = w?.picUrl ?? '';
                }),
                NumberDecimalEditText(
                  controller: controller,
                  hint: '请输入分配数',
                  helperText: '剩余$surplusQty可分配',
                  onChanged: (d) {
                    if (d > max) {
                      controller.text = max.toShowString();
                      dispatchQty = max;
                    } else {
                      dispatchQty = d;
                    }
                  },
                )
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (worker == null) {
                showSnackBar(
                  title: 'snack_bar_default_wrong'.tr,
                  message: '请输入正确的员工工号',
                  isWarning: true,
                );
                return;
              }
              if (data.dispatchList.any(
                (v) => v.workerNumber == worker!.empCode,
              )) {
                showSnackBar(
                  title: 'snack_bar_default_wrong'.tr,
                  message: '该员工已分配',
                  isWarning: true,
                );
                return;
              }
              if (dispatchQty == 0) {
                showSnackBar(
                  title: 'snack_bar_default_wrong'.tr,
                  message: '请正确填写分配数量',
                  isWarning: true,
                );
                return;
              }
              data.dispatchList.add(DispatchInfo(
                workerEmpID: worker!.empID,
                workerNumber: worker!.empCode,
                workerName: worker!.empName,
                workerAvatar: worker!.picUrl,
                dispatchQty: dispatchQty,
                signature: null,
              ));
              Get.back();
              refresh.call();
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
      ),
    ),
  );
}
