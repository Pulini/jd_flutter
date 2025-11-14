import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/machine_dispatch_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'machine_dispatch_dialog.dart';
import 'machine_dispatch_logic.dart';

class MachineDispatchHandoverPage extends StatefulWidget {
  const MachineDispatchHandoverPage({super.key});

  @override
  State<MachineDispatchHandoverPage> createState() =>
      _MachineDispatchReportPageState();
}

class _MachineDispatchReportPageState extends State<MachineDispatchHandoverPage> {
  final logic = Get.find<MachineDispatchLogic>();
  final state = Get.find<MachineDispatchLogic>().state;

  itemTitle() => SizedBox(
        width: 100,
        child: Column(
          children: [
            expandedFrameText(
              text: 'machine_dispatch_report_size'.tr,
              backgroundColor: Colors.blue.shade300,
              textColor: Colors.white,
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: 'machine_dispatch_report_report_qty'.tr,
              backgroundColor: Colors.green.shade200,
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: 'machine_dispatch_report_current_shift_under_qty'.tr,
              backgroundColor: Colors.orange.shade100,
              alignment: Alignment.center,
            ),
          ],
        ),
      );

  SizedBox item(Items data, RxBool isSelect) => SizedBox(
        width: 70,
        child: Column(
          children: [
            expandedFrameText(
              text: data.size ?? '',
              backgroundColor: Colors.blue.shade300,
              textColor: Colors.white,
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: data.getReportQty().toShowString(),
              backgroundColor: Colors.green.shade200,
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: data.notFullQty.toShowString(),
              backgroundColor: Colors.orange.shade100,
              alignment: Alignment.center,
            ),
          ],
        ),
      );

  totalItem(List<Items> data) {
    var notFullQty = 0.0;
    var reportQty = 0.0;
    for (var v in data) {
      notFullQty = notFullQty.add(v.notFullQty ?? 0.0);
      reportQty = reportQty.add(v.getReportQty());
    }
    return SizedBox(
      width: 70,
      child: Column(
        children: [
          expandedFrameText(
            text: 'machine_dispatch_report_total'.tr,
            backgroundColor: Colors.blue.shade300,
            textColor: Colors.white,
            alignment: Alignment.center,
          ),
          expandedFrameText(
            text: reportQty.toShowString(),
            backgroundColor: Colors.green.shade200,
            alignment: Alignment.center,
          ),
          expandedFrameText(
            text: notFullQty.toShowString(),
            backgroundColor: Colors.orange.shade100,
            alignment: Alignment.center,
          ),
        ],
      ),
    );
  }

  handoverItem(HandoverInfo data, int index) {
    return Container(
      height: 140,
      margin: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              expandedTextSpan(
                hint: '',
                text: data.personal,
                fontSize: 20,
              ),
            ],
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: data.handoverInfoDispatchList.length,
                    itemBuilder: (_, i) => workerItem(data, i),
                  ),
                ),
                GestureDetector(
                  onTap: () => addHandoverWorker(data, () => setState(() {})),
                  child: Container(
                    width: 50,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.green.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.group_add,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  workerItem(HandoverInfo dpi, int index) {
    var data = dpi.handoverInfoDispatchList[index];
    var avatar = Padding(
      padding: const EdgeInsets.all(5),
      child: avatarPhoto(data.workerAvatar),
    );
    return GestureDetector(
      onTap: () => workerSignature(
          context, data, () => logic.signatureIdenticalWorker(data)),
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: data.signature == null
              ? Colors.orange.shade200
              : Colors.green.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => showWorkerAvatar(avatar),
              child: avatar,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textSpan(
                    hint: 'machine_dispatch_report_name'.tr,
                    text: data.workerName ?? '',
                    textColor: Colors.blue.shade900,
                    fontSize: 18,
                  ),
                  textSpan(
                    hint: 'machine_dispatch_report_worker'.tr,
                    text: data.workerNumber ?? '',
                    textColor: Colors.blue.shade900,
                    fontSize: 14,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                if (data.signature == null) {
                  dpi.handoverInfoDispatchList.removeAt(index);
                  setState(() {});
                } else {
                  askDialog(
                    content:
                        'machine_dispatch_report_delete_signed_tips'.trArgs([
                      data.workerName ?? '',
                    ]),
                    confirm: () {
                      dpi.handoverInfoDispatchList.removeAt(index);
                      setState(() {});
                    },
                  );
                }
              },
              child: Container(
                width: 30,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    state.createDispatchProcess();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        CombinationButton(
            text: '交接',
            click: () => askDialog(content: '确认要进行交接吗?',confirm: (){
              logic.handover();
            }))
      ],
      body: Column(
        children: [
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(10),
              children: [
                if (state.sizeItemList.isNotEmpty) itemTitle(),
                for (var i = 0; i < state.sizeItemList.length; ++i)
                  item(state.sizeItemList[i], state.selectList[i]),
                if (state.sizeItemList.isNotEmpty) totalItem(state.sizeItemList)
              ],
            ),
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.only(left: 5, right: 5),
                itemCount: state.handoverList.length,
                itemBuilder: (context, index) =>
                    handoverItem(state.handoverList[index],index),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
