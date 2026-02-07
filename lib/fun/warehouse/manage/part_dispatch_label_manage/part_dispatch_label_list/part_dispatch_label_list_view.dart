import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/printer/print_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/view_photo.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

import 'part_dispatch_label_list_logic.dart';
import 'part_dispatch_label_list_state.dart';

class PartDispatchLabelListPage extends StatefulWidget {
  const PartDispatchLabelListPage({
    super.key,
    this.partIds,
    this.packOrderId,
  });

  final String? partIds;
  final int? packOrderId;

  @override
  State<PartDispatchLabelListPage> createState() =>
      _PartDispatchLabelListPageState();
}

class _PartDispatchLabelListPageState extends State<PartDispatchLabelListPage> {
  final PartDispatchLabelListLogic logic =
      Get.put(PartDispatchLabelListLogic());
  final PartDispatchLabelListState state =
      Get.find<PartDispatchLabelListLogic>().state;

  var pu = PrintUtil();

  Widget _item(int index) => GestureDetector(
        onTap: () => state.labelList[index].isSelected.value =
            !state.labelList[index].isSelected.value,
        child: Obx(() {
          var data = state.labelList[index];
          var url = data.pictureUrlList.first;
          var errorImage = Image.asset(
            width: 70,
            'assets/images/ic_logo.png',
            color: Colors.blue,
          );
          var indexWidget = Container(
            width: 30,
            height: 30,
            margin: EdgeInsetsGeometry.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(50)),
              border: Border.all(
                width: 2,
                color: data.isSelected.value ? Colors.green : Colors.grey,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              (index + 1).toString(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          );
          var centerWidget = Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    textSpan(hint: '型体：', text: data.productName ?? ''),
                    Text(
                      '${data.totalQty()}${data.materialList!.first.unitName ?? ''}/部件',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                ),
                textSpan(hint: '部位：', text: data.getPartsName()),
                textSpan(hint: '指令：', text: data.billNo ?? ''),
                textSpan(hint: '尺码：', text: data.getSize()),
              ],
            ),
          );
          var endWidget = GestureDetector(
            onTap: () => Get.to(() => ViewNetPhoto(photos: data.pictureUrlList)),
            child: Container(
              height: 80,
              width: 160,
              margin: EdgeInsetsGeometry.only(left: 10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: data.isSelected.value ? Colors.green : Colors.grey,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(7),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: url.isNotEmpty
                    ? Image.network(
                        width: 70,
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => errorImage,
                      )
                    : errorImage,
              ),
            ),
          );
          return Container(
            margin: EdgeInsetsGeometry.only(bottom: 10),
            padding: EdgeInsetsGeometry.all(5),
            decoration: BoxDecoration(
              border: Border.all(
                color: data.isSelected.value ? Colors.green : Colors.grey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [
                  data.isSelected.value
                      ? Colors.green.shade100
                      : Colors.blue.shade50,
                  Colors.white
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            foregroundDecoration: RotatedCornerDecoration.withColor(
              badgePosition: BadgePosition.topStart,
              color: data.isPrint == true ? Colors.green : Colors.red,
              badgeCornerRadius: Radius.circular(7),
              badgeSize: Size(50, 50),
              textSpan: TextSpan(
                text: data.isPrint == true ? '已打印' : '未打印',
                style: TextStyle(fontSize: 12),
              ),
            ),
            child: Row(children: [indexWidget, centerWidget, endWidget]),
          );
        }),
      );

  void _query() {
    logic.getLabelList(
      partIds: widget.partIds,
      packOrderId: widget.packOrderId,
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _query());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '部件贴标列表',
      actions: [
        CombinationButton(
          text: '打印设置',
          click: () => printSetDialog(),
        ),
      ],
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: state.labelList.length,
                  padding: EdgeInsetsGeometry.only(
                    left: 10,
                    right: 10,
                    bottom: 10,
                  ),
                  itemBuilder: (c, i) => _item(i),
                )),
          ),
          Row(
            children: [
              Expanded(
                child: Obx(() => CombinationButton(
                      isEnabled: logic.buttonEnable(),
                      combination: Combination.left,
                      text: '删除贴标',
                      click: () => logic.deleteLabel(refresh: () => _query()),
                    )),
              ),
              Expanded(
                child: Obx(() => CombinationButton(
                      isEnabled: logic.buttonEnable(),
                      combination: Combination.middle,
                      text: '打印锁定',
                      click: () => logic.printLockOrUnlock(
                        isLock: true,
                        refresh: () => _query(),
                      ),
                    )),
              ),
              Expanded(
                child: Obx(() => CombinationButton(
                      isEnabled: logic.buttonEnable(),
                      combination: Combination.middle,
                      text: '打印解锁',
                      click: () => logic.printLockOrUnlock(
                        isLock: false,
                        refresh: () => _query(),
                      ),
                    )),
              ),
              Expanded(
                child: Obx(() => CombinationButton(
                      isEnabled: state.labelList.isNotEmpty,
                      combination: Combination.middle,
                      text: '全选已印',
                      click: () => logic.selectAllPrintedItem(),
                    )),
              ),
              Expanded(
                child: Obx(() => CombinationButton(
                      isEnabled: state.labelList.isNotEmpty,
                      combination: Combination.middle,
                      text: '全选未印',
                      click: () => logic.selectAllNotPrintItem(),
                    )),
              ),
              Expanded(
                child: Obx(() => CombinationButton(
                      isEnabled: logic.buttonEnable(),
                      combination: Combination.middle,
                      text: '取消选择',
                      click: () => logic.unSelectAllItem(),
                    )),
              ),
              Expanded(
                child: Obx(() => CombinationButton(
                      isEnabled: logic.buttonEnable(),
                      combination: Combination.right,
                      text: '批量打印',
                      click: () => askDialog(
                        content: '确定要打印吗？',
                        confirm: () async => pu.printLabelList(
                          labelList: await logic.getLabelListData(),
                          start: () => loadingShow('正在下发标签...'),
                          progress: (i, j) => loadingShow('正在下发标签($i/$j)'),
                          finished: (s, f) => successDialog(
                            title: '标签下发结束',
                            content: '完成${s.length}张, 失败${f.length}张',
                            back: () => logic.printLockOrUnlock(
                              isLock: true,
                              refresh: () => _query(),
                            ),
                          ),
                        ),
                      ),
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<PartDispatchLabelListLogic>();
    super.dispose();
  }
}
