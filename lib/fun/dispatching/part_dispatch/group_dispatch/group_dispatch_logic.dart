import 'package:get/get.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_item.dart';

import 'group_dispatch_state.dart';

/// 班组派工 - 业务层
///
/// 负责：串联接口数据与页面交互（查询、缓存、重置、提交）。
class GroupDispatchLogic extends GetxController {
  final GroupDispatchState state = GroupDispatchState();

  /// 查询派工单
  ///
  /// 拉取工序卡明细后：
  /// 1. 主信息赋值给 [GroupDispatchState.titleInfo]；
  /// 2. 部件清单赋值给 [GroupDispatchState.partList]；
  /// 3. 按尺码把已派工人员登记到 [GroupDispatchState.dispatchMap]；
  /// 4. 最后统一赋值给 [GroupDispatchState.sizeList] 触发刷新。
  ///
  /// [order] 工序卡号
  void queryOrder(String order) {
    state.getProcessWorkCardInfo(
      order,
      success: (data) {
        state.titleInfo.value = data.processWorkCardInfo;
        state.partList.value = data.componentList;
        // 按尺码把已派工人员登记到 dispatchMap（每个尺码只保留属于该尺码的人）
        state.dispatchMap.clear();
        // 换单时清空多选状态
        state.clearSelectedSizes();
        for (var v in data.sizeList) {
          state.dispatchMap[v.size] = data.dispatchedList
              .where((v2) => v2.size == v.size)
              .toList()
              .obs;
        }
        state.sizeList.value = data.sizeList;
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  /// 获取工作中心列表
  ///
  /// 已有缓存则直接 [callback] 回传，否则先请求再回传（避免重复请求）。
  void getWorkCenter(Function(List<PickerSapWorkCenterNew>) callback) {
    if (state.workCenterList.isEmpty) {
      state.getWorkCenter(
        success: (list) {
          state.workCenterList = list;
          callback.call(list);
        },
        error: (msg) => errorDialog(content: msg),
      );
    } else {
      callback.call(state.workCenterList);
    }
  }

  /// 重置派工：清空所有尺码下已分配的员工（尺码本身保留）
  void resetAssign() {
    state.clearDispatch();
  }

  /// 校验派工数据是否可提交
  ///
  /// 检查项：
  /// 1. 是否已查询到尺码数据（未查询时提示并返回 false）；
  /// 2. 是否**所有尺码都已分配人员**（存在未分配的尺码时，列出这些尺码并提示）。
  ///
  /// 校验不通过时弹窗提示并返回 false；全部通过返回 true，
  /// 由页面再弹确认框执行提交。
  bool checkSubmitData() {
    // 1. 尚未查询到尺码数据
    if (state.sizeList.isEmpty) {
      msgDialog(content: 'group_dispatch_no_data_submit'.tr);
      return false;
    }

    // 2. 存在未分配人员的尺码
    var unassigned = <String>[
      for (var v in state.sizeList)
        // 该尺码没有派工记录、或记录为空，均视为未分配
        if (state.dispatchMap[v.size]?.isEmpty ?? true) v.size
    ];
    if (unassigned.isNotEmpty) {
      msgDialog(
        content: 'group_dispatch_size_not_assigned'
            .trArgs([unassigned.join('、')]),
      );
      return false;
    }

    return true;
  }

  /// 提交派工
  ///
  /// 成功后清空页面数据，并回调 [refresh]（由页面重置查询输入框等）。
  void submitDispatch(Function() refresh) {
    state.submitDispatch(
      success: (msg) => successDialog(
        content: msg,
        back: () {
          state.sizeList.clear();
          state.titleInfo.value = null;
          state.partList.clear();
          state.dispatchMap.clear();
          state.clearSelectedSizes();
          refresh.call();
        },
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }
}
