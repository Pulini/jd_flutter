import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_scan_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'sap_packing_scan_cache_list_state.dart';

class SapPackingScanCacheListLogic extends GetxController {
  final SapPackingScanCacheListState state = SapPackingScanCacheListState();

  List<List<SapPackingScanAbnormalInfo>> showAbnormalList() => [
        ...groupBy(getAbnormalSearchData(), (v) => v.materialNumber ?? '')
            .values
      ];

  List<SapPackingScanAbnormalInfo> getAbnormalSearchData() =>
      state.abnormalSearchText.isEmpty
          ? state.abnormalList
          : state.abnormalList
              .where((v) => v.search(state.abnormalSearchText.value))
              .toList();

  List<SapPackingScanAbnormalInfo> selectedAbnormalItem() =>
      getAbnormalSearchData().where((v) => v.isSelected.value).toList();

  bool isSelectedAllAbnormalItem() {
    var list = getAbnormalSearchData();
    return list.isNotEmpty && list.every((v) => v.isSelected.value);
  }

  selectAllAbnormalItem(bool select) {
    for (var v in getAbnormalSearchData()) {
      v.isSelected.value = select;
    }
  }

  getAbnormalOrders({
    required String plannedDate,
    required String destination,
    required String factory,
    required String warehouse,
    required String actualCabinet,
    required Function() refresh,
  }) {
    state.getAbnormalOrders(
      plannedDate: plannedDate,
      destination: destination,
      factory: factory,
      warehouse: warehouse,
      actualCabinet: actualCabinet,
      success:refresh,
      error: (msg) => errorDialog(content: msg),
    );
  }

  deleteAbnormal() {
    state.deleteAbnormal(
      list: selectedAbnormalItem(),
      success: (list, msg) {
        for (var delete in list) {
          state.abnormalList.removeWhere(
            (v) => v.labelNumber == delete.labelNumber,
          );
        }
        successDialog(content: msg);
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  getReSubmitData(
    Function(List<SapPackingScanAbnormalInfo>, DateTime) callback,
  ) {
    var list = <SapPackingScanAbnormalInfo>[...selectedAbnormalItem()];
    var timeList = <String>[...selectedAbnormalItem().map((v) => v.date ?? '')];
    _findMaxDate(timeList);
    if (list.isEmpty) {
      errorDialog(content: '没有可提交的数据!');
      return;
    }
    callback.call(list, _findMaxDate(timeList));
  }

  DateTime _findMaxDate(List<String> dateList) {
    var dateTimes = <DateTime>[];
    for (String date in dateList) {
      try {
        dateTimes.add(DateTime(
          date.substring(0, 4).toIntTry(),
          date.substring(5, 7).toIntTry(),
          date.substring(8, 10).toIntTry(),
        ));
      } catch (e) {
        dateTimes.add(DateTime.now());
      }
    }
    DateTime maxDate = dateTimes[0];
    for (DateTime date in dateTimes.sublist(1)) {
      if (date.isAfter(maxDate)) {
        maxDate = date;
      }
    }
    return maxDate;
  }

  reSubmit({
    required String actualCabinet,
    required String postingDate,
    required List<SapPackingScanAbnormalInfo> submitList,
    required Function() refresh,
  }) {
    state.reSubmit(
      actualCabinet: actualCabinet,
      postingDate: postingDate,
      list: submitList,
      success: (msg) {
        refresh.call();
        successDialog(content: msg);
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  selectAbnormalItem({
    required List<List<SapPackingScanAbnormalInfo>> list,
    required SapPackingScanAbnormalInfo item,
    required bool isSelected,
  }) {
    item.isSelected.value = isSelected;
    for (var group in list) {
      for (var i in group) {
        if (i != item && i.pieceNumber == item.pieceNumber) {
          i.isSelected.value = item.isSelected.value;
        }
      }
    }
  }

  selectAbnormalItems({
    required List<List<SapPackingScanAbnormalInfo>> list,
    required int index,
    required bool isSelected,
  }) {
    var pieceList = <String>[];
    for (var item in list[index]) {
      if (!pieceList.contains(item.pieceNumber ?? '')) {
        pieceList.add(item.pieceNumber ?? '');
      }
    }
    for (var piece in pieceList) {
      for (var group in list) {
        group
            .where((v) => v.pieceNumber == piece)
            .forEach((v) => v.isSelected.value = isSelected);
      }
    }
  }

  queryCache() {}

  selectAbnormalMaterialItem(bool isSelect, String materialId) {
    groupBy(
      getAbnormalSearchData().where((v) => v.materialId() == materialId),
      (v) => v.pieceNumber ?? '',
    ).forEach((k, v) {
      state.abnormalList
          .where((l) => l.pieceNumber == k)
          .forEach((v2) => v2.isSelected.value = isSelect);
    });
  }

  selectAbnormalPieceItem(bool isSelect, String pieceNumber) {
    getAbnormalSearchData()
        .where((v) => v.pieceNumber == pieceNumber)
        .forEach((v) => v.isSelected.value = isSelect);
  }
}
