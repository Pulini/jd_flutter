import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/part_dispatch_label_manage_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/part_dispatch_label_manage/part_dispatch_label_manage_dialog.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/scanner.dart';
import 'package:jd_flutter/widget/switch_button_widget.dart';
import 'package:jd_flutter/widget/view_photo.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

import 'part_dispatch_order_list_logic.dart';
import 'part_dispatch_order_list_state.dart';

class PartDispatchLabelManagePage extends StatefulWidget {
  const PartDispatchLabelManagePage({super.key});

  @override
  State<PartDispatchLabelManagePage> createState() =>
      _PartDispatchLabelManagePageState();
}

class _PartDispatchLabelManagePageState
    extends State<PartDispatchLabelManagePage> {
  final PartDispatchLabelManageLogic logic =
      Get.put(PartDispatchLabelManageLogic());
  final PartDispatchLabelManageState state =
      Get.find<PartDispatchLabelManageLogic>().state;

  //日期选择器的控制器
  var dpcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey:
        '${RouteConfig.partDispatchLabelManage.name}${PickerType.startDate}',
  );

  //日期选择器的控制器
  var dpcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.partDispatchLabelManage.name}${PickerType.endDate}',
  );

  var tecInstruction = TextEditingController(text: 'PNS26312586-01');

  void _query({String? code}) {
    logic.queryInstruction(
      code: code,
      productName: tecInstruction.text,
      startTime: dpcStartDate.getDateFormatYMD(),
      endTime: dpcEndDate.getDateFormatYMD(),
      show: (batchGroups) => selectInstructionsDialog(
        batchGroups: batchGroups,
        selected: (list, isSingleInstruction) =>
            logic.queryOrderDetail(list, isSingleInstruction),
      ),
    );
  }

  Widget _imageItem(int i) => GestureDetector(
        onTap: () => Get.to(() => ViewNetPhoto(photos: state.productUrlList)),
        child: Hero(
          tag: state.productUrlList[i],
          child: Image.network(
            state.productUrlList[i],
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, st) => Image.asset(
              'assets/images/ic_logo.png',
              color: Colors.blue,
            ),
          ),
        ),
      );

  Widget _partItem(PartDispatchOrderPartInfo data) {
    var url = data.partPictureUrl();
    var errorImage = Image.asset(
      'assets/images/ic_logo.png',
      color: Colors.blue,
    );
    return GestureDetector(
      onTap: () => data.isSelected.value = !data.isSelected.value,
      child: Obx(() => Container(
            margin: const EdgeInsets.all(5),
            padding: EdgeInsetsGeometry.all(5),
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: data.isSelected.value ? Colors.blue : Colors.grey,
              ),
              borderRadius: BorderRadius.circular(10),
              color: data.isSelected.value
                  ? Colors.blue.shade100
                  : Colors.transparent,
            ),
            foregroundDecoration: RotatedCornerDecoration.withColor(
              color: data.packTypeID == 478
                  ? Colors.deepOrange
                  : Colors.deepPurple,
              badgeCornerRadius: const Radius.circular(8),
              badgeSize: const Size(45, 45),
              textSpan: TextSpan(
                text: data.packTypeID == 478 ? '单码' : '混码',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AspectRatio(
                  aspectRatio: 2 / 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: url.isNotEmpty
                        ? Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, st) => errorImage,
                          )
                        : errorImage,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data.materialName ?? '',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${data.remainingQty.toShowString()}/${data.dispatchQty.toShowString()}',
                    )
                  ],
                ),
              ],
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      popTitle: '确定要退出部件标签管理吗？',
      actions: [
        Obx(() => state.partList.isNotEmpty &&
                state.partList.where((v) => v.isSelected.value).length == 1
            ? CombinationButton(
                text: '查看部件明细',
                combination: Combination.left,
                click: () => viewPartDetailDialog(
                  state.partList.firstWhere((v) => v.isSelected.value),
                ),
              )
            : Container()),
        Obx(() => state.partList.isNotEmpty &&
                state.partList.any((v) => v.isSelected.value)
            ? CombinationButton(
                text: '生成贴标',
                combination:
                    state.partList.where((v) => v.isSelected.value).length == 1
                        ? Combination.right
                        : Combination.intact,
                click: () => logic.toCreateLabel(),
              )
            : Container()),
      ],
      queryWidgets: [
        Container(
          margin: const EdgeInsets.all(5),
          height: 40,
          child: TextField(
            controller: tecInstruction,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(left: 10, right: 10),
              filled: true,
              fillColor: Colors.grey[300],
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              labelText: '型体',
              labelStyle: const TextStyle(color: Colors.black54),
              prefixIcon: IconButton(
                onPressed: () => scannerDialog(detect: (c) => _query(code: c)),
                icon: Icon(Icons.qr_code_scanner, color: Colors.blue),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => tecInstruction.clear(),
              ),
            ),
          ),
        ),
        Obx(() => EditText(
              hint: '批次号',
              onChanged: (v) => state.queryBatchNo.value = v,
              initStr: state.queryBatchNo.value,
            )),
        DatePicker(pickerController: dpcStartDate),
        DatePicker(pickerController: dpcEndDate),
        Obx(() => SwitchButton(
              onChanged: (isSelect) => state.isSelectedClosed.value = isSelect,
              name: '显示已关闭',
              value: state.isSelectedClosed.value,
            )),
      ],
      query: () => _query(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 100,
            padding: EdgeInsetsGeometry.all(5),
            margin: EdgeInsetsGeometry.only(left: 5, right: 5, bottom: 5),
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          textSpan(hint: '派工单号：', text: state.orderNo.value),
                          textSpan(hint: '指令：', text: state.instructions.value),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              textSpan(hint: '型体：', text: state.typeBody.value),
                              textSpan(
                                  hint: '派工批次：',
                                  text: state.dispatchBatchNo.value),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              textSpan(
                                  hint: '尺码：', text: state.sizeListText.value),
                              Text(
                                state.total.value,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                ),
                SizedBox(width: 5),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AspectRatio(
                    aspectRatio: 2 / 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Obx(() => Swiper(
                            itemBuilder: (c, i) => _imageItem(i),
                            itemCount: state.productUrlList.length,
                            pagination: const SwiperPagination(),
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() => GridView.builder(
                  itemCount: state.partList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    childAspectRatio: 3 / 2,
                  ),
                  itemBuilder: (c, i) => _partItem(state.partList[i]),
                )),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<PartDispatchLabelManageLogic>();
    super.dispose();
  }
}
