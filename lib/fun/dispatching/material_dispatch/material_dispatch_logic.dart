import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/material_dispatch_info.dart';
import 'package:jd_flutter/bean/http/response/material_dispatch_label_detail.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/preview_label_widget.dart';
import 'package:jd_flutter/widget/tsc_label_templates/110w_dynamic_label.dart';
import 'package:jd_flutter/widget/tsc_label_templates/75w45h_fixed_label.dart';
import 'package:jd_flutter/widget/tsc_label_templates/75w_dynamic_label.dart';
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
    required MaterialDispatchInfo submitData,
    required Children subData,
    required bool isPrint,
    required String qty,
    required String long,
    required String wide,
    required String height,
    required String gw,
    required String nw,
    required int titlePosition,
    required int clickPosition,
    required Function(
      String guid,
      String pick,
      List<MaterialDispatchLabelDetail> bill,
      String long,
      String wide,
      String height,
      String gwQty,
      String nwQty,
    ) success,
  }) {
    state.subItemReport(
      reportQty: qty,
      data: submitData,
      subData: subData,
      titlePosition: titlePosition,
      clickPosition: clickPosition,
      longQty: long,
      wideQty: wide,
      heightQty: height,
      gwQty: gw,
      nwQty: nw,
      success: (guid, pick) {
        if (state.allInstruction.value) {
          success.call(
            guid,
            pick,
            <MaterialDispatchLabelDetail>[],
            long,
            wide,
            height,
            gw,
            nw,
          );
        } else {
          state.getLabelDetail(
            guid: guid,
            success: (List<MaterialDispatchLabelDetail> bill) {
              success.call(
                guid,
                pick,
                bill,
                long,
                wide,
                height,
                gw,
                nw,
              );
            },
          );
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
        back:refresh ,
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  printLabel({
    required MaterialDispatchInfo data,
    required String billNo,
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
      //国内标
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

        Get.to(() => PreviewLabel(
          labelWidget: materialWorkshopDynamicLabel(
            qrCode: guid,
            productName: data.productName ?? '',
            materialName: data.materialName ?? '',
            partName: data.partName ?? '',
            materialNumber: data.materialNumber ?? '',
            processName: data.processName ?? '',
            subList: subList,
            sapDecideArea: data.sapDecideArea ?? '',
            color: color,
            drillingCrewName: data.drillingCrewName ?? '',
            qty: qty,
            unitName: data.unitName ?? '',
          ),
          isDynamic: true,
        ));
      } else {
        var ins = '';
        var toPrint = '';
        for (var data in bill) {
          if (data.billNo!.isNotEmpty) {
            ins = '$ins${data.billNo!},';
          }
        }
        ins.split(',').forEachIndexed((i, s) {
          if (i <= 1 && s.isNotEmpty) {
            toPrint = '$toPrint$s,';
          }
        });
        if (toPrint.endsWith(',')) {
          toPrint.substring(0, toPrint.length - 1);
        }

        Get.to(() => PreviewLabel(
          labelWidget: materialWorkshopFixedLabel(
            qrCode: guid,
            productName: data.productName ?? '',
            materialName: data.materialName ?? '',
            partName: data.partName ?? '',
            toPrint: toPrint,
            palletNumber: state.palletNumber,
            materialNumber: data.materialNumber ?? '',
            processName: data.processName ?? '',
            sapDecideArea: data.sapDecideArea ?? '',
            color: color,
            drillingCrewName: data.drillingCrewName ?? '',
            qty: qty,
            unitName: data.unitName ?? '',
            pick: pick,
          ),
        ));
      }
    } else if (data.exitLabelType == '102') {
      var order = '';
      if (data.billStyle == '0') {
        order = '${data.factoryID} 正单';
      } else {
        order = '${data.factoryID} 补单';
      }

      Get.to(() => PreviewLabel(
        labelWidget: dynamicSizeMaterialLabel1095n1096(
          labelID: guid,
          productName: data.description ?? '',
          orderType: order,
          typeBody: data.productName ?? '',
          trackNo: '',
          instructionNo: billNo,
          generalMaterialNumber: data.materialNumber ?? '',
          materialDescription: data.materialName ?? '',
          materialList: {},
          inBoxQty: qty,
          customsDeclarationUnit: data.unitName ?? '',
          customsDeclarationType: '',
          pieceID: guid,
          pieceNo: '1-1',
          grossWeight: gw,
          netWeight: ew,
          specifications: '${specificationSplit}CM(LxWxH)',
          volume: specifications,
          supplier: data.sapSupplierNumber ?? '',
          manufactureDate: getDateYMD(),
          consignee: data.sourceFactoryName ?? '',
          hasNotes: false,
          notes: '',
        ),
        isDynamic: true,
      ));
    } else if (data.exitLabelType == '103') {
      Get.to(() => PreviewLabel(
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
          manufactureDate: getDateYMD(),
          hasNotes: false,
          notes: '',
        ),
        isDynamic: true,
      ));
    }
  }
}
