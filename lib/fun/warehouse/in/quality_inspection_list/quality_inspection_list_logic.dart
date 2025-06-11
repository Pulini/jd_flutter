import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/stuff_quality_inspection_detail_info.dart';
import 'package:jd_flutter/bean/http/response/quality_inspection_receipt_info.dart';
import 'package:jd_flutter/bean/http/response/quality_inspection_show_color.dart';
import 'package:jd_flutter/bean/http/response/stuff_quality_inspection_info.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_list_detail_view.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_list_state.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_reverse_color_view.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/spinner_widget.dart';

import '../stuff_quality_inspection/stuff_quality_inspection_view.dart';

class QualityInspectionListLogic extends GetxController {
  final QualityInspectionListState state = QualityInspectionListState();

  var selectList = <StuffQualityInspectionInfo>[];
  var selectIndex = -1;
  var selectCode = '';

  //公司
  var sapCompany = OptionsPickerController(
    hasAll: true,
    PickerType.sapCompany,
    buttonName: 'quality_inspection_select_company'.tr,
    saveKey:
        '${RouteConfig.qualityInspectionList.name}${PickerType.sapCompany}',
  );

  //工厂
  var factoryController = OptionsPickerController(
    PickerType.sapFactory,
    buttonName: 'quality_inspection_select_factory'.tr,
    saveKey:
        '${RouteConfig.qualityInspectionList.name}${PickerType.sapFactory}',
  );

  //供应商
  var supplierController = OptionsPickerController(
    hasAll: true,
    buttonName: 'quality_inspection_select_supplier'.tr,
    PickerType.sapSupplier,
    saveKey:
        '${RouteConfig.qualityInspectionList.name}${PickerType.sapSupplier}',
  );

  //日期选择器 开始时间
  var startDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.qualityInspectionList.name}${PickerType.startDate}',
  );

  //日期选择器 结束时间
  var endDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.qualityInspectionList.name}${PickerType.endDate}',
  );

  //选择搜索按钮条件
  late SpinnerController spType = SpinnerController(
    dataList: [
      'quality_inspection_not_in_stock'.tr,
      'quality_inspection_in_stock'.tr,
      'quality_inspection_delete'.tr,
      'quality_inspection_all_not_delete'.tr,
      'quality_inspection_all_not_returned'.tr,
    ],
    onChanged: (index) => {changeShowType(index)},
  );

  //改变按钮状态
  changeShowType(int position) {
    switch (position) {
      case 0:
        changeBtn(true, true, true, true, true, false);
        break;
      case 1:
        changeBtn(false, false, false, true, true, true);
        break;
      case 2:
        changeBtn(false, false, false, true, true, false);
        break;
      case 3:
        changeBtn(false, true, true, true, true, false);
        break;
      case 4:
        changeBtn(false, true, true, true, true, false);
        break;
    }
  }

  // 是否显示按钮
  changeBtn(bool store, bool delete, bool change, bool location, bool color,
      bool reverse) {
    state.btnShowStore.value = store;
    state.btnShowDelete.value = delete;
    state.btnShowChange.value = change;
    state.btnShowLocation.value = location;
    state.btnShowColor.value = color;
    state.btnShowReverse.value = reverse;
    getInspectionList();
  }

  getSelectData() {
    selectList.clear();
    for (var data in state.showDataList) {
      for (var c in data) {
        if (c.isSelected.value == true) {
          selectList.add(c);
        }
      }
    }
  }

  //获取品检单列表
  getInspectionList() {
    var typeValue = '';

    switch (spType.selectIndex) {
      case 0:
        typeValue = '04';
        break;
      case 1:
        typeValue = '03';
        break;
      case 2:
        typeValue = 'DEL';
        break;
      case 3:
        typeValue = '0';
        break;
      case 4:
        typeValue = '05';
        break;
    }

    httpPost(
      method: webApiGetInspectionList,
      loading: 'quality_inspection_list_quality_inspection'.tr,
      body: {
        'StartDate': startDate.getDateFormatYMD(),
        'EndDate': endDate.getDateFormatYMD(),
        'FactoryType': state.typeBody, //型体
        'InstructionNumber': state.inspectionOrder,
        'MaterialCode': state.materialCode,
        'SupplierNumber': supplierController.selectedId.value,
        'InspectionNo': state.inspectionOrder,
        'TemporaryNo': state.temporaryReceipt,
        'imvoucher': state.receiptVoucher,
        'Type': typeValue,
        'ProducerNumber': getUserInfo()!.number,
        'DeliveryAddress': sapCompany.selectedId.value, //公司
        'Role': getUserInfo()!.sapRole,
        'FactoryCode': factoryController.selectedId.value, //工厂代码
        'TrackNo': state.trackingNumber, //跟踪号
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.dataList = [
          for (var i = 0; i < response.data.length; ++i)
            StuffQualityInspectionInfo.fromJson(response.data[i])
        ];
        arrangeData();
      } else {
        state.showDataList.clear();
        errorDialog(
            content:
                response.message ?? 'process_dispatch_label_delete_fail'.tr);
      }
    });
  }

  //整理数据
  arrangeData() {
    state.showDataList.clear();
    var name = <String>[];

    for (var data in state.dataList) {
      if (!name.contains('${data.inspectionOrderNo}_${data.materialCode}')) {
        name.add('${data.inspectionOrderNo}_${data.materialCode}');
      }
    }

    for (var name in name) {
      var dataList = <StuffQualityInspectionInfo>[];
      dataList.clear();
      for (var data in state.dataList) {
        if (('${data.inspectionOrderNo}_${data.materialCode}') == name) {
          dataList.add(data);
        }
      }
      state.showDataList.add(dataList);
    }
  }

  //选择子项数据
  selectSubItem(bool select, int index, int position) {
    state.showDataList[position][index].isSelected.value = select;
    state.showDataList.refresh();
  }

  //选择所有子项数据
  selectAllSubItem(bool select, int position) {
    for (var item in state.showDataList[position]) {
      item.isSelected.value = select;
    }
    state.showDataList.refresh();
  }

  //去看详情
  goDetail(int position) {
    var list = <StuffQualityInspectionInfo>[];
    for (var data in state.showDataList[position]) {
      list.add(data);
    }
    state.showDetailDataList.value = state.showDataList[position];

    Get.to(() => const QualityInspectionListDetailPage());
  }

  //删除判断
  checkDelete({
    required Function success,
  }) {
    if (checkUserPermission('105180503')) {
      var selectNum = 0;

      for (var data in state.showDataList) {
        for (var c in data) {
          if (c.isSelected.value == true) {
            selectNum = selectNum + 1;
          }
        }
      }
      if (selectNum > 0) {
        if (checkSameData()) {
          success.call();
        } else {
          showSnackBar(message: 'quality_inspection_different_order'.tr);
        }
      } else {
        showSnackBar(message: 'quality_inspection_select_data'.tr);
      }
    } else {
      showSnackBar(message: 'quality_inspection_no_delete'.tr);
    }
  }

  //验证是否是同一个品检单
  bool checkSameData() {
    var name = <String>[];
    for (var data in state.showDataList) {
      for (var c in data) {
        if (c.isSelected.value == true) {
          if (!name.contains(c.inspectionOrderNo)) {
            name.add(c.inspectionOrderNo.toString());
          }
        }
      }
    }
    if (name.length == 1) {
      return true;
    } else {
      return false;
    }
  }

  //删除品检单
  deleteData({
    required String reason,
    required Function(String)? success,
  }) {
    getSelectData();
    httpPost(
      method: webApiCreateInspection,
      loading: 'quality_inspection_deleting'.tr,
      body: {
        'MES_Heads': [
          {
            'CompanyCode': '',
            'Creator': '',
            'Factory': '',
            'IsConcessive': '',
            'ModifiedBy': '',
            'Remarks': '',
            'SourceOrderType': '',
            'SupplierAccountNumber': '',
            'DeletedBy': getUserInfo()!.number,
            'InspectionOrderNo': selectList[0].inspectionOrderNo,
          }
        ],
        'MES_IdS': '',
        'MES_Items': [
          for (var item in selectList)
            {
              'BasicQuantity': '',
              'BasicUnit': '',
              'Coefficient': '',
              'CommonUnits': '',
              'DistributiveForm': '',
              'FactoryType': '',
              'InspectionMethod': '',
              'InspectionQuantity': '',
              'MaterialCode': '',
              'PlanLineNumber': '',
              'PurchaseDocumentItemNumber': '',
              'PurchaseVoucherNo': '',
              'QualifiedQuantity': '',
              'Remarks': '',
              'SalesAndDistributionVoucherNumber': '',
              'SamplingQuantity': '',
              'SamplingRatio': '',
              'ShortCodesNumber': '',
              'StorageQuantity': '',
              'TemporaryCollectionBankNo': '',
              'TemporaryReceiptNo': '',
              'UnqualifiedQuantity': '',
              'DeleteReason': reason,
              'DeletedBy': getUserInfo()!.number,
              'InspectionLineNumber': item.inspectionLineNumber,
              'InspectionOrderNo': item.inspectionOrderNo,
            }
        ],
        'MES_Items2': [],
        'MES_Items3': [],
        'MES_Items4': [],
        'MES_Items5': [],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success!
            .call(response.message ?? 'quality_inspection_success_deleting'.tr);
      } else {
        errorDialog(
            content: response.message ?? 'quality_inspection_fail_deleting'.tr);
      }
    });
  }

  //入库判断
  checkStore({
    required Function success,
  }) {
    if (checkUserPermission('105180401')) {
      var selectNum = 0;

      for (var data in state.showDataList) {
        for (var c in data) {
          if (c.isSelected.value == true) {
            selectNum = selectNum + 1;
          }
        }
      }
      if (selectNum > 0) {
        if (checkStoreSameData()) {
          success.call();
        } else {
          showSnackBar(message: 'quality_inspection_different_order'.tr);
        }
      } else {
        showSnackBar(message: 'quality_inspection_select_data'.tr);
      }
    } else {
      showSnackBar(message: 'quality_inspection_no_store_inspection'.tr);
    }
  }

  //验证是否是同一个税码
  bool checkStoreSameData() {
    var name = <String>[];
    for (var data in state.showDataList) {
      for (var c in data) {
        if (c.isSelected.value == true) {
          if (!name.contains(c.taxCode)) {
            name.add(c.taxCode.toString());
          }
        }
      }
    }
    if (name.length == 1) {
      return true;
    } else {
      return false;
    }
  }

  //入库
  store({
    required String date,
    required String store1,
    required Function(String)? success,
  }) {
    getSelectData();
    httpPost(
      method: webApiPurchaseOrderStockInForQuality,
      loading: 'quality_inspection_storing'.tr,
      body: [
        for (var item in selectList)
          {
            'InspectionLineItem': item.inspectionLineNumber,
            'Remarks': item.remarks,
            'InspectionOrderNo': item.inspectionOrderNo,
            'PurchaseOrderMeasureUnit': item.commonUnits,
            'PurchaseOrderQuantity': item.qualifiedQuantity,
            'PurchaseDocumentItemNumber': item.purchaseDocumentItemNumber,
            'PurchaseVoucherNo': item.purchaseVoucherNo,
            'PostingDate': date,
            'StorageLocation': store1,
            'EnglishName': '',
            'MaterialDocumentLineItemNumber': '',
            'MaterialDocumentNo': '',
            'MaterialVoucherYear': '',
            'Remarks': '',
            'ReversalMark': '',
          }
      ],
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success!
            .call(response.message ?? 'quality_inspection_storing_success'.tr);
      } else {
        errorDialog(
            content: response.message ?? 'quality_inspection_storing_fail'.tr);
      }
    });
  }

  //验证是否是同一个检验单
  checkSame({
    required Function success,
  }) {
    var selectNum = 0;

    for (var data in state.showDataList) {
      for (var c in data) {
        if (c.isSelected.value == true) {
          selectNum = selectNum + 1;
        }
      }
    }
    if (selectNum > 0) {
      if (checkSameData()) {
        success.call();
      } else {
        showSnackBar(message: 'quality_inspection_different_order'.tr);
      }
    } else {
      showSnackBar(message: 'quality_inspection_select_data'.tr);
    }
  }

  //获取品检单货位信息
  getLocation({
    required String store,
    required Function? success,
  }) {
    getSelectData();
    httpGet(
      method: webApiGetQualityInspection,
      loading: 'quality_inspection_quality_detail'.tr,
      params: {
        'inspectionOrderNo': selectList[0].inspectionOrderNo,
        'inspectionLineItem': selectList[0].inspectionLineNumber,
        'storageLocation': store,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.locationList.clear();
        state.locationList = [
          for (var json in response.data)
            StuffQualityInspectionDetailInfo.fromJson(json)
        ];
        if (state.locationList.isNotEmpty) {
          success!.call();
        }
      } else {
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //更改货位
  changeLocation({
    required String location,
    required Function? success,
  }) {
    httpPost(
      method: webApiGetQualityInspectionList,
      loading: 'quality_inspection_change_location'.tr,
      body: {
        'Reviser': getUserInfo()!.number,
        'DataList': [
          for (var list in state.locationList)
            {
              'InspectionOrderNo': list.inspectionOrderNo,
              'InspectionLineNumber':
                  list.stuffColorSeparationList?[0].inspectionLineNumber,
              'ColorSeparationSheetNumber':
                  list.stuffColorSeparationList?[0].colorSeparationSheetNumber,
              'ColorSeparationSingleLineNumber':
                  list.stuffColorSeparationList?[0].colorSeparationSingleLineNumber,
              'BatchNumber': list.stuffColorSeparationList?[0].batch,
              'Location': location,
              'MaterialCode': list.stuffColorSeparationList?[0].materialCode,
            }
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success!
            .call(response.message ?? 'quality_inspection_change_success'.tr);
      } else {
        errorDialog(
            content: response.message ?? 'quality_inspection_change_failed'.tr);
      }
    });
  }

  //获取分色信息
  getColor({required Function? success}) {
    getSelectData();
    httpGet(
      method: webApiGetQualityInspection,
      loading: 'quality_inspection_quality_detail'.tr,
      params: {
        'inspectionOrderNo': selectList[0].inspectionOrderNo,
        'inspectionLineItem': selectList[0].inspectionLineNumber,
        'storageLocation': '',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.locationList.clear();
        state.locationList = [
          for (var json in response.data)
            StuffQualityInspectionDetailInfo.fromJson(json)
        ];
        if (state.locationList.isNotEmpty) {
          var colors = <StuffColorSeparationList>[];
          var allQty = 0.0;
          colors.clear();
          for (var data in state.locationList) {
            data.stuffColorSeparationList?.forEach((sub) {
              allQty = allQty + sub.colorSeparationQuantity.toDoubleTry();
              colors.add(sub);
            });
          }

          colors.add(StuffColorSeparationList(
            batch: '合计',
            colorSeparationQuantity: allQty.toShowString(),
          ));

          state.colorList = colors;
          success!.call();
        }
      } else {
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //验证是否可以冲销
  checkReceipt({
    required Function success,
  }) {
    var selectNum = 0;

    for (var data in state.showDataList) {
      for (var c in data) {
        if (c.isSelected.value == true) {
          selectNum = selectNum + 1;
        }
      }
    }
    if (selectNum > 0) {
      if (checkSameData()) {
        success.call();
      } else {
        showSnackBar(message: 'quality_inspection_different_order'.tr);
      }
    } else {
      showSnackBar(message: 'quality_inspection_select_data'.tr);
    }
  }

  //是否含有多个物料凭证
  checkSameMater() {
    var name = <String>[];
    for (var data in state.showDataList) {
      for (var c in data) {
        if (c.isSelected.value == true) {
          if (!name.contains(c.materialDocumentNo)) {
            name.add(c.materialDocumentNo.toString());
          }
        }
      }
    }
    if (name.length == 1) {
      return true;
    } else {
      return false;
    }
  }

  //冲销获取色系信息
  receiptReversal({
    required Function? error,
  }) {
    getSelectData();
    sapPost(
      loading: 'quality_inspection_get_color'.tr,
      method: webApiForSapReceiptReversal,
      body: {
        'GT_REQITEMS': [
          for (var item in selectList)
            {
              'ZCHECKBNO': item.inspectionOrderNo,
            }
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.receiptList.value = [
          for (var json in response.data)
            QualityInspectionReceiptInfo.fromJson(json)
        ];
        if (state.receiptList.isNotEmpty) {
          arrangeColorData();
          Get.to(() => const QualityInspectionReverseColorPage())?.then((v) {
            if (v != null && v) {
              getInspectionList();
            }
          });
        }
      } else {
        error?.call();
      }
    });
  }

  //整理色系数据
  arrangeColorData() {
    getSelectData();
    var list = <QualityInspectionShowColor>[];
    list.clear();

    var name = <String>[];
    for (var c in selectList) {
      if (!name.contains(c.materialCode)) {
        name.add(c.materialCode.toString());
      }
    }

    for (var name in name) {
      for (var data in state.receiptList
          .where((receipt) => receipt.materialCode == name)) {
        data.item?.forEach((sub) {
          list.add(QualityInspectionShowColor(
            subItem: '1',
            name: data.materialDescription,
            code: data.materialCode,
            color: sub.batch,
            qty: sub.qty,
            allQty: 0.0,
          ));
        });

        list.add(QualityInspectionShowColor(
          subItem: '2',
          name: '',
          code: data.materialCode,
          color: '分色合计',
          qty: data.item?.map((v) => v.qty ?? 0.0).reduce((a, b) => a.add(b)) ??
              0.0,
          allQty:
              data.item?.map((v) => v.qty ?? 0.0).reduce((a, b) => a.add(b)) ??
                  0.0,
        ));

        list.add(QualityInspectionShowColor(
          subItem: '3',
          name: '',
          code: data.materialCode,
          color: '冲销合计',
          qty: selectList
              .where((select) => select.materialCode == name)
              .map((v) => v.storageQuantity.toDoubleTry())
              .reduce((a, b) => a.add(b)),
          allQty: 0.0,
        ));
      }
    }

    state.showReceiptColorList.value = list;
  }

  //选中分色数据
  selectColorSubItem(int position) {
    for (var sub in state.showReceiptColorList.where((v) => v.subItem == '1')) {
      sub.isSelected.value = false;
    }

    state.showReceiptColorList[position].isSelected.value = true;
    state.showReceiptColorList.refresh();
  }

  //是否选中数据
  bool havaColorSelect() {
    if (state.showReceiptColorList.none((v) => v.isSelected.value == true)) {
      showSnackBar(message: 'quality_inspection_color_select'.tr);
      return false;
    } else {
      state.showReceiptColorList.forEachIndexed((i, v) {
        if (v.isSelected.value == true) {
          selectIndex = i;
        }
      });
      return true;
    }
  }

  //新增
  colorAdd() {
    if (havaColorSelect()) {
      var position = 0;
      var selectCode = '';
      var selectName = '';

      state.showReceiptColorList.forEachIndexed((i, v) {
        if (v.isSelected.value == true) {
          position = i;
          selectCode = v.code!;
          selectCode = v.name!;
        }
      });

      var subAllQty = 0.0;
      var remainQty = 0.0;

      state.showReceiptColorList
          .where((v) => v.code == selectCode && v.subItem == '1')
          .forEach((v) {
        subAllQty = subAllQty + v.qty!;
      });

      state.showReceiptColorList
          .where((v) => v.code == selectCode && v.subItem == '2')
          .forEach((v) {
        remainQty = v.allQty! - subAllQty;
      });

      if (remainQty <= 0) {
        showSnackBar(message: 'quality_inspection_no_qty'.tr);
      } else {
        state.showReceiptColorList.insert(
            position + 1,
            QualityInspectionShowColor(
              subItem: '1',
              name: selectName,
              code: selectCode,
              color: '',
              qty: remainQty,
            ));
        state.showReceiptColorList.refresh();
      }
    }
  }

  //设置分色数量
  colorInputQty(double qty, int position, String code) {
    state.showReceiptColorList[position].qty = qty;
    state.showReceiptColorList.refresh();
    setShowColorAllQty(code);
  }

  //设置分色合计
  setShowColorAllQty(String selectCode) {
    var allQty = 0.0;

    if (state.showReceiptColorList
        .none((data) => data.code == selectCode && data.subItem == '1')) {
      allQty = 0.0;
      logger.f('没有');
    } else {
      allQty = state.showReceiptColorList
          .where((data) => data.code == selectCode && data.subItem == '1')
          .map((v) => v.qty ?? 0.0)
          .reduce((a, b) => a.add(b));
      logger.f('有');
    }

    for (var c in state.showReceiptColorList) {
      if (c.code == selectCode && c.subItem == '2') {
        c.qty = allQty;
      }
    }
  }

  //输入色系
  inputColor(String inputColor, int position) {
    state.showReceiptColorList[position].color = inputColor;
    state.showReceiptColorList.refresh();
  }

  //删除
  colorDelete() {
    var position = 0;
    var selectCode = '';

    state.showReceiptColorList.forEachIndexed((i, v) {
      if (v.isSelected.value == true) {
        position = i;
        selectCode = v.code!;
      }
    });

    if (havaColorSelect()) {
      state.showReceiptColorList.removeAt(position);
    }
    setShowColorAllQty(selectCode);
  }

  //验证是否可以提交
  bool checkSubmit() {
    var checkQty = 0;

    if (state.showReceiptColorList.isNotEmpty) {
      var name = <String>[];
      for (var c in state.showReceiptColorList) {
        if (!name.contains(c.code)) {
          name.add(c.code.toString());
        }
      }

      for (var s in name) {
        if ((state.showReceiptColorList
                .where((data) => data.code == s && data.subItem == '2')
                .toList()[0]
                .qty) !=
            (state.showReceiptColorList
                .where((data) => data.code == s && data.subItem == '3')
                .toList()[0]
                .qty)) {
          checkQty = checkQty + 1;
        }
      }
    }

    if (checkQty == 0) {
      return true;
    } else {
      showSnackBar(message: 'quality_inspection_color_no_same'.tr);
      return false;
    }
  }

  //提交
  colorSubmit({
    required String reason,
    required Function(String)? success,
  }) {
    getSelectData();
    httpPost(
      method: webApiPurchaseOrderStockInNew,
      loading: 'quality_inspection_eliminating'.tr,
      body: {
        'OffCGOrderInstock2SapList': [
          for (var item in selectList)
            for (var sub in item.materialVoucherItem!.split(',').toList())
              {
                'UserName': getUserInfo()!.number, //用户名
                'ChineseName': getUserInfo()!.name, //中文名
                'InspectionOrderNo': item.inspectionOrderNo, //检验单号
                'InspectionLineItem': item.inspectionLineNumber, //检验行项目
                'MaterialDocumentNo': item.materialDocumentNo, //物料凭证编码
                'MaterialVoucherYear': item.materialVoucherYear, //年度
                'MaterialDocumentLineItemNumber': sub, //物料行项目
                'ReversalMark': 'X',
                'PurchaseOrderQuantity': item.storageQuantity,
                'Remarks': reason,
              }
        ],
        'CGOrder': [
          for (var color in state.showReceiptColorList.where(
            (data) => data.subItem == '1',
          ))
            {
              'MaterialCode': color.code,
              'ZCOLOR': color.color,
              'Quantity': color.qty,
            }
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success!.call(
            response.message ?? 'quality_inspection_reversal_successful'.tr);
      } else {
        errorDialog(
            content:
                response.message ?? 'quality_inspection_reversal_failed'.tr);
      }
    });
  }

//验证是否可以品检
  checkChange({
    required Function success,
  }) {
    if (checkUserPermission('105180502')) {
      var selectNum = 0;

      for (var data in state.showDataList) {
        for (var c in data) {
          if (c.isSelected.value == true) {
            selectNum = selectNum + 1;
          }
        }
      }
      if (selectNum > 0) {
        if (checkSameData()) {
          success.call();
        } else {
          showSnackBar(message: 'quality_inspection_different_order'.tr);
        }
      } else {
        showSnackBar(message: 'quality_inspection_select_data'.tr);
      }
    } else {
      showSnackBar(message: 'quality_inspection_no_inspection'.tr);
    }
  }

  //整理品检数据
  arrangeChangeData() {
    getSelectData();

    Get.to(() => const StuffQualityInspectionPage(), arguments: {
      'inspectionType': '1',
      //品检单列表
      'dataList': jsonEncode(selectList.map((v) => v.toJson()).toList()),
      //品检单列表
    })?.then((v) {
      if (v == true) {
        getInspectionList();
      }
    });
  }
}
