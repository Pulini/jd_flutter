import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/part_production_dispatch_info.dart';
import 'package:jd_flutter/fun/dispatching/part_production_dispatch_d/part_production_dispatch_logic.dart';
import 'package:jd_flutter/fun/dispatching/part_production_dispatch_d/part_production_dispatch_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/printer/print_util.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/view_photo.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

class PartProductionDispatchLabelPage extends StatefulWidget {
  const PartProductionDispatchLabelPage({super.key});

  @override
  State<PartProductionDispatchLabelPage> createState() =>
      _PartProductionDispatchLabelPageState();
}

class _PartProductionDispatchLabelPageState
    extends State<PartProductionDispatchLabelPage> {
  final PartProductionDispatchLogic logic =
      Get.find<PartProductionDispatchLogic>();
  final PartProductionDispatchState state =
      Get.find<PartProductionDispatchLogic>().state;
  var pu = PrintUtil();

  Widget _item(PartProductionDispatchLabelInfo label) {
    return Obx(() => GestureDetector(
          onTap: () => label.isSelected.value = !label.isSelected.value,
          child: Container(
            padding: EdgeInsetsGeometry.all(5),
            margin: EdgeInsetsGeometry.only(bottom: 10),
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: label.isSelected.value
                    ? [Colors.green.shade100, Colors.green.shade50]
                    : [Colors.blue.shade50, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              color: Colors.white,
              border: Border.all(
                color: label.isSelected.value
                    ? Colors.green
                    : Colors.grey.shade300,
                width: 2,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            foregroundDecoration: RotatedCornerDecoration.withColor(
              color: label.isInStock == true ? Colors.orange : Colors.blue,
              badgeCornerRadius: const Radius.circular(8),
              badgeSize: const Size(50, 50),
              textSpan: TextSpan(
                text: label.isInStock == true ? '已入库' : '未入库',
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.all(10),
                  child: Icon(
                    label.isSelected.value
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: label.isSelected.value ? Colors.green : Colors.grey,
                    size: 30,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          textSpan(hint: '型体：', text: label.typeBody ?? ''),
                          Text(
                            '${label.getTotalQty().toShowString()} ${label.unitName}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      textSpan(hint: '部位：', text: label.getPartList()),
                      textSpan(hint: '指令：', text: label.getInstructionList()),
                      textSpan(hint: '尺码：', text: label.getSizeList()),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: ()=>Get.to(()=>ViewNetPhoto(photos: label.photoList)),
                  child: Container(
                    margin: EdgeInsetsGeometry.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: AspectRatio(
                      aspectRatio: 2 / 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          label.photoList.first,
                          fit: BoxFit.cover,
                          cacheHeight: 200,
                          cacheWidth: 100,
                          errorBuilder: (ctx, err, st) => Image.asset(
                            'assets/images/ic_logo.png',
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '标签列表',
      actions: [
        Obx(() => state.labelList.isNotEmpty &&
                state.labelList.any((v) => v.isSelected.value)
            ? Row(
                children: [
                  CombinationButton(
                    text: '删除贴标',
                    combination: Combination.left,
                    click: () => askDialog(
                      content: '确定要删除贴标吗？',
                      confirm: () => logic.deleteLabels(),
                    ),
                  ),
                  CombinationButton(
                    text: '打印贴标',
                    combination: Combination.right,
                    click: () => printSetDialog(
                      print: () async => pu.printLabelList(
                        labelList: await logic.getLabelListData(),
                        start: () => loadingShow('正在下发标签...'),
                        progress: (i, j) => loadingShow('正在下发标签($i/$j)'),
                        finished: (s, f) => successDialog(
                          title: '标签下发结束',
                          content: '完成${s.length}张, 失败${f.length}张',
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Container()),
        Obx(() => state.labelList.isNotEmpty
            ? CheckBox(
                onChanged: (c) {
                  for (var v in state.labelList) {
                    v.isSelected.value = c;
                  }
                },
                name: '全选',
                value: state.labelList.every((v) => v.isSelected.value),
              )
            : Container()),
      ],
      body: Obx(() => ListView.builder(
            padding: EdgeInsetsGeometry.only(left: 10, right: 10, bottom: 10),
            itemCount: state.labelList.length,
            itemBuilder: (c, i) => _item(state.labelList[i]),
          )),
    );
  }
}
