import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/people_message_info.dart';
import 'package:jd_flutter/bean/http/response/quality_inspection_info.dart';
import 'package:jd_flutter/bean/http/response/show_color_batch.dart';
import 'package:jd_flutter/bean/http/response/temporary_order_info.dart';
import 'package:jd_flutter/bean/http/response/visit_photo_bean.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection/stuff_quality_inspection_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class StuffQualityInspectionLogic extends GetxController {
  final StuffQualityInspectionState state = StuffQualityInspectionState();

  var inspectionQuantityController = TextEditingController(); //检验数量控制器
  var waitInspectionQuantityController = TextEditingController(); //待抽检数控制器
  var qualifiedController = TextEditingController(); //合格数控制器
  var unqualifiedQualifiedController = TextEditingController(); //不合数控制器
  var shortQualifiedController = TextEditingController(); //短码数控制器
  var reviewerController = TextEditingController(); //审核人控制器
  var exceptionDescriptionController = TextEditingController(); //异常说明
  var processingMethodController = TextEditingController(); //处理方法
  var availabilityController = TextEditingController(); //可利用率

  //添加照片
  addPicture(String bitmapBase64) {
    state.picture.add(VisitPhotoBean(photo: bitmapBase64, typeAdd: "1"));
  }

  //删除照片
  removePicture(int position) {
    state.picture.removeAt(position);
  }

  //分色
  addColor(String batch, String qty) {
    if (batch.isNotEmpty && qty.isNotEmpty) {
      state.inspectionColorList.add(ShowColorBatch(
        batch: batch,
        qty: qty,
      ));
    }
    state.unColorQty.value =
        (state.unColorQty.toString().toDoubleTry() - qty.toDoubleTry())
            .toStringAsFixed(2);
  }

  //移除分色
  removeColor(int position) {
    state.unColorQty.value = (state.unColorQty.toString().toDoubleTry() +
            state.inspectionColorList[position].qty.toDoubleTry())
        .toStringAsFixed(2);
    state.inspectionColorList.removeAt(position);
  }

  //全部合格或者全部不合格
  allBtn() {
    if (state.showAllBtnName.value == '全部合格') {
      //数量全部合格 无受理单位
      unqualifiedQualifiedController.text = '0';
      qualifiedController.text = inspectionQuantityController.text;
      shortQualifiedController.text = '0';
      state.groupTypeEnable.value = false;
      state.abnormalExplanationEnable.value = false;
      state.processingMethodEnable.value = false;

      state.showAllBtnName.value == '全部不合格';
    } else {
      //数量全部不合格
      unqualifiedQualifiedController.text = inspectionQuantityController.text;
      qualifiedController.text = '0';
      shortQualifiedController.text = '0';
      state.groupTypeEnable.value = true;
      state.abnormalExplanationEnable.value = true;
      state.processingMethodEnable.value = true;

      state.showAllBtnName.value == '全部合格';
    }
  }

  //输入了不合格数量
  inputUnqualified(double qty) {
    if (unqualifiedQualifiedController.text.toDoubleTry() <= 0 &&
        shortQualifiedController.text.toDoubleTry() <= 0) {
      //如果没有不合格数量或短码，没有受理单位

      state.groupTypeEnable.value = false;
      state.groupType.value = '无';
    } else {
      state.groupTypeEnable.value = true;

      if ((qty + shortQualifiedController.text.toDoubleTry()) >
          inspectionQuantityController.text.toDoubleTry()) {
        //如果不合格数量加短码超过了上限，不合格数量等于检验数量-短码

        unqualifiedQualifiedController.text =
            (inspectionQuantityController.text.toDoubleTry() -
                    shortQualifiedController.text.toDoubleTry())
                .toStringAsFixed(2);
      }
    }

    qualifiedController.text =
        (inspectionQuantityController.text.toDoubleTry() -
                unqualifiedQualifiedController.text.toDoubleTry() -
                shortQualifiedController.text.toDoubleTry())
            .toStringAsFixed(2);
  }

  //输入短码
  inputShort(double qty) {
    if (unqualifiedQualifiedController.text.toDoubleTry() <= 0 &&
        shortQualifiedController.text.toDoubleTry() <= 0) {
      //如果没有不合格数量或短码，没有受理单位
      state.groupTypeEnable.value = false;
      state.groupType.value = '无';
    } else {
      state.groupTypeEnable.value = true;

      if ((qty + unqualifiedQualifiedController.text.toDoubleTry()) >
          inspectionQuantityController.text.toDoubleTry()) {
        //如果不合格数量加短码超过了上限，不合格数量等于检验数量-不合格

        shortQualifiedController.text =
            (inspectionQuantityController.text.toDoubleTry() -
                    unqualifiedQualifiedController.text.toDoubleTry())
                .toStringAsFixed(2);
      }
    }

    qualifiedController.text =
        (inspectionQuantityController.text.toDoubleTry() -
                unqualifiedQualifiedController.text.toDoubleTry() -
                shortQualifiedController.text.toDoubleTry())
            .toStringAsFixed(2);
  }

  //确定提交品检
  submitInspection(
    String inspectionType,
    String type,
    String groupType, {
    required Function(String)? success,
  }) {
    //有异常信息走OA
    if (inspectionQuantityController.text.toDoubleTry() > 0 &&
            unqualifiedQualifiedController.text.toDoubleTry() > 0 ||
        shortQualifiedController.text.toDoubleTry() > 0) {

      if(state.fromInspectionType=='1'){  //品检单列表走异常
        submitInspectionToOAFromList(inspectionType, type, groupType, success: (s) {
          success!.call(s);
        });
      }else{  //暂收单详情走异常
        submitInspectionToOAFromDetail(inspectionType, type, groupType, success: (s) {
          success!.call(s);
        });
      }
    } else {

      if(state.fromInspectionType == '1'){
        createInspectionFromList(inspectionType, type, success: (s) {
          success!.call(s);
        });
      }else{
        createInspectionFromDetail(inspectionType, type, success: (s) {
          success!.call(s);
        });
      }
    }
  }

  //有不合格数量或短码走OA
  submitInspectionToOAFromList(
    String inspectionType,
    String type,
    String groupType, {
    required Function(String)? success,
  }) {
    var name = state.inspectionsListData[0].materialDescription?.split(',')[0];
    for (var c in state.inspectionsListData) {
      name = ('${name!},');
      name = name + (c.characteristicValue ?? '');
    }

    var upInspectionType = '';
    var upType = '';
    var upGroupType = '';
    var upSubmitGroupType = '';

    if (state.inspectionTypeEnable.value) {
      upInspectionType = inspectionType;
    } else {
      upInspectionType = state.inspectionType.value;
    }

    if (state.typeEnable.value) {
      upType = type;
    } else {
      upType = state.type.value;
    }

    if (state.groupTypeEnable.value) {
      upGroupType = groupType;
    } else {
      upGroupType = state.groupType.value;
    }

    switch (upGroupType) {
      case '无':
        upSubmitGroupType = '';
        break;
      case '面部采购课':
        upSubmitGroupType = '3078';
        break;
      case '底部采购课':
        upSubmitGroupType = '3079';
        break;
      case '采购中心':
        upSubmitGroupType = '3075';
        break;
    }

    if (upInspectionType == '无') {
      showSnackBar(message: '请选择抽检方式');
      return;
    }
    if (upType == '无') {
      showSnackBar(message: '请选择类别');
      return;
    }
    if (waitInspectionQuantityController.text.toDoubleTry() <= 0) {
      showSnackBar(message: '抽检数量不能为零');
      return;
    }
    if (unqualifiedQualifiedController.text.toDoubleTry() > 0 ||
        shortQualifiedController.text.toDoubleTry() > 0) {
      if (upSubmitGroupType.isEmpty) {
        showSnackBar(message: '有不合格或短码，请选择受理单位');
        return;
      }
    }
    if (waitInspectionQuantityController.text.toDoubleTry() == 0 ||
        waitInspectionQuantityController.text.toDoubleTry() >
            inspectionQuantityController.text.toDoubleTry()) {
      if (upSubmitGroupType.isEmpty) {
        showSnackBar(message: '抽检数量必须大于0且不能大于检验数量');
        return;
      }
    }

    logger.f(
        'exceptionDescriptionController:${exceptionDescriptionController.text.isEmpty}');
    logger.f(
        'processingMethodController:${processingMethodController.text.isEmpty}');

    if (unqualifiedQualifiedController.text.toDoubleTry() > 0 &&
        (exceptionDescriptionController.text.isEmpty ||
            processingMethodController.text.isEmpty)) {
      showSnackBar(message: '请输入异常说明和处理方法');
      return;
    }
    if (shortQualifiedController.text.toDoubleTry() > 0 &&
        (exceptionDescriptionController.text.isEmpty ||
            processingMethodController.text.isEmpty)) {
      showSnackBar(message: '请输入异常说明和处理方法');
      return;
    }
    if ((unqualifiedQualifiedController.text.toDoubleTry() > 0 ||
            shortQualifiedController.text.toDoubleTry() > 0) &&
        reviewerController.text.isEmpty) {
      showSnackBar(message: '有不合格或短码件,审核人不能为空');
      return;
    }

    httpPost(
      method: webApiAbnormalMaterialQuality,
      loading: 'quality_inspection_submit_abnormal'.tr,
      body: {
        'ApplicantNumber': getUserInfo()!.number,
        //申报人工号
        'StorageDate': getDateYMD(),
        //入库日期
        'DeclarationDate': getDateYMD(),
        //申报日期
        'FactoryModel': state.inspectionsListData[0].factoryType,
        //工厂型体
        'DistributiveModel': state.inspectionsListData[0].distributiveForm,
        //分配型体
        'MaterialName': name,
        //物料名称
        'MaterialCode': state.inspectionsListData[0].materialCode,
        //物料编码
        'ExceptionDescription': exceptionDescriptionController.text,
        //异常说明
        'ExceptionType': upType,
        //异常类别
        'ProcessingMethod': processingMethodController.text,
        //处理方法
        'Reviewer': reviewerController.text,
        //审核人
        'AcceptanceUnit': upSubmitGroupType,
        //受理单位
        'InspectionQuantity': inspectionQuantityController.text,
        //检验数量
        'ShortCodesNumber': shortQualifiedController.text,
        //短码数量
        'InspectionUnit': state.inspectionsListData[0].commonUnits,
        //报检单位
        'Photos': [
          for (var pic in state.picture)
            if (pic.typeAdd != '0') {'Photo': pic.photo}
        ],
        //图片
        'SupplierNumber': state.inspectionsListData[0].supplierNumber
        //供应商编号
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.toCreateOrderMes = response.message ?? '';
        createInspectionFromList(upInspectionType, upType, success: (s) {
          success!.call(s);
        });
      } else {
        errorDialog(
            content: response.message ?? 'quality_inspection_submit_failed'.tr);
      }
    });
  }

  //创建品检单  (品检单列表)
  createInspectionFromList(
    String upInspectionType,
    String upType, {
    required Function(String)? success,
  }) {
    var countQuality = 0.0; //合格数量
    var countUnQuality = 0.0; //不合格数量
    var countShortQuality = 0.0; //短码
    var countWaitQuality =
        waitInspectionQuantityController.text.toDoubleTry(); //抽检数量
    var countInspectionQuality =
        inspectionQuantityController.text.toDoubleTry(); //检验数量

    if (upInspectionType == '抽检') {
      countShortQuality = (shortQualifiedController.text.toDoubleTry() /
              waitInspectionQuantityController.text.toDoubleTry()) *
          inspectionQuantityController.text.toDoubleTry();

      countUnQuality = (unqualifiedQualifiedController.text.toDoubleTry() /
              waitInspectionQuantityController.text.toDoubleTry()) *
          inspectionQuantityController.text.toDoubleTry();

      countQuality = (inspectionQuantityController.text.toDoubleTry() -
              countShortQuality -
              countUnQuality)
          .toStringAsFixed(2)
          .toDoubleTry();
    } else {
      countShortQuality = shortQualifiedController.text.toDoubleTry();
      countUnQuality = unqualifiedQualifiedController.text.toDoubleTry();
      countQuality = qualifiedController.text.toDoubleTry();
    }

    for (var data in state.inspectionsListData) {
      //初始化合格数
      data.qualifiedQuantity = '0';
    }

    if (countQuality > 0) {
      //合格数>0  分配合格数
      for (var data in state.inspectionsListData) {
        //合格数量大于检验数量
        if (countQuality >= data.inspectionQuantity.toDoubleTry()) {
          //合格数量=检验数量
          data.qualifiedQuantity = data.inspectionQuantity;

          //剩余合格数量=总合格数量-检验数量
          countQuality = countQuality - data.inspectionQuantity.toDoubleTry();
        } else {
          //合格数量=剩余可分配合格数量
          if (countQuality > 0) {
            data.qualifiedQuantity = countQuality.toStringAsFixed(2);
            countQuality = 0.0;
          }
        }
      }
    } else {
      for (var data in state.inspectionsListData) {
        data.qualifiedQuantity = '0';
      }
    }

    //不合格数>0  分配不合格数
    if (countUnQuality > 0) {
      for (var data in state.inspectionsListData) {
        //可分配数量=送货数量-合格数量
        var lastQty = data.inspectionQuantity.toDoubleTry() -
            data.qualifiedQuantity.toDoubleTry() -
            data.shortCodesNumber.toDoubleTry();
        if (lastQty > 0) {
          //可分配数量大于0 说明可以进行不合格数量分配
          if (countUnQuality >= lastQty) {
            //不合格数量大于可分配数量
            //不合格数量=可分配数量
            data.unqualifiedQuantity = lastQty.toStringAsFixed(2);
            //剩余不合格数量=不合格总数-剩余可分配数量
            countUnQuality = countUnQuality - lastQty;
          }
        } else {
          if (countUnQuality > 0) {
            data.unqualifiedQuantity = countUnQuality.toStringAsFixed(2);
            countUnQuality = 0.0;
          }
        }
      }
    } else {
      for (var data in state.inspectionsListData) {
        //不合格数量小于等于0  等于全部合格
        data.unqualifiedQuantity = '0';
      }
    }

    if (countShortQuality > 0) {
      //短码数量大于0 说明可以分配短码
      for (var data in state.inspectionsListData) {
        //剩余可分配数量=送货数量-合格数量-不合格数量

        var lastQty = data.inspectionQuantity.toDoubleTry() -
            data.qualifiedQuantity.toDoubleTry() -
            data.unqualifiedQuantity.toDoubleTry();

        //剩余可分配>0 可以分配短码
        if (lastQty > 0) {
          //短码数量大于剩余可分配数量
          if (countShortQuality >= lastQty) {
            //本行短码数量=剩余可分配数量
            data.shortCodesNumber = lastQty.toStringAsFixed(2);
            //剩余短码数量=总短码数量-剩余可分配数量
            countShortQuality = countShortQuality - lastQty;
          } else {
            //短码数量=剩余短码数量
            if (countShortQuality > 0) {
              data.shortCodesNumber = countShortQuality.toStringAsFixed(2);
              countShortQuality = 0;
            }
          }
        } else {
          for (var data in state.inspectionsListData) {
            data.shortCodesNumber = '0';
          }
        }
      }
    }

    //抽检数量大于0
    if (countWaitQuality > 0) {
      for (var data in state.inspectionsListData) {
        //抽检数 大于 带过来的抽检数
        if (countWaitQuality >= data.samplingQuantity.toDoubleTry()) {
          //抽检数量 == 抽检数量
          data.samplingQuantity = data.samplingQuantity;

          //剩余抽检数量=总抽检数量-抽检数量
          countWaitQuality =
              countWaitQuality - data.samplingQuantity.toDoubleTry();
        } else {
          //抽检数量=剩余抽检数量
          data.samplingQuantity = countWaitQuality.toStringAsFixed(2);
        }
      }
    }

    //检验数量大于0
    if (countInspectionQuality > 0) {
      for (var data in state.inspectionsListData) {
        if (countInspectionQuality >= data.inspectionQuantity.toDoubleTry()) {
          //检验数量 == 检验数量
          data.inspectionQuantity = data.inspectionQuantity;

          //剩余检验数量=总检验数量-检验数量
          countInspectionQuality =
              countInspectionQuality - data.inspectionQuantity.toDoubleTry();
        } else {
          //检验数量=剩余检验数量
          data.inspectionQuantity = countInspectionQuality.toStringAsFixed(2);
        }
      }
    }

    var reason = '';
    reason = exceptionDescriptionController.text;
    if (unqualifiedQualifiedController.text.toDoubleTry() > 0) {
      reason = '$reason,不合格数量：${unqualifiedQualifiedController.text}';
    }
    if (shortQualifiedController.text.toDoubleTry() > 0) {
      reason = '$reason,短码数量：${shortQualifiedController.text}';
    }
    reason = '$reason,${processingMethodController.text}';

    httpPost(
      method: webApiCreateInspection,
      loading: 'quality_inspection_create_inspection'.tr,
      body: {
        'MES_IdS': getUserInfo()!.userID,
        'MES_Heads': [
          {
            'CompanyCode': state.inspectionsListData[0].companyCode,
            'Creator': '',
            'Factory': state.inspectionsListData[0].factoryNumber,
            'IsConcessive': state.compromise.value ? 'X' : '',
            'ModifiedBy': getUserInfo()!.number,
            'Remarks': state.inspectionsListData[0].remarks,
            'SourceOrderType': state.inspectionsListData[0].sourceOrderType,
            'SupplierAccountNumber':
                state.inspectionsListData[0].supplierNumber,
            'DeletedBy': '',
            'InspectionOrderNo': state.inspectionsListData[0].inspectionOrderNo,
          }
        ],
        'MES_Items': [
          for (var item in state.inspectionsListData)
            {
              'BasicQuantity': '',
              'BasicUnit': '',
              'Coefficient': '',
              'CommonUnits': '',
              'DistributiveForm': '',
              'FactoryType': '',
              'InspectionMethod': upInspectionType,
              'InspectionQuantity': item.inspectionQuantity,
              'MaterialCode': '',
              'PlanLineNumber': '',
              'PurchaseDocumentItemNumber': '',
              'PurchaseVoucherNo': '',
              'QualifiedQuantity': item.qualifiedQuantity,
              'Remarks': '',
              'SalesAndDistributionVoucherNumber': '',
              'SamplingQuantity': item.samplingQuantity,
              'SamplingRatio': '0.0',
              'ShortCodesNumber': item.shortCodesNumber,
              'StorageQuantity': '',
              'TemporaryCollectionBankNo': item.temporaryCollectionBankNo,
              'TemporaryReceiptNo': item.temporaryNo, //暂收单号
              'UnqualifiedQuantity': item.unqualifiedQuantity,
              'DeleteReason': '',
              'DeletedBy': '',
              'InspectionLineNumber': item.inspectionLineNumber,
              'InspectionOrderNo': item.inspectionOrderNo,
            }
        ],
        'MES_Items2': [
          for (var item in state.inspectionsListData)
            {
              'UnqualifiedGroup': upType,
              'UnqualifiedReason': reason,
              'SourceNumber': state.toCreateOrderMes,
              'AvailAbility': availabilityController.text,
              'UnqualifiedType': '0'
            }
        ],
        'MES_Items3': [
          for (var item in state.inspectionColorList)
            {
              'Batch': item.batch,
              'ColorSeparationQuantity': item.qty,
              'Creator': getUserInfo()!.number,
              'PurchaseVoucherNo': '',
              'PurchaseDocumentItemNumber': '',
              'SalesAndDistributionVoucherNumber': '',
              'FactoryType': '',
              'MaterialCode': '',
              'BasicUnit': '',
              'BasicQuantity': '',
              'Coefficient': '',
              'CommonUnits': '',
            }
        ],
        'MES_Items4': [],
        'MES_Items5': [],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success!
            .call(response.message ?? 'quality_inspection_create_success'.tr);
      } else {
        errorDialog(
            content: response.message ?? 'quality_inspection_create_fail'.tr);
      }
    });
  }

  //根据工号获取人员信息
  searchPeople(String number) {
    if (number.isNotEmpty && number.length == 6) {
      httpGet(
        method: webApiGetEmpAndLiableByEmpCode,
        loading: 'device_maintenance_personnel_information'.tr,
        params: {
          'EmpCode': number,
        },
      ).then((response) {
        if (response.resultCode == resultSuccess) {
          state.peoPleInfo.value = PeopleMessageInfo.fromJson(response.data);
          reviewerController.text = state.peoPleInfo.value.liableEmpCode ?? '';
        } else {
          errorDialog(content: response.message);
        }
      });
    }
  }


  //品检单列表
  getData(jsonDat) {
    List<dynamic> jsonData = jsonDecode(jsonDat);

    state.inspectionsListData =
        jsonData.map((item) => QualityInspectionInfo.fromJson(item)).toList();

    var qty = 0.0;

    var name = <String>[];
    for (var c in state.inspectionsListData) {
      qty = qty + c.inspectionQuantity.toDoubleTry();
      if (!name.contains(c.materialCode)) {
        name.add(c.materialCode.toString());
      }
    }
    qualifiedController.text = qty.toShowString(); //合格数量
    inspectionQuantityController.text = qty.toShowString(); //检验数量
    waitInspectionQuantityController.text = qty.toShowString(); //待检验数量

    state.isSameCode = name.length == 1; //是否同物料
    state.isShowTips.value = name.length>1; //多种物料的时候提示
    if (state.inspectionsListData[0].colorSeparation == 'X') {
      state.inspectionType.value = '全检';
      state.inspectionTypeEnable.value = false; //检验方式不可点击
      state.inspectionEnable.value = false; //检验数量不可点击
      state.waitInputInspectionEnable.value = false; //抽检数量不可点击
      state.hadSplit = true;
      state.typeEnable.value = true;
      state.groupTypeEnable.value = false;
    }

    //如果是不同物料，无法填写不合格数
    if (!state.isSameCode) {
      state.unqualifiedQuantityEnable.value = false;
      state.abnormalExplanationEnable.value = false;
      state.processingMethodEnable.value = false;
    }

    //是否显示分色按钮
    state.showColor.value = (state.isSameCode && state.hadSplit);
    state.showAllBtn.value = !state.isSameCode;
    state.shortQuantityEnable.value = state.isSameCode;

    //跑马物料无法操作
    if (state.inspectionsListData[0].isCodeRunningMaterial == 'X') {
      state.inspectionEnable.value = false;
      state.unqualifiedQuantityEnable.value = false;
      state.shortQuantityEnable.value = false;
    }
  }

  getTemporary(String jsonDat) {
    state.detailInfo = TemporaryOrderDetailInfo.fromJson(jsonDecode(jsonDat));

    logger.f('打印带过来的数据：${state.detailInfo!.toJson()}');

    var name = <String>[]; //子物料名称
    var mainName = <String>[]; //主物料名称
    var waitQty = 0.0; //待检数量

    state.detailInfo!.receipt?.where((data) => data.isSelected.value == true).toList().forEach((info) {
      waitQty = waitQty + (info.quantityTemporarilyReceived! - info.inspectionQuantity!);
      name.add(info.materialCode!);
      mainName.add(info.mainMaterialCode!);
    });

    if (name.length > 1 && mainName.length > 1) {
      state.isSameCode = false;
      state.shortQuantityEnable.value = false;
      state.isShowTips.value = true; //多种物料的时候提示
    }else{
      state.shortQuantityEnable.value = true;
      state.isShowTips.value = false;
    }

    inspectionQuantityController.text = waitQty.toStringAsFixed(2);
    waitInspectionQuantityController.text = waitQty.toStringAsFixed(2);
    qualifiedController.text = waitQty.toStringAsFixed(2);


    if((state.detailInfo!.receipt?[0].colorSeparation) == 'X'){

      state.inspectionType.value = '全检';
      state.inspectionTypeEnable.value = false; //检验方式不可点击
      state.inspectionEnable.value = false; //检验数量不可点击
      state.waitInputInspectionEnable.value = false; //抽检数量不可点击
      state.hadSplit = true;

    }

    //如果是不同物料，无法填写不合格数
    if (!state.isSameCode) {
      state.inspectionEnable.value = false;  //检验数量不可更改
      state.abnormalExplanationEnable.value = false;  //异常说明
      state.processingMethodEnable.value = false;  //处理方法
      state.showAllBtn.value = true;
    }

    if(state.isSameCode && state.hadSplit) state.showColor.value = true;  //是否显示分色按钮

  }

  //有不合格数量或短码走OA
  submitInspectionToOAFromDetail(
      String inspectionType,
      String type,
      String groupType, {
        required Function(String)? success,
      }) {
    var name = state.inspectionsListData[0].materialDescription?.split(',')[0];
    for (var c in state.inspectionsListData) {
      name = ('${name!},');
      name = name + (c.characteristicValue ?? '');
    }

    var upInspectionType = '';
    var upType = '';
    var upGroupType = '';
    var upSubmitGroupType = '';

    if (state.inspectionTypeEnable.value) {
      upInspectionType = inspectionType;
    } else {
      upInspectionType = state.inspectionType.value;
    }

    if (state.typeEnable.value) {
      upType = type;
    } else {
      upType = state.type.value;
    }

    if (state.groupTypeEnable.value) {
      upGroupType = groupType;
    } else {
      upGroupType = state.groupType.value;
    }

    switch (upGroupType) {
      case '无':
        upSubmitGroupType = '';
        break;
      case '面部采购课':
        upSubmitGroupType = '3078';
        break;
      case '底部采购课':
        upSubmitGroupType = '3079';
        break;
      case '采购中心':
        upSubmitGroupType = '3075';
        break;
    }

    if (upInspectionType == '无') {
      showSnackBar(message: '请选择抽检方式');
      return;
    }
    if (upType == '无') {
      showSnackBar(message: '请选择类别');
      return;
    }
    if (waitInspectionQuantityController.text.toDoubleTry() <= 0) {
      showSnackBar(message: '抽检数量不能为零');
      return;
    }
    if (unqualifiedQualifiedController.text.toDoubleTry() > 0 ||
        shortQualifiedController.text.toDoubleTry() > 0) {
      if (upSubmitGroupType.isEmpty) {
        showSnackBar(message: '有不合格或短码，请选择受理单位');
        return;
      }
    }
    if (waitInspectionQuantityController.text.toDoubleTry() == 0 ||
        waitInspectionQuantityController.text.toDoubleTry() >
            inspectionQuantityController.text.toDoubleTry()) {
      if (upSubmitGroupType.isEmpty) {
        showSnackBar(message: '抽检数量必须大于0且不能大于检验数量');
        return;
      }
    }

    logger.f(
        'exceptionDescriptionController:${exceptionDescriptionController.text.isEmpty}');
    logger.f(
        'processingMethodController:${processingMethodController.text.isEmpty}');

    if (unqualifiedQualifiedController.text.toDoubleTry() > 0 &&
        (exceptionDescriptionController.text.isEmpty ||
            processingMethodController.text.isEmpty)) {
      showSnackBar(message: '请输入异常说明和处理方法');
      return;
    }
    if (shortQualifiedController.text.toDoubleTry() > 0 &&
        (exceptionDescriptionController.text.isEmpty ||
            processingMethodController.text.isEmpty)) {
      showSnackBar(message: '请输入异常说明和处理方法');
      return;
    }
    if ((unqualifiedQualifiedController.text.toDoubleTry() > 0 ||
        shortQualifiedController.text.toDoubleTry() > 0) &&
        reviewerController.text.isEmpty) {
      showSnackBar(message: '有不合格或短码件,审核人不能为空');
      return;
    }

    httpPost(
      method: webApiAbnormalMaterialQuality,
      loading: 'quality_inspection_submit_abnormal'.tr,
      body: {
        'ApplicantNumber': getUserInfo()!.number,
        //申报人工号
        'StorageDate': getDateYMD(),
        //入库日期
        'DeclarationDate': getDateYMD(),
        //申报日期
        'FactoryModel': state.detailInfo!.receipt?.where((data)=>data.isSelected!.value==true).toList()[0].factoryModel,
        //工厂型体
        'DistributiveModel': state.detailInfo!.receipt?.where((data)=>data.isSelected!.value==true).toList()[0].distributiveModel,
        //分配型体
        'MaterialName': state.detailInfo!.receipt?.where((data)=>data.isSelected!.value==true).toList()[0].materialName,
        //物料名称
        'MaterialCode': state.detailInfo!.receipt?.where((data)=>data.isSelected!.value==true).toList()[0].materialCode,
        //物料编码
        'ExceptionDescription': exceptionDescriptionController.text,
        //异常说明
        'ExceptionType': upType,
        //异常类别
        'ProcessingMethod': processingMethodController.text,
        //处理方法
        'Reviewer': reviewerController.text,
        //审核人
        'AcceptanceUnit': upSubmitGroupType,
        //受理单位
        'InspectionQuantity': inspectionQuantityController.text,
        //检验数量
        'ShortCodesNumber': shortQualifiedController.text,
        //短码数量
        'InspectionUnit': state.detailInfo!.receipt?.where((data)=>data.isSelected!.value==true).toList()[0].commonUnits,
        //报检单位
        'Photos': [
          for (var pic in state.picture)
            if (pic.typeAdd != '0') {'Photo': pic.photo}
        ],
        //图片
        'SupplierNumber': state.detailInfo!.supplierNumber
        //供应商编号
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.toCreateOrderMes = response.message ?? '';
        createInspectionFromDetail(upInspectionType, upType, success: (s) {
          success!.call(s);
        });
      } else {
        errorDialog(
            content: response.message ?? 'quality_inspection_submit_failed'.tr);
      }
    });
  }

  //创建品检单  (品检单列表)
  createInspectionFromDetail(
      String upInspectionType,
      String upType, {
        required Function(String)? success,
      }) {
    var countQuality = 0.0; //合格数量
    var countUnQuality = 0.0; //不合格数量
    var countShortQuality = 0.0; //短码
    var countWaitQuality = waitInspectionQuantityController.text.toDoubleTry(); //抽检数量
    var countInspectionQuality = inspectionQuantityController.text.toDoubleTry(); //检验数量

    if (upInspectionType == '抽检') {
      countShortQuality = (shortQualifiedController.text.toDoubleTry() /
          waitInspectionQuantityController.text.toDoubleTry()) *
          inspectionQuantityController.text.toDoubleTry();

      countUnQuality = (unqualifiedQualifiedController.text.toDoubleTry() /
          waitInspectionQuantityController.text.toDoubleTry()) *
          inspectionQuantityController.text.toDoubleTry();

      countQuality = (inspectionQuantityController.text.toDoubleTry() -
          countShortQuality -
          countUnQuality)
          .toStringAsFixed(2)
          .toDoubleTry();
    } else {
      countShortQuality = shortQualifiedController.text.toDoubleTry();
      countUnQuality = unqualifiedQualifiedController.text.toDoubleTry();
      countQuality = qualifiedController.text.toDoubleTry();
    }

    var detailList = state.detailInfo!.receipt!.where((data)=>data.isSelected!.value == true);

    for (var data in detailList) {
      //初始化合格数
      data.qualifiedQuantity = 0;
    }

    if (countQuality > 0) {
      //合格数>0  分配合格数
      for (var data in detailList) {
        //合格数量大于检验数量
        if (countQuality >= data.quantityTemporarilyReceived!) {
          //合格数量=检验数量
          data.qualifiedQuantity = data.quantityTemporarilyReceived;

          //剩余合格数量=总合格数量-检验数量
          countQuality = countQuality - data.quantityTemporarilyReceived!;
        } else {
          //合格数量=剩余可分配合格数量
          if (countQuality > 0) {
            data.qualifiedQuantity = countQuality;
            countQuality = 0.0;
          }
        }
      }
    } else {
      for (var data in detailList) {
        data.qualifiedQuantity = 0;
      }
    }

    //不合格数>0  分配不合格数
    if (countUnQuality > 0) {
      for (var data in detailList) {
        //可分配数量=送货数量-合格数量
        var lastQty = data.quantityTemporarilyReceived! -
            data.qualifiedQuantity! -
            data.missingQuantity!;
        if (lastQty > 0) {
          //可分配数量大于0 说明可以进行不合格数量分配
          if (countUnQuality >= lastQty) {
            //不合格数量大于可分配数量
            //不合格数量=可分配数量
            data.unqualifiedQuantity = lastQty;
            //剩余不合格数量=不合格总数-剩余可分配数量
            countUnQuality = countUnQuality - lastQty;
          }
        } else {
          if (countUnQuality > 0) {
            data.unqualifiedQuantity = countUnQuality;
            countUnQuality = 0.0;
          }
        }
      }
    } else {
      for (var data in detailList) {
        //不合格数量小于等于0  等于全部合格
        data.unqualifiedQuantity = 0;
      }
    }

    if (countShortQuality > 0) {
      //短码数量大于0 说明可以分配短码
      for (var data in detailList) {
        //剩余可分配数量=送货数量-合格数量-不合格数量

        var lastQty = data.quantityTemporarilyReceived! -
            data.qualifiedQuantity!-
            data.unqualifiedQuantity!;

        //剩余可分配>0 可以分配短码
        if (lastQty > 0) {
          //短码刷量大于剩余可分配数量
          if (countShortQuality >= lastQty) {
            //本行短码数量=剩余可分配数量
            data.missingQuantity = lastQty;
            //剩余短码数量=总短码数量-剩余可分配数量
            countShortQuality = countShortQuality - lastQty;
          } else {
            //短码数量=剩余短码数量
            if (countShortQuality > 0) {
              data.missingQuantity = countShortQuality;
              countShortQuality = 0;
            }
          }
        } else {
          for (var data in detailList) {
            data.missingQuantity = 0;
          }
        }
      }
    }

    //抽检数量大于0
    if (countWaitQuality > 0) {
      for (var data in detailList) {
        //抽检数 大于 带过来的抽检数
        if (countWaitQuality >= data.inspectionQuantity!) {
          //抽检数量 == 抽检数量
          data.samplingQuantity = data.inspectionQuantity;

          //剩余抽检数量=总抽检数量-抽检数量
          countWaitQuality =
              countWaitQuality - data.inspectionQuantity!;
        } else {
          //抽检数量=剩余抽检数量
          data.samplingQuantity = countWaitQuality;
        }
      }
    }

    //检验数量大于0
    if (countInspectionQuality > 0) {
      for (var data in detailList) {
        if (countInspectionQuality >= data.inspectionQuantity!) {
          //检验数量 == 检验数量
          data.inspectionQuantity = data.inspectionQuantity;

          //剩余检验数量=总检验数量-检验数量
          countInspectionQuality =
              countInspectionQuality - data.inspectionQuantity!;
        } else {
          //检验数量=剩余检验数量
          data.inspectionQuantity = countInspectionQuality;
        }
      }
    }

    var reason = '';
    reason = exceptionDescriptionController.text;
    if (unqualifiedQualifiedController.text.toDoubleTry() > 0) {
      reason = '$reason,不合格数量：${unqualifiedQualifiedController.text}';
    }
    if (shortQualifiedController.text.toDoubleTry() > 0) {
      reason = '$reason,短码数量：${shortQualifiedController.text}';
    }
    reason = '$reason,${processingMethodController.text}';

    httpPost(
      method: webApiCreateInspection,
      loading: 'quality_inspection_create_inspection'.tr,
      body: {
        'MES_IdS': getUserInfo()!.userID,
        'MES_Heads': [
          {
            'CompanyCode':state.detailInfo!.companyNumber,
            'Creator': getUserInfo()!.number,
            'Factory': state.detailInfo!.factoryNumber,
            'IsConcessive': state.compromise.value ? 'X' : '',
            'ModifiedBy': '',
            'Remarks': state.detailInfo!.remarks,
            'SourceOrderType': state.detailInfo!.sourceType,
            'SupplierAccountNumber': state.detailInfo!.supplierNumber,
            'DeletedBy': '',
            'InspectionOrderNo': '',
          }
        ],
        'MES_Items': [
          for (var item in detailList)
            {
              'BasicQuantity': item.basicQuantity,
              'BasicUnit': item.basicUnits,
              'Coefficient': item.coefficient,
              'CommonUnits': item.commonUnits,
              'DistributiveForm': item.distributiveModel,
              'FactoryType': item.factoryModel,
              'InspectionMethod': upInspectionType,
              'InspectionQuantity': item.quantityTemporarilyReceived,
              'MaterialCode': item.materialCode,
              'PlanLineNumber': item.planningLineNumber,
              'PurchaseDocumentItemNumber': item.purchaseOrderLineNumber,
              'PurchaseVoucherNo': item.contractNo,
              'QualifiedQuantity': item.qualifiedQuantity,
              'Remarks': item.remarks,
              'SalesAndDistributionVoucherNumber': item.productionNumber,
              'SamplingQuantity': item.quantityTemporarilyReceived,
              'SamplingRatio': '',
              'ShortCodesNumber': item.missingQuantity,
              'StorageQuantity': '',
              'TemporaryCollectionBankNo': item.temporaryLineNumber,
              'TemporaryReceiptNo': state.detailInfo!.temporaryNumber, //暂收单号
              'UnqualifiedQuantity': item.unqualifiedQuantity,
              'DeleteReason': '',
              'DeletedBy': '',
              'InspectionLineNumber': '',
              'InspectionOrderNo':'',
            }
        ],
        'MES_Items2': [
          for (var item in detailList)
            {
              'UnqualifiedGroup': upType,
              'UnqualifiedReason': reason,
              'SourceNumber': state.toCreateOrderMes,
              'AvailAbility': availabilityController.text,
              'UnqualifiedType': '0'
            }
        ],
        'MES_Items3': [
          for (var item in state.inspectionColorList)
            {
              'Batch': item.batch,
              'ColorSeparationQuantity': item.qty,
              'Creator': getUserInfo()!.number,
              'PurchaseVoucherNo': detailList.toList()[0].contractNo,
              'PurchaseDocumentItemNumber': detailList.toList()[0].purchaseOrderLineNumber,
              'SalesAndDistributionVoucherNumber': detailList.toList()[0].productionNumber,
              'FactoryType': detailList.toList()[0].factoryModel,
              'MaterialCode': detailList.toList()[0].materialCode,
              'BasicUnit': detailList.toList()[0].basicUnits,
              'BasicQuantity': detailList.toList()[0].basicQuantity,
              'Coefficient': detailList.toList()[0].coefficient,
              'CommonUnits': detailList.toList()[0].commonUnits,
            }
        ],
        'MES_Items4': [],
        'MES_Items5': [],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success!
            .call(response.message ?? 'quality_inspection_create_success'.tr);
      } else {
        errorDialog(
            content: response.message ?? 'quality_inspection_create_fail'.tr);
      }
    });
  }
}
