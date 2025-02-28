import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/puma_box_code_info.dart';
import 'package:jd_flutter/bean/http/response/puma_code_list_info.dart';
import 'package:jd_flutter/bean/http/response/scan_code.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

class PumaAntiCounterfeitingState {
  var dataList = <PumaBoxCodeInfo>[].obs;
  var dataCodeList = <ScanCode>[].obs;
  var palletNumber = ''.obs;
  var scanNum = "0".obs;
  var outScanNum = "0".obs;
  var sortingList = <PumaCodeListInfo>[].obs;

  ///添加条码
  addCode(String newCode) {
    if (newCode.isEmpty) {
      showSnackBar(title: '警告', message: '请扫描条码');
    } else {
      if (newCode.startsWith("GE") &&
          newCode.length >= 10 &&
          newCode.length <= 13) {
        palletNumber.value = newCode;
      } else {
        if (isExists(newCode)) {
          showSnackBar(title: '警告', message: '条码已存在');
        } else {
          dataCodeList
              .add(ScanCode(palletNumber: palletNumber.value, code: newCode));
          setScanNum();
        }
      }
    }
  }

  ///判断条码是否存在
  bool isExists(String code) {
    for (var v in dataCodeList) {
      if (v.code == code) {
        return true;
      }
    }
    return false;
  }


  ///计算扫码条数
  setScanNum() {
    scanNum.value = dataCodeList.length.toString();
  }

  ///计算分拣扫码条数
  setSortingScanNum() {
    outScanNum.value = sortingList.length.toString();
  }

  ///清空条码,更新条码条数
  clearData() {
    dataCodeList.clear();
    setScanNum();
  }

  ///删除条码
  deleteCode(ScanCode data) {
    dataCodeList.remove(data);
    scanNum.value = dataCodeList.length.toString();
  }

  ///清空分拣条码信息,更新条码条数
  clearSortingList(){
    sortingList.clear();
    setSortingScanNum();
  }

}
