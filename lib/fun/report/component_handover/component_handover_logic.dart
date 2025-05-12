import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/handover_detail_info.dart';
import 'package:jd_flutter/bean/http/response/handover_process_info.dart';
import 'package:jd_flutter/bean/http/response/handover_production_process_info.dart';
import 'package:jd_flutter/bean/http/response/scan_handover_info.dart';
import 'package:jd_flutter/bean/http/response/show_handover_info.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'component_handover_state.dart';

class ComponentHandoverLogic extends GetxController {
  final ComponentHandoverState state = ComponentHandoverState();

  late final LinkOptionsPickerController pickerController;

  addCode(String code) {
    if (code.isNotEmpty) {
      var newCode = '';

      if (code.contains('\$\$\$')) {
        newCode = ScanHandoverInfo.fromJson(code.replaceAll('\$\$\$', '\''))
            .barcode
            .toString();
      } else {
        newCode = code;
      }

      if (isExists(newCode)) {
        showSnackBar(message: 'component_handover_code_is_have'.tr);
      } else {
        state.dataList.add(ShowHandoverInfo(code: newCode));
        state.dataList.refresh();
      }
    }
  }

  //是否包含次条码
  isExists(String newCode) {
    return state.dataList.any((v) => v.code == newCode);
  }

  //获取制程
  getHandoverProcessFlow() {
    if (state.dataList.isNotEmpty) {
      httpPost(
        method: webApiGetHandoverProcessFlow,
        loading: 'component_handover_get_flow'.tr,
        body: {
          'BarCodeList': [
            for (var i = 0; i < state.dataList.length; ++i)
              state.dataList[i].code
          ],
          'SCDeptID': getUserInfo()!.departmentID
        },
      ).then((response) {
        if (response.resultCode == resultSuccess) {
          var list = <HandoverProductionProcessInfo>[
            for (var i = 0; i < response.data.length; ++i)
              HandoverProductionProcessInfo.fromJson(response.data[i])
          ];
          //创建选择器控制器
          var controller = FixedExtentScrollController(
            initialItem: 0,
          );
          //创建取消按钮
          var cancel = TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text(
              'dialog_default_cancel'.tr,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 20,
              ),
            ),
          );
          //创建确认按钮
          var confirm = TextButton(
            onPressed: () {
              Get.back();
              state.process.value =
                  list[controller.selectedItem].processFlowName ?? '';
              state.processId =
                  list[controller.selectedItem].processFlowID ?? 0;
              spSave(spSaveComponentHandoverProcessName, state.process.value);
              spSave(spSaveComponentHandoverProcessID, state.processId);
            },
            child: Text(
              'dialog_default_confirm'.tr,
              style: const TextStyle(
                color: Colors.blueAccent,
                fontSize: 20,
              ),
            ),
          );
          //创建底部弹窗
          showPopup(Column(
            children: <Widget>[
              //选择器顶部按钮
              Container(
                height: 45,
                color: Colors.grey[200],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [cancel, confirm],
                ),
              ),
              //选择器主体
              Expanded(
                child: getCupertinoPicker(
                  items: list.map((data) {
                    return Center(child: Text(data.processFlowName!));
                  }).toList(),
                  controller: controller,
                ),
              )
            ],
          ));
        } else {
          errorDialog(content: response.message);
        }
      });
    } else {
      showSnackBar(message: 'component_handover_first_scan'.tr);
    }
  }

  //获取员工信息
  getWorkerInfo({
    String? number,
    String? department,
    required Function(List<WorkerInfo>) workers,
    required Function(String) error,
  }) {
    httpGet(method: webApiGetWorkerInfo, params: {
      'EmpNumber': number,
      'DeptmentID': department,
    }).then((worker) {
      if (worker.resultCode == resultSuccess) {
        workers.call([for (var json in worker.data) WorkerInfo.fromJson(json)]);
      } else {
        error.call(worker.message ?? '');
      }
    });
  }

  //获取工序列表
  getProcessList() {
    if (state.processId == 0) {
      if (state.dataList.isNotEmpty) {
        httpPost(
          method: webApiGetHandoverProcess,
          loading: 'component_handover_get_process_list'.tr,
          body: {
            'BarCodeList': [
              for (var i = 0; i < state.dataList.length; ++i)
                state.dataList[i].code
            ],
            'ProcessFlowID': state.processId
          },
        ).then((response) {
          if (response.resultCode == resultSuccess) {
            var list = <HandoverProcessInfo>[
              for (var i = 0; i < response.data.length; ++i)
                HandoverProcessInfo.fromJson(response.data[i])
            ];
            var groupController = FixedExtentScrollController();
            var subController = FixedExtentScrollController();
            var groupList = <String>[for (var group in list) group.name ?? ''];
            var subList = <List<String>>[
              for (var group in list)
                (group.processNames ?? [])
                    .map((sub) => sub.processName ?? '')
                    .toList()
            ];
            showPopup(
              Column(
                children: [
                  Container(
                    height: 80,
                    color: Colors.grey[200],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            'dialog_default_cancel'.tr,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Expanded(child: Container()),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            state.outProcess
                                .value = list[groupController.selectedItem]
                                    .processNames![subController.selectedItem]
                                    .processName ??
                                '';
                            getHandoverInfo(
                                list[groupController.selectedItem]
                                    .processFlowID
                                    .toString(),
                                list[groupController.selectedItem]
                                    .processNames![subController.selectedItem]
                                    .processName
                                    .toString());
                          },
                          child: Text(
                            'dialog_default_confirm'.tr,
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      child: getLinkCupertinoPicker(
                    groupItems: groupList,
                    subItems: subList,
                    groupController: groupController,
                    subController: subController,
                  )),
                ],
              ),
            );
          } else {
            errorDialog(content: response.message);
          }
        });
      } else {
        showSnackBar(message: 'component_handover_first_scan'.tr);
      }
    } else {
      showSnackBar(message: 'component_handover_first_flow'.tr);
    }
  }

  //获取交接信息_部件
  getHandoverInfo(String processFlowID, String name) {
    httpPost(
      method: webApiGetHandoverInfo,
      loading: 'component_handover_receipt_information'.tr,
      body: {
        'BarCodeList': [
          for (var i = 0; i < state.dataList.length; ++i) state.dataList[i].code
        ],
        'ProcessFlowID': state.processId,
        'ProcessName': name,
        'DCDeptID': state.departmentId,
        'UserID': state.empId,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.handoverDetail = HandoverDetailInfo.fromJson(response.data);
        state.typeBody.value = state.handoverDetail.factoryType ?? '';
        state.outPart.value = state.handoverDetail.upPartName ?? '';
        state.upDepartmentToDown.value =
            '${state.handoverDetail.upDeptName ?? ''}到${state.handoverDetail.downDeptName ?? ''}';
        state.dataList.clear();
        var list = <ShowHandoverInfo>[];
        state.handoverDetail.items?.forEach((v) {
          list.add(ShowHandoverInfo(code: v.barCode, size: v.size, qty: v.qty));
        });
        state.dataList.value = list;
        state.dataList.refresh();

        state.summaryDataList.value = state.handoverDetail.summary!;
      } else {
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //清理输入人员信息
  clearPeople() {
    state.empName.value = '';
    state.departmentId = '';
    state.empId = '';
    state.empCode = '';
  }

  //提交交接
  submitHandoverInfo({
    required String basePhoto,
    required Function(String) success,
  }) {
    httpPost(
      method: webApiSubmitHandoverInfo,
      loading: 'component_handover_receipt_information'.tr,
      body: {
        'BarCodeList': [
          for (var i = 0; i < state.dataList.length; ++i) state.dataList[i].code
        ],
        'ProcessFlowID': state.processId,
        'ProcessName': state.process,
        'CreateBarCode': false,
        'UserID': state.empId,
        'DCDeptID': state.departmentId, //转入人组别
        'DCEmpID': state.empId, //转入人empId
        'SCDeptID': getUserInfo()!.departmentID, //转出人empId
        'SCEmpID': getUserInfo()!.empID, //转出人empId
        'PictureList': [
          {
            "EmpCode": state.empCode,
            "Photo": basePhoto,
          }
        ],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success
            .call(response.message ?? 'component_handover_handover_success'.tr);
      } else {
        errorDialog(
            content:
                response.message ?? 'component_handover_handover_failed'.tr);
      }
    });
  }

  //清除所有数据
  clearAllData(){
    clearPeople();
    state.dataList.clear();
    state.summaryDataList.clear();
    state.process.value ='';
    state.processId =0;
    state.typeBody.value ='';
    state.outPart.value ='';
    state.outProcess.value ='';
    state.upDepartmentToDown.value ='';
  }
}
