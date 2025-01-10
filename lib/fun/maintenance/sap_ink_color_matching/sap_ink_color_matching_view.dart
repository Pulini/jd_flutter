import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_ink_color_match_info.dart';
import 'package:jd_flutter/fun/maintenance/sap_ink_color_matching/sap_ink_color_matching_dialog.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/switch_button_widget.dart';

import 'sap_ink_color_matching_logic.dart';
import 'sap_ink_color_matching_state.dart';

class SapInkColorMatchingPage extends StatefulWidget {
  const SapInkColorMatchingPage({super.key});

  @override
  State<SapInkColorMatchingPage> createState() =>
      _SapInkColorMatchingPageState();
}

class _SapInkColorMatchingPageState extends State<SapInkColorMatchingPage> {
  final SapInkColorMatchingLogic logic = Get.put(SapInkColorMatchingLogic());
  final SapInkColorMatchingState state =
      Get.find<SapInkColorMatchingLogic>().state;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ///日期选择器的控制器
  var dpcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.sapInkColorMatching.name}${PickerType.startDate}',
  );

  ///日期选择器的控制器
  var dpcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.sapInkColorMatching.name}${PickerType.endDate}',
  );
  var controller = TextEditingController(
    // text: 'PDW25308979-24',
  );

  _item(int index) {
    SapInkColorMatchOrderInfo data = state.orderList[index];
    return GestureDetector(
      onTap: () {
        if (data.materialList?.isNotEmpty == true) {
          logic.modifyOrder(index: index, refresh: () => _queryOrder(true));
        } else {
          showSnackBar(title: '错误', message: '该调色单没有调色信息！');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
        padding: const EdgeInsets.only(left: 7, top: 10, right: 7, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          expandedTextSpan(
                            flex: 3,
                            hint: '型体：',
                            text: data.typeBody ?? '',
                            textColor: Colors.green.shade700,
                          ),
                          expandedTextSpan(
                            flex: 3,
                            hint: '工厂：',
                            text: data.factoryName ?? '',
                            textColor: Colors.black87,
                            isBold: false,
                          ),
                          expandedTextSpan(
                            flex: 2,
                            hint: '调色单号：',
                            text: data.orderNumber ?? '',
                            textColor: Colors.green.shade700,
                            isBold: false,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          expandedTextSpan(
                            flex: 3,
                            hint: '油墨师：',
                            text: data.inkMaster ?? '',
                            textColor: Colors.black87,
                            isBold: false,
                          ),
                          expandedTextSpan(
                            flex: 3,
                            hint: '调色日期：',
                            text: data.mixDate ?? '',
                            textColor: Colors.black87,
                            isBold: false,
                          ),
                          expandedTextSpan(
                            flex: 2,
                            hint: '混合物重量：',
                            text: '${data.mixtureWeight.toMaxString()}千克',
                            textColor: Colors.black87,
                            isBold: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if ((data.trialQty ?? 0) == 0)
                  CombinationButton(
                    text: '试做完成',
                    click: () => trialFinishDialog(
                      typeBody: data.typeBody ?? '',
                      orderNumber: data.orderNumber ?? '',
                      mixWeight: data.mixtureWeight ?? 0,
                      refresh: () => _queryOrder(true),
                    ),
                  )
              ],
            ),
            if ((data.trialQty ?? 0) > 0) ...[
              const Divider(indent: 10, endIndent: 10),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    expandedTextSpan(
                      hint: '试做数量：',
                      text: '${data.trialQty.toMaxString()}双',
                      textColor: Colors.black87,
                      isBold: false,
                    ),
                    expandedTextSpan(
                      hint: '混合物试做后重量：',
                      text: '${data.mixtureTheoreticalWeight.toMaxString()}千克',
                      textColor: Colors.black87,
                      isBold: false,
                    ),
                    expandedTextSpan(
                      hint: '损耗：',
                      text: '${data.loss.toMaxString()}%',
                      textColor: Colors.black87,
                      isBold: false,
                    ),
                    expandedTextSpan(
                      hint: '单位用量：',
                      text: data.unitUsage.toMaxString(),
                      textColor: Colors.black87,
                      isBold: false,
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  _queryOrder(bool isRefresh) {
    logic.queryOrder(
      startDate: dpcStartDate.getDateFormatSapYMD(),
      endDate: dpcEndDate.getDateFormatSapYMD(),
      refresh: () {
        FocusScope.of(context).unfocus();
        if (!isRefresh) {
          Get.back();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      scaffoldKey: _scaffoldKey,
      actions: [
        Container(
          width: 300,
          margin: const EdgeInsets.all(5),
          height: 40,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(
                top: 0,
                bottom: 0,
                left: 15,
                right: 10,
              ),
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
              hintText: '型体',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: IconButton(
                  onPressed: () => controller.clear(),
                  icon: const Icon(
                    Icons.replay_circle_filled,
                    color: Colors.red,
                  )),
              suffixIcon: CombinationButton(
                text: '新增调色',
                click: () => logic.createMixOrder(
                  newTypeBody: controller.text,
                  refresh: () {
                    controller.clear();
                    FocusScope.of(context).unfocus();
                    _queryOrder(true);
                  },
                ),
              ),
            ),
          ),
        )
      ],
      queryWidgets: [
        EditText(
          hint: '请输入型体',
          onChanged: (v) => state.typeBody.value = v,
        ),
        DatePicker(pickerController: dpcStartDate),
        DatePicker(pickerController: dpcEndDate),
        Obx(() => SwitchButton(
              onChanged: (s) => state.idTested.value = s,
              name: '试做完成',
              value: state.idTested.value,
            ))
      ],
      query: () => _queryOrder(false),
      body: Obx(() => ListView.builder(
            itemCount: state.orderList.length,
            itemBuilder: (c, i) => _item(i),
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<SapInkColorMatchingLogic>();
    super.dispose();
  }
}
