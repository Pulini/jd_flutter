import 'package:get/get.dart';
import 'package:jd_flutter/utils.dart';

import '../../../bean/http/response/material_dispatch_info.dart';

class MaterialDispatchState {
  final String spPalletDate = 'MaterialDispatchPickPalletDate';
  final String spMachine = 'MaterialDispatchPickMachine';
  final String spWarehouseLocation = 'MaterialDispatchPickWarehouseLocation';
  final String spPallet = 'MaterialDispatchPickPallet';


  var typeBody = '';
  var lastProcess = false.obs;
  var unStockIn = false.obs;
  var orderList = <MaterialDispatchInfo>[];
  var showOrderList = <MaterialDispatchInfo>[].obs;

  int date = 0;
  String machineId = '';
  String locationId = '';
  String palletNumber = '';

  MaterialDispatchState() {
    getSavePickData();
  }

  getSavePickData() {
    date = spGet(spPalletDate) ?? DateTime.now().millisecondsSinceEpoch;
    machineId = spGet(spMachine) ?? '';
    locationId = spGet(spWarehouseLocation) ?? '';
    palletNumber = spGet(spPallet) ?? '';
  }

  savePickData({
    required int date,
    required String machineId,
    required String locationId,
    required String palletNumber,
  }) {
    this.date = date;
    this.machineId = machineId;
    this.locationId = locationId;
    this.palletNumber = palletNumber;
    spSave(spPalletDate, date);
    spSave(spMachine, machineId);
    spSave(spWarehouseLocation, locationId);
    spSave(spPallet, palletNumber);
  }

  isNeedSetInitData() {
    return machineId.isEmpty ||
        locationId.isEmpty ||
        date == 0 ||
        palletNumber.isEmpty;
  }
}
