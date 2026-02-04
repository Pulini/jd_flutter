import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/pack_order_list_info.dart';
import 'package:jd_flutter/utils/printer/print_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

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

  Widget _item(int index) {
    var data = state.labelList[index];
    return Container(
      margin: EdgeInsetsGeometry.only(bottom: 10),
      padding: EdgeInsetsGeometry.all(5),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(5),
        gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.white]),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(50)),
              color: Colors.white,
              border: Border.all(width: 2, color: Colors.grey),
            ),
            alignment: Alignment.center,
            child: Text(
              (index + 1).toString(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Column(
            children: [
              textSpan(hint: '型体：', text: data.productName??''),
              textSpan(hint: '部位：', text: data.getPartList().join(',')),
              textSpan(hint: '指令：', text: data.batchNo??''),
              textSpan(hint: '尺码：', text: data.getSizeList().join(',')),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logic.getLabelList(
        partIds: widget.partIds,
        packOrderId: widget.packOrderId,
      );
    });
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
                child: CombinationButton(
                  combination: Combination.left,
                  text: '删除贴标',
                  click: () => logic.deleteLabel(),
                ),
              ),
              Expanded(
                child: CombinationButton(
                  combination: Combination.middle,
                  text: '打印锁/解锁',
                  click: () => logic.printLockOrUnlock(),
                ),
              ),
              Expanded(
                child: CombinationButton(
                  combination: Combination.middle,
                  text: '全选/反选',
                  click: () => logic.selectAllItem(),
                ),
              ),
              Expanded(
                child: CombinationButton(
                  combination: Combination.right,
                  text: '批量打印',
                  click: () => logic.printLabels(),
                ),
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
