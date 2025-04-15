import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/device_list_info.dart';
import 'package:jd_flutter/fun/other/hydroelectric_excess/hydroelectric_excess_logic.dart';
import 'package:jd_flutter/fun/other/hydroelectric_excess/hydroelectric_excess_treat_list_view.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

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

  textField(
          {required TextEditingController controller,
          required String hint,
          required Function()? onClicked}) =>
      SizedBox(
        height: 40,
        child: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[300],
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Colors.transparent,
              ),
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: Colors.grey),
              onPressed: () {
                onClicked?.call();
              },
            ),
          ),
        ),
      );

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

  @override
  void initState() {
    pdaScanner(
      scan: (code) => {
        state.textThisTime.text = code,
        if (code.isNotEmpty)
          {
            state.stateToSearch.value = '0',
            state.searchRoom(DeviceListInfo(number: code), false)
          }
      },
    );
    super.initState();
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
                          child: textField(
                            controller: state.textNumber,
                            hint: 'hydroelectric_excess_room_number'.tr,
                            onClicked: () {
                              if (state.textNumber.text.isNotEmpty) {
                                state.searchRoom(
                                    DeviceListInfo(
                                        number: state.textNumber.text.toString()),
                                    false);
                              }
                            },
                          )),
                      Expanded(
                          flex: 1,
                          child: EditText(
                            hint: 'hydroelectric_this_copying_process'.tr,
                            onChanged: (v) => {
                              state.countMonth(v),
                            },
                            controller: state.textThisTime,
                          ))
                    ],
                  ),
                  _text('hydroelectric_device_name'.tr, state.dataDetail.value.name.toString()),
                  _text('hydroelectric_type'.tr, state.dataDetail.value.typeName.toString()),
                  _text(
                      'hydroelectric_organization_name'.tr, state.dataDetail.value.organizeName.toString()),
                  _text(
                      'hydroelectric_building_number'.tr, state.dataDetail.value.dormitoriesName.toString()),
                  _text('hydroelectric_room_number'.tr, state.dataDetail.value.roomNumber.toString()),
                  _text('hydroelectric_last_copying_time'.tr,
                      state.dataDetail.value.lastDateTime.toString()),
                  _text('hydroelectric_last_copying'.tr, state.dataDetail.value.lastDegree.toString()),
                  _text('hydroelectric_usage_this_month'.tr, state.thisMonthUse.value),
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
                                text: 'hydroelectric_scan_device_code'.tr,
                                click: () =>
                                    Get.to(() => const Scanner())?.then((v) {
                                  if (v != null) {
                                    state.searchRoom(
                                        DeviceListInfo(number: v), false);
                                  }
                                }),
                              ),
                            )),
                            Expanded(
                                child: SizedBox(
                              width: double.infinity,
                              child: CombinationButton(
                                combination: Combination.right,
                                text: 'hydroelectric_checked_list'.tr,
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
                          text: state.stateToSearch.value == '0' ? 'hydroelectric_submit'.tr : 'hydroelectric_change'.tr,
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

  @override
  void dispose() {
    Get.delete<HydroelectricExcessLogic>();
    super.dispose();
  }
}
