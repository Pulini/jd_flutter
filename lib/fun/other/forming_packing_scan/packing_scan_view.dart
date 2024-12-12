import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/other/forming_packing_scan/packing_scan_logic.dart';

import '../../../../bean/http/response/container_scanner_info.dart';
import '../../../../widget/custom_widget.dart';
import '../../../../widget/picker/picker_view.dart';
import '../../../widget/dialogs.dart';

class PackingScanPage extends StatefulWidget {
  const PackingScanPage({super.key});

  @override
  State<PackingScanPage> createState() => _PackingScanPageState();
}

class _PackingScanPageState extends State<PackingScanPage> {
  final logic = Get.put(PackingScanLogic());
  final state = Get.find<PackingScanLogic>().state;

  ///带框、带点击事件带文本
  expandedLeftFrameText({
    Function? click,
    Color? backgroundColor,
    Color? textColor,
    int? flex,
    EdgeInsetsGeometry? padding,
    AlignmentGeometry? alignment,
    bool isBold = false,
    required String text,
  }) {
    return Expanded(
      flex: flex ?? 1,
      child: GestureDetector(
        onTap: () => click?.call(),
        child: Container(
          padding: padding ?? const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: const Border(
                top: BorderSide(width: 1, color: Colors.grey),
                bottom: BorderSide(width: 1, color: Colors.grey),
                right: BorderSide(width: 1, color: Colors.grey)),
            color: backgroundColor ?? Colors.transparent,
          ),
          alignment: alignment ?? Alignment.centerLeft,
          child: Text(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text,
            style: TextStyle(
              color: textColor ?? Colors.black87,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  _item(ContainerScanner data) {
    return GestureDetector(
      onTap: () => {
        state.getShipmentInformation(
            time: logic.pickerControllerDate
                .getDateFormatYMD()
                .replaceAll('-', ''),
            cabinetNumber: data.ZZKHXH1,
            error: (String msg) {
              errorDialog(content: msg);
            }),
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              expandedFrameText(
                text: data.ZZKHXH1.toString(),
                backgroundColor: Colors.blue.shade50,
                flex: 1,
              ),
              expandedFrameText(
                text: '${data.YFXS}/${data.ZZYCXS}',
                backgroundColor: Colors.blue.shade50,
                flex: 1,
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        actions: [],
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: DatePicker(pickerController: logic.pickerControllerDate),
          ),
          const SizedBox(
            height: 10,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  expandedFrameText(
                    text: '柜号',
                    backgroundColor: Colors.blue.shade50,
                    flex: 1,
                  ),
                  expandedLeftFrameText(
                    text: '已发/应出',
                    backgroundColor: Colors.blue.shade50,
                    flex: 1,
                  )
                ],
              ),
            ],
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: state.dataList.length,
                itemBuilder: (BuildContext context, int index) =>
                    _item(state.dataList.toList()[index]),
              ),
            ),
          )
        ]));
  }

  @override
  void didChangeDependencies() {
    state.getAllData(
        time: logic.pickerControllerDate.getDateFormatYMD().replaceAll('-', ''),
        error: (msg) => errorDialog(content: msg));
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    Get.delete<PackingScanLogic>();
    super.dispose();
  }
}
