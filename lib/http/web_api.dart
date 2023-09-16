import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/http/response/base_data.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../constant.dart';
import '../main.dart';
import '../route.dart';
import '../utils.dart';
import '../widget/dialogs.dart';

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

UserController userController = Get.find();

///post请求
Future<BaseData> httpPost({
  String? loading,
  required String method,
  Map<String, dynamic>? query,
  Object? body,
}) {
  return _doHttp(true, method, loading: loading, query: query, body: body);
}

///get请求
Future<BaseData> httpGet({
  String? loading,
  required String method,
  Map<String, dynamic>? query,
  Object? body,
}) {
  return _doHttp(false, method, loading: loading, query: query, body: body);
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
    Get.back();
    spSave(spSaveUserInfo, '');
    reLoginPopup();
  } else if (baseData.resultCode == 3) {
    Get.back();
    logger.e('需要更新版本');
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
  Map<String, dynamic>? query,
  Object? body,
}) async {

  if (loading != null && loading.isNotEmpty) {
    loadingDialog(loading);
  }

  ///根据路由获取当前所在的功能
  var nowFunction = getNowFunction();

  ///设置请求的headers
  var options = Options(headers: {
    'Content-Type': 'application/json',
    'FunctionID': nowFunction?.id,
    'Version': nowFunction?.version,
    'Language': language,
    'Token': userController.user.value!.token ?? '',
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
            queryParameters: query, data: body, options: options)
        : await dio.get(method,
            queryParameters: query, data: body, options: options);
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
    logger.e('error:${e.error}');
    base.message = '链接服务器失败：${e.error}';
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

///获取扫码日产量接口
const webApiGetDayOutput = 'api/Piecework/GetDayOutput';

///获取实时产量汇总表接口
const webApiGetPrdShopDayReport = 'api/ProductionReport/GetPrdShopDayReport';

///获取生产日报表
const webApiGetPrdDayReport = 'api/ProductionReport/GetPrdDayReport';

///提交生产日报表未达标原因
const webApiSubmitDayReportReason = 'api/WorkCard/Submit2PrdDayReportNote';

///获取车间生产日报表汇总数据
const webApiGetWorkshopProductionDailySummary= 'api/ProductionReport/GetEarlyWarningInfoReportOne';

///获取车间生产日报表明细数据
const webApiGetWorkshopProductionDailyDetail= 'api/ProductionReport/GetEarlyWarningInfoReportTwo';
