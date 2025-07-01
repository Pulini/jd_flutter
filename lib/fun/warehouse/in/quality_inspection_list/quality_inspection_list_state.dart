import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/quality_inspection_receipt_info.dart';
import 'package:jd_flutter/bean/http/response/stuff_quality_inspection_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class QualityInspectionListState {
  var showDataList = <List<StuffQualityInspectionInfo>>[].obs;
  var showReceiptColorList = <QualityInspectionShowColor>[].obs; //分色展示信息

  var orderTypeList = <String, String>{
    'quality_inspection_not_in_stock'.tr: '04',
    'quality_inspection_in_stock'.tr: '03',
    'quality_inspection_delete'.tr: 'DEL',
    'quality_inspection_all_not_delete'.tr: '0',
    'quality_inspection_all_not_returned'.tr: '05',
  };
  var orderType = 0.obs;

  //获取品检单列表
  getInspectionList({
    required String typeBody,
    required String materialCode,
    required String instruction,
    required String inspectionOrder,
    required String temporaryReceipt,
    required String receiptVoucher,
    required String trackingNumber,
    required String startDate,
    required String endDate,
    required String supplier,
    required String sapCompany,
    required String factory,
    required Function(String) error,
  }) {
    httpPost(
      method: webApiGetInspectionList,
      loading: 'quality_inspection_list_quality_inspection'.tr,
      body: {
        'StartDate': startDate,
        'EndDate': endDate,
        'FactoryType': typeBody, //型体
        'InstructionNumber': inspectionOrder,
        'MaterialCode': materialCode,
        'SupplierNumber': supplier,
        'InspectionNo': inspectionOrder,
        'TemporaryNo': temporaryReceipt,
        'imvoucher': receiptVoucher,
        'Type': orderTypeList[orderTypeList.keys.toList()[orderType.value]],
        'ProducerNumber': userInfo?.number,
        'DeliveryAddress': sapCompany, //公司
        'Role': userInfo?.sapRole,
        'FactoryCode': factory, //工厂代码
        'TrackNo': trackingNumber, //跟踪号
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        showDataList.value = groupBy([
          for (var json in response.data)
            StuffQualityInspectionInfo.fromJson(json)
        ], (v) => v.getDataID()).values.toList();
      } else {
        showDataList.clear();
        error.call(response.message ?? 'process_dispatch_label_delete_fail'.tr);
      }
    });
  }

  deleteOrder({
    required String reason,
    required Function(String) success,
    required Function(String) error,
  }) {
    var selectList = [
      for (var data in showDataList)
        for (var c in data.where((v) => v.isSelected.value)) c
    ];
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
            'DeletedBy': userInfo?.number,
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
              'DeletedBy': userInfo?.number,
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
        success
            .call(response.message ?? 'quality_inspection_success_deleting'.tr);
      } else {
        error.call(response.message ?? 'quality_inspection_fail_deleting'.tr);
      }
    });
  }

  //入库
  store({
    required String date,
    required String store1,
    required Function(String) success,
    required Function(String) error,
  }) {
    var selectList = [
      for (var data in showDataList)
        for (var c in data.where((v) => v.isSelected.value)) c
    ];
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
            'ReversalMark': '',
          }
      ],
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success
            .call(response.message ?? 'quality_inspection_storing_success'.tr);
      } else {
        error.call(response.message ?? 'quality_inspection_storing_fail'.tr);
      }
    });
  }

  reversal({
    required Function(List<QualityInspectionReceiptInfo>) success,
    required Function() error,
  }) {
    var selectList = [
      for (var data in showDataList)
        for (var c in data.where((v) => v.isSelected.value)) c
    ];
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
        success.call([
          for (var json in response.data)
            QualityInspectionReceiptInfo.fromJson(json)
        ]);
      } else {
        error.call();
      }
    });
  }

  //提交
  colorSubmit({
    required String reason,
    required Function(String) success,
    required Function(String) error,
  }) {
    var selectList = [
      for (var data in showDataList)
        for (var c in data.where((v) => v.isSelected.value)) c
    ];
    httpPost(
      method: webApiPurchaseOrderStockInNew,
      loading: 'quality_inspection_eliminating'.tr,
      body: {
        'OffCGOrderInstock2SapList': [
          for (var item in selectList)
            for (var sub in item.materialVoucherItem!.split(',').toList())
              {
                'UserName': userInfo?.number, //用户名
                'ChineseName': userInfo?.name, //中文名
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
        'CGOrderInstockCosep2SapList': [
          for (var color
              in showReceiptColorList.where((data) => data.subItem == '1'))
            {
              'MaterialCode': color.code,
              'ZCOLOR': color.color,
              'Quantity': color.qty,
            }
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(
            response.message ?? 'quality_inspection_reversal_successful'.tr);
      } else {
        error.call(response.message ?? 'quality_inspection_reversal_failed'.tr);
      }
    });
  }

  //获取品检单货位信息
  getLocation({
    String? store,
    required Function(List<StuffQualityInspectionDetailInfo>) success,
    required Function(String) error,
  }) {
    var selectList = [
      for (var data in showDataList)
        for (var c in data.where((v) => v.isSelected.value)) c
    ];
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
        success.call([
          for (var json in response.data)
            StuffQualityInspectionDetailInfo.fromJson(json)
        ]);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //更改货位
  changeLocation({
    required String location,
    required List<StuffQualityInspectionDetailInfo> locationList,
    required Function(String) success,
    required Function(String) error,
  }) {
    httpPost(
      method: webApiGetQualityInspectionList,
      loading: 'quality_inspection_change_location'.tr,
      body: {
        'Reviser': userInfo?.number,
        'DataList': [
          for (var list in locationList)
            {
              'InspectionOrderNo': list.inspectionOrderNo,
              'InspectionLineNumber':
                  list.stuffColorSeparationList?[0].inspectionLineNumber,
              'ColorSeparationSheetNumber':
                  list.stuffColorSeparationList?[0].colorSeparationSheetNumber,
              'ColorSeparationSingleLineNumber': list
                  .stuffColorSeparationList?[0].colorSeparationSingleLineNumber,
              'BatchNumber': list.stuffColorSeparationList?[0].batch,
              'Location': location,
              'MaterialCode': list.stuffColorSeparationList?[0].materialCode,
            }
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success
            .call(response.message ?? 'quality_inspection_change_success'.tr);
      } else {
        error.call(response.message ?? 'quality_inspection_change_failed'.tr);
      }
    });
  }

  getOrderColorLabelInfo({
    required List<StuffQualityInspectionInfo> selectList,
    required Function() success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在获取分色及标签信息...',
      method: webApiGetQualityInspectionColorLabelInfo,
      body: {
        'GT_REQITEMS': [
          for (var item in selectList.where((v)=>v.colorDistinguishEnable==true))
            {
              'ZDELINO': item.inspectionOrderNo,
            }
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        // success.call([
        //   for (var json in response.data)
        //     QualityInspectionReceiptInfo.fromJson(json)
        // ]);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
