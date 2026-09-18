import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_posting_info.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_picking_posting/sap_picking_posting_dialog.dart';

import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'sap_picking_posting_logic.dart';
import 'sap_picking_posting_state.dart';

class SapPickingPostingPage extends StatefulWidget {
  const SapPickingPostingPage({super.key});

  @override
  State<SapPickingPostingPage> createState() => _SapPickingPostingPageState();
}

class _SapPickingPostingPageState extends State<SapPickingPostingPage> {
  final SapPickingPostingLogic logic = Get.put(SapPickingPostingLogic());
  final SapPickingPostingState state = Get.find<SapPickingPostingLogic>().state;
  var tecSemiFinishedProduct = TextEditingController();
  var tecFinishedProduct = TextEditingController();

  Widget _itemSemiFinishedProduct(SapPickingPostingGroup data) =>
      _SapPickingPostingSemiFinishedItem(data: data, logic: logic);

  Widget productPageTitle({
    required String title,
    Color? bkgColor = Colors.indigoAccent,
  }) =>
      Container(
        height: 40,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(7),
            topRight: Radius.circular(7),
          ),
          color: bkgColor,
        ),
        child: Center(
          child: AutoSizeText(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            minFontSize: 14,
            maxFontSize: 24,
          ),
        ),
      );

  late var semiFinishedProductPageInput = Container(
    width: double.infinity,
    color: Colors.white,
    height: 45,
    padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
    child: TextField(
      controller: tecSemiFinishedProduct,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(
          top: 0,
          bottom: 0,
          left: 15,
          right: 10,
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        hintText: 'sap_picking_posting_scan_semi_barcode'.tr,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: IconButton(
          onPressed: () => tecSemiFinishedProduct.clear(),
          icon: const Icon(
            Icons.replay_circle_filled,
            color: Colors.red,
          ),
        ),
        suffixIcon: IconButton(
          onPressed: () => logic.getMaterialDetail(
            code: tecSemiFinishedProduct.text,
            semiFinishedProduct: () {
              tecSemiFinishedProduct.clear();
              FocusManager.instance.primaryFocus?.unfocus();
            },
          ),
          icon: const Icon(
            Icons.add_circle,
            color: Colors.blue,
          ),
        ),
      ),
    ),
  );

  late var finishedProductPageInput = Container(
    width: double.infinity,
    color: Colors.white,
    height: 45,
    padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
    child: TextField(
      controller: tecFinishedProduct,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(
          top: 0,
          bottom: 0,
          left: 15,
          right: 10,
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        hintText: 'sap_picking_posting_scan_finished_barcode'.tr,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: IconButton(
          onPressed: () => tecFinishedProduct.clear(),
          icon: const Icon(
            Icons.replay_circle_filled,
            color: Colors.red,
          ),
        ),
        suffixIcon: IconButton(
          onPressed: () => logic.getMaterialDetail(
            code: tecFinishedProduct.text,
            finishedProduct: () {
              tecFinishedProduct.clear();
              FocusManager.instance.primaryFocus?.unfocus();
            },
          ),
          icon: const Icon(
            Icons.add_circle,
            color: Colors.blue,
          ),
        ),
      ),
    ),
  );

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pdaScanner(scan: (code) {
        logic.getMaterialDetail(code: code);
        FocusManager.instance.primaryFocus?.unfocus();
      });
      logic.getNewOrderNumber();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        CombinationButton(
          text: 'sap_picking_posting_temp_record'.tr,
          click: () => pickingCacheDialog(
              refresh: (orderNumber, labels) =>
                  logic.refreshLabels(orderNumber, labels)),
        ),
      ],
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 10, right: 10),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: Obx(() => textSpan(hint: 'sap_picking_posting_picking_order_no_colon'.tr, text: state.order.value)),
          ),
          Expanded(
            child: Obx(() => ListView(
                  padding: const EdgeInsets.all(10),
                  children: [
                    productPageTitle(title: 'sap_picking_posting_semi_barcode_detail'.tr, bkgColor: Colors.blue),
                    semiFinishedProductPageInput,
                    for (var item in state.semiFinishedProductList)
                      _itemSemiFinishedProduct(item),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(7),
                          bottomRight: Radius.circular(7),
                        ),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: CombinationButton(
                              text: 'sap_picking_posting_add_material'.tr,
                              combination: Combination.left,
                              click: () => addSemiFinishedProductMaterialDialog(
                                  state.semiFinishedProductList),
                            ),
                          ),
                          Expanded(
                            child: CombinationButton(
                              text: 'sap_picking_posting_clear_list'.tr,
                              combination: Combination.right,
                              isEnabled:
                                  state.semiFinishedProductList.isNotEmpty,
                              backgroundColor: Colors.orange,
                              click: () => askDialog(
                                title: 'sap_picking_posting_semi_picking'.tr,
                                content: 'sap_picking_posting_confirm_clear_all'.tr,
                                confirm: () => logic.clearSemiFinishedProduct(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    productPageTitle(
                      title: 'sap_picking_posting_finished_barcode_detail'.tr,
                      bkgColor: Colors.green,
                    ),
                    finishedProductPageInput,
                    state.finishedProductList.isNotEmpty
                        ? Container(
                            padding:
                                const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(7),
                                bottomRight: Radius.circular(7),
                              ),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoSizeText(
                                  '(${state.finishedProductList.first.materialCode})${state.finishedProductList.first.materialName}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  minFontSize: 8,
                                  maxFontSize: 16,
                                ),
                                SizedBox(
                                  height: 35,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: textSpan(
                                          hint: 'sap_picking_posting_order_no_colon'.tr,
                                          hintColor: Colors.grey.shade700,
                                          text: state.finishedProductList.first
                                                  .salesOrder ??
                                              '',
                                          isBold: false,
                                        ),
                                      ),
                                      Expanded(
                                        child: textSpan(
                                          hint: 'sap_picking_posting_qty_colon'.tr,
                                          hintColor: Colors.grey.shade700,
                                          text: state.finishedProductList
                                              .map((v) => v.quantity ?? 0)
                                              .reduce((a, b) => a.add(b))
                                              .toShowString(),
                                          isBold: false,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => askDialog(
                                          content: 'sap_picking_posting_confirm_delete_material'.tr,
                                          confirm: () =>
                                              logic.clearFinishedProduct(),
                                        ),
                                        icon: const Icon(
                                          Icons.delete_forever,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.only(bottom: 5),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(7),
                                bottomRight: Radius.circular(7),
                              ),
                              color: Colors.white,
                            ),
                          ),
                  ],
                )),
          ),
          Row(
            children: [
              Expanded(
                child: CombinationButton(
                  text: 'sap_picking_posting_temp_save'.tr,
                  click: () => askDialog(
                    content: 'sap_picking_posting_confirm_temp_save'.tr,
                    confirm: () => logic.submitPickingLabel(false),
                  ),
                  backgroundColor: Colors.orange,
                  combination: Combination.left,
                ),
              ),
              Expanded(
                child: CombinationButton(
                  text: 'sap_picking_posting_submit'.tr,
                  click: () => askDialog(
                    content: 'sap_picking_posting_confirm_submit'.tr,
                    confirm: () => logic.submitPickingLabel(true),
                  ),
                  backgroundColor: Colors.green,
                  combination: Combination.right,
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
    Get.delete<SapPickingPostingLogic>();
    super.dispose();
  }
}

class _SapPickingPostingSemiFinishedItem extends StatefulWidget {
  final SapPickingPostingGroup data;
  final SapPickingPostingLogic logic;

  const _SapPickingPostingSemiFinishedItem({
    required this.data,
    required this.logic,
  });

  @override
  State<_SapPickingPostingSemiFinishedItem> createState() =>
      _SapPickingPostingSemiFinishedItemState();
}

class _SapPickingPostingSemiFinishedItemState
    extends State<_SapPickingPostingSemiFinishedItem> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 5),
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 35,
            child: Row(
              children: [
                Expanded(
                  child: AutoSizeText(
                    widget.data.material(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    minFontSize: 8,
                    maxFontSize: 16,
                  ),
                ),
                IconButton(
                  onPressed: () => askDialog(
                    content: 'sap_picking_posting_confirm_delete_material'.tr,
                    confirm: () => widget.logic.deleteSemiFinishedProductItem(widget.data),
                  ),
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 35,
            child: Row(
              children: [
                Expanded(
                  child: textSpan(
                    hint: 'sap_picking_posting_cumulative_qty_colon'.tr,
                    hintColor: Colors.grey.shade700,
                    text: widget.data.cumulativeQty().toShowString(),
                    isBold: false,
                  ),
                ),
                Expanded(
                  child: widget.data.dataList.first.label.isNullOrEmpty()
                      ? Text(
                          'sap_picking_posting_manual_add_material'.tr,
                          style: TextStyle(color: Colors.green.shade700),
                        )
                      : textSpan(
                          hint: 'sap_picking_posting_scan_count_colon'.tr,
                          hintColor: Colors.grey.shade700,
                          text: widget.data.scanCount().toString(),
                          isBold: false,
                        ),
                ),
                IconButton(
                  onPressed: () => semiFinishedProductDetailsDialog(widget.data),
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
                ),
              ],
            ),
          ),
          const Divider(
            indent: 5,
            endIndent: 10,
            height: 2,
          ),
        ],
      ),
    );
  }
}
