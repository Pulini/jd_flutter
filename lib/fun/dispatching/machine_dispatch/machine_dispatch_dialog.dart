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

generateAndPrintDialog({
  required Function() printLast,
  required Function() print,
}){
  Get.dialog(
    PopScope(
      //拦截返回键
      canPop: false,
      child: AlertDialog(
        title: Text('生成并打印'),
        content: Text( '确定要打印标签吗?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back();
              printLast.call();
            },
            child: Text('打印尾标'),
          ),   TextButton(
            onPressed: () {
              Get.back();
              print.call();
            },
            child: Text('打印'),
          ),
          TextButton(
            onPressed: ()=>Get.back(),
            child: Text('dialog_default_cancel'.tr,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    ),
    barrierDismissible: false, //拦截dialog外部点击
  );
}
showWorkCardListDialog(
  List<MachineDispatchInfo> list,
  Function(MachineDispatchInfo) callback,
) {
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('machine_dispatch_dialog_select_dispatch_order'.tr),
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
        title: Text('machine_dispatch_dialog_surplus_material_info'.tr),
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
                      content:
                          'machine_dispatch_dialog_surplus_material_print_tips'
                              .trArgs([stuBarName]),
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
        title: Text('machine_dispatch_dialog_label_list'.tr),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (notScanLabelList.isEmpty && lastLabelList.isNotEmpty)
                textSpan(
                  hint: 'machine_dispatch_dialog_size_not_scan_error_tips'.tr,
                  text: lastLabelList.join(','),
                  textColor: Colors.red,
                  fontSize: 20,
                ),
              if (notScanLabelList.isNotEmpty && lastLabelList.isEmpty)
                textSpan(
                  hint: 'machine_dispatch_dialog_number_not_scan_error_tips'.tr,
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
                          text: state.labelList[i].isScanned
                              ? 'machine_dispatch_dialog_scanned'.tr
                              : 'machine_dispatch_dialog_not_scanned'.tr,
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
                              hint: 'machine_dispatch_dialog_material_name'.tr,
                              text: state.detailsInfo?.materialName ?? '',
                            ),
                            expandedTextSpan(
                              hint: 'machine_dispatch_dialog_process'.tr,
                              text: state.detailsInfo?.processflow ?? '',
                            ),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            expandedTextSpan(
                              flex: 3,
                              hint: 'machine_dispatch_dialog_dispatch_date'.tr,
                              text: state.detailsInfo?.startDate ?? '',
                              textColor: Colors.black54,
                            ),
                            expandedTextSpan(
                              flex: 3,
                              hint: 'machine_dispatch_dialog_type_body'.tr,
                              text: state.detailsInfo?.factoryType ?? '',
                              textColor: Colors.black54,
                            ),
                            expandedTextSpan(
                              flex: 2,
                              hint: 'machine_dispatch_dialog_size_qty'.tr,
                              text: 'machine_dispatch_dialog_size_qty_input'
                                  .trArgs([
                                '${state.labelList[i].size}',
                                '${state.labelList[i].qty.toShowString()}${state.labelList[i].unit}${state.labelList[i].isLastLabel ? 'machine_dispatch_dialog_tail_label'.tr : ''}',
                              ]),
                              textColor: state.labelList[i].isLastLabel
                                  ? Colors.red
                                  : Colors.black54,
                            ),
                            expandedTextSpan(
                              hint: 'machine_dispatch_dialog_number'.tr,
                              text: state.labelList[i].number ?? '',
                              textColor: Colors.black54,
                            ),
                          ],
                        ),
                        leading: IconButton(
                          onPressed: () => askDialog(
                            content: 'machine_dispatch_dialog_label_print_tips'.tr,
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
                                    errorDialog(content: 'machine_dispatch_dialog_delete_label_error_tips'.tr);
                                  } else {
                                    askDialog(
                                      content: 'machine_dispatch_dialog_delete_label_tips'.tr,
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
    loading: 'machine_dispatch_dialog_deleting_labels'.tr,
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
  state.leaderVerify.value = true;
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('machine_dispatch_dialog_leader_id_verify'.tr),
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
                      hint: 'machine_dispatch_dialog_verify_code'.tr,
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
      message: 'machine_dispatch_dialog_enter_number'.tr,
      isWarning: true,
    );
  } else {
    httpGet(
      loading: 'machine_dispatch_dialog_sending_verify_code'.tr,
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
      message: 'machine_dispatch_dialog_enter_number'.tr,
      isWarning: true,
    );
    return;
  }
  if (verificationCode.isEmpty) {
    showSnackBar(
      title: 'get_verify_code'.tr,
      message: 'machine_dispatch_dialog_enter_verify_code'.tr,
      isWarning: true,
    );
    return;
  }
  httpGet(
    loading: 'machine_dispatch_dialog_verifying_leader'.tr,
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
      title: Text('machine_dispatch_dialog_worker_photos'.tr),
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
              'machine_dispatch_dialog_sign_tips_below'.tr,
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
                      color: Colors.black87.withValues(alpha: 0.1),
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
                    message: 'machine_dispatch_dialog_sign_tips'.tr,
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
        title: Text('machine_dispatch_dialog_add_worker'.tr),
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
                  hint: 'machine_dispatch_dialog_enter_allocation_number_tips'.tr,
                  helperText: 'machine_dispatch_dialog_allocation_tips'.trArgs([surplusQty.toShowString()]),
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
                  message: 'machine_dispatch_dialog_enter_worker_number_tips'.tr,
                  isWarning: true,
                );
                return;
              }
              if (data.dispatchList.any(
                (v) => v.workerNumber == worker!.empCode,
              )) {
                showSnackBar(
                  message: 'machine_dispatch_dialog_worker_has_been_assigned'.tr,
                  isWarning: true,
                );
                return;
              }
              if (dispatchQty == 0) {
                showSnackBar(
                  message: 'machine_dispatch_dialog_enter_quantity_tips'.tr,
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
