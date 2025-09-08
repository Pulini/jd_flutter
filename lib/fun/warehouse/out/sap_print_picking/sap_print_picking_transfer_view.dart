import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_print_picking/sap_print_picking_logic.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_print_picking/sap_print_picking_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

class SapPrintPickingTransferPage extends StatefulWidget {
  const SapPrintPickingTransferPage({super.key});

  @override
  State<SapPrintPickingTransferPage> createState() =>
      _SapPrintPickingTransferPageState();
}

class _SapPrintPickingTransferPageState
    extends State<SapPrintPickingTransferPage> {
  final SapPrintPickingLogic logic = Get.find<SapPrintPickingLogic>();
  final SapPrintPickingState state = Get.find<SapPrintPickingLogic>().state;
  TextEditingController controller = TextEditingController();
  late AlertDialog dialog;

  @override
  void initState() {
    pdaScanner(scan: (code) {
      setState(() {
        if (Get.isDialogOpen == true) {
          controller.text = code;
          logic.checkPalletAndTransfer(
            pallet: code,
            refresh: () => setState(() {}),
          );
        } else {
          logic.transferScanCode(code);
        }
      });
    });
    dialog = AlertDialog(
      title: Text('sap_print_picking_transfer_new_pallet'.tr),
      content: SizedBox(
        width: 300,
        child: EditText(controller: controller),
      ),
      contentPadding: const EdgeInsets.only(left: 30, right: 30),
      actionsPadding: const EdgeInsets.only(right: 10, bottom: 10),
      actions: [
        TextButton(
          onPressed: () {},
          child: Text('dialog_default_confirm'.tr),
        ),
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'dialog_default_cancel'.tr,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
    super.initState();
  }

  _item(List<PalletDetailItem1Info> list) {
    return Container(
      margin: const EdgeInsets.only(left: 4, right: 4, bottom: 10),
      padding: const EdgeInsets.only(left: 4, right: 4),
      decoration: BoxDecoration(
        color:
            list.every((v) => v.select) ? Colors.blue.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: list.every((v) => v.select)
            ? Border.all(color: Colors.green, width: 2)
            : Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              expandedTextSpan(
                hint: 'sap_print_picking_transfer_pallet_no'.tr,
                text: list[0].palletNumber ?? '',
              ),
              Checkbox(
                  value: list.every((v) => v.select),
                  onChanged: (checked) {
                    setState(() {
                      for (var v in list) {
                        v.select = checked!;
                      }
                    });
                  })
            ],
          ),
          const Divider(height: 10, color: Colors.black),
          for (var item in list)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          textSpan(
                              hint: 'sap_print_picking_transfer_label_no'.tr,
                              text: item.labelNumber ?? ''),
                          Row(
                            children: [
                              expandedTextSpan(
                                  hint:
                                      'sap_print_picking_transfer_type_body'.tr,
                                  text: item.typeBody ?? ''),
                              textSpan(
                                hint:
                                    'sap_print_picking_transfer_size_or_qty'.tr,
                                text:
                                    '${item.size} / ${item.quantity.toShowString()}',
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: item.select,
                      onChanged: (checked) {
                        setState(() {
                          item.select = checked!;
                        });
                      },
                    ),
                  ],
                ),
                const Divider(height: 10, color: Colors.black),
              ],
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'sap_print_picking_transfer_surplus_material_transfer'.tr,
      actions: [
        TextButton(
          onPressed: () {
            if (state.transferList.any((v) => v.any((v2) => v2.select))) {
              Get.dialog(
                PopScope(
                  canPop: false,
                  child: dialog,
                ),
              );
            } else {
              errorDialog(
                content:
                    'sap_print_picking_transfer_scan_or_select_label_fo_transfer_tips'
                        .tr,
              );
            }
          },
          child: Text('sap_print_picking_transfer_transfer'.tr),
        ),
      ],
      body: ListView.builder(
        itemCount: state.transferList.length,
        itemBuilder: (c, i) => _item(state.transferList[i]),
      ),
    );
  }

  @override
  void dispose() {
    state.transferList.clear();
    super.dispose();
  }
}
