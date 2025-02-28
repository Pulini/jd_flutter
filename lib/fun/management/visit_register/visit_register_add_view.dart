import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/visit_add_record_info.dart';
import 'package:jd_flutter/bean/http/response/visit_photo_bean.dart';
import 'package:jd_flutter/fun/management/visit_register/visit_register_logic.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class VisitRegisterAddPage extends StatefulWidget {
  const VisitRegisterAddPage({super.key});

  //来访登记详情页 新增

  @override
  State<VisitRegisterAddPage> createState() => _VisitRegisterAddPageState();
}

class _VisitRegisterAddPageState extends State<VisitRegisterAddPage> {
  final logic = Get.find<VisitRegisterLogic>();
  final state = Get.find<VisitRegisterLogic>().state;
  var hintStyle = const TextStyle(color: Colors.black);
  var textStyle = TextStyle(color: Colors.blue.shade900);

  var line = const Divider(
    height: 10,
  );
  var inputNumber = [
    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
  ];

  //  搜索弹窗
  searchDialog({
    required String title,
    required String hintTitle,
    Function()? confirm,
    Function()? cancel,
  }) {
    Get.dialog(
      PopScope(
        //拦截返回键
        canPop: false,
        child: AlertDialog(
          title: Text(title, style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
          content: _inputText(hintTitle, '', [], controller: logic.textSearch),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Get.back();
                confirm?.call();
              },
              child: Text('dialog_default_confirm'.tr),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                cancel?.call();
              },
              child: Text(
                'dialog_default_cancel'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false, //拦截dialog外部点击
    );
  }

  _text(String title, String? text1) {
    return Row(
      children: [
        Container(
          width: 90,
          margin: const EdgeInsets.only(right: 10),
          alignment: Alignment.centerRight,
          child: Text(title, style: hintStyle),
        ),
        Expanded(
          child: Text(text1 ?? '', style: textStyle),
        ),
      ],
    );
  }

  _subTitle(String title) {
    return Text(
      //子标题
      textAlign: TextAlign.center,
      title,
      style: const TextStyle(
          color: Colors.green, fontWeight: FontWeight.w900, fontSize: 18),
    );
  }

  _inputText(
      String hint,
      String? text1,
      List<TextInputFormatter>? inputType, {
        TextEditingController? controller,
        bool search = false,
        bool canEnable = true,
        Function()? click,
        Function(String)? onChange,
      }) {
    return Row(
      children: [
        Container(
          width: 90,
          height: 40,
          margin: const EdgeInsets.only(right: 10),
          alignment: Alignment.centerRight,
          child: Text(hint, style: hintStyle),
        ),
        Expanded(
            child: CupertinoTextField(
              inputFormatters: inputType,
              enabled: canEnable,
              onChanged: (str) => onChange?.call(str),
              controller: controller ?? TextEditingController(text: text1 ?? ""),
            )),
        search
            ? IconButton(
          icon: const Icon(Icons.search, color: Colors.grey),
          onPressed: () {
            click?.call();
          },
        )
            : const SizedBox(
          height: 1,
        )
      ],
    );
  }

  _peoplePhotos() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              takePhoto((f) {
                state.upAddDetail.value.cardPic = f.toBase64(); //身份证照片
              });
            },
            child: Column(
              children: [
                state.cardPicture.value.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    state.cardPicture.value,
                    gaplessPlayback: true,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Icon(
                  Icons.add_a_photo_outlined,
                  color: Colors.blueAccent,
                  size: 150,
                ),
                Text('visit_details_card_picture'.tr),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              takePhoto((f) {
                state.upAddDetail.value.peoPic = f.toBase64();
              });
            },
            child: Column(
              children: [
                state.facePicture.value.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    state.facePicture.value,
                    gaplessPlayback: true,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Icon(
                  Icons.add_a_photo_outlined,
                  color: Colors.blueAccent,
                  size: 150,
                ),
                Text('visit_details_face_picture'.tr),
              ],
            ),
          )
        ],
      )),
    );
  }

  _checkCar() {
    return Obx(() => Row(children: [
      Expanded(
        flex: 1,
        child: ListTile(
          title: const Text('无车'),
          leading: Radio(
            value: "",
            groupValue: state.carType.value,
            onChanged: (v) {
              state.carType.value = v!;
              state.showWeight.value = false;
              state.showCarNumber.value = false;
            },
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: ListTile(
          title: const Text('小轿车'),
          leading: Radio(
            value: "小桥车",
            groupValue: state.carType.value,
            onChanged: (v) {
              state.carType.value = v!;
              state.showWeight.value = false;
              state.showCarNumber.value = true;
            },
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: ListTile(
          title: const Text('货车'),
          leading: Radio(
            value: "货车",
            groupValue: state.carType.value,
            onChanged: (v) {
              state.carType.value = v!;
              state.showWeight.value = false;
              state.showCarNumber.value = true;
            },
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: ListTile(
          title: const Text('拖车'),
          leading: Radio(
            value: "拖车",
            groupValue: state.carType.value,
            onChanged: (v) {
              state.carType.value = v!;
              state.showWeight.value = true;
              state.showCarNumber.value = true;
            },
          ),
        ),
      )
    ]));
  }

  _checkDoor() {
    return Obx(() => Row(children: [
      Expanded(
        flex: 1,
        child: ListTile(
          title: const Text('1号门'),
          leading: Radio(
            value: "1号门",
            groupValue: state.doorType.value,
            onChanged: (v) {
              state.doorType.value = v!;
            },
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: ListTile(
          title: const Text('2号门'),
          leading: Radio(
            value: "2号门",
            groupValue: state.doorType.value,
            onChanged: (v) {
              state.doorType.value = v!;
            },
          ),
        ),
      ),
    ]));
  }

  _showCarNumber() {
    return Obx(
          () => state.showCarNumber.value
          ? Column(
        children: [
          _inputText('visit_details_license_plate_number'.tr, '', [],
              controller: logic.textCarNo,
              onChange: (s) => {
                state.upAddDetail.value.carNo = s,
              }),
          line,
        ],
      )
          : Container(),
    );
  }

  _showInspectList() {
    return Obx(
          () => state.showWeight.value
          ? Column(
        children: [
          _inputText(
              'visit_details_wheel_area_inspection'.tr, '', inputNumber,
              controller: logic.textWheel,
              onChange: (s) => {
                state.upAddDetail.value.carBottom = s,
              }),
          line,
          _inputText(
              'visit_details_external_inspection'.tr, '', inputNumber,
              controller: logic.textExternal,
              onChange: (s) => {
                state.upAddDetail.value.carExterior = s,
              }),
          line,
          _inputText(
              'visit_details_Driver_cab_inspection'.tr, '', inputNumber,
              controller: logic.textCab,
              onChange: (s) => {
                state.upAddDetail.value.carCab = s,
              }),
          line,
          _inputText(
              'visit_details_Driver_cab_inspection'.tr, '', inputNumber,
              controller: logic.textTail,
              onChange: (s) => {
                state.upAddDetail.value.carRear = s,
              }),
          line,
          _inputText('visit_details_landing_gear'.tr, '', inputNumber,
              controller: logic.textLandingGear,
              onChange: (s) => {
                state.upAddDetail.value.landingGear = s,
              }),
          line,
          _inputText('visit_details_remark'.tr, '', inputNumber,
              controller: logic.textRemark,
              onChange: (s) => {
                state.upAddDetail.value.note = s,
              }),
          line,
        ],
      )
          : Container(),
    );
  }

  _comePhotoItem(VisitPhotoBean data, int index) {
    return Container(
        margin: const EdgeInsets.only(left: 20),
        child: GestureDetector(
          onTap: () {
            if (index == 5) {
              informationDialog(
                  content: 'visit_details_unable_to_add_more_images'.tr);
            } else {
              if (data.typeAdd == "0") {
                takePhoto((f) {
                  logic.addPicture(f.toBase64(), true);
                });
              }
            }
          },
          child: data.typeAdd != '0'
              ? ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(
              base64Decode(data.photo!),
              gaplessPlayback: true,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          )
              : const Icon(
            Icons.add_a_photo_outlined,
            color: Colors.blueAccent,
            size: 50,
          ),
        ));
  }

  comeListView() {
    return Obx(() => Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          //背景
          borderRadius: const BorderRadius.all(Radius.circular(4.0)),
          //设置四周边框
          border: Border.all(width: 1, color: Colors.blue),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          scrollDirection: Axis.horizontal,
          itemCount: state.upComePicture.length,
          itemBuilder: (BuildContext context, int index) =>
              _comePhotoItem(state.upComePicture.toList()[index], index),
        )));
  }

  _clickButton() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: () {
              logic.addVisitRecord();
            },
            child: const Text(
              "新增",
              style: TextStyle(color: Colors.white),
            )),
      ),
    );
  }

  _textList(VisitAddRecordInfo data) {
    return [
      _inputText('visit_details_id_card'.tr, data.iDCard, inputNumber,
          controller: logic.textIdCard,
          onChange: (s) => {
            state.upAddDetail.value.iDCard = s,
          }),
      line,
      _inputText('visit_details_name'.tr, data.name, [],
          controller: logic.textPersonName,
          onChange: (s) => {
            state.upAddDetail.value.name = s,
          }),
      line,
      _inputText('visit_details_phone'.tr, data.phone, inputNumber,
          controller: logic.textPhone,
          onChange: (s) => {
            state.upAddDetail.value.phone = s,
          }),
      line,
      _inputText('visit_details_unit'.tr, data.unit, [],
          controller: logic.textUnit,
          onChange: (s) => {
            state.upAddDetail.value.unit = s,
          }),
      line,
      _inputText(
          'visit_details_number_of_visitors'.tr, data.visitorNum, inputNumber,
          controller: logic.textVisitors,
          onChange: (s) => {
            state.upAddDetail.value.visitorNum = s,
          }),
      line,
      _text('visit_details_factory_area'.tr, getUserInfo()!.factory),
      line,
      _inputText(
          'visit_details_name_of_interviewee'.tr, data.intervieweeName, [],
          search: true,
          canEnable: false,
          controller: logic.textIntervieweeName,
          click: () {
            searchDialog(title: 'visit_details_to_search'.tr, hintTitle: 'visit_details_name_of_interviewee'.tr,confirm: () {
              logic.searchPeople();
            });
          },
          onChange: (s) => {
            if (s.isNotEmpty) {state.searchMes = s}
          }),
      line,
      _inputText(
          'visit_details_interviewed_department'.tr, data.visitedDept, [],
          controller: logic.textVisitedDept,
          onChange: (s) => {
            state.upAddDetail.value.visitedDept = s,
          }),
      line,
      Obx(() => Row(
        //监听活动区域是否可以输入
        children: [
          Container(
            width: 90,
            margin: const EdgeInsets.only(right: 10),
            alignment: Alignment.centerRight,
            child:
            Text('visit_details_zone_of_action'.tr, style: hintStyle),
          ),
          Expanded(
              child: CupertinoTextField(
                enabled: state.canInput.value,
                controller: logic.textVisitorPlace,
              )),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.grey),
            onPressed: () {
              logic.visitorPlace();
            },
          )
        ],
      )),
      line,
      _inputText('visit_details_visitor_id_number'.tr, data.credentials, [],
          controller: logic.textVisitNumber,
          onChange: (s) => {
            state.upAddDetail.value.credentials = s,
          }),
      line,
      _inputText('visit_details_reason_for_visit'.tr, data.subjectMatter, [],
          controller: logic.textReason,
          onChange: (s) => {
            state.upAddDetail.value.subjectMatter = s,
          }),
      _peoplePhotos(),
      _subTitle('visit_details_vehicle_information'.tr), //车辆信息
      _checkCar(), //选择车辆
      _checkDoor(), //选择门
      _showCarNumber(), //选择是否填车牌号
      _showInspectList(),
      _inputText('visit_details_bring_your_own_goods'.tr, data.ownGoods, [],
          onChange: (s) => {
            state.upAddDetail.value.ownGoods = s,
          }),
      line,
      _inputText('visit_details_on_duty_security_guard'.tr,
          data.securityStaffName, inputNumber,
          canEnable: false),
      const SizedBox(height: 10),
      _subTitle('visit_details_visits_photo'.tr), //来访照片
      const SizedBox(height: 10),
      comeListView(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('visit_details_new_visits'.tr),
        ),
        body: ListView(
          padding: const EdgeInsets.only(left: 20, right: 20),
          children: [
            const SizedBox(height: 10),
            ..._textList(state.upAddDetail.value), //详情内容
            _clickButton(),
          ],
        ),
      ),
    );
  }
}
