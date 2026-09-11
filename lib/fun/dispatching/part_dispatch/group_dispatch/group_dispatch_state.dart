import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/http/response/group_dispatch_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/picker/picker_item.dart';

import 'group_dispatch_dialog.dart';

/// 员工工号长度（用于按工号查询人员时的前置校验）
const int groupDispatchEmpCodeLength = 6;

/// 班组派工 - 数据层
///
/// 负责：接口请求、以及页面所需状态的持有（不含 UI 逻辑）。
class GroupDispatchState {
  /// 工序卡主信息（顶部标题区展示）；查询前为 null
  var titleInfo = Rxn<ProcessWorkCardInfo>();

  /// 部件清单（左侧列表）
  var partList = <ComponentItem>[].obs;

  /// 尺码列表（右侧派工区）
  var sizeList = <SizeInfo>[].obs;

  /// 各尺码下已分配的员工，key 为尺码（如 `5`、`6`）
  ///
  /// 响应式状态集中在此处维护，数据 bean [SizeInfo] 保持纯数据。
  var dispatchMap = <String, RxList<DispatchedItem>>{}.obs;

  /// 工作中心列表缓存（非响应式：仅用于避免重复请求，不驱动 UI 刷新）
  var workCenterList = <PickerSapWorkCenterNew>[];

  /// 默认部门 ID：优先取本地缓存的部门，其次取工序卡上的部门，都没有则为空
  String get departmentId =>
      spGet(groupDispatchDepartmentId) ??
      titleInfo.value?.departId.toString() ??
      '';

  /// 获取指定尺码的已派工列表；不存在时自动创建并登记到 [dispatchMap]
  RxList<DispatchedItem> dispatchListOf(String size) =>
      dispatchMap.putIfAbsent(size, () => <DispatchedItem>[].obs);

  /// 清空所有尺码下已分配的员工（尺码本身保留）
  void clearDispatch() {
    for (var list in dispatchMap.values) {
      list.value = [];
    }
  }

  /// 查询工序卡明细
  ///
  /// [order] 工序卡号，如 `GXPG250103497/1`
  /// [success] 成功回调，返回解析后的工序卡明细
  /// [error]   失败回调，返回错误信息
  void getProcessWorkCardInfo(
    String order, {
    required Function(WorkCardDetail) success,
    required Function(String) error,
  }) {
    httpGet(
      method: webApiGetProcessWorkCardInfo,
      loading: 'group_dispatch_getting_work_card_info'.tr,
      params: {'processNo': order},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(WorkCardDetail.fromJson(response.data));
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  /// 获取工作中心列表（用于按部门筛选员工）
  ///
  /// 用 [JsonParse.list] 归一：非数组时返回空列表，
  /// 避免对 null/字符串/对象做 for-in 遍历时崩溃。
  void getWorkCenter({
    required Function(List<PickerSapWorkCenterNew>) success,
    required Function(String) error,
  }) {
    httpGet(
      method: webApiPickerSapWorkCenterNew,
      params: {
        'ShowType': 'GetWorkcenterAndDevices',
        'UserID': userInfo?.userID ?? 0,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(
          JsonParse.list(response.data, PickerSapWorkCenterNew.fromJson),
        );
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  /// 提交派工：把各尺码下已分配的员工提交到后端
  ///
  /// 提交体：`FInterID`（工序卡内码）、`FCardNo`（卡号）、
  /// `SizeList`（每个尺码及其员工 ID 列表，见 [SizeInfo.getSubmitData]）
  void submitDispatch({
    required void Function(String) success,
    required void Function(String) error,
  }) {
    httpPost(
      method: webApiSaveProcessWorkCardInfo,
      loading: 'team_leader_issue_work_order'.tr,
      body: {
        'FInterID': titleInfo.value?.interId,
        'FCardNo': titleInfo.value?.cardNo,
        'SizeList': sizeList
            .map((v) => v.getSubmitData(dispatchListOf(v.size)))
            .toList(),
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

}
