import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/leave_visit_record.dart';
import 'package:jd_flutter/bean/http/response/photo_bean.dart';
import 'package:jd_flutter/bean/http/response/search_people_info.dart';
import 'package:jd_flutter/bean/http/response/visit_add_record_info.dart';
import 'package:jd_flutter/bean/http/response/visit_data_list_info.dart';
import 'package:jd_flutter/bean/http/response/visit_get_detail_info.dart';
import 'package:jd_flutter/bean/http/response/visit_last_record.dart';
import 'package:jd_flutter/bean/http/response/visit_photo_bean.dart';
import 'package:jd_flutter/bean/http/response/visit_place_bean.dart';
import 'package:jd_flutter/fun/management/visit_register/visit_register_add_view.dart';
import 'package:jd_flutter/fun/management/visit_register/visit_register_detail_view.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';

import 'visit_register_state.dart';

class VisitRegisterLogic extends GetxController {
  //逻辑代码
  final VisitRegisterState state = VisitRegisterState();

  var textIdCard = TextEditingController(); //身份证
  var textPersonName = TextEditingController(); //姓名
  var textPhone = TextEditingController(); //电话
  var textUnit = TextEditingController(); //单位
  var textVisitors = TextEditingController(); //来访人数
  var textIntervieweeName = TextEditingController(); //被访人姓名
  var textVisitedDept = TextEditingController(); //被访部门
  var textVisitorPlace = TextEditingController(); //活动区域
  var textVisitNumber = TextEditingController(); //来访证编号
  var textReason = TextEditingController(); //来访理由
  var textWheel = TextEditingController(); //轮区
  var textExternal = TextEditingController(); //外部
  var textTail = TextEditingController(); //尾部
  var textCab = TextEditingController(); //驾驶室
  var textLandingGear = TextEditingController(); //起落架
  var textRemark = TextEditingController(); //备注
  var textCarNo = TextEditingController(); //车牌号码
  var textSecurity = TextEditingController(); //车牌号码

  var textSearchName = TextEditingController();
  var textSearchPhone = TextEditingController();
  var textSearchCar = TextEditingController();
  var textSearchIdCard = TextEditingController();
  var textSearch = TextEditingController();

  //部门选择器的控制器
  var pickerControllerDepartment = OptionsPickerController(
    PickerType.mesDepartment,
    saveKey: '${RouteConfig.dailyReport.name}${PickerType.mesDepartment}',
  );

  //日期选择器的控制器
  var pickerControllerStartDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.property.name}${PickerType.startDate}',
  );

  //日期选择器的控制器
  var pickerControllerEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.property.name}${PickerType.endDate}',
  );

  void refreshGetVisitList(
      {String name = "",
      String iDCard = "",
      String interviewee = "",
      String intervieweeName = "",
      String securityStaff = "",
      String startTime = "",
      String endTime = "",
      String leave = "",
      String phone = "",
      String carNo = "",
      String credentials = "",
      Function()? refresh}) {
    httpPost(
        method: webApiGetVisitDtBySqlWhere,
        loading: 'visit_getting_visitor_list'.tr,
        body: {
          'Name': name,
          'IDCard': iDCard,
          'VisitedFactory': userInfo?.organizeID,
          'Interviewee': interviewee,
          'IntervieweeName': intervieweeName,
          'SecurityStaff': securityStaff,
          'StartTime': startTime,
          'EndTime': endTime,
          'Leave': leave,
          'Phone': phone,
          'CarNo': carNo,
          'Credentials': credentials,
        }).then((response) {
      if (response.resultCode == resultSuccess) {
        state.lastAdd = false;
        var jsonList = jsonDecode(response.data);
        var list = <VisitDataListInfo>[];
        for (var i = 0; i < jsonList.length; ++i) {
          list.add(VisitDataListInfo.fromJson(jsonList[i]));
        }
        state.dataList.value = list;
      } else {
        state.dataList.value = [];
        errorDialog(content: response.message);
      }
      refresh?.call();
    });
  }

  void getVisitLastList({Function()? refresh}) {
    httpPost(
        method: webApiGetVisitInfoByJsonStr,
        loading: 'visit_latest_visit_history'.tr,
        body: VisitLastRecord(
          name: textSearchName.text,
          phone: textSearchPhone.text,
          idCard: textSearchCar.text,
          carNo: textSearchIdCard.text,
        )).then((response) {
      if (response.resultCode == resultSuccess) {
        var jsonList = jsonDecode(response.data);
        var list = <VisitDataListInfo>[];
        for (var i = 0; i < jsonList.length; ++i) {
          list.add(VisitDataListInfo.fromJson(jsonList[i]));
        }
        state.dataList.clear();
        state.dataList.value = list;
      } else {
        state.dataList.value = [];
        errorDialog(content: response.message);
      }
      refresh?.call();
    });
  }

  void getInviteCode() {
    httpGet(
      method: webApiGetInviteCode,
      loading: 'visit_obtaining_visitor_id'.tr,
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.visitCode.value = response.message!;
        logger.d(state.visitCode.value);
      } else {
        state.visitCode.value = response.message!;
        errorDialog(content: response.message);
      }
      refreshGetVisitList(leave: "0", startTime: "", endTime: "");
    });
  }

  void getVisitorDetailInfo(String interId, bool isLeave) {
    httpGet(
        method: webApiGetVisitorInfo,
        loading: 'visit_obtaining_visit_details'.tr,
        params: {
          'InterID': interId,
        }).then((response) {
      if (response.resultCode == resultSuccess) {
        if (isLeave) {
          //去点击离场
          state.dataDetail =
              VisitGetDetailInfo.fromJson(jsonDecode(response.data));
          Get.to(() => const VisitRegisterDetailPage());
        } else {
          //带数据的新增

          if (state.lastAdd) {
            logger.d('带数据的新增');
            state.dataDetail =
                VisitGetDetailInfo.fromJson(jsonDecode(response.data));
            textIdCard.text = state.dataDetail.iDCard ?? '';
            textPersonName.text = state.dataDetail.name ?? '';
            textPhone.text = state.dataDetail.phone ?? '';
            textUnit.text = state.dataDetail.unit ?? '';
            textSecurity.text = userInfo?.name??'';
            state.upAddDetail.value.examineID = userInfo?.empID.toString();
            state.upAddDetail.value.securityStaff =
                userInfo?.empID.toString();
          } else {
            logger.d('走详情界面');
            state.dataDetail =
                VisitGetDetailInfo.fromJson(jsonDecode(response.data));
            state.cardPicture.value = state.dataDetail.cardPic ?? '';
            state.facePicture.value = state.dataDetail.peoPic ?? '';
            state.upLeavePicture.clear();
            state.upLeavePicture.add(VisitPhotoBean(photo: "", typeAdd: "0"));
          }
          state.upAddDetail.value.examineID = userInfo?.empID.toString();
          state.upAddDetail.value.securityStaff =
              userInfo?.empID.toString();

          Get.to(() => const VisitRegisterAddPage());
        }
      } else {
        //没有找到记录，直接到新增
        Get.to(() => const VisitRegisterAddPage());
      }
    });
  }

  void addPicture(String bitmapBase64, bool isCome) {
    if (isCome) {
      logger.d('添加来访图片');
      state.upComePicture
          .add(VisitPhotoBean(photo: bitmapBase64, typeAdd: "1"));
    } else {
      logger.d('添加离场图片');
      state.upLeavePicture
          .add(VisitPhotoBean(photo: bitmapBase64, typeAdd: "1"));
    }
  }

  void updateLeaveFVisit() {
    var body = <PhotoBean>[];
    for (var value1 in state.upLeavePicture) {
      body.add(PhotoBean(photo: value1.photo));
    }
    httpPost(
            method: webApiUpdateLeaveFVisit,
            loading: 'visit_submitting_departure_information'.tr,
            body: LeaveVisitRecord(
                interID: state.dataDetail.interID,
                leaveTime: getDateYMD(),
                leavePics: body))
        .then((response) {
      if (response.resultCode == resultSuccess) {
        refreshGetVisitList();
        successDialog(content: response.message, back: () => Get.back());
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  void addVisitRecord() {
    var body = <PhotoBean>[];
    for (var value1 in state.upLeavePicture) {
      body.add(PhotoBean(photo: value1.photo));
    }
    state.upAddDetail.value.securityStaff = userInfo?.empID.toString();
    state.upAddDetail.value.visitPics = body;

    logger.d(state.upAddDetail.value.toJson());

    if (!isIDCorrect(state.upAddDetail.value.iDCard.toString())) {
      errorDialog(content: 'visit_search_idCard_error'.tr);
      return;
    }
    if (state.upAddDetail.value.name == null) {
      errorDialog(content: 'visit_search_name_empty'.tr);
      return;
    }
    if (!validatePhoneNumber(state.upAddDetail.value.phone.toString())) {
      //手机
      errorDialog(content: 'visit_search_phone_empty'.tr);
      return;
    }
    if (state.upAddDetail.value.unit == null) {
      //单位
      errorDialog(content: 'visit_search_unit_empty'.tr);
      return;
    }
    if (state.upAddDetail.value.visitorNum == null) {
      //人数
      errorDialog(content: 'visit_search_visitor_number_empty'.tr);
      return;
    }
    if (state.upAddDetail.value.intervieweeName == null) {
      //被访人
      errorDialog(content: 'visit_search_personnel_empty'.tr);
      return;
    }
    if (state.upAddDetail.value.actionZone == null) {
      //活动区域
      errorDialog(content: 'visit_search_area_empty'.tr);
      return;
    }
    if (state.upAddDetail.value.credentials == null) {
      //来访证
      errorDialog(content: 'visit_search_credentials_empty'.tr);
      return;
    }

    if (state.upAddDetail.value.subjectMatter == null) {
      //来访事由
      errorDialog(content: 'visit_search_subjectMatter_empty'.tr);
      return;
    }

    if (state.upAddDetail.value.carType!.isNotEmpty == true) {
      //如果车辆类型不为空
      if (state.upAddDetail.value.carNo!.isEmpty == true) {
        errorDialog(content: 'visit_search_car_number_empty'.tr);
        return;
      }
      if (state.carType.value == '拖车') {
        if (state.checkCarBottomValue.value == false) {
          //如果没勾选起来
          if (state.upAddDetail.value.carBottom?.isEmpty == true) {
            //轮区
            errorDialog(content: 'visit_search_input_wheel_error'.tr);
            return;
          }
        }

        if (!state.checkCarExteriorValue.value) {
          if (state.upAddDetail.value.carExterior?.isEmpty == true) {
            //外部
            errorDialog(content: 'visit_search_input_external_error'.tr);
            return;
          }
        }
        if (!state.checkCarRearValue.value) {
          if (state.upAddDetail.value.carRear?.isEmpty == true) {
            //尾部
            errorDialog(content: 'visit_search_input_rear_error'.tr);
            return;
          }
        }

        if (!state.checkCarCabValue.value) {
          if (state.upAddDetail.value.carCab?.isEmpty == true) {
            //驾驶室
            errorDialog(content: 'visit_search_input_cab_error'.tr);
            return;
          }
        }
        if (!state.checkCarLandingGearValue.value) {
          if (state.upAddDetail.value.landingGear?.isEmpty == true) {
            //起落架
            errorDialog(content: 'visit_search_input_landingGear_error'.tr);
            return;
          }
        }
      }
    }
    httpPost(
            method: webApiInsertIntoFVisit,
            loading: 'visit_submitting_new_records'.tr,
            body: state.upAddDetail.value)
        .then((response) {
      if (response.resultCode == resultSuccess) {
        successDialog(
            content: response.message,
            back: () {
                  refreshGetVisitList();
                  Get.back();
                });
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  void getToAddPage() {
    //跳转到新增的时候需要建立的数据
    state.upAddDetail.value = VisitAddRecordInfo(
        visitedFactory: userInfo?.organizeID.toString(),
        securityStaff: userInfo?.empID.toString(),
        securityStaffName: userInfo?.name,
        examineID: userInfo?.empID.toString(),
        dateTime: getCurrentTime());
    state.upComePicture.add(VisitPhotoBean(photo: "", typeAdd: "0"));
    textIdCard.clear();
    textPersonName.clear();
    textPhone.clear();
    textUnit.clear();
    textVisitors.clear();
    textIntervieweeName.clear();
    textVisitedDept.clear();
    textVisitorPlace.clear();
    textVisitNumber.clear();
    textReason.clear();
    textWheel.clear();
    textExternal.clear();
    textTail.clear();
    textCab.clear();
    textLandingGear.clear();
    textRemark.clear();
    textCarNo.clear();
    Get.to(() => const VisitRegisterAddPage());
  }

  Future<void> searchPeople() async {
    if (textSearch.text.isNotEmpty) {
      //获取人员信息
      var searchPeopleCallback = await httpGet(
        loading: 'visit_obtaining_employee_information'.tr,
        method: webApiGetEmpByField,
        params: {
          'FieldValue': textSearch.text,
          'FieldName': 'FName',
        },
      );
      if (searchPeopleCallback.resultCode == resultSuccess) {
        //创建部门列表数据
        List<SearchPeopleInfo> list = [];
        for (var item in jsonDecode(searchPeopleCallback.data)) {
          list.add(SearchPeopleInfo.fromJson(item));
        }
        //创建选择器控制器
        var controller = FixedExtentScrollController(
          initialItem: 0,
        );
        //创建取消按钮
        var cancel = TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text(
            'dialog_default_cancel'.tr,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 20,
            ),
          ),
        );
        //创建确认按钮
        var confirm = TextButton(
          onPressed: () {
            Get.back();
            state.upAddDetail.value.interviewee =
                list[controller.selectedItem].empID.toString();
            state.upAddDetail.value.intervieweeName =
                list[controller.selectedItem].empName.toString();
            state.upAddDetail.value.visitedDept =
                list[controller.selectedItem].empDepartName.toString();

            textIntervieweeName.text =
                list[controller.selectedItem].empName.toString();
            textVisitedDept.text =
                list[controller.selectedItem].empDepartName.toString();
            textSearch.clear();
            logger.d("访问部门：${state.upAddDetail.value.visitedDept}");
          },
          child: Text(
            'dialog_default_confirm'.tr,
            style: const TextStyle(
              color: Colors.blueAccent,
              fontSize: 20,
            ),
          ),
        );
        //创建底部弹窗
        showPopup(Column(
          children: <Widget>[
            //选择器顶部按钮
            Container(
              height: 45,
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [cancel, confirm],
              ),
            ),
            //选择器主体
            Expanded(
              child: getCupertinoPicker(
                items: list.map((data) {
                  return Center(
                      child: Text("${data.empName!}_${data.empDepartName!}"));
                }).toList(),
                controller: controller,
              ),
            )
          ],
        ));
      } else {
        errorDialog(content: searchPeopleCallback.message);
      }
    } else {
      errorDialog(content: 'visit_search_mes_empty'.tr);
    }
  }

  void visitorPlace() {
    httpGet(
        method: webApiGetReceiveVisitorPlace,
        loading: 'visit_getting_activity_area'.tr,
        params: {"FPlaceName": ""}).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <VisitPlaceBean>[
          for (var i = 0; i < response.data.length; ++i)
            VisitPlaceBean.fromJson(response.data[i])
        ];
        //创建选择器控制器
        var controller = FixedExtentScrollController(
          initialItem: 0,
        );
        //创建取消按钮
        var cancel = TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text(
            'dialog_default_cancel'.tr,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 20,
            ),
          ),
        );
        //创建确认按钮
        var confirm = TextButton(
          onPressed: () {
            Get.back();
            if (list[controller.selectedItem].fInterID == 5) {
              //其他区域
              state.canInput.value = true;
              textVisitorPlace.text = "";
              state.upAddDetail.value.actionZoneID =
                  list[controller.selectedItem].fInterID.toString();
            } else {
              state.canInput.value = false;
              state.upAddDetail.value.actionZone =
                  list[controller.selectedItem].fPlaceName;
              state.upAddDetail.value.actionZoneID =
                  list[controller.selectedItem].fInterID.toString();
              textVisitorPlace.text = list[controller.selectedItem].fPlaceName!;
            }
          },
          child: Text(
            'dialog_default_confirm'.tr,
            style: const TextStyle(
              color: Colors.blueAccent,
              fontSize: 20,
            ),
          ),
        );
        //创建底部弹窗
        showPopup(Column(
          children: <Widget>[
            //选择器顶部按钮
            Container(
              height: 45,
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [cancel, confirm],
              ),
            ),
            //选择器主体
            Expanded(
              child: getCupertinoPicker(
                items: list.map((data) {
                  return Center(child: Text(data.fPlaceName!));
                }).toList(),
                controller: controller,
              ),
            )
          ],
        ));
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  bool isIDCorrect(String id) {
    final RegExp idExp = RegExp(
        r'^[1-9]\d{5}(18|19|20)?\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])\d{3}(\d|[Xx])$');
    return idExp.hasMatch(id);
  }

  bool validatePhoneNumber(String phoneNumber) {
    final RegExp phoneExp = RegExp(
      r'^(?:[+0]9)?[0-9]{10,12}$',
    );
    return phoneExp.hasMatch(phoneNumber);
  }
}
