import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import 'bean/http/response/base_data.dart';
import 'constant.dart';
import 'route.dart';
import 'utils.dart';
import 'widget/dialogs.dart';

///接口返回异常
const resultError = 0;

///接口返回成功
const resultSuccess = 1;

///重新登录
const resultReLogin = 2;

///版本升级
const resultToUpdate = 3;

///WebService 基地址
const baseUrlForMES = 'https://geapp.goldemperor.com:1226/';

///WebService 基地址
const testUrlForMES = 'https://geapptest.goldemperor.com:1224/';

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
  return _doHttp(true, method, loading: loading, params: params, body: body);
}

///get请求
Future<BaseData> httpGet({
  String? loading,
  required String method,
  Map<String, dynamic>? params,
  Object? body,
}) {
  return _doHttp(false, method, loading: loading, params: params, body: body);
}

///接口拦截器
var _interceptors = InterceptorsWrapper(onRequest: (options, handler) {
  options.print();
  handler.next(options);
}, onResponse: (response, handler) {
  var baseData = BaseData.fromJson(response.data.runtimeType == String
      ? jsonDecode(response.data)
      : response.data);
  baseData.print();
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
}, onError: (DioException e, handler) {
  logger.e('error:$e');
  handler.next(e);
});

///初始化网络请求
Future<BaseData> _doHttp(
  bool isPost,
  String method, {
  String? loading,
  Map<String, dynamic>? params,
  Object? body,
}) async {
  snackbarController?.close(withAnimations: false);
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
      baseUrl: testUrlForMES,
      // baseUrl: baseUrlForMES,
      connectTimeout: const Duration(minutes: 2),
      receiveTimeout: const Duration(minutes: 2),
    ))
      ..interceptors.add(_interceptors);

    ///发起post/get请求
    var response = isPost
        ? await dio.post(method,
            queryParameters: params, data: body, options: options)
        : await dio.get(method,
            queryParameters: params, data: body, options: options);
    if (response.statusCode == 200) {
      var baseData = BaseData.fromJson(response.data.runtimeType == String
          ? jsonDecode(response.data)
          : response.data);
      base.resultCode = baseData.resultCode ?? 0;
      base.data = jsonEncode(baseData.data);
      base.message = baseData.message ?? '';
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
  return base;
}

///登录接口
const webApiLogin = 'api/User/Login';

///登录接口
const webApiGetUserPhoto = 'api/User/GetEmpPhotoByPhone';

///获取验证码接口
const webApiVerificationCode = 'api/User/SendVerificationCode';

///获取主页入口列表
const webApiGetMenuFunction = 'api/AppMenuFunction/GetAppMenuFunction';

///修改头像接口
const webApiChangeUserAvatar = 'api/User/UploadEmpPicture';

///修改密码接口
const webApiChangePassword = 'api/User/ChangePassWord';

///获取部门组别列表接口
const webApiGetDepartment = 'api/User/GetDepListByEmpID';

///修改部门组别接口
const webApiChangeDepartment = 'api/User/GetLoginInfo';

///检查版本更新接口
const webApiCheckVersion = 'api/Public/VersionUpgrade';

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
const webApiGetVisitDtBySqlWhere = 'api/VisitorRegistration/GetVisitDtBySqlWhere';

///获取来访编号
const webApiGetInviteCode = 'api/VisitorRegistration/GetInviteCode';

///获取工艺指导书列表
const webApiGetManufactureInstructions = 'api/NeedleCartDispatch/GetManufactureInstructions';

///获取用料清单
const webApiGetWorkPlanMaterial = 'api/NeedleCartDispatch/GetWorkPlanMaterial';

///获取工艺路线
const webApiGetPrdRouteInfo = 'api/NeedleCartDispatch/GetPrdRouteInfo';

///发送微信校对信息给派工员工
const webApiSendDispatchToWechat = 'api/NeedleCartDispatch/WechatPostByFEmpID';

///工序计工
const webApiProductionDispatch = 'api/NeedleCartDispatch/ProcessCalculation';

///获取派工单派工数、完工数信息
const webApiGetIntactProductionDispatch = 'api/WorkCard/GetSubmitScWorkCard2ProcessOutputReport';

///获取生产用料表
const webApiGetSapMoPickList = 'api/Material/GetSapMoPickList';

///获取指令表
const webApiGetProductionOrderPDF = 'api/Package/GetProductionOrderPDF';

///获取配色单列表
const webApiGetMatchColors = 'api/Inspection/GetMatchColors';

///获取配色单pdf
const webApiGetMatchColorsPDF = 'api/Inspection/GetMatchColorsPDF';

///修改派工单开关状态
const webApiChangeWorkCardStatus = 'api/NeedleCartDispatch/SetWorkCardCloseStatus';

///删除派工单下游工序
const webApiDeleteScProcessWorkCard = 'api/NeedleCartDispatch/DeleteScProcessWorkCard';

///删除派工单上次报工
const webApiDeleteLastReport = 'api/NeedleCartDispatch/DeleteLastProcessWorkCardAndProcessOutPut';

///更新sap配套数
const webApiUpdateSAPPickingSupportingQty = 'api/CompoundDispatching/UpdateSAPPickingSupportingQty';

///更新sap配套数
const webApiReportSAPByWorkCardInterID = 'api/CompoundDispatching/ReportSAPByWorkCardInterID';

///获取贴标列表
const webApiGetLabelList = 'api/CompoundDispatching/PackagePrintLabelList';

///创建单码贴标
const webApiCreateSingleLabel = 'api/CompoundDispatching/GeneratePackingListByWorkCardInterID';

///创建单码贴标
const webApiGetPackingListBarCodeCount = 'api/CompoundDispatching/GetPackingListBarCodeCount';

