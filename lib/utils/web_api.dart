import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/app_init_service.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import 'utils.dart';

//接口返回异常
const resultError = 0;

//接口返回成功
const resultSuccess = 1;

//重新登录
const resultReLogin = 2;

//版本升级
const resultToUpdate = 3;

//MES正式库
const baseUrlForMES = 'https://geapp.goldemperor.com:1226/';

//MES测试库
const testUrlForMES = 'https://geapptest.goldemperor.com:1224/';

//SAP正式库
const baseUrlForSAP = 'https://erpprd01.goldemperor.com:8003/';

//SAP测试库
const testUrlForSAP = 'https://erpqas01.goldemperor.com:8002/';

//SAP开发库
const developUrlForSAP = 'https://erpdev01.goldemperor.com:8001/';

//SAP正式库
const baseClientForSAP = 800;

//SAP开发库
const developClientForSAP = 300;

// 日志工具
var logger = Logger();

//当前语言
var language = 'zh';

//post请求
Future<BaseData> httpPost({
  String? loading,
  required String method,
  Map<String, dynamic>? params,
  Object? body,
}) {
  return _doHttp(
    loading: loading,
    params: params,
    body: body,
    baseUrl: baseUrlForMES,
    isPost: true,
    method: method,
  );
}

//get请求
Future<BaseData> httpGet({
  String? loading,
  required String method,
  Map<String, dynamic>? params,
  Object? body,
}) {
  return _doHttp(
    loading: loading,
    params: params,
    body: body,
    baseUrl: baseUrlForMES,
    isPost: false,
    method: method,
  );
}

//post请求
Future<BaseData> sapPost({
  String? loading,
  required String method,
  Map<String, dynamic>? params,
  Object? body,
}) {
  return _doHttp(
    loading: loading,
    params: {...?params},
    body: body,
    baseUrl: baseUrlForSAP,
    isPost: true,
    method: method,
  );
}

//get请求
Future<BaseData> sapGet({
  String? loading,
  required String method,
  Map<String, dynamic>? params,
  Object? body,
}) {
  return _doHttp(
    loading: loading,
    params: {...?params},
    body: body,
    baseUrl: baseUrlForSAP,
    isPost: false,
    method: method,
  );
}

//初始化网络请求
Future<BaseData> _doHttp({
  required bool isPost,
  required String method,
  required String baseUrl,
  String? loading,
  Map<String, dynamic>? params,
  Object? body,
}) async {
  if (isTestUrl()) {
    if (baseUrl == baseUrlForMES) {
      baseUrl = testUrlForMES;
    } else if (baseUrl == baseUrlForSAP) {
      baseUrl = developUrlForSAP;
    }
  }
  if (baseUrl == baseUrlForSAP || baseUrl == developUrlForSAP) {
    params = {
      'sap-client':
          baseUrl == baseUrlForSAP ? baseClientForSAP : developClientForSAP,
      ...?params,
    };
  }

  try {
    debugPrint('SnackbarStatus=$snackbarStatus');
    if (Get.isSnackbarOpen) {
      snackbarController?.close(withAnimations: false);
    }
  } catch (e) {
    debugPrint('销毁snackbar异常');
  }

  if (loading != null && loading.isNotEmpty) {
    loadingShow(loading);
  }

  //根据路由获取当前所在的功能
  var nowFunction = getNowFunction();

  //设置请求的headers
  var options = Options(headers: {
    'Content-Type': 'application/json',
    'FunctionID': nowFunction?.id ?? '0',
    'Version': nowFunction?.version ?? 0,
    'Language': language,
    'Token': userInfo?.token ?? '',
    'GUID': const Uuid().v1(),
  });

  //创建返回数据载体
  var base = BaseData()..resultCode = resultError;

  try {
    //创建dio对象
    var dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(minutes: 2),
      sendTimeout: const Duration(minutes: 2),
      receiveTimeout: const Duration(minutes: 2),
    ));

    //接口拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.print();
          handler.next(options);
        },
        onResponse: (response, handler) {
          var baseData = BaseData.fromJson(
            response.data.runtimeType == String
                ? jsonDecode(response.data)
                : response.data,
          )..print(
              '${response.realUri.origin}/$method',
              response.realUri.queryParameters,
            );
          if (baseData.resultCode == 2) {
            logger.e('需要重新登录');
            spSave(spSaveUserInfo, '');
            if (loading != null && loading.isNotEmpty) loadingDismiss();
            // handler.next(response);
            reLoginPopup();
          } else if (baseData.resultCode == 3) {
            logger.e('需要更新版本');
            if (loading != null && loading.isNotEmpty) loadingDismiss();
            upData();
          } else {
            handler.next(response);
          }
        },
        onError: (DioException e, handler) {
          logger.e('error:$e');
          handler.next(e);
        },
      ),
    );

    //发起post/get请求
    var response = isPost
        ? await dio.post(
            method,
            queryParameters: params,
            data: body,
            options: options,
          )
        : await dio.get(
            method,
            queryParameters: params,
            data: body,
            options: options,
          );
    if (response.statusCode == 200) {
      var json = response.data.runtimeType == String
          ? jsonDecode(response.data)
          : response.data;
      base.resultCode = json['ResultCode'];
      base.data = json['Data'];
      base.message = json['Message'];
    } else {
      if (loading != null && loading.isNotEmpty) Get.back();
      logger.e('网络异常');
      base.message = '网络异常';
    }
  } on DioException catch (e) {
    logger.e('error:${e.toString()}');
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        base.message = '连接服务器超时';
        break;
      case DioExceptionType.sendTimeout:
        base.message = '发送数据超时';
        break;
      case DioExceptionType.receiveTimeout:
        base.message = '接收数据超时';
        break;
      case DioExceptionType.badResponse:
        base.message = '请求配置错误';
        break;
      case DioExceptionType.cancel:
        base.message = '取消请求';
        break;
      case DioExceptionType.connectionError:
        base.message = '连接服务器异常';
        break;
      case DioExceptionType.badCertificate:
        base.message = '服务器证书错误';
        break;
      case DioExceptionType.unknown:
        base.message = '未知异常';
        break;
    }
  } on Exception catch (e) {
    logger.e('error:${e.toString()}');
    base.message = '发生错误：${e.toString()}';
  } on Error catch (e) {
    logger.e('error:${e.toString()}');
    base.message = '发生异常：${e.toString()}';
  } finally {
    if (loading != null && loading.isNotEmpty) loadingDismiss();
    base.baseUrl = baseUrl;
  }
  return base;
}

//网络测试接口
const webApiLNetTest = 'api/Public/NetTest';

//登录接口
const webApiLogin = 'api/User/Login';

//获取用户头像
const webApiGetUserPhoto = 'api/User/GetEmpPhotoByPhone';

//获取验证码接口
const webApiVerificationCode = 'api/User/SendVerificationCode';

//获取主页入口列表
const webApiGetMenuFunction = 'api/AppMenuFunction/GetAppMenuFunction';

//修改头像接口
const webApiChangeUserAvatar = 'api/User/UploadEmpPicture';

//修改密码接口
const webApiChangePassword = 'api/User/ChangePassWord';

//修改部门组别接口
const webApiChangeDepartment = 'api/User/GetLoginInfo';

//检查版本更新接口
const webApiCheckVersion = 'api/Public/FlutterVersionUpgrade';

//获取sap供应商列表接口
const webApiPickerSapSupplier = 'api/Supplier/GetSAPSupplierMessageNew';

//获取sap公司列表接口
const webApiPickerSapCompany = 'api/Department/GetSAPFactoryArea';

//获取sap厂区列表接口
const webApiPickerSapFactory = 'api/Department/GetSAPFactoryInfo';

//获取sap工作中心列表接口
const webApiPickerSapWorkCenter = 'api/Department/GetSAPWorkCenter';

//获取sap部门列表接口
const webApiPickerSapDepartment = 'api/Department/GetSAPDeptInfo';

//获取mes部门列表接口
const webApiPickerMesDepartment = 'api/Department/GetDeptInfoByOrganizeID';

//获取mes车间列表接口
const webApiPickerMesWorkShop = 'api/Department/GetMESWorkShop';

//获取mes组织列表接口
const webApiPickerMesOrganization = 'api/User/GetOrganization';

//获取sap制程列表接口
const webApiPickerSapProcessFlow = 'api/ProcessFlow/GetSAPProcessFlow';

//获取mes制程列表接口
const webApiPickerMesProcessFlow = 'api/ProcessFlow/GetProcessFlowInfo';

//获取sap机台列表接口
const webApiPickerSapMachine = 'api/CompoundDispatching/GetDrillingCrewList';

//获取sap新工作中心列表接口
const webApiPickerSapWorkCenterNew = 'api/Department/GetSAP_WorkCenterNew';

//获取sap组别列表接口
const webApiPickerSapGroup = 'api/User/GetDepListByEmpID';

//获取sap工厂及仓库列表接口
const webApiPickerSapFactoryAndWarehouse = 'api/Stock/GetSAPFactoryStockInfo';

//获取MES仓库列表
const webApiPickerMesStockList = 'api/Stock/GetStockList';

//获取MES仓库列表
const webApiPickerOrderStockList = 'api/Stock/GetBillStockList';

//获取送货单绑定件号信息汇总
const webApiSapGetDestination = 'sap/zapp/ZFUN_PDA_ZGD';

//获取sap仓库库位列表接口
const webApiPickerSapWarehouseStorageLocation =
    'api/InStockTrackingNum/GetWarehouseStorageLocationList';

//获取mes组别
const webApiPickerMesGroup = 'api/Autoworkshopbatch/GetClassList';

//获取mes包装区域列表
const webApiGetPickerMesMoldingPackArea = 'api/BaseInfo/GetMoldingPackAreaInfo';

//获取扫码日产量接口
const webApiGetDayOutput = 'api/Piecework/GetDayOutput';

//获取实时产量汇总表接口
const webApiGetPrdShopDayReport = 'api/ProductionReport/GetPrdShopDayReport';

//获取生产日报表
const webApiGetPrdDayReport = 'api/ProductionReport/GetPrdDayReport';

//提交生产日报表未达标原因
const webApiSubmitDayReportReason = 'api/WorkCard/Submit2PrdDayReportNote';

//获取车间生产日报表汇总数据
const webApiGetWorkshopProductionDailySummary =
    'api/ProductionReport/GetEarlyWarningInfoReportOne';

//获取车间生产日报表明细数据
const webApiGetWorkshopProductionDailyDetail =
    'api/ProductionReport/GetEarlyWarningInfoReportTwo';

//根据指令号和制程查询指令pdf在线文档
const webApiGetInstructionDetailsFile = 'api/Package/GetPreviewFileByMoNo';

//获取员工计件产量报表
const webApiGetWorkerProductionReport =
    'api/Piecework/GetDayWorkDataByDepartmentID';

//获取员工计件明细报表类型
const webApiGetProductionReportType = 'api/WorkCard/GetProcessOutputReport';

//获取员工计件明细报表
const webApiProductionReport = 'api/WorkCard/GetProcessOutputReportDetail';

//获取指定型体的工艺说明书列表
const webApiGetProcessSpecificationList =
    'api/NeedleCartDispatch/GetManufactureInstructionsByProduct';

//添加制造说明书查看日志
const webApiInstructionsLog =
    'api/NeedleCartDispatch/InsertManufactureInstructionsLog';

//检查设备是否授权查看PDF
const webApiCheckAuthorize = 'api/User/CheckAuthorize';

//申请授权
const webApiAuthorizedApplication = 'api/User/AuthorizedApplication';

//获取包装区报表
const webApiGetMoldingPackAreaReport = 'api/Package/GetMoldingPackAreaReport';

//获取包装区报表明细
const webApiGetMoldingPackAreaReportDetail =
    'api/Package/GetMoldingPackAreaPODetail';

//获取成型后段扫码看板
const webApiGetMoldingScanBulletinReport = 'api/Package/GetProductionOrderST';

//提交成型后段扫码工单排序
const webApiSubmitNewSort = 'api/Package/SubmitWorkCardPriority';

//根据时间和部门信息获得生产派工单列表信息
const webApiGetWorkCardCombinedSizeList =
    'api/WorkCard/GetWorkCardCombinedSizeList';

//生产派工单下推
const webApiPushProductionOrder =
    'api/NeedleCartDispatch/GetProcessWorkCardForWorkCard';

//生产派工单批量下推
const webApiBatchPushProductionOrder =
    'api/NeedleCartDispatch/GetProcessWorkCardForWorkCardBatch';

//根据组别获取本组组员信息
const webApiGetWorkerInfo = 'api/User/GetEmpByFNumber';

//查询财产审核列表
const webApiQueryProperty = 'api/FixedAsset/SearchUnnumberedProperty';

//获取财产明细
const webApiGetPropertyDetail = 'api/FixedAsset/GetAssetsByFInterID';

//财产审核关闭
const webApiPropertyClose = 'api/FixedAsset/AssetsRegistrationClose';

//跳过财产验收
const webApiSkipAcceptance = 'api/FixedAsset/CloseAssets';

//更新财产信息
const webApiUpdateProperty = 'api/FixedAsset/UpdateAssets';

//人员来访记录列表
const webApiGetVisitDtBySqlWhere =
    'api/VisitorRegistration/GetVisitDtBySqlWhere';

//获取来访编号
const webApiGetInviteCode = 'api/VisitorRegistration/GetInviteCode';

//获取工艺指导书列表
const webApiGetManufactureInstructions =
    'api/NeedleCartDispatch/GetManufactureInstructions';

//获取用料清单
const webApiGetWorkPlanMaterial = 'api/NeedleCartDispatch/GetWorkPlanMaterial';

//获取工艺路线
const webApiGetPrdRouteInfo = 'api/NeedleCartDispatch/GetPrdRouteInfo';

//获取批量工艺路线
const webApiGetBatchPrdRouteInfo =
    'api/NeedleCartDispatch/GetPrdRouteInfoNewBatch';

//发送微信校对信息给派工员工
const webApiSendDispatchToWechat = 'api/NeedleCartDispatch/WechatPostByFEmpID';

//工序计工
const webApiProductionDispatch = 'api/NeedleCartDispatch/ProcessCalculation';

//查询生产派工单生产进度表
const webApiGetWorkCardDetailList = 'api/WorkCard/GetWorkCardDetailList';

//获取派工单派工数、完工数信息
const webApiGetIntactProductionDispatch =
    'api/WorkCard/GetSubmitScWorkCard2ProcessOutputReport';

//获取生产用料表
const webApiGetSapMoPickList = 'api/Material/GetSapMoPickList';

//获取指令表
const webApiGetProductionOrderPDF = 'api/Package/GetProductionOrderPDF';

//获取配色单列表
const webApiGetMatchColors = 'api/Inspection/GetMatchColors';

//获取配色单pdf
const webApiGetMatchColorsPDF = 'api/Inspection/GetMatchColorsPDF';

//修改派工单开关状态
const webApiChangeWorkCardStatus =
    'api/NeedleCartDispatch/SetWorkCardCloseStatus';

//删除派工单下游工序
const webApiDeleteScProcessWorkCard =
    'api/NeedleCartDispatch/DeleteScProcessWorkCard';

//删除派工单上次报工
const webApiDeleteLastReport =
    'api/NeedleCartDispatch/DeleteLastProcessWorkCardAndProcessOutPut';

//更新sap配套数
const webApiUpdateSAPPickingSupportingQty =
    'api/CompoundDispatching/UpdateSAPPickingSupportingQty';

//更新sap配套数
const webApiReportSAPByWorkCardInterID =
    'api/CompoundDispatching/ReportSAPByWorkCardInterID';

//获取贴标列表
const webApiGetLabelList = 'api/CompoundDispatching/PackagePrintLabelList';

//创建单码贴标
const webApiCreateSingleLabel =
    'api/CompoundDispatching/GeneratePackingListByWorkCardInterID';

//获取可创建标签数据
const webApiGetPackingListBarCodeCount =
    'api/CompoundDispatching/GetPackingListBarCodeCount';

//获取可创建标签数据
const webApiGetPackingListBarCodeCountBySize =
    'api/CompoundDispatching/GetPackingListBarCodeCountBySize';

//创建混码贴标
const webApiCreateMixLabel =
    'api/CompoundDispatching/GeneratePackingListBarCodeBySizedMultiple';

//创建自定义贴标
const webApiCreateCustomLargeLabel =
    'api/CompoundDispatching/GeneratePackingListLargeBarCode';

//创建自定义贴标
const webApiCreateCustomSizeLabel =
    'api/CompoundDispatching/GeneratePackingListBarCodeBySize';

//删除包装清单所有标签
const webApiCleanLabel = 'api/CompoundDispatching/DelPackingListBarcode';

//删除标签
const webApiDeleteLabels = 'api/CompoundDispatching/DelBarcode';

//获取物料属性
const webApiGetMaterialProperties =
    'api/CompoundDispatching/GetMaterialProperties';

//修改物料属性配置
const webApiSetMaterialProperties =
    'api/CompoundDispatching/SubmitMaterialProperties';

//获取物料箱容信息
const webApiGetMaterialCapacity =
    'api/CompoundDispatching/GetBodySizeBoxCapacity';

//修改物料箱容配置
const webApiSetMaterialCapacity =
    'api/CompoundDispatching/SubmitBodySizeBoxCapacity';

//获取物料语言信息信息
const webApiGetMaterialLanguages =
    'api/CompoundDispatching/GetMaterialMultilingual';

//修改物料语言信息信息
const webApiSetMaterialLanguages =
    'api/CompoundDispatching/SubmitMaterialMultilingual';

//获取生产派工单
const webApiGetWorkCardOrderList =
    'api/WorkCard/GetWorkCardCombinedSizeListByScan';

//获取生产派工单部件信息
const webApiGetPartList = 'api/WetPrinting/GetWorkCardParts';

//获取生产派工单部件信息明细
const webApiGetPartDetail = 'api/WetPrinting/GetWorkCardPartDetails';

//创建部件贴标
const webApiCreatePartLabel = 'api/WetPrinting/CreatePartLabelingBarcode';

//删除部件贴标
const webApiDeletePartLabel = 'api/WetPrinting/DelBarcode';

//获取贴标工序汇总表_已报工
const webApiGetPartProcessReportedReport =
    'api/WetPrinting/GetPartProcessReport_Barcode_Reported';

//获取工序派工单列表
const webApiGetScWorkCardProcess =
    'api/CompoundDispatching/GetScWorkCardProcessListStripDrawing';

//获取SPA仓库托盘列表
const webApiGetPallet = 'api/InStockTrackingNum/GetPallet';

//抽条末道工序生成工序汇报单
const webApiCreateLastProcessReport =
    'api/CompoundDispatching/CreateProcessOutPutByDepIDStripDrawing';

//取件码-批量生产入库
const webApiPickCodeBatchProductionWarehousing =
    'api/CompoundDispatching/PickCodeBatchProductionWarehousing';

//抽条获取用料清单
const webApiGetSubItemBatchMaterialInformation =
    'api/CompoundDispatching/GetSubItemBatchMaterialInformation';

//抽条用料清单数量矫正
const webApiMetersConvert = 'api/CompoundDispatching/MetersConvert';

//抽条获取贴标列表
const webApiGetQRCodeList = 'api/BarCode/GetQRCodeList';

//抽条车间贴标打印记工
const webApiCreateProcessOutPutStripDrawing =
    'api/CompoundDispatching/CreateProcessOutPutStripDrawing';

//批量取消报工
const webApiProcessOutPutReport =
    'api/CompoundDispatching/ProcessOutPutReport1';

//取件码-生产入库
const webApiPickCodeProductionWarehousing =
    'api/CompoundDispatching/PickCodeProductionWarehousing';

//获取工序派工单列表
const webApiGetWorkCardList =
    'api/CompoundDispatching/GetScWorkCardListJinZhen';

//获取时段内工序派工单列表
const webApiGetWorkCardListByDate =
    'api/CompoundDispatching/GetScWorkCardListByDateJinZhen';

//获取工序派工单详情
const webApiGetWorkCardDetail =
    'api/CompoundDispatching/GetScWorkCardDetailJinZhen';

//获取已入库的贴标列表
const webApiSapGetMaterialDispatchLabelList = 'sap/zapp/ZFUN_APP_BARCODE_FETCH';

//机台派工单--贴标维护
const webApiSapMaterialDispatchLabelMaintain =
    'sap/zapp/ZFUN_APP_BARCODE_MAINTAIN';

//机台派工单--获取英文贴标
const webApiSapGetMaterialDispatchEnglishLabel =
    'sap/zapp/ZFUN_APP_BARCODE_MEAS';

//机台派工单--更新料头标信息
const webApiUpdateSurplusMaterialLabelState =
    'api/CompoundDispatching/UpdateScWorkCardStubBarPrintFlagJinZhen';

//验证码发送接口
const webApiSendManagerCode = 'api/Public/SendManagerCode';

//验证人员
const webApiCheckManagerByCode = 'api/Public/CheckManagerByCode';

//上班尾数标识状态修改_金臻
const webApiCleanOrRecoveryLastQty =
    'api/CompoundDispatching/UpdateLastScWorkCardMantissaFlagJinZhen';

//修改派工表_金臻
const webApiModifyWorkCardItem =
    'api/CompoundDispatching/UpdateScWorkCardJinZhen';

//取消工号确认
const webApiCancelConfirmation = 'api/CompoundDispatching/ClearEmpJinZhen';

//生成报工产量表_金臻
const webApiReportDispatch =
    'api/CompoundDispatching/SubmitScWorkCardReportJinZhen';

//最近一次来访记录
const webApiGetVisitInfoByJsonStr =
    'api/VisitorRegistration/GetVisitInfoByJsonStr';

//来访详情
const webApiGetVisitorInfo = 'api/VisitorRegistration/GetVisitorInfo';

//离场更新
const webApiUpdateLeaveFVisit = 'api/VisitorRegistration/UpdateLeaveFVisit';

//离场新增
const webApiInsertIntoFVisit = 'api/VisitorRegistration/InsertIntoFVisit';

//根据部门ID或员工工号获得员工信息
const webApiGetEmpByField = 'api/VisitorRegistration/GetEmpByField';

//获取会客地点
const webApiGetReceiveVisitorPlace =
    'api/VisitorRegistration/GetReceiveVisitorPlace';

//成型集装箱出货扫码汇总
const webApiSapContainerScanner = 'sap/zapp/ZMM_ZXCFSM_SUMM';

//根据条件获取成型集装箱出货信息
const webApiSapContainerShipmentScanner = 'sap/zapp/ZMM_ZXCFSM_D';

//贴标工序报工_修改已报工
const webApiProductionDispatchReportSubmit =
    'api/WetPrinting/BarCodeProcessReportSubmit_Reported';

//获取工序派工单信息
const webApiGetProcessWorkCard = 'api/WetPrinting/GetProcessWorkCardByBarcode';

//获取报工信息
const webApiGetReportDataByBarcode = 'api/WetPrinting/GetReportDataByBarcode';

//修改操作员
const webApiChangeLabelingBarcodeEmp =
    'api/WetPrinting/ChangeLabelingBarcodeEmp';

//删除标签
const webApiUnReportAndDelLabelingBarcode =
    'api/WetPrinting/UnReportAndDelLabelingBarcode';

//智能AGV派送获取工单列表
const webApiSmartDeliveryGetWorkCardList =
    'api/Autoworkshopbatch/GetWorkCardList';

//发料明细(材料清单)
const webApiSmartDeliveryGetWorkCardMaterial =
    'api/Autoworkshopbatch/GetWorkCardMaterial';

//获取楦头库存
const webApiSmartDeliveryGetShorTreeList = 'api/Autoworkshopbatch/GetBalance';

//保存楦头库存
const webApiSmartDeliverySaveShorTree = 'api/Autoworkshopbatch/BalanceEdit';

//具体部件物料发料详情
const webApiSmartDeliveryDetail = 'api/Autoworkshopbatch/GetPartsOrder';

//新增发料数据
const webApiSmartDeliveryAddPartsStock = 'api/Autoworkshopbatch/AddPartsStock';

//删除发料数据
const webApiSmartDeliveryDeletePartsStock =
    'api/Autoworkshopbatch/DeletePartsStock';

//修改发料状态为备料
const webApiSmartDeliveryEditSendType = 'api/Autoworkshopbatch/EditSendType';

//发料数据创建机器人任务
const webApiSmartDeliveryCreatRobTask = 'api/Autoworkshopbatch/CreatRobTask';

//获取机器人信息
const webApiSmartDeliveryGetRobInfo = 'api/Autoworkshopbatch/GetRobInfo';

//机器人任务记录
const webApiSmartDeliveryGetRobTask = 'api/Autoworkshopbatch/GetRobTask';

//机器人任务取消
const webApiSmartDeliveryCancelTask = 'api/Autoworkshopbatch/CancelTask';

//暂停机器人
const webApiSmartDeliveryStopRobot = 'api/Autoworkshopbatch/StopRobot';

//恢复机器人
const webApiSmartDeliveryResumeRobot = 'api/Autoworkshopbatch/ResumeRobot';

//外箱内盒条码关联数据
const webApiGetCartonLabelInfo = 'api/OutBoxScan/GetLinkData';

//外箱鞋盒贴标数据提交
const webApiSubmitScannedCartonLabel = 'api/OutBoxScan/SubOutBoxData';

//外箱鞋盒更改优先级
const webApiChangePOPriority = 'api/OutBoxScan/ChangePOPriority';

//订单扫码情况表查询
const webApiGetCartonLabelScanHistory = 'api/OutBoxScan/GetOrderScan';

//订单扫码情况明细表
const webApiGetCartonLabelScanHistoryDetail =
    'api/OutBoxScan/GetOrderScanDetail';

//获取品质异常详情
const webApiGetSCDispatchOrders = 'api/QMProcessFlowEx/GetSCDispatchOrders';

//获取品质异常类型
const webApiGetProcessFlowEXTypes = 'api/QMProcessFlowEx/GetProcessFlowEXTypes';

//品质异常插入
const webApiAddAbnormalQuality = 'api/QMProcessFlowEx/QMAbnormityBysuitID';

//sap送货单列表
const webApiSapGetDeliveryList = 'sap/zapp/ZFUN_APP_GET_DELI_1500';

//sap获取客户订单包材信息
const webApiSapGetPackMaterialInfo = 'sap/zapp/ZFUNSD_PMAT_GET';

//sap送货单明细
const webApiSapGetDeliveryDetail = 'sap/zapp/ZFUN_APP_GET_DELIDETAIL_1500';

//sap检查暂收单是否已生成
const webApiSapCheckTemporaryOrder = 'sap/zapp/ZFUN_APP_TEMPORARYDEYAIL_1500A';

//根据工厂编号获取存储位置列表
const webApiGetStorageLocationList = 'api/Department/GetStorageLocationList';

//sap送货单保存核查
const webApiSapSaveDeliveryCheck = 'sap/zapp/ZFUN_APP_RECEIVE_1500';

//获取仓库是否启用了人脸识别
const webApiGetStockFaceConfig = 'api/User/Flutter_GetLiableInfoByEmpCode';

//sap送货单入库
const webApiSapDeliveryOrderStockIn = 'sap/zapp/ZFUN_RES_ZCLCGRUKU_1500';

//sap创建暂收单
const webApiSapCreateTemporary = 'sap/zapp/ZFUN_APP_TEMPORARYDEYAIL_1500';

//sap获取领料工单列表
const webApiSapGetPickingOrders = 'sap/zapp/ZFUN_GET_ZDLL_PO_HEAD_1500';

//sap获取领料明细
const webApiSapGetPickingOrderDetail = 'sap/zapp/ZFUN_GET_ZDLL_PO_ITEM_1500';

//sap领料过账
const webApiSapMaterialsPicking = 'sap/zapp/ZFUN_RES_ZLINGYONG_1500';

//根据物料编码获取条码
const webApiGetProductionPickingBarCodeList =
    'api/CompoundDispatching/GetBarcodeByMaterialNumberJinZhen';

//材料出库——金臻拌料
const webApiMixBarCodePicking =
    'api/CompoundDispatching/MaterialOutStockJinZhen';

//sap喷漆领料过账
const webApiSapPrintPicking = 'sap/zapp/ZFUN_RES_ZLINGYONG_1500A';

//sap待上架列表
const webApiSapGetPalletList = 'sap/zapp/ZWMS_STOCK_FETCH';

//sap上架移库
const webApiSapPuttingOnShelves = 'sap/zapp/ZWMS_INTERFACE';

//sap获取托盘明细
const webApiSapGetPalletDetails = 'sap/zapp/ZWMS_BARCODE_LIST';

//sap移库领料
const webApiSapRelocationPicking = 'sap/zapp/ZWMS_BARCODE_YK';

//sap获取入库派工单列表
const webApiSapGetNoLabelStockInOrderList = 'sap/zapp/ZFUN_APP_PO_LIST_1500';

//sap无标入库单提交入库
const webApiSapSubmitNoLabelStockIn = 'sap/zapp/ZFUN_APP_PO_POST_1500';

//sap获取贴标汇总状态
const webApiSapGetStockInReport = 'sap/zapp/ZFUN_APP_PO_LIST_1500A';

//sap注塑入库单提交入库
const webApiSapInjectionMoldingStockIn = 'sap/zapp/ZFUN_APP_PO_POST_1500A';

//删除品质异常
const webApiDelExBill = 'api/QMProcessFlowEx/DelExBill';

//扫码添加成型集装箱出货
const webApiSapScanAdd = 'sap/zapp/ZMM_RES_ZXCFSM_D';

//获取汇总表
const webApiNewGetSubmitBarCodeReport =
    'api/ScanJobBooking/NewGetSubmitBarCodeReport';

//sap料头入库历史记录
const webApiSapSurplusMaterialHistory = 'sap/zapp/ZFUN_GET_LTRUKU';

//sap料头入库
const webApiSapPostingSurplusMaterial = 'sap/zapp/ZFUN_RES_LTRUKU';

//mes根据编码获取物料信息
const webApiMesGetMaterialInfo = 'api/Piecework/GetMaterialByCode';

//sap获取客户订单信息
const webApiSapGetOrderInfoFromCode = 'sap/zapp/ZMM_ZCXSMRK_ZCTN';

//sap获取待出货列表
const webApiSapGetSalesShipmentList = 'sap/zapp/ZFUN_RES_ZXSOUT_LIST_1500';

//sap销售出库过账
const webApiSapPostingSalesShipment = 'sap/zapp/ZFUN_RES_ZXSOUT_JINC_1500';

//sap生产领料、收货列表
const webApiSapProductionReceipt = 'sap/zapp/ZFUN_APP_PO_CANCEL_1500';

//sap生产领料、收货列表 冲销
const webApiSapProductionReceiptWriteOff = 'sap/zapp/ZFUN_APP_PO_CANCEL_1500A';

//sap获取推荐库位
const webApiSapGetRecommendLocation = 'sap/zapp/ZWMS_LOCATION_RECOMMEND';

//sap获取贴标列表
const webApiSapGetLabels = 'sap/zapp/ZFUN_APP_BARCODE_PRINT';

//sap根据原标获取新标
const webApiSapGetNewLabel = 'sap/zapp/ZWMS_BARCODE_SPLIT';

//提交条形码数据,自动生成调拨单
const webApiUploadWarehouseAllocation =
    'api/BarCode/SubmitBarCode2CkRequisitionSlipCollectBillNew';

//获取设备信息
const webApiGetWaterEnergyMachine = 'api/SsDormitory/GetWaterEnergyMachine';

//获取抄度数据
const webApiGetWaterEnergyMachineDetail =
    'api/SsDormitory/GetWaterEnergyMachineDetail';

//提交水电表抄度
const webApiSubmitSsWaterEnergyMachineDetail =
    'api/SsDormitory/SubmitSsWaterEnergyMachineDetail';

//根据设备编号获取设备信息
const webApiGetDeviceInformationByFNumber =
    'api/EquipmentRepair/GetDeviceInformationByFNumber';

//获取设备维修单列表
const webApiGetRepairOrderList = 'api/EquipmentRepair/GetRepairOrderList';

//设备维修记录单作废
const webApiRepairOrderVoid = 'api/EquipmentRepair/RepairOrderVoid';

//通过保管人工号获取保管人，监管人信息以及保管人部门
const webApiGetEmpAndLiableByEmpCode = 'api/User/GetEmpAndLiableByEmpCode';

//获取设备维修记录单故障原因列表
const webApiGetIssueCauseType = 'api/EquipmentRepair/GetIssueCauseType';

//设备报修提交数据
const webApiSubmitRecordData = 'api/EquipmentRepair/SubmitRecordData';

//获取即时库存
const webApiGetImmediateStockList = 'api/Stock/GetImmediateStockList';

//即时库存修改库位
const webApiModifyStorageLocation = 'api/Stock/ModifyStorageLocation';

//获取箱标详情
const webApiGetBarCodeListByBoxNumber =
    'api/BoxLabelBarcode/GetBarCodeListByBoxNumber';

//Puma防伪标入库
const webApiBarCodeInStock = 'api/BoxLabelBarcode/BarCodeInStock';

//获取条码
const webApiGetBarCodeListByEmp =
    'api/BoxLabelBarcode/GetBarCodeListByEmpNumber';

//Puma防伪标出库
const webApiBarCodeOutStock = 'api/BoxLabelBarcode/BarCodeOutStock';

//sap油墨调色单查询
const webApiSapGetInkColorMatchOrder = 'sap/zapp/ZFUN_APP_YM_QUERY';

//sap油墨获取物料列表及型体判断
const webApiSapCheckInkColorMatchTypeBody = 'sap/zapp/ZFUN_APP_YM_MATNR';

//sap创建油墨调色单
const webApiSapCreateInkColorMatch = 'sap/zapp/ZFUN_APP_YM_WOFNR';

//sap油墨调色单试做结果提交
const webApiSapSubmitTrialFinish = 'sap/zapp/ZFUN_APP_YM_RESULT';

//Mes获取成型线生成执行进度表
const webApiGetProductionOrderSchedule =
    'api/Package/GetProductionOrderSchedule';

//Mes获取成型线生成执行进度明细表
const webApiGetProductionOrderScheduleDetail =
    'api/Package/GetProductionOrderScheduleBillorPO';

//检查工号是否合法
const webApiJudgeEmpNumber = 'api/User/JudgeEmpNumber';

//获得已入库条形码数据
const webApiGetBarCodeStatusByDepartmentID =
    'api/BarCode/GetBarCodeStatusByDepartmentID';

//提交条形码数据,自动生成外购入库单
const webApiUploadSupplierBarCode = 'api/BarCode/SubmitBarCode2CollectBill';

//验证生产扫码入库条码
const webApiGetUnReportedBarCode = 'api/scanjobbooking/GetUnReportedBarCode';

//生产扫码入库提交
const webApiUploadProductionScanning =
    'api/ScanJobBooking/SubmitBarCode2PrdInStockCollectBillNew';

//根据SAP供应商ID获取待稽查送货单列表
const webApiGetDeliListBySupplier = 'api/Incoming/GetDeliListBySupplier';

//稽查扫码获取信息
const webApiGetDeliListByBarCode = 'api/Incoming/GetInspectionDetail';

//提交稽查申请
const webApiInspectionApplication = 'api/Incoming/InspectionApplication';

//获取稽查列表
const webApiGetIncomingList = 'api/Incoming/GetIncomingList';

//稽查详情,根据FInterID获取稽查单信息
const webApiGetIncomingMessage = 'api/Incoming/GetIncomingMessage';

//稽查结果提交
const webApiIncomingInspection = 'api/Incoming/IncomingInspection';

//稽查签收
const webApiSigning = 'api/Incoming/Signing';

//异常上传
const webApiAbnormalUpload = 'api/Incoming/AbnormalUpload';

//提交异常处理
const webApiAuditExceptionHandling = 'api/Incoming/AuditExceptionHandling';

//稽查结案
const webApiClosingCase = 'api/Incoming/ClosingCase';

//获取已入库条码数据
const webApiGetBarCodeStatus = 'api/BarCode/GetBarCodeStatus';

//根据条形码数据,获得对应的制程
const webApiGetProcessFlowInfoByBarCode =
    'api/ProcessFlow/GetProcessFlowInfoByBarCode';

//金灿领料出库
const webApiJinCanMaterialOutStockSubmit =
    'api/ScanJobBooking/JincanMaterialOutStockSubmit';

//金灿销售扫码销售出库提交
const webApiJinCanSalesScanningCodeSubmit =
    'api/ScanJobBooking/JinCanSalesScanningCodeSubmit';

//获取领料员可领部门信息
const webApiSapGetPickerInfo = 'sap/zapp/ZMM_ZMMWORK_D';

//修改物料库位
const webApiSapModifyLocation = 'sap/zapp/ZFUN_UPDATE_ZMMLGORT';

//获取正单(车间)领料列表
const webApiGetMaterialList = 'api/Material/GetMaterialList';

//获取物料库存信息列表
const webApiGetMaterialInventoryList = 'api/Material/GetMaterialInventoryList';

//APP创建过账正单(车间)领料单-原材料第二屏
// const webApiSubmitPickingMaterial = 'api/Material/ResZDLLDPic';

//获取已备料待出库领料单列表
const webApiSapGetPickingMaterialList = 'sap/zapp/ZFUN_GET_ZDLL_GDMVT';

//获取已备料待出库领料单物料打印信息
const webApiSapGetMaterialPrintInfo = 'sap/zapp/ZFUN_GET_ZDLL_PRINT';

//领料过账
const webApiSapSubmitPickingMaterialOrder = 'sap/zapp/ZFUN_RES_ZDLL_D';

//备料进度修改
const webApiSapReportPreparedMaterialsProgress = 'sap/zapp/ZFUN_RES_ZDLL_BL';

//生成/撤销 出门单
const webApiSapCreateOutTicket = 'sap/zapp/ZFUN_RES_ZDLL_OAGATEPASS';

//获取盘点明细
const webApiSapGetInventoryPalletList = 'sap/zapp/ZWMS_PD_LIST';

//盘点结果接收
const webApiSapSubmitInventory = 'sap/zapp/ZWMS_PD_POST';

//工序汇报入库提交
const webApiUploadProcessReport =
    'api/ScanJobBooking/SubmitScWorkCardBarCode2ProcessOutput';

//工序汇报入库，获取贴标数据
const webApiGetBarCodeInfo = 'api/BarCode/GetBarCodeInfo';

//工序汇报入库，提交贴标数据
const webApiUpdateBarCodeInfo = 'api/BarCode/UpdateBarCodeInfo';

//获取工序派工单列表   金甄
const webApiGetScWorkCardList =
    'api/CompoundDispatching/GetScWorkCardListJinZhen';

//获取工序派工单详情  金甄
const webApiGetScWorkCardDetail =
    'api/CompoundDispatching/GetScWorkCardDetailJinZhen';

//根据派工单ID删除贴标和框数
const webApiClearBarCodeAndBoxQty =
    'api/CompoundDispatching/ClearBarCodeAndBoxQtyJinZhen';

//修改派工表_金臻 (产量汇报)
const webApiUpdateScWorkCard =
    'api/CompoundDispatching/UpdateScWorkCardJinZhen';

//班组长获取报工交接确认列表_金臻
const webApiGetScWorkCardReportCheckList =
    'api/CompoundDispatching/GetScWorkCardReportCheckListJinZhen';

//班组长反审核汇报单并删除工序汇报单_金臻
const webApiUnCheckScWorkCardReport =
    'api/CompoundDispatching/UnCheckScWorkCardReportJinZhen';

//删除报工产量表数据_金臻
const webApiDelScWorkCardReport =
    'api/CompoundDispatching/DelScWorkCardReportJinZhen';

//班组长审核汇报单并生成工序汇报单_金臻
const webApiCheckScWorkCardReport =
    'api/CompoundDispatching/CheckScWorkCardReportJinZhen';

//根据条形码获得工序派工信息
const webApiGetDispatchInfo = 'api/WorkCard/GetDispatchInfo';

//提交工序派工条形码数据
const webApiSubmitProcessBarCode2CollectBill =
    'api/WorkCard/SubmitProcessBarCode2CollectBill';

//获取送货单列表
const webApiGetDeliveryOrders = 'api/Package/GetDeliveryOrders';

//获取送货单详情
const webApiGetDeliveryOrdersDetails = 'api/Package/GetDeliveryOrdersDetails';

//获取暂收单详情
const webApiGetTemporaryDetail = 'api/Temporary/GetTemporaryDetail';

//保存核查数据
const webApiSaveDeliveryOrderCheck = 'api/DeliveryNote/SendLetterOfAdvice';

//获取仓库是否启用了人脸识别
const webApiGetStockFaceEnable = 'api/Stock/GetStockEnableFaceRec';

//人脸识别,通过保管人工号获取保管人，监管人信息以及保管人部门
const webApiGetLiableInfo = 'api/User/GetLiableInfoByEmpCode';

//SAP包材批量入库
const webApiDeliveryOrderStockIn =
    'api/DeliveryNote/SAPPackagingMaterialBatchStorage';

//SAP包材批量入库
const webApiDeliveryOrderStockOut =
    'api/DeliveryNote/SAPPackagingMaterialBatchOutsourcing';

//根据送货单号或品检单号获取标签,用于冲销
const webApiSapReversalStockInCheck = 'sap/zapp/ZMM_GET_JBQ_CX';

//SAP包材批量入库冲销
const webApiReversalStockIn =
    'api/DeliveryNote/SAPPackagingMaterialBatchStorage_Off';

//SAP包材批量出库冲销
const webApiReversalStockOut =
    'api/DeliveryNote/SAPPackagingMaterialBatchOutsourcing_Off';

//供应商所属标签信息列表
const webApiSapGetSupplierLabelInfo = 'sap/zapp/ZMM_GET_DELIBQ';

//获取送货单和件号绑定暂存数据
const webApiSapGetLabelBindingStaging = 'sap/zapp/ZMM_GET_DELIPIE_TMP';

//暂存SAP标签绑定已扫标签
const webApiSapStagingLabelBinding = 'sap/zapp/ZMM_RES_DELIPIE_TMP';

//提交SAP标签绑定
const webApiSapSubmitLabelBinding = 'sap/zapp/ZMM_RES_DELI_PIECE';

//批量生成暂收单
const webApiCreateTemporary = 'api/DeliveryNote/TemporaryBatchGeneration';

//获取条码报工数据汇总表
const webApiGetBarCodeReportDetails = 'api/ShearOff/GetBarCodeReportDetails';

//条码报工
const webApiBarCodeReport = "api/ShearOff/BarCodeReport";

//获取制程
const webApiGetHandoverProcessFlow = "api/WetPrinting/GetHandoverProcessFlow";

//获取交接工序_部件
const webApiGetHandoverProcess = "api/WetPrinting/GetHandoverProcess";

//获取交接信息_部件
const webApiGetHandoverInfo = "api/WetPrinting/GetHandoverInfo";

//提交交接信息生成交接单_部件
const webApiSubmitHandoverInfo = "api/WetPrinting/SubmitHandoverInfo";

//员工获取可报工信息_部件
const webApiGetCanReportSummary = "api/WetPrinting/GetCanReportSummary";

//员工报工_部件
const webApiSubmitBarCode = "api/WetPrinting/SubmitBarCode";

//扫工票取消报工
const webApiUnReportByWorkCard = "api/WetPrinting/UnReportByWorkCard";

//获取暂收单列表
const webApiGetTemporaryList = 'api/Temporary/GetTemporaryList';

//删除暂收单
const webApiDeleteTemporary = 'api/Temporary/DeleteTemporary';

//暂收单列表获取测试标准接口
const webApiSapGetTestStandards = 'sap/zapp/ZMM_GET_QMSTANDARD';

//暂收单提交测试申请
const webApiSapCreateTestApplication = 'sap/zapp/ZFUN_APP_TESTPR';

//获取采购订单
const webApiGetPurchaseOrder = 'api/Package/GetPurchaseOrder';

//采购订单含图片入库
const webApiPurchaseOrderStockIn = 'api/Package/PurchaseOrderStockInPic';

//获取入库凭证列表
const webApiSapGetReceiptVoucherList = 'sap/zapp/ZFUN_GET_ZCGSLTZD_CX';

//采购订单入库冲销
const webApiPurchaseOrderReversal = 'api/Package/PurchaseOrderStockInPic_Off';

//品检工单查询
const webApiSapGetQualityInspectionOrders = 'sap/zapp/ZFUN_APP_PJ_ORDERQUERY';

//获取品检工单详情
const webApiSapGetQualityInspectionOrderDetail =
    'sap/zapp/ZFUN_APP_PJ_ORDERDETAILQUERY';

//添加品检异常记录
const webApiSapAddAbnormalRecord = 'sap/zapp/ZFUN_APP_PJ_ORDERTESTADD';

//修改品检异常记录状态
const webApiSapModifyAbnormalRecord = 'sap/zapp/ZFUN_APP_PJ_ORDERTESTEDIT';

//删除品检异常记录
const webApiSapDeleteAbnormalRecord = 'sap/zapp/ZFUN_APP_PJ_ORDERTESTDEL';

//品检提交质检完成标识
const webApiSapInspectionCompleted = 'sap/zapp/ZFUN_APP_PJ_ORDERTESTCOMP';

//获取质检汇总表
const webApiSapGetInspectionReport = 'sap/zapp/ZFUN_APP_PJ_SUMQUERY';

//根据件号获取装柜信息
const webApiSapGetContainerLoadingInfo = 'sap/zapp/ZFUN_ZGD';

//检查货柜状态
const webApiSapCheckContainer = 'sap/zapp/ZFUN_ZGD_6';

//排柜提交
const webApiSapSubmit = 'sap/zapp/ZFUN_ZGD_2';

//保存异常单
const webApiSapSaveAbnormalPiece = 'sap/zapp/ZFUN_ZGD_5';

//获取装柜异常单数据
const webApiSapGetAbnormalList = 'sap/zapp/ZFUN_ZGD_4';

//获取巡检产线及异常记录
const webApiSapGetPatrolInspectionInfo = 'sap/zapp/ZFUN_APP_PJ_ORDERSUMQUERY';

//添加巡查记录
const webApiSapAddPatrolInspectionRecord = 'sap/zapp/ZFUN_APP_PJ_ORDERTESTADD2';

//删除巡查记录
const webApiSapDeletePatrolInspectionRecord =
    'sap/zapp/ZFUN_APP_PJ_ORDERTESTDEL2';

//获取巡查记录
const webApiSapGetPatrolInspectionReport = 'sap/zapp/ZFUN_APP_PJ_SUMQUERY2';

//获取工序派工单列表
const webApiGetProcessWorkCardList = "api/ShearOff/GetProcessWorkCardList";

//部件拆分
const webApiPartsDisassembly = "api/ShearOff/PartsDisassembly";

//部件合并
const webApiPartsMerging = "api/ShearOff/PartsMerging";

//获取派工单贴标详情
const webApiGetBarcodeDetails = "api/ShearOff/GetBarcodeDetails";

//生成贴标条码
const webApiCreateLabelingBarcode = "api/ShearOff/CreateLabelingBarcode";

//删除条码
const webApiDelLabelingBarcode = "api/ShearOff/DelLabelingBarcode";

//打印传递打印次数
const webApiUpdatePartsPrintTimes = "api/WetPrinting/UpdatePartsPrintTimes";

//获取组别工单列表
const webApiGetProductionOrderST = "api/Package/GetProductionOrderST";

//获取品检单列表
const webApiGetInspectionList = "api/Inspection/GetInspectionList";

//创建品检单(删除)
const webApiCreateInspection = "api/Inspection/CreateInspection";

//采购订单条码扫描入库（SAP）
const webApiPurchaseOrderStockInForQuality = "api/Package/PurchaseOrderStockIn";

//微信,APP获取SAP品质检验单单条数据
const webApiGetQualityInspection = "api/Inspection/GetQualityInspection";

//微信,APP获取SAP品质检验单单条数据(编辑)
const webApiGetQualityInspectionList = "api/DeliveryNote/GetQualityInspectionList";

//入库冲销获取色系信息
const webApiForSapReceiptReversal = "sap/zapp/ZFUN_GET_ZCHECKB_COSEP";

//品检单冲销
const webApiPurchaseOrderStockInNew = "api/Package/PurchaseOrderStockIn_Off";

//材料品质异常 品检不合格原因到OA
const webApiAbnormalMaterialQuality = "api/Inspection/AbnormalMaterialQuality";

//获取标签信息
const webApiSapLabelBindingGetLabelInfo = 'sap/zapp/ZMM051_GET_BQSC';

//提交标签绑定操作
const webApiSapLabelBindingSubmitOperation = 'sap/zapp/ZMM051_RES_ZDBDX';

//查询多少天内的派工数据
const webApiGetWorkCardPriority = "api/Package/GetWorkCardPriority";

//提交优先级
const webApiSubmitWorkCardPriority = "api/Package/SubmitWorkCardPriority";

//扫码提交鞋盒信息
const webApiReceiveWorkCardDataST = "api/Package/ReceiveWorkCardDataST";

//获得线别的当前的分析报告
const webApiGetWorkLineAnalysisReportNowNew = "api/Package/GetWorkLineAnalysisReportNowNew";

//获得线别的分配信息
const webApiGetDeptDistributeInfoNew = "api/Package/GetDeptDistributeInfoNew";

//获得该线别的所扫描的所有指令单信息【主要查看最后激活时间】
const webApiGetDepartmentScanInfoNew = "api/Package/GetDepartmentSacnInfoNew";

//根据指令单号 获得该指令单的报表明细
const webApiGetMoReportByMoNo = "api/Package/GetMoReportByMoNo";

//根据指令单号获得尺码数据
const webApiGetScMoSizeBarCodeByMONo = "api/Package/GetScMoSizeBarCodeByMONo";

//更新无规则条码到指令单尺码分录表中，并执行存储过程同步到表Sc_MO_InBoxBarCode中
const webApiSubmitScMoSizeBarCodeNew = "api/BarCode/SubmitScMoSizeBarCodeNew";

