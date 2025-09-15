import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hand_signature/signature.dart';
import 'package:jd_flutter/bean/http/response/machine_dispatch_info.dart';
import 'package:jd_flutter/bean/http/response/sap_label_info.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/extension_util.dart';
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
}) {
  Get.dialog(
    PopScope(
      //拦截返回键
      canPop: false,
      child: AlertDialog(
        title: Text('machine_dispatch_dialog_create_and_print'.tr),
        content: Text('machine_dispatch_dialog_print_tips'.tr),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back();
              printLast.call();
            },
            child: Text('machine_dispatch_dialog_print_last_label'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              print.call();
            },
            child: Text('machine_dispatch_dialog_print'.tr),
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

showPrintSetting(BuildContext context) {
  RxDouble printSpeed = 3.0.obs;
  RxDouble printDensity = 15.0.obs;
  if( spGet(spSavePrintSpeed) !=null){
    printSpeed.value = spGet(spSavePrintSpeed);
  }
  if(spGet(spSavePrintDensity)!=null){
    printDensity.value = spGet(spSavePrintDensity);
  }
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('machine_dispatch_dialog_surplus_material_info'.tr),
        content: SizedBox(
          width: 500,
          height: 200,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsetsGeometry.only(left: 10, right: 10),
                child: Row(
                  children: [
                    const Text('打印速度：'),
                    Expanded(
                      child: Obx(() => Slider(
                            value: printSpeed.value,
                            min: 1,
                            max: 10,
                            divisions: 9,
                            thumbColor: Colors.blueAccent,
                            activeColor: Colors.green.shade300,
                            onChanged: (v) {
                              printSpeed.value = v;
                              spSave(spSavePrintSpeed, v);
                            },
                          )),
                    ),
                    Obx(() => Text(printSpeed.value.toShowString())),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsGeometry.only(left: 10, right: 10),
                child: Row(
                  children: [
                    const Text('打印浓度：'),
                    Expanded(
                      child: Obx(() => Slider(
                            value: printDensity.value,
                            min: 1,
                            max: 15,
                            divisions: 14,
                            thumbColor: Colors.blueAccent,
                            activeColor: Colors.green.shade300,
                            onChanged: (v) {
                              printDensity.value = v;
                              spSave(spSavePrintDensity, v);
                            },
                          )),
                    ),
                    Obx(() => Text(printDensity.value.toShowString())),
                  ],
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

showSurplusMaterialListDialog(
  BuildContext context, {
  required Function(String, String, MachineDispatchDetailsInfo) print,
}) {
  final state = Get.find<MachineDispatchLogic>().state;
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('machine_dispatch_dialog_surplus_material_info'.tr),
        content: SizedBox(
          width: getScreenSize().width * 0.5,
          height: getScreenSize().height * 0.5,
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: state.surplusMaterialList.length,
            itemBuilder: (context, index) {
              var stuBarCode =
                  state.surplusMaterialList[index]['StuBarCode'] ?? '';
              var stuBarName =
                  state.surplusMaterialList[index]['StuBarName'] ?? '';

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
                      confirm: () => updateSurplusMaterialLabelState(
                        surplusMaterial: state.surplusMaterialList[index],
                        details: state.detailsInfo!,
                        print: (code, name, detail) {
                          Get.back();
                          print.call(code, name, detail);
                        },
                      ),
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

updateSurplusMaterialLabelState({
  required Map<String, dynamic> surplusMaterial,
  required MachineDispatchDetailsInfo details,
  required Function(String, String, MachineDispatchDetailsInfo) print,
}) {
  var stuBarCode = surplusMaterial['StuBarCode'] ?? '';
  var stuBarName = surplusMaterial['StuBarName'] ?? '';
  var stuBarNumber = surplusMaterial['StuBarNumber'] ?? '';
  var interID = surplusMaterial['InterID'] ?? 0;
  httpPost(
    loading: 'machine_dispatch_dialog_update_surplus_material_label_state'.tr,
    method: webApiUpdateSurplusMaterialLabelState,
    params: {
      'Type': stuBarNumber,
      'InterID': interID,
      'Number': details.dispatchNumber,
    },
  ).then((response) async {
    if (response.resultCode == resultSuccess) {
      print.call(stuBarCode, stuBarName, details);
    } else {
      errorDialog(content: response.message ?? 'query_default_error'.tr);
    }
  });
}

showLabelListDialog({
  required BuildContext context,
  required Function(MachineDispatchReprintLabelInfo) print,
}) {
  final state = Get.find<MachineDispatchLogic>().state;

  createLabel(Item label) {
    label.type = label.type;
    print.call(MachineDispatchReprintLabelInfo(
      isLastLabel: label.isLastLabel,
      isEnglish: label.type == '01',
      number: label.number,
      labelID: label.subLabelID ?? '',
      processes: state.detailsInfo?.processflow ?? '',
      qty: label.qty ?? 0,
      size: label.size ?? '',
      factoryType: state.detailsInfo?.factoryType ?? '',
      date: state.detailsInfo?.startDate ?? '',
      materialName: label.type == '01'
          ? label.englishName ?? ''
          : state.detailsInfo?.materialName ?? '',
      unit: label.type == '01' ? label.englishUnit ?? '' : label.unit ?? '',
      machine: state.detailsInfo?.machine ?? '',
      shift: state.detailsInfo?.shift ?? '',
      dispatchNumber: state.nowDispatchNumber.value,
      decrementNumber: state.detailsInfo?.decrementNumber ?? '',
      specifications: label.specifications,
      netWeight: label.netWeight.toDoubleTry(),
      grossWeight: label.grossWeight.toDoubleTry(),
      englishName: label.englishName ?? '',
      englishUnit: label.englishUnit ?? '',
    ));
  }

  item(int i) => Container(
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
          color: state.labelList[i].isScanned ? Colors.green : Colors.red,
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
                hint: '制程：',
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
                text: 'machine_dispatch_dialog_size_qty_input'.trArgs([
                  '${state.labelList[i].size}',
                  '${state.labelList[i].qty.toShowString()}${state.labelList[i].unit}${state.labelList[i].isLastLabel ? 'machine_dispatch_dialog_tail_label'.tr : ''}',
                ]),
                textColor: state.labelList[i].isLastLabel
                    ? Colors.red
                    : Colors.black54,
              ),
              expandedTextSpan(
                hint: 'machine_dispatch_dialog_number'.tr,
                text: state.labelList[i].number,
                textColor: Colors.black54,
              ),
            ],
          ),
          leading: IconButton(
            onPressed: () => askDialog(
              content: 'machine_dispatch_dialog_label_print_tips'.tr,
              confirm: () => createLabel(state.labelList[i]),
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
                      errorDialog(
                          content:
                              'machine_dispatch_dialog_delete_label_error_tips'
                                  .tr);
                    } else {
                      askDialog(
                        content: 'machine_dispatch_dialog_delete_label_tips'.tr,
                        confirm: () {
                          _deleteLabel(
                            labelId: state.labelList[i].subLabelID ?? '',
                            callback: () {
                              state.labelList.removeAt(i);
                              state.sizeItemList
                                  .firstWhere((v1) =>
                                      v1.size == state.labelList[i].size)
                                  .labelQty -= 1;
                              state.sizeItemList.refresh();
                            },
                          );
                        },
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                  ),
                )
              : null,
        ),
      );

  state.getSapLabelList(
    success: () {
      var notScan = state.labelList.where((v) => !v.isScanned).toList();
      var notScanLabelList = <String>[
        for (var i = 0; i < notScan.length; ++i) notScan[i].number
      ];
      var lastAndNotScan = notScan.where((v) => v.isLastLabel).toList();
      var lastLabelList = <String>[
        for (var i = 0; i < lastAndNotScan.length; ++i)
          lastAndNotScan[i].size ?? ''
      ];
      Get.dialog(
        PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text('machine_dispatch_dialog_label_list'.tr),
            content: SizedBox(
              width: getScreenSize().width * 0.9,
              height: getScreenSize().height * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notScanLabelList.isEmpty && lastLabelList.isNotEmpty)
                    textSpan(
                      hint:
                          'machine_dispatch_dialog_size_not_scan_error_tips'.tr,
                      text: lastLabelList.join(','),
                      textColor: Colors.red,
                      fontSize: 20,
                    ),
                  if (notScanLabelList.isNotEmpty && lastLabelList.isEmpty)
                    textSpan(
                      hint: 'machine_dispatch_dialog_number_not_scan_error_tips'
                          .tr,
                      text: notScanLabelList.join(','),
                      textColor: Colors.red,
                      fontSize: 20,
                    ),
                  Expanded(
                    child: Obx(
                      () => ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: state.labelList.length,
                        itemBuilder: (_, i) => item(i),
                      ),
                    ),
                  )
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
    },
    error: (msg) => errorDialog(content: msg),
  );
}

_deleteLabel({
  required String labelId,
  required Function() callback,
}) {
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
  // state.leaderVerify.value = true; //测试用
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
              () {
                Get.back();
                state.leaderVerify.value = true;
              },
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
    initialSetup: const SignaturePathSetup(
      threshold: 3,
      smoothRatio: 0.65,
      velocityRange: 2,
    ),
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
          width: getScreenSize().width * 0.5,
          height: getScreenSize().height * 0.5,
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
                          drawer: const ShapeSignatureDrawer(
                            width: 1,
                            maxWidth: 10,
                            color: Colors.blueGrey,
                          ),
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
                  hint:
                      'machine_dispatch_dialog_enter_allocation_number_tips'.tr,
                  helperText: 'machine_dispatch_dialog_allocation_tips'
                      .trArgs([surplusQty.toShowString()]),
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
                  message:
                      'machine_dispatch_dialog_enter_worker_number_tips'.tr,
                  isWarning: true,
                );
                return;
              }
              if (data.dispatchList.any(
                (v) => v.workerNumber == worker!.empCode,
              )) {
                showSnackBar(
                  message:
                      'machine_dispatch_dialog_worker_has_been_assigned'.tr,
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

selectLabelTypeDialog({
  required EnglishLabelInfo englishLabel,
  required Function(double, String) printLast,
  required Function(double, String) print,
}) {
  if (englishLabel.specificationsList?.isEmpty == true) {
    errorDialog(
        content: 'machine_dispatch_dialog_label_specifications_empty'.tr);
    return;
  }
  var workerNumberController = TextEditingController();
  var vCodeController = TextEditingController();
  var btName = 'get_verify_code'.tr.obs;
  var isCheckedManager = false.obs;
  var countTimer = 0;
  var select = 0.obs;
  double outerBoxWeight = englishLabel.outerBoxWeight ?? 0;

  outerBoxWeight = 10;
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Row(
          children: [
            Expanded(
              child: Text('machine_dispatch_dialog_select_dispatch_order'.tr),
            ),
            Container(
              width: 210,
              margin: const EdgeInsets.all(1),
              height: 40,
              child: TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                ],
                controller: workerNumberController,
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
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(
                      color: Colors.transparent,
                    ),
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                  labelText: 'machine_dispatch_dialog_leader_number'.tr,
                  hintStyle: const TextStyle(color: Colors.white),
                  suffixIcon: Obx(() => CombinationButton(
                        text: btName.value,
                        isEnabled: btName.value == 'get_verify_code'.tr,
                        click: () =>
                            _sendManagerCode(workerNumberController.text, () {
                          isCheckedManager.value = true;
                          Timer.periodic(
                            const Duration(milliseconds: 1000),
                            (timer) {
                              countTimer++;
                              if (countTimer == 60) {
                                timer.cancel();
                                countTimer = 0;
                                btName.value = 'get_verify_code'.tr;
                              } else {
                                btName.value = (60 - countTimer).toString();
                              }
                            },
                          );
                        }),
                      )),
                ),
              ),
            )
          ],
        ),
        content: SizedBox(
          width: 450,
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(children: [
                Obx(() => Expanded(
                      child: isCheckedManager.value
                          ? NumberDecimalEditText(
                              hint: 'machine_dispatch_dialog_weight_input_tips'
                                  .tr,
                              initQty: outerBoxWeight,
                              onChanged: (v) {
                                outerBoxWeight = v;
                              },
                            )
                          : textSpan(
                              hint: 'machine_dispatch_dialog_weight'.tr,
                              text: outerBoxWeight.toShowString(),
                            ),
                    )),
                Container(
                  width: 180,
                  margin: const EdgeInsets.all(1),
                  height: 40,
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                    ],
                    controller: vCodeController,
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
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      labelText: 'machine_dispatch_dialog_verify_code'.tr,
                      hintStyle: const TextStyle(color: Colors.white),
                      suffixIcon: CombinationButton(
                        text: 'machine_dispatch_dialog_verify_leader'.tr,
                        click: () => _checkManagerByCode(
                          vCodeController.text,
                          workerNumberController.text,
                          () => isCheckedManager.value = true,
                        ),
                      ),
                    ),
                  ),
                )
              ]),
              const SizedBox(height: 10),
              Text(
                'machine_dispatch_dialog_carton_size'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsets.only(bottom: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                  child: ListView.builder(
                    itemCount: englishLabel.specificationsList!.length,
                    itemBuilder: (c, i) => Obx(() => GestureDetector(
                          onTap: () => select.value = i,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: select.value == i
                                  ? Colors.blue.shade100
                                  : Colors.white,
                              border: Border.all(
                                color: select.value == i
                                    ? Colors.blue
                                    : Colors.grey,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              englishLabel
                                      .specificationsList![i].specifications ??
                                  '',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )),
                  ),
                ),
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (outerBoxWeight > 0) {
                Get.back();
                printLast.call(
                  outerBoxWeight,
                  englishLabel
                          .specificationsList![select.value].specifications ??
                      '',
                );
              } else {
                errorDialog(
                    content: 'machine_dispatch_dialog_weight_error_tips'.tr);
              }
            },
            child: Text('machine_dispatch_dialog_print_last'.tr),
          ),
          TextButton(
            onPressed: () {
              if (outerBoxWeight > 0) {
                Get.back();
                print.call(
                  outerBoxWeight,
                  englishLabel
                          .specificationsList![select.value].specifications ??
                      '',
                );
              } else {
                errorDialog(
                    content: 'machine_dispatch_dialog_weight_error_tips'.tr);
              }
            },
            child: Text('machine_dispatch_dialog_print'.tr),
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

//修改模具
showMachineInputDialog({
  required Items data,
  required int? maxMould,
  required Function() confirm,
}) {
  var mould = 0.0;
  var qty = (0.0).obs;
  Get.dialog(
    PopScope(
      //拦截返回键
      canPop: false,
      child: AlertDialog(
        title: const Text('请输入数据',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 300,
          height: 150,
          child: ListView(
            children: [
              Text('尺码：${data.size}',
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              Text('建议模具数：$maxMould',
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              Text('可用模具数：${data.availableMouldsQty.toShowString()}',
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              Obx(() => Text('派工数量：${qty.value}')),
              NumberDecimalEditText(
                initQty: data.mould ?? 0,
                max: data.availableMouldsQty,
                hint: '输入模具数',
                onChanged: (s) {
                  mould = s;
                  qty.value = data.mantissaMark == 'X'
                      ? data.sumUnderQty ?? 0
                      : s.mul(data.capacityPerMold ?? 0);
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              if (mould > 0) {
                Get.back();
                data.mould = mould;
                data.todayDispatchQty = qty.value;
                confirm.call();
              } else {
                showSnackBar(message: 'machine_dispatch_input_number'.tr);
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
      ),
    ),
    barrierDismissible: false, //拦截dialog外部点击
  );
}

//当日派工数量
showInputDayReportDialog({
  required Items data,
  required Function() confirm,
}) {
  var qty = 0.0;
  Get.dialog(
    PopScope(
      //拦截返回键
      canPop: false,
      child: AlertDialog(
        title: const Text('请输入当日派工数量',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 300,
          height: 60,
          child: ListView(
            children: [
              Text('尺码：${data.size}',
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              NumberDecimalEditText(
                initQty: data.todayDispatchQty,
                max: data.todayDispatchQty,
                onChanged: (s) {
                  qty = s;
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              if (qty > 0) {
                Get.back();
                data.todayDispatchQty = qty;
                confirm.call();
              } else {
                showSnackBar(message: '当日派工数量不能为空');
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
      ),
    ),
    barrierDismissible: false, //拦截dialog外部点击
  );
}

//修改箱容
showInputCapacityDialog({
  required Items data,
  required Function() confirm,
}) {
  var newCapacity = 0.0;
  Get.dialog(
    PopScope(
      //拦截返回键
      canPop: false,
      child: AlertDialog(
        title: const Text('请输入箱容',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 300,
          height: 60,
          child: ListView(
            children: [
              Text('尺码：${data.size}',
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              NumberDecimalEditText(
                initQty: data.capacity,
                onChanged: (s) {
                  newCapacity = s;
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              if (newCapacity > 0) {
                Get.back();
                data.capacity = newCapacity;
                confirm.call();
              } else {
                showSnackBar(message: 'machine_dispatch_input_number'.tr);
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
      ),
    ),
    barrierDismissible: false, //拦截dialog外部点击
  );
}

//修改尾箱
showInputLastNumDialog({
  required Items data,
  required Function() confirm,
}) {
  var lastNum = 0.0;
  Get.dialog(
    PopScope(
      //拦截返回键
      canPop: false,
      child: AlertDialog(
        title: const Text('请输入尾箱',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 300,
          height: 60,
          child: ListView(
            children: [
              Text('尺码：${data.size}',
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              NumberDecimalEditText(
                initQty: 0,
                onChanged: (s) {
                  lastNum = s;
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              if (lastNum > 0) {
                Get.back();
                data.notFullQty = lastNum;
                confirm.call();
              } else {
                showSnackBar(message: 'machine_dispatch_input_number'.tr);
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
      ),
    ),
    barrierDismissible: false, //拦截dialog外部点击
  );
}
