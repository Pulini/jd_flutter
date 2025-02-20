import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/feishu_info.dart';
import 'package:jd_flutter/bean/http/response/production_tasks_info.dart';
import 'package:jd_flutter/fun/report/production_tasks/production_tasks_detail_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/feishu_authorize.dart';

import 'production_tasks_state.dart';

class ProductionTasksLogic extends GetxController {
  final ProductionTasksState state = ProductionTasksState();

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  refreshTable({
    required Function() refresh,
  }) {
    state.getProductionOrderSchedule(
      success: () => refresh.call(),
      error: (msg) => showSnackBar(title: '错误', message: msg, isWarning: true),
    );
  }

  WorkCardSizeInfos getTotalItem() => WorkCardSizeInfos(
        size: '合计',
        qty: (state.orderList[0].workCardSizeInfo ?? [])
            .map((v) => v.qty ?? 0)
            .reduce((a, b) => a.add(b)),
        productScannedQty: (state.orderList[0].workCardSizeInfo ?? [])
            .map((v) => v.productScannedQty ?? 0)
            .reduce((a, b) => a.add(b)),
        manualScannedQty: (state.orderList[0].workCardSizeInfo ?? [])
            .map((v) => v.manualScannedQty ?? 0)
            .reduce((a, b) => a.add(b)),
        scannedQty: (state.orderList[0].workCardSizeInfo ?? [])
            .map((v) => v.scannedQty ?? 0)
            .reduce((a, b) => a.add(b)),
        installedQty: (state.orderList[0].workCardSizeInfo ?? [])
            .map((v) => v.installedQty ?? 0)
            .reduce((a, b) => a.add(b)),
      );

  ProductionTasksDetailItemInfo getDetailTotalItem() =>
      ProductionTasksDetailItemInfo(
        size: '合计',
        qty: state.detailTableInfo
            .map((v) => v.qty ?? 0)
            .reduce((a, b) => a.add(b)),
        productScannedQty: state.detailTableInfo
            .map((v) => v.productScannedQty ?? 0)
            .reduce((a, b) => a.add(b)),
        manualScannedQty: state.detailTableInfo
            .map((v) => v.manualScannedQty ?? 0)
            .reduce((a, b) => a.add(b)),
        scannedQty: state.detailTableInfo
            .map((v) => v.scannedQty ?? 0)
            .reduce((a, b) => a.add(b)),
        installedQty: state.detailTableInfo
            .map((v) => v.installedQty ?? 0)
            .reduce((a, b) => a.add(b)),
      );

  changeSort({
    required int oldIndex,
    required int newIndex,
    required Function() refresh,
  }) {
    if (checkUserPermission('1053802')) {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      var newLine = <ProductionTasksSubInfo>[...state.orderList];
      newLine.insert(newIndex, newLine.removeAt(oldIndex));
      state.changeSort(
        newLine: newLine,
        success: (msg) {
          showSnackBar(
            title: 'molding_scan_bulletin_report_sort'.tr,
            message: msg,
          );
          refresh.call();
        },
        error: (msg) => errorDialog(content: msg),
      );
    } else {
      errorDialog(content: '没有操作权限！');
    }
  }

  getDetail({String? ins, String? po, required String imageUrl}) {
    state.getProductionOrderScheduleDetail(
      ins: ins ?? '',
      po: po ?? '',
      success: () {
        if (ins != null && ins.isNotEmpty) {
          Get.to(
            () => const ProductionTasksDetailPage(),
            arguments: {'isInstruction': true, 'imageUrl': imageUrl},
          );
        } else if (po != null && po.isNotEmpty) {
          Get.to(
            () => const ProductionTasksDetailPage(),
            arguments: {'isInstruction': false, 'imageUrl': imageUrl},
          );
        }
      },
      error: (msg) => showSnackBar(title: '错误', message: msg, isWarning: true),
    );
  }

  mqttRefresh({
    required String topic,
    required String data,
    required Function(String) refreshItem,
    required Function() refreshAll,
  }) {
    if (topic == state.mqttTopic[1] || topic == state.mqttTopic[2]) {
      var info = MqttMsgInfo.fromJson(jsonDecode(data));
      try {
        if (state.orderList[0].workCardInterID == info.workCardID &&
            state.orderList[0].clientOrderNumber == info.clientOrderNumber &&
            state.orderList[0].moID == info.moID) {
          debugPrint('主页表格');
          WorkCardSizeInfos? findSize = state.orderList[0].workCardSizeInfo
              ?.firstWhere((v) => v.size == info.size);
          if (findSize != null) {
            if (info.scanTypeID == '1') {
              findSize.addManualScannedQty(info.qty ?? 0);
              state.todayCompleteQty.value += 1;
              state.monthCompleteQty.value += 1;
            } else if (info.scanTypeID == '2' || info.scanTypeID == '3') {
              findSize.addProductScannedQty(info.qty ?? 0);
              state.todayCompleteQty.value += 1;
              state.monthCompleteQty.value += 1;
            } else {
              findSize.addInstalledQty(info.qty ?? 0);
            }
            state.tableInfo.refresh();
            refreshItem.call('${info.size}码 +${info.qty.toShowString()}');
          }
        } else {
          debugPrint('其他表格');
          WorkCardSizeInfos? findSize = state.orderList
              .firstWhere((v) =>
                  v.workCardInterID == info.workCardID &&
                  v.clientOrderNumber == info.clientOrderNumber &&
                  v.moID == info.moID)
              .workCardSizeInfo
              ?.firstWhere((v) => v.size == info.size);
          if (findSize != null) {
            if (info.scanTypeID == '1') {
              findSize.addManualScannedQty(info.qty ?? 0);
              state.todayCompleteQty.value += 1;
              state.monthCompleteQty.value += 1;
            } else if (info.scanTypeID == '2' || info.scanTypeID == '3') {
              findSize.addProductScannedQty(info.qty ?? 0);
              state.todayCompleteQty.value += 1;
              state.monthCompleteQty.value += 1;
            } else {
              findSize.addInstalledQty(info.qty ?? 0);
            }
            refreshItem.call('${info.size}码 +${info.qty.toShowString()}');
          }
        }
      } catch (e) {
        debugPrint('mqttRefresh error=$e');
      }
    } else if (topic == state.mqttTopic[0]) {
      var info = ProductionTasksInfo.fromJson(jsonDecode(data)['Data']);
      logger.f(info.toJson());
      state.orderList = info.subInfo ?? [];
      state.todayTargetQty.value = info.toDayPlanQty ?? 0;
      state.todayCompleteQty.value = info.toDayFinishQty ?? 0;
      state.monthCompleteQty.value = info.toMonthFinishQty ?? 0;
      state.refreshUiData();
      refreshAll.call();
    }
  }

  queryProcessInstruction({
    required String query,
    required Function(List<FeishuWikiSearchItemInfo> list) files,
  }) {
    feishuAuthorizeCheck(
      notAuthorize: () =>
          Get.to(() => FeishuAuthorize())?.then((token) => _queryFeishuWiki(
                token: token,
                query: query,
                files: files,
              )),
      authorized: (token) => _queryFeishuWiki(
        token: token,
        query: query,
        files: files,
      ),
    );
  }

  _queryFeishuWiki({
    required String token,
    required String query,
    required Function(List<FeishuWikiSearchItemInfo> list) files,
  }) {

    feishuWikiSearch(
      token: token,
      query: query,
      success: (list) =>files.call(list),
      failed: (msg) => errorDialog(content: msg),
    );
  }
}
