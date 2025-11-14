import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/property_detail_info.dart';
import 'package:jd_flutter/fun/management/property/property_logic.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class PropertyDetailPage extends StatefulWidget {
  const PropertyDetailPage({super.key});

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  final logic = Get.find<PropertyLogic>();
  final state = Get.find<PropertyLogic>().state;
  var hintStyle = const TextStyle(color: Colors.black);
  var textStyle = TextStyle(color: Colors.blue.shade900);

  Row _text(
    String hint,
    String? text1, {
    Function(String)? onChange,
  }) {
    return Row(
      children: [
        Container(
          width: 70,
          margin: const EdgeInsets.only(right: 10),
          alignment: Alignment.centerRight,
          child: Text(hint, style: hintStyle),
        ),
        Expanded(
          child: onChange != null && state.canModify
              ? CupertinoTextField(
                  enabled: state.canModify,
                  onChanged: (str) => onChange.call(str),
                  controller: TextEditingController(text: text1 ?? ''),
                )
              : Text(text1 ?? '', style: textStyle),
        ),
      ],
    );
  }

  void _timePick(DateTime? initialDate, Function(String) pickDate) {
    var now = DateTime.now();
    showDatePicker(
      locale: View.of(Get.overlayContext!).platformDispatcher.locale,
      context: Get.overlayContext!,
      initialDate: initialDate ?? now,
      firstDate: DateTime(now.year - 1, now.month, now.day),
      lastDate: DateTime(now.year, now.month, now.day + 7), //最大可选日期
    ).then((date) {
      if (date != null) {
        pickDate.call(getDateYMD(time: date));
      }
    });
  }

  Row _textDate(String hint, String? date, Function(String) time) {
    DateTime? dateTime;
    if (date?.isNotEmpty == true) dateTime = DateTime.parse(date ?? '');
    return Row(
      children: [
        Container(
          width: 70,
          margin: const EdgeInsets.only(right: 10),
          alignment: Alignment.centerRight,
          child: Text(hint, style: hintStyle),
        ),
        Expanded(
          child: state.canModify
              ? GestureDetector(
                  onTap: () => _timePick(dateTime, time),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    height: 35,
                    padding: const EdgeInsets.only(left: 5),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Text(
                      dateTime == null
                          ? 'property_select_time'.tr
                          : getDateYMD(time: dateTime),
                      style: TextStyle(
                        color: dateTime == null ? Colors.red : Colors.black,
                      ),
                    ),
                  ),
                )
              : Text(date ?? '', style: textStyle),
        ),
      ],
    );
  }

  Text _orderState(int processStatus) {
    String text;
    Color color;
    if (processStatus == 0) {
      //未审核
      text = 'property_detail_state1'.tr;
      color = Colors.orange;
    } else if (processStatus == 1) {
      //审核中
      text = 'property_detail_state2'.tr;
      color = Colors.blue;
    } else if (processStatus == 2) {
      //已审核
      text = 'property_detail_state3'.tr;
      color = Colors.green;
    } else {
      //工单异常
      text = 'property_detail_state4'.tr;
      color = Colors.red;
    }

    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  List<Widget> _textList(PropertyDetailInfo data) {
    var line = const Divider(
      height: 10,
    );
    return [
      _text('property_detail_hint1'.tr, data.sno),
      line,
      _text('property_detail_hint2'.tr, data.sapInvoiceNo),
      line,
      _text(
        'property_detail_hint3'.tr,
        data.number,
        onChange: (s) => data.number = s,
      ),
      line,
      _text(
        'property_detail_hint4'.tr,
        data.name,
        onChange: (s) => data.name = s,
      ),
      line,
      _text(
        'property_detail_hint5'.tr,
        data.model,
        onChange: (s) => data.model = s,
      ),
      line,
      _text('property_detail_hint6'.tr, data.typeName),
      line,
      _text('property_detail_hint7'.tr, data.qty.toShowString()),
      line,
      _text('property_detail_hint8'.tr, data.unit),
      line,
      _text(
        'property_detail_hint9'.tr,
        data.price.toShowString(),
        onChange: (s) => data.price = s.toDoubleTry(),
      ),
      line,
      _text(
        'property_detail_hint10'.tr,
        data.orgVal.toShowString(),
        onChange: (s) => data.orgVal = s.toDoubleTry(),
      ),
      line,
      _text('property_detail_hint11'.tr, data.vender),
      line,
      _text(
        'property_detail_hint12'.tr,
        data.manufacturer,
        onChange: (s) => data.manufacturer = s,
      ),
      line,
      _text('property_detail_hint13'.tr, data.produceDate),
      line,
      _textDate(
        'property_detail_hint14'.tr,
        data.buyDate,
        (date) => setState(() => data.buyDate = date),
      ),
      line,
      _text(
        'property_detail_hint15'.tr,
        data.guaranteePeriod,
        onChange: (s) => data.guaranteePeriod = s,
      ),
      line,
      _text(
        'property_detail_hint16'.tr,
        data.expectedLife.toString(),
        onChange: (s) => data.expectedLife = s.toIntTry(),
      ),
      line,
      Row(
        children: [
          Expanded(
            child: _text(
              'property_detail_hint17'.tr,
              data.participatorCode,
              onChange: (s) => logic.setParticipator(s),
            ),
          ),
          Obx(() => Container(
                width: state.participatorName.value.isEmpty
                    ? 0
                    : state.participatorName.value.length * 17,
                alignment: Alignment.centerRight,
                child: Text(state.participatorName.value),
              )),
        ],
      ),
      line,
      Row(
        children: [
          Expanded(
            child: _text(
              'property_detail_hint18'.tr,
              data.custodianCode,
              onChange: (s) => logic.setCustodian(s),
            ),
          ),
          Obx(() => Container(
                width: state.custodianName.value.isEmpty
                    ? 0
                    : state.custodianName.value.length * 17,
                alignment: Alignment.centerRight,
                child: Text(state.custodianName.value),
              )),
        ],
      ),
      line,
      Row(
        children: [
          Expanded(
            child: _text(
              'property_detail_hint19'.tr,
              data.liableEmpCode,
              onChange: (s) => logic.setLiable(s),
            ),
          ),
          Obx(() => Container(
                width: state.liableEmpName.value.isEmpty
                    ? 0
                    : state.liableEmpName.value.length * 17,
                alignment: Alignment.centerRight,
                child: Text(state.liableEmpName.value),
              )),
        ],
      ),
      line,
      _textDate(
        'property_detail_hint20'.tr,
        data.reviceDate,
        (date) => setState(() => data.reviceDate = date),
      ),
      line,
      _text('property_detail_hint21'.tr, data.deptName),
      line,
      _textDate(
        'property_detail_hint22'.tr,
        data.writeDate,
        (date) => setState(() => data.writeDate = date),
      ),
      line,
      _text(
        'property_detail_hint23'.tr,
        data.address,
        onChange: (s) => data.address = s,
      ),
      line,
      _text('property_detail_hint24'.tr, data.sapCgOrderNo),
    ];
  }

  Padding _remake() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 10,
      ),
      child: TextField(
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
            borderSide: BorderSide(
              color: Colors.grey,
              width: 2,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
            borderSide: BorderSide(
              color: Colors.blueAccent,
              width: 4,
            ),
          ),
          labelText: 'property_detail_hint25'.tr,
          hintText: 'property_detail_hint25'.tr,
        ),
        onChanged: (s) => state.detail.notes = s,
        maxLines: 5,
        controller: TextEditingController(text: state.detail.notes ?? ''),
      ),
    );
  }

  Padding _photos() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  if (state.canModify) {
                    takePhoto(callback: (f) {
                      state.assetPicture.value = f.toBase64();
                    });
                  }
                },
                child: Column(
                  children: [
                    state.assetPicture.value.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              base64Decode(state.assetPicture.value),
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
                    Text('property_detail_photo1'.tr),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (state.canModify) {
                    takePhoto(callback: (f) {
                      state.ratingPlatePicture.value = f.toBase64();
                    });
                  }
                },
                child: Column(
                  children: [
                    state.ratingPlatePicture.value.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              base64Decode(state.ratingPlatePicture.value),
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
                    Text('property_detail_photo2'.tr),
                  ],
                ),
              )
            ],
          )),
    );
  }

  List<dynamic> _affiliated(List<CardEntry> devices) {
    var list = [];
    for (var device in devices) {
      list.add(Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'property_detail_item_hint1'.tr,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    device.name ?? '',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'property_detail_hint7'.tr,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    device.qty.toShowString(),
                    style: TextStyle(
                      color: Colors.blue[900],
                    ),
                  ),
                ),
                Text(
                  'property_detail_hint9'.tr,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    device.price.toShowString(),
                    style: TextStyle(
                      color: Colors.blue[900],
                    ),
                  ),
                ),
                Text(
                  'property_detail_item_hint2'.tr,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    device.amount.toShowString(),
                    style: TextStyle(
                      color: Colors.blue[900],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text('property_detail_hint23'.tr),
                Expanded(
                  flex: 1,
                  child: Text(
                    device.place ?? '',
                    style: TextStyle(color: Colors.blue[900]),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('property_detail_hint25'.tr),
                Expanded(
                  flex: 1,
                  child: Text(
                    device.notes ?? '',
                    style: TextStyle(color: Colors.blue[900]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ));
    }
    return list;
  }

  void _sheet(BuildContext context, bool hasSubmit) {
    showSheet(
      context: context,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CombinationButton(
            text: 'property_bt_print'.tr,
            click: () {
              logger.d(state.detail.toJson());
            },
          ),
          CombinationButton(
            text: 'property_detail_bt_close'.tr,
            click: () => askDialog(
              content: 'property_detail_hint_close'.tr,
              confirm: () {
                Get.back();
                logic.propertyClose(state.detail.interID ?? -1);
              },
            ),
          ),
          CombinationButton(
            text: 'property_detail_bt_no_acceptance'.tr,
            backgroundColor: Colors.grey,
            click: () => askDialog(
              content: 'property_detail_hint_no_acceptance'.tr,
              confirm: () {
                Get.back();
                logic.skipAcceptance(state.detail.interID ?? -1);
              },
            ),
          ),
          if (hasSubmit)
            CombinationButton(
              text: 'property_detail_bt_submit'.tr,
              backgroundColor: Colors.green,
              click: () {
                if (logic.checkData()) {
                  askDialog(
                    content: 'property_detail_hint_submit'.tr,
                    confirm: () {
                      Get.back();
                      logic.updatePropertyInfo();
                    },
                  );
                }
              },
            ),
        ],
      ),
      scrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'property_detail_title'.tr,
      actions: [
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _sheet(context, state.detail.processStatus == 0),
        )
      ],
      body: ListView(
        padding: const EdgeInsets.only(left: 20, right: 20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_orderState(state.detail.processStatus!)],
          ),
          const SizedBox(height: 10),
          ..._textList(state.detail),
          _photos(),
          _remake(),
          if (state.detail.cardEntry?.isNotEmpty == true)
            ..._affiliated(state.detail.cardEntry!),
        ],
      ),
    );
  }
}
