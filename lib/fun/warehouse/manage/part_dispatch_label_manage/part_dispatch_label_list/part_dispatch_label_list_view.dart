import 'package:cached_network_image/cached_network_image.dart';
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

  Widget _item(int index) => _PartDispatchLabelListItem(
        index: index,
        logic: logic,
        state: state,
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
      title: 'part_dispatch_label_list'.tr,
      actions: [
        CombinationButton(
          text: 'part_dispatch_label_print_setting'.tr,
          click: () => printSetDialog(),
        ),
      ],
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: state.labelList.length,
                  padding: const EdgeInsets.only(
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
                      text: 'part_dispatch_label_delete_label'.tr,
                      click: () => logic.deleteLabel(refresh: () => _query()),
                    )),
              ),
              Expanded(
                child: Obx(() => CombinationButton(
                      isEnabled: logic.buttonEnable(),
                      combination: Combination.middle,
                      text: 'part_dispatch_label_print_lock'.tr,
                      click: () => logic.printLockOrUnlock(
                        isPrint: false,
                        isLock: true,
                        refresh: () => _query(),
                      ),
                    )),
              ),
              Expanded(
                child: Obx(() => CombinationButton(
                      isEnabled: logic.buttonEnable(),
                      combination: Combination.middle,
                      text: 'part_dispatch_label_print_unlock'.tr,
                      click: () => logic.printLockOrUnlock(
                        isPrint: false,
                        isLock: false,
                        refresh: () => _query(),
                      ),
                    )),
              ),
              Expanded(
                child: Obx(() => CombinationButton(
                      isEnabled: state.labelList.isNotEmpty,
                      combination: Combination.middle,
                      text: 'part_dispatch_label_select_all_printed'.tr,
                      click: () => logic.selectAllPrintedItem(),
                    )),
              ),
              Expanded(
                child: Obx(() => CombinationButton(
                      isEnabled: state.labelList.isNotEmpty,
                      combination: Combination.middle,
                      text: 'part_dispatch_label_select_all_not_printed'.tr,
                      click: () => logic.selectAllNotPrintItem(),
                    )),
              ),
              Expanded(
                child: Obx(() => CombinationButton(
                      isEnabled: logic.buttonEnable(),
                      combination: Combination.middle,
                      text: 'part_dispatch_label_cancel_select'.tr,
                      click: () => logic.unSelectAllItem(),
                    )),
              ),
              Expanded(
                child: Obx(() => CombinationButton(
                      isEnabled: logic.buttonEnable(),
                      combination: Combination.right,
                      text: 'part_dispatch_label_batch_print'.tr,
                      click: () => logic.printLabel(
                        (labels) async => pu.printLabelList(
                          labelList: labels,
                          start: () =>
                              loadingShow('part_dispatch_label_push_label'.tr),
                          progress: (i, j) => loadingShow(
                              'part_dispatch_label_pushing_progress'
                                  .trArgs([i.toString(), j.toString()])),
                          finished: (s, f) => successDialog(
                            title: 'part_dispatch_label_push_label_end'.tr,
                            content: 'part_dispatch_label_push_finished'.trArgs(
                                [s.length.toString(), f.length.toString()]),
                            back: () => logic.printLockOrUnlock(
                              isPrint: true,
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

class _PartDispatchLabelListItem extends StatelessWidget {
  final int index;
  final PartDispatchLabelListLogic logic;
  final PartDispatchLabelListState state;

  const _PartDispatchLabelListItem({
    required this.index,
    required this.logic,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(50)),
            border: Border.all(
              width: 2,
              color: data.isSelected.value ? Colors.green : Colors.grey,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            (index + 1).toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
        var centerWidget = Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  textSpan(
                      hint: 'part_dispatch_label_type_body'.tr,
                      text: data.productName ?? ''),
                  Text(
                    'part_dispatch_label_material'.trArgs([
                      data.totalQty().toString(),
                      data.materialList!.first.unitName ?? ''
                    ]),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
              textSpan(
                  hint: 'part_dispatch_label_part'.tr,
                  text: data.getPartsName()),
              textSpan(
                  hint: 'part_dispatch_label_instruction'.tr,
                  text: data.billNo ?? ''),
              textSpan(
                  hint: 'part_dispatch_label_size'.tr, text: data.getSize()),
            ],
          ),
        );
        var endWidget = GestureDetector(
          onTap: () =>
              Get.to(() => ViewNetPhoto(photos: data.pictureUrlList)),
          child: Container(
            height: 80,
            width: 160,
            margin: const EdgeInsets.only(left: 10),
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
                  ? CachedNetworkImage(
                      imageUrl: url,
                      width: 70,
                      fit: BoxFit.cover,
                      errorWidget: (ctx, err, st) => errorImage,
                    )
                  : errorImage,
            ),
          ),
        );
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(5),
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
            badgeCornerRadius: const Radius.circular(7),
            badgeSize: const Size(50, 50),
            textSpan: TextSpan(
              text: data.isPrint == true
                  ? 'part_dispatch_label_printed'.tr
                  : 'part_dispatch_label_not_printed'.tr,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          child: Row(children: [indexWidget, centerWidget, endWidget]),
        );
      }),
    );
  }
}
