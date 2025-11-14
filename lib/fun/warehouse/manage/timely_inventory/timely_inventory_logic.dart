import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/timely_inventory_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/timely_inventory/timely_inventory_state.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class TimelyInventoryLogic extends GetxController {
  final TimelyInventoryState state = TimelyInventoryState();

  void getImmediateStockList({
    required String factoryNumber,
    required String stockId,
    required String instructionNumber,
    required String materialCode,
    required String batch,
  }) {
    state.getImmediateStockList(
      factoryNumber: factoryNumber,
      stockId: stockId,
      instructionNumber: instructionNumber,
      materialCode: materialCode,
      batch: batch,
      error: (msg) => errorDialog(content: msg),
    );
  }

  void modifyStorageLocation({
    required TimelyInventoryInfo data,
    required TimeItems item,
    required String newLocation,
    required Function(String msg) success,
  }) {
    state.modifyStorageLocation(
      data: data,
      item: item,
      newLocation: newLocation,
      success: success,
      error: (msg) => errorDialog(content: msg),
    );
  }
}
