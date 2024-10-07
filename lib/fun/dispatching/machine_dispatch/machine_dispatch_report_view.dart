import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import '../../../bean/http/response/machine_dispatch_info.dart';
import 'machine_dispatch_dialog.dart';
import 'machine_dispatch_logic.dart';

class MachineDispatchReportPage extends StatefulWidget {
  const MachineDispatchReportPage({super.key});

  @override
  State<MachineDispatchReportPage> createState() =>
      _MachineDispatchReportPageState();
}

class _MachineDispatchReportPageState extends State<MachineDispatchReportPage> {
  final logic = Get.find<MachineDispatchLogic>();
  final state = Get.find<MachineDispatchLogic>().state;

  @override
  void initState() {
    state.createDispatchProcess();
    super.initState();
  }

  itemTitle() => SizedBox(
        width: 100,
        child: Column(
          children: [
            expandedFrameText(
              text: '尺码',
              backgroundColor: Colors.blue.shade300,
              textColor: Colors.white,
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: '报工数量',
              backgroundColor: Colors.green.shade200,
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: '本班未满箱数',
              backgroundColor: Colors.orange.shade100,
              alignment: Alignment.center,
            ),
          ],
        ),
      );

  item(Items data, RxBool isSelect) => SizedBox(
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
            text: '合计',
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

  processItem(DispatchProcessInfo data) {
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
                hint: '工序：',
                text: '<${data.processNumber}> ${data.processName}',
                fontSize: 20,
              ),
              Text.rich(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                TextSpan(
                  children: [
                    const TextSpan(text: '已分配< '),
                    TextSpan(
                      text: data.dispatchList.length.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const TextSpan(text: ' >名员工，剩余可分配产量：'),
                    TextSpan(
                      text: data.getSurplus().toShowString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: data.getSurplus() == 0
                            ? Colors.green
                            : data.getSurplus() < 0
                                ? Colors.redAccent
                                : Colors.blue,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: data.dispatchList.length,
                    itemBuilder: (_, i) => workerItem(data, i),
                  ),
                ),
                GestureDetector(
                  onTap: () => data.totalProduction > 1
                      ? addDispatchWorker(data, () => setState(() {}))
                      : errorDialog(content: '无剩余可分配产量！'),
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

  workerItem(DispatchProcessInfo dpi, int index) {
    var data = dpi.dispatchList[index];
    var avatar = Padding(
      padding: const EdgeInsets.all(5),
      child:avatarPhoto(data.workerAvatar),
    );
    return GestureDetector(
      onTap: () => workerSignature(context, data, () => logic.signatureIdenticalWorker(data)),
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
                    hint: '姓名：',
                    text: data.workerName ?? '',
                    textColor: Colors.blue.shade900,
                    fontSize: 18,
                  ),
                  textSpan(
                    hint: '工号：',
                    text: data.workerNumber ?? '',
                    textColor: Colors.blue.shade900,
                    fontSize: 14,
                  ),
                  textSpan(
                    hint: '产量：',
                    text: data.dispatchQty.toShowString(),
                    textColor: Colors.red,
                    fontSize: 14,
                  )
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                if (data.signature == null) {
                  dpi.dispatchList.removeAt(index);
                  setState(() {});
                } else {
                  askDialog(
                    content: '员工< ${data.workerName} >已签字！！！\n确定要删除该员工吗？',
                    confirm: () {
                      dpi.dispatchList.removeAt(index);
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
                    Icons.delete_forever_rounded,
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
  Widget build(BuildContext context) {
    return pageBody(
      actions: [CombinationButton(text: '报工', click: () => logic.report())],
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
                itemCount: state.processList.length,
                itemBuilder: (context, index) =>
                    processItem(state.processList[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
