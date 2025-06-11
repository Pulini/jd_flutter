import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_wms_reprint_label_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/preview_label_list_widget.dart';
import 'package:jd_flutter/widget/preview_label_widget.dart';
import 'package:jd_flutter/widget/tsc_label_template.dart';

import 'sap_wms_split_label_state.dart';

class SapWmsSplitLabelLogic extends GetxController {
  final SapWmsSplitLabelState state = SapWmsSplitLabelState();

  scanCode(String code) {
    state.getLabels(
      labelNumber: code,
      error: (msg) => errorDialog(content: msg),
    );
  }

  split({
    required double splitQty,
    required Function() input,
    required Function() finish,
  }) {
    if (splitQty == 0) {
      errorDialog(
          content: 'sap_wms_split_label_input_split_qty_tips'.tr, back: input);
      return;
    }
    if ((state.originalLabel?.quantity ?? 0) == splitQty) {
      errorDialog(content: 'sap_wms_split_label_split_qty_error_tops'.tr);
      return;
    }
    state.originalLabel?.quantity = state.originalLabel?.quantity.sub(splitQty);
    state.labelList.add(ReprintLabelInfo(
      isNewLabel: 'X',
      labelNumber: state.originalLabel?.labelNumber,
      materialCode: state.originalLabel?.materialCode,
      materialName: state.originalLabel?.materialName,
      typeBody: state.originalLabel?.typeBody,
      size: state.originalLabel?.size,
      quantity: splitQty,
      unit: state.originalLabel?.unit,
    ));
    finish.call();
  }

  deleteLabel() {
    var removeQty = state.labelList
        .where((v) => v.isNewLabel == 'X' && v.select)
        .map((v) => v.quantity ?? 0)
        .reduce((a, b) => a.add(b));
    state.labelList.removeWhere((v) => v.isNewLabel == 'X' && v.select);
    state.originalLabel?.quantity =
        state.originalLabel?.quantity.add(removeQty);
  }

  submitSplit() {
    state.submitSplit(
      success: (msg) => successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
    );
  }

  reprintLabel({required String factory, required String warehouse}) {
    if (factory != '1500' &&
        warehouse != '1200' &&
        warehouse != '1101' &&
        warehouse != '1102' &&
        warehouse != '1105') {
      msgDialog(
          content:
              'sap_wms_split_label_select_warehouse_before_print_label_tips'
                  .tr);
      return;
    }
    var list = <Widget>[];
    state.labelList.where((v) => v.select).forEach((v) {
      if (warehouse == '1101') {
        list.add(_warehouse1101(v));
      } else if (warehouse == '1102' || warehouse == '1105') {
        list.add(_warehouse1102a1105(v));
      } else if (warehouse == '1200') {
        list.add(_warehouse1200(v));
      } else {
        list.add(_warehouseOther(v));
      }
    });
    if (list.isEmpty) {
      msgDialog(
          content: 'sap_wms_split_label_select_label_fo_print'.tr);
    } else {
      if (list.length > 1) {
        Get.to(() => PreviewLabelList(labelWidgets: list));
      } else {
        Get.to(() => PreviewLabel(labelWidget: list[0]));
      }
    }
  }

  Widget _warehouse1101(ReprintLabelInfo data) {
    return fixedLabelTemplate75x45(
      qrCode: data.labelNumber ?? '',
      title: Text(
        data.factory ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      subTitle: Text(
        data.process ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Text(
              data.materialName.allowWordTruncation(),
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold,
                fontSize: 16.5,
                height: 1,
              ),
              maxLines: 2,
            ),
          ),
          Text(
            '派工号:${data.dispatchNumber}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            '递减号:${data.decrementTableNumber}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          )
        ],
      ),
      bottomLeft: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            '序号：${data.numPage}',
            style: const TextStyle(fontWeight: FontWeight.bold, height: 1),
          ),
          Text(
            '产期：${data.dispatchDate}',
            style: const TextStyle(fontWeight: FontWeight.bold, height: 1),
          ),
        ],
      ),
      bottomMiddle: Center(
        child: Text(
          '班次：${data.dayOrNightShift} 机台：${data.machineNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      bottomRight: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            '${data.size}#',
            style: const TextStyle(fontWeight: FontWeight.bold, height: 1),
          ),
          Text(
            '${data.boxCapacity}${data.unit}',
            style: const TextStyle(fontWeight: FontWeight.bold, height: 1),
          ),
        ],
      ),
    );
  }

  Widget _warehouse1102a1105(ReprintLabelInfo data) {
    return fixedLabelTemplate75x45(
      qrCode: data.labelNumber ?? '',
      title: Text(
        data.typeBody ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      content: Text(
        '(${data.materialCode})${data.materialName}'.allowWordTruncation(),
        style: const TextStyle(
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.bold,
          fontSize: 16.5,
          height: 1,
        ),
        maxLines: 3,
      ),
      bottomLeft: Center(
        child: Text(
          '页码：${data.numPage}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      bottomMiddle: Center(
        child: Text(
          data.quantity.toShowString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      bottomRight: Center(
        child: Text(
          data.unit ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    );
  }

  Widget _warehouse1200(ReprintLabelInfo data) {
    return fixedLabelTemplate75x45(
      qrCode: data.labelNumber ?? '',
      title: Text(
        data.typeBody ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      subTitle: Text(
        data.instructionNo ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Text(
              '(${data.materialCode})${data.materialName}'
                  .allowWordTruncation(),
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold,
                fontSize: 16.5,
                height: 1,
              ),
              maxLines: 2,
            ),
          ),
          const Text(
            'GW：0KG NW：0KG',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Text(
            'MEAS:No Data',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          )
        ],
      ),
      bottomLeft: Center(
        child: Text(
          '${data.quantity.toShowString()}${data.unit}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      bottomMiddle: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'page：${data.numPage}#',
            style: const TextStyle(fontWeight: FontWeight.bold, height: 1),
          ),
          const Text(
            'Made in China',
            style: TextStyle(fontWeight: FontWeight.bold, height: 1),
          ),
        ],
      ),
      bottomRight: Center(
        child: Text(
          '${data.size}#',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    );
  }

  Widget _warehouseOther(ReprintLabelInfo data) {
    return fixedLabelTemplate75x45(
      qrCode: data.labelNumber ?? '',
      title: Text(
        data.typeBody ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      subTitle: Text(
        data.instructionNo ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      content: Text(
        '(${data.materialCode})${data.materialName}'.allowWordTruncation(),
        style: const TextStyle(
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.bold,
          fontSize: 16.5,
          height: 1,
        ),
        maxLines: 3,
      ),
      bottomLeft: Text(
        '页码：${data.numPage}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      bottomMiddle: Text(
        data.quantity.toShowString(),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      bottomRight: Text(
        data.unit ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }
}
