import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/part_production_dispatch_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/switch_button_widget.dart';

import 'part_production_dispatch_logic.dart';
import 'part_production_dispatch_state.dart';

class PartProductionDispatchPage extends StatefulWidget {
  const PartProductionDispatchPage({super.key});

  @override
  State<PartProductionDispatchPage> createState() =>
      _PartProductionDispatchPageState();
}

class _PartProductionDispatchPageState
    extends State<PartProductionDispatchPage> {
  final PartProductionDispatchLogic logic =
      Get.put(PartProductionDispatchLogic());
  final PartProductionDispatchState state =
      Get.find<PartProductionDispatchLogic>().state;

  //日期选择器的控制器
  var dpcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey:
        '${RouteConfig.partProductionDispatch.name}${PickerType.startDate}',
  );

  //日期选择器的控制器
  var dpcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.partProductionDispatch.name}${PickerType.endDate}',
  );

  var tecInstruction = TextEditingController();

  void _query() => logic.queryOrders(
        startTime: dpcStartDate.getDateFormatYMD(),
        endTime: dpcEndDate.getDateFormatYMD(),
        instruction: tecInstruction.text,
      );

  Widget _image(String url) => Container(
        height: 70,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: AspectRatio(
          aspectRatio: 2 / 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              cacheHeight: 200,
              cacheWidth: 200,
              errorBuilder: (ctx, err, st) => Image.asset(
                'assets/images/ic_logo.png',
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

  Widget _item(PartProductionDispatchOrderInfo data) => GestureDetector(
        onTap: () => data.isSelected.value = !data.isSelected.value,
        child: Obx(() => Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    data.isSelected.value
                        ? Colors.green.shade50
                        : Colors.blue.shade50,
                    Colors.white
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        color:
                            data.isSelected.value ? Colors.green : Colors.blue,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        data.isSelected.value
                            ? Icons.check_box_outlined
                            : Icons.check_box_outline_blank,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      textSpan(
                                        hint: '派工单号：',
                                        text: data.workCardNo ?? '',
                                      ),
                                      textSpan(
                                        hint: '派工日期：',
                                        text: data.date ?? '',
                                      ),
                                      textSpan(
                                        hint: '型体：',
                                        text: data.productName ?? '',
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => msgDialog(
                                    title: '工序',
                                    content: data.processName ?? '',
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.blue, width: 2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      data.processName ?? '',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            textSpan(hint: '指令：', text: data.instruction ?? ''),
                            textSpan(
                                hint: '部位：', text: data.materialName ?? ''),
                            textSpan(
                              hint: '尺码：',
                              text: data.sizesQuantities ?? '',
                            ),
                            Row(
                              children: [
                                Text(
                                  '生成贴标数量：',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Expanded(
                                  child: percentIndicator(
                                    max: data.dispatchQty ?? 0,
                                    value: data.sumCardNoQty ?? 0,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '${data.sumCardNoQty.toShowString()}/${data.dispatchQty.toShowString()} ${data.unitName}',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.all(5),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _image(data.productPicUrl ?? ''),
                          SizedBox(height: 5),
                          _image(data.partPictureUrls ?? ''),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      );

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      queryWidgets: [
        EditText(
          hint: '计划跟踪单号、指令、型体',
          controller: tecInstruction,
        ),
        DatePicker(pickerController: dpcStartDate),
        DatePicker(pickerController: dpcEndDate),
        Obx(() => SwitchButton(
              onChanged: (isSelect) => logic.changeClosedStatus(isSelect),
              name: '显示已关闭',
              value: state.isSelectedClosed.value,
            )),
      ],
      query: () => _query(),
      body: Obx(() => Column(
            children: [
              Expanded(
                  child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: state.orderList.length,
                itemBuilder: (c, i) => _item(state.orderList[i]),
              )),
              state.orderList.isNotEmpty &&
                      state.orderList.any((v) => v.isSelected.value)
                  ? Row(
                      children: [
                        Expanded(
                          child: CombinationButton(
                            text: '创建标签',
                            combination: Combination.left,
                            click: () => logic.toDetail(
                              refresh: () => _query(),
                            ),
                          ),
                        ),
                        Expanded(
                          child: CombinationButton(
                            text: '打印标签',
                            combination: Combination.right,
                            click: () => logic.queryLabelList(
                              refresh: () => _query(),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container()
            ],
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<PartProductionDispatchLogic>();
    super.dispose();
  }
}
