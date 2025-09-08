import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/visit_get_detail_info.dart';
import 'package:jd_flutter/bean/http/response/visit_photo_bean.dart';
import 'package:jd_flutter/fun/management/visit_register/visit_register_logic.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class VisitRegisterDetailPage extends StatefulWidget {
  //来访登记详情页 离场
  const VisitRegisterDetailPage({super.key});

  @override
  State<VisitRegisterDetailPage> createState() =>
      _VisitRegisterDetailPageState();
}

class _VisitRegisterDetailPageState extends State<VisitRegisterDetailPage> {
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

  _peoplePhotos() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
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

  _inspectWeight(
    String title,
    String text,
    bool checkBool,
  ) {
    return Row(
      children: [
        Container(
          width: 30,
          margin: const EdgeInsets.only(right: 10),
          alignment: Alignment.centerRight,
          child: Checkbox(
            value: checkBool,
            onChanged: (bool? value) {},
          ),
        ),
        Expanded(
          child: _text(title, text),
        ),
      ],
    );
  }

  _inspectList(VisitGetDetailInfo data) {
    if (data.carType == "拖车") {
      return [
        _inspectWeight('visit_details_wheel_area_inspection'.tr,
            data.carBottom!, state.checkCarBottom),
        line,
        _inspectWeight('visit_details_external_inspection'.tr,
            data.carExterior!, state.checkCarExterior),
        line,
        _inspectWeight('visit_details_tail_inspection'.tr, data.carRear!,
            state.checkCarRear),
        line,
        _inspectWeight('visit_details_Driver_cab_inspection'.tr, data.carCab!,
            state.checkCarCab),
        line,
        _inspectWeight('visit_details_landing_gear'.tr, data.landingGear!,
            state.checkCarLandingGear),
        line,
        _text('visit_details_remark'.tr, data.note!),
        line,
      ];
    } else {
      return [
        const SizedBox(
          height: 1,
        )
      ];
    }
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
              logic.updateLeaveFVisit();
            },
            child: Text(
              'visit_departure'.tr,
              style: const TextStyle(color: Colors.white),
            )),
      ),
    );
  }

  _comePhotoItem(String? photoUrl) {
    return Container(
        margin: const EdgeInsets.only(left: 20),
        child: GestureDetector(
          child: photoUrl!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    photoUrl,
                    gaplessPlayback: true,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(
                  Icons.error_outline_outlined,
                  color: Colors.blueAccent,
                  size: 50,
                ),
        ));
  }

  _comeListView() {
    if (state.dataDetail.visitPics!.isNotEmpty) {
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
            itemCount: state.dataDetail.visitPics?.length,
            itemBuilder: (BuildContext context, int index) =>
                _comePhotoItem(state.dataDetail.visitPics?[index].photo!),
          )));
    } else {
      return const SizedBox(
        height: 1,
      );
    }
  }

  _leavePhotoItem(VisitPhotoBean data, int index) {
    return Container(
        margin: const EdgeInsets.only(left: 20),
        child: GestureDetector(
          onTap: () {
            if (index == 5) {
              msgDialog(content: 'visit_details_unable_to_add_more_images'.tr);
            } else {
              if (data.typeAdd == "0") {
                takePhoto(callback: (f) {
                  logic.addPicture(f.toBase64(), false);
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

  _leaveListView() {
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
          itemCount: state.upLeavePicture.length,
          itemBuilder: (BuildContext context, int index) =>
              _leavePhotoItem(state.upLeavePicture.toList()[index], index),
        )));
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

  _showCarList(VisitGetDetailInfo data) {
    if (data.carType!.isEmpty) {
      return [
        const SizedBox(
          height: 5,
        )
      ];
    } else {
      return [
        _text('visit_details_car_type'.tr, data.carType),
        line,
        _text('visit_details_license_plate_number'.tr, data.carNo),
        line
      ];
    }
  }

  _textList(VisitGetDetailInfo data) {
    //是离场
    return <Widget>[
      _text('visit_details_id_card'.tr, data.iDCard),
      line,
      _text('visit_details_name'.tr, data.name),
      line,
      _text('visit_details_phone'.tr, data.phone),
      line,
      _text('visit_details_unit'.tr, data.unit),
      line,
      _text('visit_details_number_of_visitors'.tr, data.visitorNum),
      line,
      _text('visit_details_factory_area'.tr, data.visitedFactory),
      line,
      _text('visit_details_name_of_interviewee'.tr, data.intervieweeName),
      line,
      _text('visit_details_interviewed_department'.tr, data.visitedDept),
      line,
      _text('visit_details_zone_of_action'.tr, data.actionZone),
      line,
      _text('visit_details_visitor_id_number'.tr, data.credentials),
      line,
      _text('visit_details_reason_for_visit'.tr, data.subjectMatter),
      line,
      if (state.cardPicture.value.isNotEmpty ||
          state.facePicture.value.isNotEmpty)
        _peoplePhotos(),
      if (data.carNo!.isNotEmpty) ...[
        const SizedBox(height: 10),
        line,
        _subTitle('visit_details_vehicle_information'.tr),
        const SizedBox(height: 10),
      ],
      Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            line,
            _subTitle('visit_details_vehicle_information'.tr),
          ],
        ),
      ),
      _text('visit_details_entrance_ate'.tr, data.gate),
      line,
      ..._showCarList(data),
      if (state.dataDetail.ownGoods!.isNotEmpty) ...[
        _text(
            'visit_details_bring_your_own_goods'.tr, state.dataDetail.ownGoods),
        line
      ],
      _text('visit_details_on_duty_security_guard'.tr,
          state.dataDetail.securityStaff),
      line,
      ..._inspectList(state.dataDetail),
      _subTitle('visit_details_departure_photos'.tr),
      const SizedBox(height: 10),
      state.dataDetail.visitPics!.isNotEmpty
          ? _subTitle('visit_details_visits_photo'.tr)
          : const SizedBox(height: 1),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'visit_document_details'.tr,
      body: ListView(
        padding: const EdgeInsets.only(left: 20, right: 20),
        children: [
          const SizedBox(height: 10),
          ..._textList(state.dataDetail), //详情内容
          _comeListView(),
          _leaveListView(),
          if (state.dataDetail.leaveTime!.isEmpty) _clickButton(),
        ],
      ),
    );
  }
}
