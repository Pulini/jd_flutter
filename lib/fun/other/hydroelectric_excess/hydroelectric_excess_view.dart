import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/other/hydroelectric_excess/hydroelectric_excess_logic.dart';
import 'package:jd_flutter/fun/other/hydroelectric_excess/hydroelectric_excess_treat_list_view.dart';
import '../../../constant.dart';
import '../../../widget/combination_button_widget.dart';
import '../../../widget/custom_widget.dart';
import '../../../widget/edit_text_widget.dart';

class HydroelectricExcessPage extends StatefulWidget {
  const HydroelectricExcessPage({super.key});

  @override
  State<HydroelectricExcessPage> createState() =>
      _HydroelectricExcessPageState();
}

class _HydroelectricExcessPageState extends State<HydroelectricExcessPage> {
  final logic = Get.put(HydroelectricExcessLogic());
  final state = Get.find<HydroelectricExcessLogic>().state;

  var hintStyle = const TextStyle(color: Colors.black);
  var textStyle = TextStyle(color: Colors.blue.shade900);


  _text(String title, String text1) {
    return Row(
      children: [
        Container(
          width: 90,
          height: 40,
          margin: const EdgeInsets.only(right: 10),
          alignment: Alignment.bottomRight,
          child: Text(title, style: hintStyle),
        ),
        Expanded(
          child: Container(
            width: 90,
            height: 40,
            margin: const EdgeInsets.only(right: 20),
            alignment: Alignment.bottomRight,
            child: Text(text1, style: textStyle),
          ),
        ),
      ],
    );
  }

  _methodChannel() {
    debugPrint('注册监听');
    const MethodChannel(channelScanFlutterToAndroid)
        .setMethodCallHandler((call) {
      switch (call.method) {
        case 'PdaScanner':
          {
            state.textThisTime.text = call.arguments.toString();
          }
          break;
      }
      return Future.value(call);
    });
  }

  @override
  void initState() {
    super.initState();
    _methodChannel();
  }

  @override
  void dispose(){
    Get.delete<HydroelectricExcessLogic>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: InkWell(
            child: const Icon(
              Icons.dehaze,
              size: 35,
              color: Colors.white,
            ),
            onTap: () => {state.clickShow()},
          ),
        )
      ],
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              Expanded(
                  child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: EditText(
                            hint: '房号'.tr,
                            onChanged: (v) => {
                              if (v.isEmpty) {state.clearData()}
                            },
                            controller: state.textNumber,
                          )),
                      Expanded(
                          flex: 1,
                          child: EditText(
                            hint: '本次抄度'.tr,
                            onChanged: (v) => {
                              state.countMonth(v),
                            },
                            controller: state.textThisTime,
                          ))
                    ],
                  ),
                  _text('设备名称:', state.dataDetail.value.name.toString()),
                  _text('类型:', state.dataDetail.value.typeName.toString()),
                  _text(
                      '组织名称:', state.dataDetail.value.organizeName.toString()),
                  _text(
                      '楼号:', state.dataDetail.value.dormitoriesName.toString()),
                  _text('房间编号:', state.dataDetail.value.roomNumber.toString()),
                  _text('上次抄度时间:',
                      state.dataDetail.value.lastDateTime.toString()),
                  _text('上次抄度:', state.dataDetail.value.lastDegree.toString()),
                  _text('本月使用量:', state.thisMonthUse.value),
                ],
              )),
              Column(
                children: [
                  Obx(() => Visibility(
                        visible: state.isShow.value,
                        child: Row(
                          children: [
                            Expanded(
                                child: SizedBox(
                              width: double.infinity,
                              child: CombinationButton(
                                combination: Combination.left,
                                text: '扫描设备码',
                                click: () => {
                                  //扫描二维码或者条形码
                                },
                              ),
                            )),
                            Expanded(
                                child: SizedBox(
                              width: double.infinity,
                              child: CombinationButton(
                                combination: Combination.right,
                                text: '待查列表',
                                click: () => {
                                  state.isShow.value = false,
                                  Get.to(() =>
                                      const HydroelectricExcessTreatListPage())
                                },
                              ),
                            ))
                          ],
                        ),
                      )),
                  Obx(() => SizedBox(
                        width: double.infinity,
                        child: CombinationButton(
                          text: state.stateToSearch.value == '0' ? '提交' : '修改',
                          click: () => {state.submit()},
                        ),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
