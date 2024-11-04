import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../bean/http/response/base_data.dart';
import '../constant.dart';
import '../route.dart';
import 'utils.dart';
import '../widget/dialogs.dart';

///接口返回异常
const resultError = 0;

///接口返回成功
const resultSuccess = 1;

///重新登录
const resultReLogin = 2;

///版本升级
const resultToUpdate = 3;

///MES正式库
const baseUrlForMES = 'https://geapp.goldemperor.com:1226/';

///MES测试库
const testUrlForMES = 'https://geapptest.goldemperor.com:1224/';

///SAP正式库
const baseUrlForSAP = 'https://erpprd01.goldemperor.com:8003/';

///SAP开发库
const developUrlForSAP = 'https://erpqas01.goldemperor.com:8001/';

///SAP正式库
const baseClientForSAP = 800;

///SAP开发库
const developClientForSAP = 300;

/// 日志工具
var logger = Logger();

///当前语言
var language = 'zh';

///post请求
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

///get请求
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

///post请求
Future<BaseData> sapPost({
  String? loading,
  required String method,
  Map<String, dynamic>? params,
  Object? body,
}) {
  return _doHttp(
    loading: loading,
    params: {'sap-client': baseClientForSAP, ...?params},
    body: body,
    baseUrl: baseUrlForSAP,
    isPost: true,
    method: method,
  );
}

///初始化网络请求
Future<BaseData> _doHttp({
  required bool isPost,
  required String method,
  required String baseUrl,
  String? loading,
  Map<String, dynamic>? params,
  Object? body,
}) async {
  ///用于开发时切换测试库，打包时必须屏蔽
  // baseUrl = baseUrl == baseUrlForSAP? developUrlForSAP : baseUrl==baseUrlForMES? testUrlForMES:baseUrl;
  ///--------------------------------------------x----
  try {
    logger.f('SnackbarStatus=$snackbarStatus');
    if(snackbarStatus==SnackbarStatus.OPEN || snackbarStatus == SnackbarStatus.OPENING){
      snackbarController?.close(withAnimations: false);
    }
  } catch (e) {
    logger.f('销毁snackbar异常');
  }
  if (loading != null && loading.isNotEmpty) {
    loadingDialog(loading);
  }

  ///根据路由获取当前所在的功能
  var nowFunction = getNowFunction();

  ///设置请求的headers
  var options = Options(headers: {
    'Content-Type': 'application/json',
    'FunctionID': nowFunction?.id ?? '0',
    'Version': nowFunction?.version ?? 0,
    'Language': language,
    'Token': userInfo?.token ?? '',
    'GUID': const Uuid().v1(),
  });

  ///创建返回数据载体
  var base = BaseData();

  try {
    ///创建dio对象
    var dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(minutes: 2),
      receiveTimeout: const Duration(minutes: 2),
    ));

    ///接口拦截器
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
            if (Get.isDialogOpen == true) Get.back();
            spSave(spSaveUserInfo, '');
            reLoginPopup();
          } else if (baseData.resultCode == 3) {
            logger.e('需要更新版本');
            if (Get.isDialogOpen == true) Get.back();
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

    ///发起post/get请求
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
      // base.data = jsonEncode(json['Data']);
      base.data = json['Data'];
      base.message = json['Message'];
    } else {
      logger.e('网络异常');
      base.message = '网络异常';
    }
  } on DioException catch (e) {
    logger.e('error:${e.toString()}');
    base.message = '链接服务器失败：${e.toString()}';
  } on Exception catch (e) {
    logger.e('error:${e.toString()}');
    base.message = '发生错误：${e.toString()}';
  } on Error catch (e) {
    logger.e('error:${e.toString()}');
    base.message = '发生异常：${e.toString()}';
  }
  if (loading != null && loading.isNotEmpty) Get.back();
  base.baseUrl=baseUrl;
  return base;
}

///登录接口
const webApiLogin = 'api/User/Login';

///获取用户头像
const webApiGetUserPhoto = 'api/User/GetEmpPhotoByPhone';

///获取验证码接口
const webApiVerificationCode = 'api/User/SendVerificationCode';

///获取主页入口列表
const webApiGetMenuFunction = 'api/AppMenuFunction/GetAppMenuFunction';

///修改头像接口
const webApiChangeUserAvatar = 'api/User/UploadEmpPicture';

///修改密码接口
const webApiChangePassword = 'api/User/ChangePassWord';

///修改部门组别接口
const webApiChangeDepartment = 'api/User/GetLoginInfo';

///检查版本更新接口
const webApiCheckVersion = 'api/Public/FlutterVersionUpgrade';

///获取sap供应商列表接口
const webApiPickerSapSupplier = 'api/Supplier/GetSAPSupplierMessageNew';

///获取sap公司列表接口
const webApiPickerSapCompany = 'api/Department/GetSAPFactoryArea';

///获取sap厂区列表接口
const webApiPickerSapFactory = 'api/Department/GetSAPFactoryInfo';

///获取sap工作中心列表接口
const webApiPickerSapWorkCenter = 'api/Department/GetSAPWorkCenter';

///获取sap部门列表接口
const webApiPickerSapDepartment = 'api/Department/GetSAPDeptInfo';

///获取mes部门列表接口
const webApiPickerMesDepartment = 'api/Department/GetDeptInfoByOrganizeID';

///获取mes车间列表接口
const webApiPickerMesWorkShop = 'api/Department/GetMESWorkShop';

///获取mes组织列表接口
const webApiPickerMesOrganization = 'api/User/GetOrganization';

///获取sap制程列表接口
const webApiPickerSapProcessFlow = 'api/ProcessFlow/GetSAPProcessFlow';

///获取mes制程列表接口
const webApiPickerMesProcessFlow = 'api/ProcessFlow/GetProcessFlowInfo';

///获取sap机台列表接口
const webApiPickerSapMachine = 'api/CompoundDispatching/GetDrillingCrewList';

///获取sap新工作中心列表接口
const webApiPickerSapWorkCenterNew = 'api/Department/GetSAP_WorkCenterNew';

///获取sap组别列表接口
const webApiPickerSapGroup = 'api/User/GetDepListByEmpID';

///获取sap工厂及仓库列表接口
const webApiPickerSapFactoryAndWarehouse = 'api/Stock/GetSAPFactoryStockInfo';

///获取sap仓库库位列表接口
const webApiPickerSapWarehouseStorageLocation =
    'api/InStockTrackingNum/GetWarehouseStorageLocationList';

///获取mes组别
const webApiPickerMesGroup = 'api/Autoworkshopbatch/GetClassList';

///获取mes包装区域列表
const webApiGetPickerMesMoldingPackArea = 'api/BaseInfo/GetMoldingPackAreaInfo';

///获取扫码日产量接口
const webApiGetDayOutput = 'api/Piecework/GetDayOutput';

///获取实时产量汇总表接口
const webApiGetPrdShopDayReport = 'api/ProductionReport/GetPrdShopDayReport';

///获取生产日报表
const webApiGetPrdDayReport = 'api/ProductionReport/GetPrdDayReport';

///提交生产日报表未达标原因
const webApiSubmitDayReportReason = 'api/WorkCard/Submit2PrdDayReportNote';

///获取车间生产日报表汇总数据
const webApiGetWorkshopProductionDailySummary =
    'api/ProductionReport/GetEarlyWarningInfoReportOne';

///获取车间生产日报表明细数据
const webApiGetWorkshopProductionDailyDetail =
    'api/ProductionReport/GetEarlyWarningInfoReportTwo';

///根据指令号和制程查询指令pdf在线文档
const webApiGetInstructionDetailsFile = 'api/Package/GetPreviewFileByMoNo';

///获取员工计件产量报表
const webApiGetWorkerProductionReport =
    'api/Piecework/GetDayWorkDataByDepartmentID';

///获取员工计件明细报表类型
const webApiGetProductionReportType = 'api/WorkCard/GetProcessOutputReport';

///获取员工计件明细报表
const webApiProductionReport = 'api/WorkCard/GetProcessOutputReportDetail';

///获取指定型体的工艺说明书列表
const webApiGetProcessSpecificationList =
    'api/NeedleCartDispatch/GetManufactureInstructionsByProduct';

///检查设备是否授权查看PDF
const webApiCheckAuthorize = 'api/User/CheckAuthorize';

///申请授权
const webApiAuthorizedApplication = 'api/User/AuthorizedApplication';

///获取包装区报表
const webApiGetMoldingPackAreaReport = 'api/Package/GetMoldingPackAreaReport';

///获取包装区报表明细
const webApiGetMoldingPackAreaReportDetail =
    'api/Package/GetMoldingPackAreaPODetail';

///获取成型后段扫码看板
const webApiGetMoldingScanBulletinReport = 'api/Package/GetProductionOrderST';

///提交成型后段扫码工单排序
const webApiSubmitNewSort = 'api/Package/SubmitWorkCardPriority';

///根据时间和部门信息获得生产派工单列表信息
const webApiGetWorkCardCombinedSizeList =
    'api/WorkCard/GetWorkCardCombinedSizeList';

///生产派工单下推
const webApiPushProductionOrder =
    'api/NeedleCartDispatch/GetProcessWorkCardForWorkCard';

///生产派工单批量下推
const webApiBatchPushProductionOrder =
    'api/NeedleCartDispatch/GetProcessWorkCardForWorkCardBatch';

///根据组别获取本组组员信息
const webApiGetWorkerInfo = 'api/User/GetEmpByFNumber';

///查询财产审核列表
const webApiQueryProperty = 'api/FixedAsset/SearchUnnumberedProperty';

///获取财产明细
const webApiGetPropertyDetail = 'api/FixedAsset/GetAssetsByFInterID';

///财产审核关闭
const webApiPropertyClose = 'api/FixedAsset/AssetsRegistrationClose';

///跳过财产验收
const webApiSkipAcceptance = 'api/FixedAsset/CloseAssets';

///更新财产信息
const webApiUpdateProperty = 'api/FixedAsset/UpdateAssets';

///人员来访记录列表
const webApiGetVisitDtBySqlWhere =
    'api/VisitorRegistration/GetVisitDtBySqlWhere';

///获取来访编号
const webApiGetInviteCode = 'api/VisitorRegistration/GetInviteCode';

///获取工艺指导书列表
const webApiGetManufactureInstructions =
    'api/NeedleCartDispatch/GetManufactureInstructions';

///获取用料清单
const webApiGetWorkPlanMaterial = 'api/NeedleCartDispatch/GetWorkPlanMaterial';

///获取工艺路线
const webApiGetPrdRouteInfo = 'api/NeedleCartDispatch/GetPrdRouteInfo';

///获取批量工艺路线
const webApiGetBatchPrdRouteInfo =
    'api/NeedleCartDispatch/GetPrdRouteInfoNewBatch';

///发送微信校对信息给派工员工
const webApiSendDispatchToWechat = 'api/NeedleCartDispatch/WechatPostByFEmpID';

///工序计工
const webApiProductionDispatch = 'api/NeedleCartDispatch/ProcessCalculation';

///获取派工单派工数、完工数信息
const webApiGetIntactProductionDispatch =
    'api/WorkCard/GetSubmitScWorkCard2ProcessOutputReport';

///获取生产用料表
const webApiGetSapMoPickList = 'api/Material/GetSapMoPickList';

///获取指令表
const webApiGetProductionOrderPDF = 'api/Package/GetProductionOrderPDF';

///获取配色单列表
const webApiGetMatchColors = 'api/Inspection/GetMatchColors';

///获取配色单pdf
const webApiGetMatchColorsPDF = 'api/Inspection/GetMatchColorsPDF';

///修改派工单开关状态
const webApiChangeWorkCardStatus =
    'api/NeedleCartDispatch/SetWorkCardCloseStatus';

///删除派工单下游工序
const webApiDeleteScProcessWorkCard =
    'api/NeedleCartDispatch/DeleteScProcessWorkCard';

///删除派工单上次报工
const webApiDeleteLastReport =
    'api/NeedleCartDispatch/DeleteLastProcessWorkCardAndProcessOutPut';

///更新sap配套数
const webApiUpdateSAPPickingSupportingQty =
    'api/CompoundDispatching/UpdateSAPPickingSupportingQty';

///更新sap配套数
const webApiReportSAPByWorkCardInterID =
    'api/CompoundDispatching/ReportSAPByWorkCardInterID';

///获取贴标列表
const webApiGetLabelList = 'api/CompoundDispatching/PackagePrintLabelList';

///创建单码贴标
const webApiCreateSingleLabel =
    'api/CompoundDispatching/GeneratePackingListByWorkCardInterID';

///获取可创建标签数据
const webApiGetPackingListBarCodeCount =
    'api/CompoundDispatching/GetPackingListBarCodeCount';

///获取可创建标签数据
const webApiGetPackingListBarCodeCountBySize =
    'api/CompoundDispatching/GetPackingListBarCodeCountBySize';

///创建混码贴标
const webApiCreateMixLabel =
    'api/CompoundDispatching/GeneratePackingListBarCodeBySizedMultiple';

///创建自定义贴标
const webApiCreateCustomLargeLabel =
    'api/CompoundDispatching/GeneratePackingListLargeBarCode';

///创建自定义贴标
const webApiCreateCustomSizeLabel =
    'api/CompoundDispatching/GeneratePackingListBarCodeBySize';

///删除包装清单所有标签
const webApiCleanLabel = 'api/CompoundDispatching/DelPackingListBarcode';

///删除标签
const webApiDeleteLabels = 'api/CompoundDispatching/DelBarcode';

///获取物料属性
const webApiGetMaterialProperties =
    'api/CompoundDispatching/GetMaterialProperties';

///修改物料属性配置
const webApiSetMaterialProperties =
    'api/CompoundDispatching/SubmitMaterialProperties';

///获取物料箱容信息
const webApiGetMaterialCapacity =
    'api/CompoundDispatching/GetBodySizeBoxCapacity';

///修改物料箱容配置
const webApiSetMaterialCapacity =
    'api/CompoundDispatching/SubmitBodySizeBoxCapacity';

///获取物料语言信息信息
const webApiGetMaterialLanguages =
    'api/CompoundDispatching/GetMaterialMultilingual';

///修改物料语言信息信息
const webApiSetMaterialLanguages =
    'api/CompoundDispatching/SubmitMaterialMultilingual';

///获取生产派工单
const webApiGetWorkCardOrderList =
    'api/WorkCard/GetWorkCardCombinedSizeListByScan';

///获取生产派工单部件信息
const webApiGetPartList = 'api/WetPrinting/GetWorkCardParts';

///获取生产派工单部件信息明细
const webApiGetPartDetail = 'api/WetPrinting/GetWorkCardPartDetails';

///创建部件贴标
const webApiCreatePartLabel = 'api/WetPrinting/CreatePartLabelingBarcode';

///删除部件贴标
const webApiDeletePartLabel = 'api/WetPrinting/DelBarcode';

///获取贴标工序汇总表_已报工
const webApiGetPartProcessReportedReport =
    'api/WetPrinting/GetPartProcessReport_Barcode_Reported';

///获取工序派工单列表
const webApiGetScWorkCardProcess =
    'api/CompoundDispatching/GetScWorkCardProcessListStripDrawing';

///获取SPA仓库托盘列表
const webApiGetPallet = 'api/InStockTrackingNum/GetPallet';

///抽条末道工序生成工序汇报单
const webApiCreateLastProcessReport =
    'api/CompoundDispatching/CreateProcessOutPutByDepIDStripDrawing';

///取件码-批量生产入库
const webApiPickCodeBatchProductionWarehousing =
    'api/CompoundDispatching/PickCodeBatchProductionWarehousing';

///抽条获取用料清单
const webApiGetSubItemBatchMaterialInformation =
    'api/CompoundDispatching/GetSubItemBatchMaterialInformation';

///抽条用料清单数量矫正
const webApiMetersConvert = 'api/CompoundDispatching/MetersConvert';

///抽条获取贴标列表
const webApiGetQRCodeList = 'api/BarCode/GetQRCodeList';

///抽条车间贴标打印记工
const webApiCreateProcessOutPutStripDrawing =
    'api/CompoundDispatching/CreateProcessOutPutStripDrawing';

///批量取消报工
const webApiProcessOutPutReport =
    'api/CompoundDispatching/ProcessOutPutReport1';

///取件码-生产入库
const webApiPickCodeProductionWarehousing =
    'api/CompoundDispatching/PickCodeProductionWarehousing';

///获取工序派工单列表
const webApiGetWorkCardList =
    'api/CompoundDispatching/GetScWorkCardListJinZhen';

///获取工序派工单详情
const webApiGetWorkCardDetail =
    'api/CompoundDispatching/GetScWorkCardDetailJinZhen';

///获取已入库的贴标列表
const webApiSapGetMaterialDispatchLabelList = 'sap/zapp/ZFUN_APP_BARCODE_FETCH';

///机台派工单--贴标维护
const webApiSapMaterialDispatchLabelMaintain =
    'sap/zapp/ZFUN_APP_BARCODE_MAINTAIN';

///验证码发送接口
const webApiSendManagerCode = 'api/Public/SendManagerCode';

///验证人员
const webApiCheckManagerByCode = 'api/Public/CheckManagerByCode';

///上班尾数标识状态修改_金臻
const webApiCleanOrRecoveryLastQty =
    'api/CompoundDispatching/UpdateLastScWorkCardMantissaFlagJinZhen';

///修改派工表_金臻
const webApiModifyWorkCardItem =
    'api/CompoundDispatching/UpdateScWorkCardJinZhen';

///生成报工产量表_金臻
const webApiReportDispatch =
    'api/CompoundDispatching/SubmitScWorkCardReportJinZhen';
///最近一次来访记录
const webApiGetVisitInfoByJsonStr = 'api/VisitorRegistration/GetVisitInfoByJsonStr';

///来访详情
const webApiGetVisitorInfo = 'api/VisitorRegistration/GetVisitorInfo';

///离场更新
const webApiUpdateLeaveFVisit = 'api/VisitorRegistration/UpdateLeaveFVisit';

///离场新增
const webApiInsertIntoFVisit = 'api/VisitorRegistration/InsertIntoFVisit';

///根据部门ID或员工工号获得员工信息
const webApiGetEmpByField = 'api/VisitorRegistration/GetEmpByField';

///获取会客地点
const webApiGetReceiveVisitorPlace = 'api/VisitorRegistration/GetReceiveVisitorPlace';

///成型集装箱出货扫码汇总
const webApiSapContainerScanner = "sap/zapp/ZMM_ZXCFSM_SUMM";

///根据条件获取成型集装箱出货信息
const webApiSapContainerShipmentScanner = "sap/zapp/ZMM_ZXCFSM_D";

///贴标工序报工_修改已报工
const webApiProductionDispatchReportSubmit = 'api/WetPrinting/BarCodeProcessReportSubmit_Reported';

///获取工序派工单信息
const webApiGetProcessWorkCard = 'api/WetPrinting/GetProcessWorkCardByBarcode';

///获取报工信息
const webApiGetReportDataByBarcode = 'api/WetPrinting/GetReportDataByBarcode';

///修改操作员
const webApiChangeLabelingBarcodeEmp = 'api/WetPrinting/ChangeLabelingBarcodeEmp';

///删除标签
const webApiUnReportAndDelLabelingBarcode = 'api/WetPrinting/UnReportAndDelLabelingBarcode';

///智能AGV派送获取工单列表
const webApiSmartDeliveryGetWorkCardList = 'api/Autoworkshopbatch/GetWorkCardList';

///发料明细(材料清单)
const webApiSmartDeliveryGetWorkCardMaterial = 'api/Autoworkshopbatch/GetWorkCardMaterial';

///获取楦头库存
const webApiSmartDeliveryGetShorTreeList = 'api/Autoworkshopbatch/GetBalance';

///保存楦头库存
const webApiSmartDeliverySaveShorTree = 'api/Autoworkshopbatch/BalanceEdit';

///具体部件物料发料详情
const webApiSmartDeliveryDetail = 'api/Autoworkshopbatch/GetPartsOrder';

///新增发料数据
const webApiSmartDeliveryAddPartsStock = 'api/Autoworkshopbatch/AddPartsStock';

///删除发料数据
const webApiSmartDeliveryDeletePartsStock = 'api/Autoworkshopbatch/DeletePartsStock';

///获取模板类
const webApiSmartDeliveryGetTaskType= 'api/Autoworkshopbatch/GetTaskType';

///发料数据创建机器人任务
const webApiSmartDeliveryCreatRobTask= 'api/Autoworkshopbatch/CreatRobTask';

///机器人任务记录
const webApiSmartDeliveryGetRobTask= 'api/Autoworkshopbatch/GetRobTask';

///获取机器人站点信息
const webApiSmartDeliveryGetRobotPosition = 'api/Autoworkshopbatch/GetRobotPosition';

///外箱内盒条码关联数据
const webApiGetCartonLabelInfo = 'api/OutBoxScan/GetLinkData';

///外箱鞋盒贴标数据提交
const webApiSubmitScannedCartonLabel = 'api/OutBoxScan/SubOutBoxData';

///订单扫码情况表查询
const webApiGetCartonLabelScanHistory = 'api/OutBoxScan/GetOrderScan';

///订单扫码情况明细表
const webApiGetCartonLabelScanHistoryDetail = 'api/OutBoxScan/GetOrderScanDetail';

///获取品质异常详情
const webApiGetSCDispatchOrders = 'api/QMProcessFlowEx/GetSCDispatchOrders';

///获取品质异常类型
const webApiGetProcessFlowEXTypes = 'api/QMProcessFlowEx/GetProcessFlowEXTypes';

///品质异常插入
const webApiAddAbnormalQuality = 'api/QMProcessFlowEx/QMAbnormityBysuitID';


