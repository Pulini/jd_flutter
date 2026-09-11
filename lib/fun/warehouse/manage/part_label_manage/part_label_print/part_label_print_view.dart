import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/pack_order_list_info.dart';
import 'package:jd_flutter/utils/printer/print_util.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/scanner.dart';
import 'package:jd_flutter/widget/view_photo.dart';

import 'part_label_print_logic.dart';
import 'part_label_print_state.dart';

class PartLabelPrintPage extends StatefulWidget {
  const PartLabelPrintPage({super.key});

  @override
  State<PartLabelPrintPage> createState() => _PartLabelPrintPageState();
}

class _PartLabelPrintPageState extends State<PartLabelPrintPage> {
  final PartLabelPrintLogic logic = Get.put(PartLabelPrintLogic());
  final PartLabelPrintState state = Get.find<PartLabelPrintLogic>().state;
  var pu = PrintUtil();
  var controller = TextEditingController();

  @override
  void initState() {
    pdaScanner(scan: (code) => logic.query(barCode: code));
    // WidgetsBinding.instance
    //     .addPostFrameCallback((_) => logic.query(barCode: 'GXPG250102784/1'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        Container(
          margin: const EdgeInsets.all(5),
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.blue, width: 2),
            color: Colors.white,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => scannerDialog(
                  detect: (code) => logic.query(barCode: code),
                ),
                child: Container(
                  padding: const EdgeInsets.only(left: 18, right: 18),
                  height: 40,
                  margin: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      bottomLeft: Radius.circular(50),
                    ),
                    color: Colors.blue.shade200,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.qr_code_scanner, color: Colors.white),
                ),
              ),
              Obx(() => state.labelList.isEmpty
                  ? Container()
                  : Container(
                      width: 200,
                      height: 40,
                      margin: const EdgeInsets.all(4),
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          hintText: 'part_dispatch_label_search_label'.tr,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide: const BorderSide(
                              color: Colors.blueAccent,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (v) => state.searchText.value = v,
                      ),
                    )),
              Obx(() => state.labelList.isEmpty
                  ? Container()
                  : Container(
                      height: 40,
                      margin: const EdgeInsets.only(left: 1, top: 4, bottom: 4),
                      decoration: BoxDecoration(color: Colors.green.shade200),
                      alignment: Alignment.center,
                      child: CheckBox(
                        onChanged: (v) => logic.selectAllItem(isSelect: v),
                        name: 'part_dispatch_label_select_all'.tr,
                        value: state.selectAll.value,
                      ),
                    )),
              Obx(
                () => state.labelList.isEmpty
                    ? Container()
                    : Container(
                        height: 40,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        margin:
                            const EdgeInsets.only(left: 1, top: 4, bottom: 4),
                        decoration: BoxDecoration(color: Colors.green.shade200),
                        alignment: Alignment.center,
                        child: Obx(() => RadioGroup<bool>(
                              groupValue: state.isPrinted.value,
                              onChanged: (v) => state.isPrinted.value = v!,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RadioItem<bool>(
                                    title: 'part_dispatch_label_not_printed'.tr,
                                    value: false,
                                  ),
                                  RadioItem<bool>(
                                    title: 'part_dispatch_label_printed'.tr,
                                    value: true,
                                  ),
                                ],
                              ),
                            )),
                      ),
              ),
              Obx(() => state.labelList.isEmpty
                  ? Container()
                  : CombinationButton(
                      isEnabled: logic.buttonEnable(),
                      combination: Combination.middle,
                      backgroundColor: Colors.red,
                      text: 'part_dispatch_label_delete_label'.tr,
                      click: () => logic.deleteLabel(),
                    )),
              Obx(() => state.labelList.isEmpty
                  ? Container()
                  : CombinationButton(
                      isEnabled: logic.buttonEnable(),
                      combination: Combination.middle,
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
                            content:
                                'part_dispatch_label_push_finished'.trArgs([
                              s.length.toString(),
                              f.length.toString(),
                            ]),
                            back: () => logic.upDateLabelState(s),
                          ),
                        ),
                      ),
                    )),
              Obx(() => state.labelList.isEmpty && state.barCode.isNotEmpty
                  ? CombinationButton(
                      combination: Combination.middle,
                      backgroundColor: Colors.deepPurpleAccent,
                      text: 'part_dispatch_order_generate_label'.tr,
                      click: () => logic.toConfirmPackingMethod(state.barCode),
                    )
                  : Container()),
              CombinationButton(
                text: 'part_dispatch_label_print_setting'.tr,
                combination: Combination.right,
                click: () => printSetDialog(),
              ),
            ],
          ),
        ),
      ],
      body: Obx(() {
        var list = logic.filteredByPrintState;
        return ListView.builder(
          itemCount: list.length,
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          itemBuilder: (c, i) => _PartLabelItem(
            label: list[i],
            viewLabel: () => logic.viewLabel(label: list[i]),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    Get.delete<PartLabelPrintLogic>();
    super.dispose();
  }
}

class _PartLabelItem extends StatelessWidget {
  final PartLabelInfo label;
  final Function viewLabel;

  const _PartLabelItem({
    required this.label,
    required this.viewLabel,
  });

  static final _errorImage = Image.asset(
    'assets/images/ic_logo.png',
    width: 70,
    color: Colors.blue,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => label.isSelected.value = !label.isSelected.value,
      child: Obx(() {
        var url = label.pictureUrlList.first;
        var selected = label.isSelected.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? Colors.green : Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [
                selected ? Colors.green.shade100 : Colors.blue.shade50,
                Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Icon(
                  selected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: selected ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          textSpan(
                            hint: 'part_dispatch_label_type_body'.tr,
                            text: label.productName ?? '',
                          ),
                          Text(
                            'part_dispatch_label_material'.trArgs([
                              label.totalQty().toString(),
                              label.materialList!.first.unitName ?? '',
                              label.packageType ?? ''
                            ]),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      textSpan(
                        hint: 'part_dispatch_label_part'.tr,
                        text: label.getPartsName(),
                      ),
                      textSpan(
                        hint: 'part_dispatch_label_instruction'.tr,
                        text: label.billNo ?? '',
                      ),
                      textSpan(
                        hint: 'part_dispatch_label_size'.tr,
                        text: label.getSize(),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      Get.to(() => ViewNetPhoto(photos: label.pictureUrlList)),
                  child: Container(
                    height: 80,
                    width: 160,
                    margin: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selected ? Colors.green : Colors.grey,
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
                              errorWidget: (ctx, err, st) => _errorImage,
                            )
                          : _errorImage,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => viewLabel.call(),
                  child: Container(
                    width: 45,
                    margin: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      color: Colors.blue.shade200,
                    ),
                    child: const Center(
                      child: Icon(Icons.receipt_long),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
