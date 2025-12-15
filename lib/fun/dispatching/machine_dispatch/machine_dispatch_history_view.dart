import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/dispatching/machine_dispatch/machine_dispatch_logic.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class MachineDispatchHistoryPage extends StatefulWidget {
  const MachineDispatchHistoryPage({super.key});

  @override
  State<MachineDispatchHistoryPage> createState() =>
      _MachineDispatchHistoryPageState();
}

class _MachineDispatchHistoryPageState
    extends State<MachineDispatchHistoryPage> {
  final logic = Get.find<MachineDispatchLogic>();
  final state = Get.find<MachineDispatchLogic>().state;

  @override
  Widget build(BuildContext context) {
    return pageBody(
      body: ListView.builder(
        itemCount: state.historyInfo.length,
        itemBuilder: (c, i) => GestureDetector(
          child: Container(
            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade100, Colors.green.shade50],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey, width: 2),
            ),
            child: Row(
              children: [
                expandedTextSpan(
                  hint: '派工单号：',
                  text: state.historyInfo[i].dispatchNumber ?? '',
                ),
                expandedTextSpan(
                  hint: '机台：',
                  text: state.historyInfo[i].machine ?? '',
                ),
                expandedTextSpan(
                  hint: '班次：',
                  text: state.historyInfo[i].shift ?? '',
                ),
              ],
            ),
          ),
          onTap: () => logic.getHistoryStockInLabelInfo(i),
        ),
      ),
    );
  }

  @override
  void dispose() {
    state.historyInfo.value = [];
    super.dispose();
  }
}

class MachineDispatchHistoryDetailPage extends StatefulWidget {
  const MachineDispatchHistoryDetailPage({super.key});

  @override
  State<MachineDispatchHistoryDetailPage> createState() =>
      _MachineDispatchHistoryDetailPageState();
}

class _MachineDispatchHistoryDetailPageState
    extends State<MachineDispatchHistoryDetailPage> {
  final logic = Get.find<MachineDispatchLogic>();
  final state = Get.find<MachineDispatchLogic>().state;
  final index = Get.arguments['index'];

  @override
  Widget build(BuildContext context) {
    return pageBody(
      body: ListView.builder(
        itemCount: state.historyLabelInfo.length,
        itemBuilder: (c, i) => GestureDetector(
          child: Container(
              margin: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade100, Colors.green.shade50],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey, width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      expandedTextSpan(
                        flex: 2,
                        hint: '物料名称：',
                        text: state.historyLabelInfo[i].materialName,
                      ),
                      expandedTextSpan(
                        hint: '派工日期：',
                        text: state.historyLabelInfo[i].date,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      expandedTextSpan(
                        hint: '型体：',
                        text: state.historyLabelInfo[i].factoryType,
                      ),
                      expandedTextSpan(
                        hint: '尺码：',
                        text: state.historyLabelInfo[i].size,
                      ),
                      expandedTextSpan(
                        hint: '数量：',
                        text: state.historyLabelInfo[i].qty.toShowString(),
                      ),
                      expandedTextSpan(
                        hint: '序号：',
                        text: state.historyLabelInfo[i].number,
                      ),
                    ],
                  ),
                ],
              )),
          onTap: () => askDialog(
            content: '确定要打印该贴标吗？',
            confirm: () => logic.printHistoryLabel(i),
          ),
        ),
      ),
    );
  }
}
