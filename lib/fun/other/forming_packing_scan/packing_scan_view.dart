import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/other/forming_packing_scan/packing_scan_logic.dart';

import '../../../../bean/http/response/container_scanner_info.dart';
import '../../../../widget/custom_widget.dart';
import '../../../../widget/picker/picker_view.dart';


class PackingScanPage extends StatefulWidget {
  const PackingScanPage({super.key});

  @override
  State<PackingScanPage> createState() => _PackingScanPageState();
}

class _PackingScanPageState extends State<PackingScanPage> {
  final logic = Get.put(PackingScanLogic());
  final state = Get.find<PackingScanLogic>().state;

  _item(ContainerScanner data) {
    return GestureDetector(
      onTap: () => {
        logic.goShipment(data.ZZKHXH1.toString())
      },
      child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Row(
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
          )),
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
          Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Column(
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
                      expandedFrameText(
                        text: '已发/应出',
                        backgroundColor: Colors.blue.shade50,
                        flex: 1,
                      )
                    ],
                  ),
                ],
              )),
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
  void dispose() {
    Get.delete<PackingScanLogic>();
    super.dispose();
  }
}
