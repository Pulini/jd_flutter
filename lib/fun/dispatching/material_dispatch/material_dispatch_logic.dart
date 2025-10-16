import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/material_dispatch_info.dart';
import 'package:jd_flutter/bean/http/response/material_dispatch_label_detail.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/printer/print_util.dart';
import 'package:jd_flutter/utils/printer/tsc_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/preview_label_widget.dart';
import 'package:jd_flutter/widget/tsc_label_templates/dynamic_label_110w.dart';

import 'material_dispatch_state.dart';

class MaterialDispatchLogic extends GetxController {
  final MaterialDispatchState state = MaterialDispatchState();

  // @override
  // void onReady() {
  //   userInfo?.empID = 175122;
  //   userInfo?.factory = '1000';
  //   userInfo?.defaultStockNumber = '1104';
  //   super.onReady();
  // }
  selectShow(int index) {
    if (index == 0) {
      state.showOrderList.value = state.allOrderList;
    } else {
      state.showOrderList.value = state.allOrderList
          .where((data) => data.getShowFactory() == state.factoryList[index])
          .toList();
    }
    state.showOrderList.refresh();
  }

  refreshDataList({
    required String startDate,
    required String endDate,
    required int status,
    required String typeBody,
  }) {
    state.getScWorkCardProcess(
      startDate: startDate,
      endDate: endDate,
      status: status,
      typeBody: typeBody,
      error: (msg) => errorDialog(content: msg),
    );
  }

  search(String s) {
    if (s.isEmpty) {
      state.showOrderList.value = state.orderList;
    } else {
      state.showOrderList.value = state.orderList
          .where((v) => v.materialNumber?.contains(s) ?? false)
          .toList();
    }
  }

  reportToSAP({required Function() refresh}) {
    state.reportToSAP(
      success: (msg) => successDialog(
        content: msg,
        back: refresh,
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  batchWarehousing({required Function() refresh}) {
    var submitList = state.createSubmitData();
    if (submitList.isEmpty) {
      msgDialog(content: 'material_dispatch_batch_stock_in_error_tips'.tr);
    } else {
      state.batchWarehousing(
        submitList: submitList,
        success: (msg) => successDialog(
          content: msg,
          back: refresh,
        ),
        error: (msg) => errorDialog(content: msg),
      );
    }
  }

  itemReport(
      {required MaterialDispatchInfo data, required Function() refresh}) {
    state.itemReport(
      data: data,
      success: (msg) => successDialog(
        content: msg,
        back: refresh,
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  itemCancelReport({
    required MaterialDispatchInfo data,
    required Function() refresh,
  }) {
    state.itemCancelReport(
      data: data,
      success: (msg) => successDialog(
        content: msg,
        back: refresh,
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  subItemWarehousing({
    required Children data,
    required String sapDecideArea,
    required Function() refresh,
  }) {
    state.subItemWarehousing(
      data: data,
      sapDecideArea: sapDecideArea,
      success: (msg) => successDialog(
        content: msg,
        back: refresh,
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  subItemReport({
    required BuildContext context,
    required MaterialDispatchInfo submitData,
    required Children subData,
    required bool isPrint,
    required String qty,
    required String long,
    required String wide,
    required String height,
    required String gw,
    required String nw,
  }) {
    state.subItemReport(
      reportQty: qty,
      data: submitData,
      subData: subData,
      longQty: long,
      wideQty: wide,
      heightQty: height,
      gwQty: gw,
      nwQty: nw,
      success: (guid, pick) {
        if (isPrint) {
          var sp = '${long}x' '${wide}x$height';
          var spQty = long
              .toDoubleTry()
              .div(100)
              .mul(wide.toDoubleTry().div(100))
              .mul(height.toDoubleTry().div(100))
              .toShowString();
          if (state.allInstruction.value) {
            printLabel(
              context: context,
              data: submitData,
              billNo: subData.billNo!,
              color: subData.sapColorBatch!,
              guid: guid,
              pick: pick,
              bill: <MaterialDispatchLabelDetail>[],
              qty: qty,
              specifications: spQty,
              specificationSplit: sp,
              gw: gw,
              ew: nw,
              date: getDateYMD(),
            );
          } else {
            state.getLabelDetail(
              guid: guid,
              success: (List<MaterialDispatchLabelDetail> bill) {
                printLabel(
                  context: context,
                  data: submitData,
                  billNo: subData.billNo!,
                  color: subData.sapColorBatch!,
                  guid: guid,
                  pick: pick,
                  bill: bill,
                  qty: qty,
                  specifications: spQty,
                  specificationSplit: sp,
                  gw: gw,
                  ew: nw,
                  date: getDateYMD(),
                );
              },
            );
          }
        }
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  subItemCancelReport({
    required Children subData,
    required Function() refresh,
  }) {
    state.subItemCancelReport(
      subData: subData,
      success: (msg) => successDialog(
        content: msg,
        back: refresh,
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  printLabel({
    required BuildContext context,
    required MaterialDispatchInfo data,
    required String billNo,
    required String date,
    required String color,
    required String guid,
    required String pick,
    required List<MaterialDispatchLabelDetail> bill,
    required String qty,
    required String specifications,
    required String specificationSplit,
    required String gw,
    required String ew,
  }) {
    if (data.exitLabelType == '101') {
      if (state.allInstruction.value) {
        var list = <String>[];
        billNo.split(',').forEach((data) {
          if (data.isNotEmpty) {
            list.add(data);
          }
        });
        var chunked = [
          for (int i = 0; i < list.length; i += 4)
            list.sublist(i, (i + 4).clamp(0, list.length))
        ];
        var subList = <String>[];
        for (var data in chunked) {
          var splitData = '';
          for (var subData in data) {
            splitData = '$splitData$subData,';
          }
          subList.add(splitData.substring(0, splitData.length - 1));
        }
        if (state.isBigLabel.value) {
          //国内大标的连标

          labelMultipurposeBigDynamicFixed(
            qrCode: guid,
            title: data.productName ?? '',
            subTitle: '${data.partName}<${data.processName}>$billNo',
            subTitleWrap: true,
            tableSubTitle2: subList,
            content: '${data.materialName}  (${data.materialNumber})',
            bottomLeftText1: data.drillingCrewName ?? '',
            bottomMiddleText1: '$color/$qty${data.unitName}',
            bottomRightText1: data.sapDecideArea ?? '',
            speed: spGet(spSavePrintSpeed) ?? 3.0,
            density: spGet(spSavePrintDensity) ?? 13.0,
          ).then((printLabel) {
            PrintUtil().printLabel(
                label: printLabel,
                start: () {
                  loadingShow('正在打印');
                },
                success: () {
                  loadingDismiss();
                  showSnackBar(message: '打印成功');
                },
                failed: () {
                  loadingDismiss();
                  showSnackBar(message: '打印失败');
                });
          });
        } else {
          labelMultipurposeDynamic(
            isCut: false,
            qrCode: guid,
            title: data.productName ?? '',
            subTitle: data.materialName ?? '',
            tableTitle:
                '部件：${data.partName}(${data.materialNumber})<${data.processName}>',
            tableSubTitle2: subList,
            bottomLeftText1: data.sapDecideArea ?? '',
            bottomLeftText2: data.drillingCrewName ?? '',
            bottomRightText1: '色系:$color/$qty${data.unitName}',
            bottomRightText2: '取件码:$pick',
          ).then((printLabel) {
            PrintUtil().printLabel(
                label: printLabel,
                start: () {
                  loadingShow('正在打印');
                },
                success: () {
                  loadingDismiss();
                  showSnackBar(message: '打印成功');
                },
                failed: () {
                  loadingDismiss();
                  showSnackBar(message: '打印失败');
                });
          });
        }
      } else {
        if (state.isBigLabel.value) {
          labelMultipurposeBigFixed(
            qrCode: guid,
            title: data.productName ?? '',
            subTitle: '${data.partName}<${data.processName}>$billNo',
            subTitleWrap: true,
            content: '${data.materialName}  (${data.materialNumber})',
            bottomLeftText1: data.drillingCrewName ?? '',
            bottomMiddleText1: '$color/$qty${data.unitName}',
            bottomRightText1: data.sapDecideArea ?? '',
            speed: spGet(spSavePrintSpeed) ?? 3.0,
            density: spGet(spSavePrintDensity) ?? 13.0,
          ).then((printLabel) {
            PrintUtil().printLabel(
                label: printLabel,
                start: () {
                  loadingShow('正在打印');
                },
                success: () {
                  loadingDismiss();
                  showSnackBar(message: '打印成功');
                },
                failed: () {
                  loadingDismiss();
                  showSnackBar(message: '打印失败');
                });
          });
        } else {
          labelMultipurposeFixed(
            //国内小标
            qrCode: guid,
            title: data.productName ?? '',
            subTitleWrap: true,
            subTitle: '${data.partName}<${data.processName}>$billNo',
            content: '(${data.materialNumber})${data.materialName}',
            bottomLeftText1: data.drillingCrewName ?? '',
            bottomMiddleText1: '色系:$color/$qty${data.unitName}',
            bottomMiddleText2: '取件码：$pick',
            bottomRightText1: data.sapDecideArea ?? '',
            speed: spGet(spSavePrintSpeed) ?? 3.0,
            density: spGet(spSavePrintDensity) ?? 12.0,
          ).then((printLabel) {
            PrintUtil().printLabel(
                label: printLabel,
                start: () {
                  loadingShow('正在打印');
                },
                success: () {
                  loadingDismiss();
                  showSnackBar(message: '打印成功');
                },
                failed: () {
                  loadingDismiss();
                  showSnackBar(message: '打印失败');
                });
          });
        }
      }
    } else if (data.exitLabelType == '202') {
      var order = '';
      if (data.billStyle == '0') {
        order = '${data.factoryID} 正单';
      } else {
        order = '${data.factoryID} 补单';
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PreviewLabel(
            labelWidget: dynamicInBoxLabel1095n1096(
              haveSupplier: false,
              productName: data.description ?? '',
              companyOrderType: order,
              customsDeclarationType: data.cusdeclaraType ?? '',
              pieceNo: '1-1',
              qrCode: guid,
              materialList: [
                [data.materialNumber!, data.materialName, qty, data.unitName]
              ],
              pieceID: guid,
              manufactureDate: date,
              supplier: '',
              hasNotes: false,
              notes: '',
            ),
            isDynamic: true,
          ),
        ),
      );
    } else if (data.exitLabelType == '103') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PreviewLabel(
            labelWidget: dynamicMaterialLabel1098(
              labelID: guid,
              myanmarApprovalDocument: data.description ?? '',
              typeBody: data.productName ?? '',
              trackNo: '',
              instructionNo: billNo,
              materialList: [
                [
                  data.materialNumber ?? '',
                  specificationSplit,
                  qty,
                  data.unitName,
                ]
              ],
              customsDeclarationType: data.cusdeclaraType ?? '',
              pieceNo: '1-1',
              pieceID: guid,
              grossWeight: gw,
              netWeight: ew,
              specifications: specifications,
              volume: specificationSplit,
              supplier: data.sapSupplierNumber ?? '',
              manufactureDate: date,
              hasNotes: false,
              notes: '',
            ),
            isDynamic: true,
          ),
        ),
      );
    } else if (data.exitLabelType == '102') {
      var order = '';
      if (data.billStyle == '0') {
        order = '${data.factoryID} 正单';
      } else {
        order = '${data.factoryID} 补单';
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PreviewLabel(
            labelWidget: dynamicSizeMaterialLabel1095n1096(
              labelID: guid,
              productName: data.description ?? '',
              orderType: order,
              typeBody: data.productName ?? '',
              trackNo: color,
              instructionNo: billNo,
              generalMaterialNumber: data.materialNumber ?? '',
              materialDescription: data.materialName ?? '',
              materialList: {},
              inBoxQty: qty,
              customsDeclarationUnit: data.unitName ?? '',
              customsDeclarationType: data.cusdeclaraType ?? '',
              pieceID: guid,
              pieceNo: '1-1',
              grossWeight: gw,
              netWeight: ew,
              specifications: '${specificationSplit}CM(LxWxH)',
              volume: specifications,
              supplier: data.sapSupplierNumber ?? '',
              manufactureDate: date,
              consignee: data.sourceFactoryName ?? '',
              hasNotes: false,
              notes: '',
            ),
            isDynamic: true,
          ),
        ),
      );
    }
  }
}
