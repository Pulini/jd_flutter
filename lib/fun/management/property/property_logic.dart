import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/management/property/property_detail_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/wifi_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import '../../../bean/http/response/people_message_info.dart';
import 'property_state.dart';

class PropertyLogic extends GetxController {
  final PropertyState state = PropertyState();

  final WiFiManager wifiManager = WiFiManager();

  Future<void> connectToNetwork({
    required String ssid,
    required String password,
    Function()? success, // 添加成功回调参数
  }) async {
    bool result = await wifiManager.connectToWiFi(
      ssid: ssid,
      password: password,
    );

    await Future.delayed(Duration(seconds: 5));
    loadingDismiss();
    if (result) {
      // 连接成功后，锁定当前WiFi网络防止自动切换
      bool locked = await wifiManager.lockCurrentNetwork();
      if (!locked) {
        // 如果锁定失败，给出警告但不中断流程
        errorDialog(content: '警告：无法锁定WiFi网络，可能会出现连接不稳定');
      }
      await Future.delayed(Duration(seconds: 5));
      success?.call();
    } else {
      errorDialog(content: '连接失败。');
    }
  }

  void connectAndSendData() async {
    try {
      loadingShow('正在连接到激光打印机，并下发内容...');
      // 连接到指定地址和端口
      final socket = await Socket.connect("192.168.6.2", 8050,
          timeout: Duration(seconds: 10));

      // 监听数据响应
      socket.listen((data) {
        wifiManager.disconnectFromWiFi();
      });

      // 准备发送的数据
      final printMessage = getPrintMes();
      final asciiBytes = utf8.encode(printMessage);
      final startBytes = [0x02, 0x05];
      final endBytes = [0x03];
      final completeData = [...startBytes, ...asciiBytes, ...endBytes];

      // 发送数据
      socket.add(Uint8List.fromList(completeData));
      await socket.flush();

      // 延迟关闭连接
      await Future.delayed(Duration(seconds: 3));
      socket.destroy();
      loadingDismiss();
    } catch (e) {
      errorDialog(content: '连接错误: $e');
    }
  }

  String getPrintMes() {
    var name = '';
    var nameLast = '';
    var number = '';
    var numberLast = '';
    var mes = '';

    // 假设 detail 是 PropertyState 中的某个对象
    // 需要根据实际的数据结构进行调整
    final detail = state.detail;
    final detailName = detail.name ?? '';
    final detailNumber = detail.number ?? '';

    if (detailName.length <= 8) {
      if (detailNumber.length <= 12) {
        // 名称和编码长度都正常
        mes =
            'seta:data#v1=$detailName;v2=$detailNumber;v3=${detail.buyDate};v4=${detail.interID};';
      } else {
        // 长度小于等于8    编码大于12
        final numberList = _chunked(detailNumber, 12);
        number = numberList[0];
        if (numberList.length > 1) numberLast = numberList[1];
        mes =
            'seta:data#v1=$detailName;v2=$number;v3=${detail.buyDate};v4=${detail.interID};v6=$nameLast';
      }
    } else {
      if (detailNumber.length <= 12) {
        // 名字大于8  编号小于等于12
        final nameList = _chunked(detailName, 8);
        name = nameList[0];
        if (nameList.length > 1) nameLast = nameList[1];
        mes =
            'seta:data#v1=$name;v2=$detailNumber;v3=${detail.buyDate};v4=${detail.interID};v5=$nameLast;';
      } else {
        // 名字大于8 编号大于12
        final nameList = _chunked(detailName, 8);
        final numberList = _chunked(detailNumber, 12);
        name = nameList[0];
        if (nameList.length > 1) nameLast = nameList[1];
        number = numberList[0];
        if (numberList.length > 1) numberLast = numberList[1];
        mes =
            'seta:data#v1=$name;v2=$number;v3=${detail.buyDate};v4=${detail.interID};v5=$nameLast;v6=$numberLast;';
      }
    }

    return mes;
  }

// 辅助方法：字符串分块
  List<String> _chunked(String str, int chunkSize) {
    final chunks = <String>[];
    for (var i = 0; i < str.length; i += chunkSize) {
      final end = (i + chunkSize < str.length) ? i + chunkSize : str.length;
      chunks.add(str.substring(i, end));
    }
    return chunks;
  }

  void queryProperty({
    required String propertyNumber,
    required String propertyName,
    required String serialNumber,
    required String invoiceNumber,
    required String name,
    required String workerNumber,
    required String startDate,
    required String endDate,
  }) {
    state.queryProperty(
      propertyNumber: propertyNumber,
      propertyName: propertyName,
      serialNumber: serialNumber,
      invoiceNumber: invoiceNumber,
      name: name,
      workerNumber: workerNumber,
      startDate: startDate,
      endDate: endDate,
      error: (msg) => errorDialog(content: msg),
    );
  }

  void getPropertyDetail(int detailId) {
    state.getPropertyDetail(
      detailId: detailId,
      success: () => Get.to(() => const PropertyDetailPage()),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void setParticipator(String str) {
    if (str.length >= 6) {
      getWorkerInfo(
        number: str,
        workers: (list) {
          state.setParticipator(
            empCode: list[0].empCode ?? '',
            empName: list[0].empName ?? '',
            empID: list[0].empID ?? -1,
          );
        },
        error: (msg) => errorDialog(content: msg),
      );
    } else {
      state.setParticipator();
    }
  }

  void setCustodian(
    String str, {
    required Function() success,
    required Function() fail,
  }) {
    if (str.length >= 6) {
      state.searchPeople(
          number: str,
          people: (PeopleMessageInfo p1) {
            state.detail.custodianCode = p1.empCode;
            state.detail.custodianName = p1.empName;
            state.detail.deptName = p1.deptName;
            state.detail.liableEmpName = p1.liableEmpName;
            state.detail.liableEmpCode = p1.liableEmpCode;
            state.detail.deptID = p1.departmentID;
            state.detail.liableEmpID = p1.liableEmpID;
            state.custodianName.value = p1.empName ?? '';
            setLiable(p1.liableEmpCode.toString(), success: (s) {
              success.call();
            });
          });
    } else if (str.isEmpty) {
      fail.call();
      state.setCustodian();
    }
  }

  void setLiable(
    String str, {
    required Function(String empCode) success,
  }) {
    if (str.length >= 6) {
      getWorkerInfo(
        number: str,
        workers: (list) {
          state.setLiable(
            empCode: list[0].empCode ?? '',
            empName: list[0].empName ?? '',
            empID: list[0].empID ?? -1,
          );
          success.call(list[0].empCode ?? '');
        },
        error: (msg) => errorDialog(content: msg),
      );
    } else {
      state.setLiable();
    }
  }

  void propertyClose(int detailId) {
    state.propertyClose(
      detailId: detailId,
      success: (msg) => successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void skipAcceptance(int detailId) {
    state.skipAcceptance(
      detailId: detailId,
      success: (msg) => successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void updatePropertyInfo() {
    state.updatePropertyInfo(
      success: (msg) => successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
    );
  }

  bool checkData() {
    if (state.detail.name?.isEmpty == true) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请输入名称',
        isWarning: true,
      );
      return false;
    }
    if (state.detail.number?.isEmpty == true) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请输入编号',
        isWarning: true,
      );
      return false;
    }
    if (state.detail.model?.isEmpty == true) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请输入规格型号',
        isWarning: true,
      );
      return false;
    }
    if (state.detail.price != null && state.detail.price! <= 0) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请输入单价',
        isWarning: true,
      );
      return false;
    }
    if (state.detail.orgVal != null && state.detail.orgVal! <= 0) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请输入原值',
        isWarning: true,
      );
      return false;
    }
    if (state.detail.manufacturer?.isEmpty == true) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请输入制造商',
        isWarning: true,
      );
      return false;
    }
    if (state.detail.guaranteePeriod?.isEmpty == true) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请输入保修期限(月)',
        isWarning: true,
      );
      return false;
    }
    if (state.detail.expectedLife != null && state.detail.expectedLife! <= 0) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请输入预计使用时长(月)',
        isWarning: true,
      );
      return false;
    }
    if (state.detail.participator != null && state.detail.participator! == -1) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请输入参检人工号',
        isWarning: true,
      );
      return false;
    }
    if (state.detail.keepEmpID != null && state.detail.keepEmpID! == -1) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请输入保管人工号',
        isWarning: true,
      );
      return false;
    }
    if (state.detail.liableEmpID != null && state.detail.liableEmpID! == -1) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请输入监管人工号',
        isWarning: true,
      );
      return false;
    }
    if (state.detail.writeDate?.isEmpty == true) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请选择登记日期',
        isWarning: true,
      );
      return false;
    }
    if (state.detail.address?.isEmpty == true) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请输入存放地点',
        isWarning: true,
      );
      return false;
    }
    if (state.assetPicture.isEmpty) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请拍摄现场照片',
        isWarning: true,
      );
      return false;
    }
    if (state.ratingPlatePicture.isEmpty) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请拍摄铭牌照片',
        isWarning: true,
      );
      return false;
    }
    return true;
  }

  void printLabel(int pageIndex) {
    var selectItem = [];
    switch (pageIndex) {
      case 0:
        selectItem = state.propertyList
            .where((v) => v.processStatus == '2' && v.isChecked)
            .toList();
        break;
      case 1:
        selectItem = state.propertyList
            .where((v) => v.processStatus == "0" && v.isChecked)
            .toList();
        break;
      case 2:
        selectItem = state.propertyList
            .where((v) => v.processStatus == "1" && v.isChecked)
            .toList();
        break;
    }
    if (selectItem.isEmpty) {
      errorDialog(content: 'property_print_no_selected'.tr);
      return;
    }
  }

  int interceptId(String mes) {
    if (mes.contains("FInterID=")) {
      return int.tryParse(mes.split("=")[1]) ?? 0;
    } else {
      return 0;
    }
  }
}
