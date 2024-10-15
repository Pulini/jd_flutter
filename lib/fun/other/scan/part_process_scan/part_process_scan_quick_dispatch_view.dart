import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/other/scan/part_process_scan/part_process_scan_dispatch_view.dart';
import 'package:jd_flutter/fun/other/scan/part_process_scan/part_process_scan_logic.dart';
import 'package:jd_flutter/utils/utils.dart';
import '../../../../bean/http/response/scan_barcode_info.dart';
import '../../../../bean/http/response/worker_info.dart';
import '../../../../widget/combination_button_widget.dart';
import '../../../../widget/custom_widget.dart';
import '../../../../widget/edit_text_widget.dart';
import '../../../../widget/wave_progress/wave_progress.dart';

class PartProcessScanQuickDispatchPage extends StatefulWidget {
  const PartProcessScanQuickDispatchPage({super.key});

  @override
  State<PartProcessScanQuickDispatchPage> createState() =>
      _PartProcessScanQuickDispatchPageState();
}

class _PartProcessScanQuickDispatchPageState
    extends State<PartProcessScanQuickDispatchPage> {
  final logic = Get.find<PartProcessScanLogic>();
  final state = Get.find<PartProcessScanLogic>().state;

  _workerItem(WorkerInfo wi, Distribution dis) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child:avatarPhoto(wi.picUrl),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            textSpan(
                              hint: '员工：',
                              text: '${wi.empName}<${wi.empCode}>',
                              textColor: Colors.blue.shade900,
                              fontSize: 18,
                            ),
                            NumberDecimalEditText(
                              initQty: dis.distributionQty.mul(100),
                              max: logic.getWorkerPercentageMax(dis.empId),
                              hint: '请填写分配比',
                              onChanged: (d) => setState(() {
                                dis.distributionQty = d.div(100);
                              }),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Slider(
                  value: dis.distributionQty.mul(100),
                  max: 100,
                  divisions: 1000,
                  label: '${dis.distributionQty.mul(100)}%',
                  secondaryTrackValue: logic.getWorkerPercentageMax(dis.empId),
                  onChanged: (d) {
                    var max = logic.getWorkerPercentageMax(dis.empId);
                    setState(() {
                      dis.distributionQty = (d > max ? max : d)
                          .mul(10)
                          .round()
                          .toDouble()
                          .div(1000);
                    });
                  },
                ),
              ),
              Text('${dis.distributionQty.mul(100)}%'),
              const SizedBox(width: 10)
            ],
          ),
        )
      ],
    );
  }

  @override
  void initState() {
    logic.initPercentageList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '快速分配',
      actions: [
        TextButton(
          onPressed: () =>logic.quickPercentage(),
          child: Text('分配'),
        )
      ],
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: LinearProgress(
                  borderRadius: 10,
                  value: logic.getPercentage(),
                  valueColor: AlwaysStoppedAnimation(Colors.blue.shade200),
                  backgroundColor: Colors.white,
                  borderColor: Colors.blue.shade100,
                  borderWidth: 2,
                  direction: Axis.vertical,
                  center: Text(logic.getPercentageText()), //中间显示的组件
                ),
              ),
              Expanded(
                  child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(left: 10),
                      itemCount: state.workerList.length + 1,
                      itemBuilder: (c, i) => i == state.workerList.length
                          ? addWorkerItem(
                              state.workerList,
                              callback: (w) => logic.addWorkerPercentage(w),
                            )
                          : _workerItem(
                              state.workerList[i],
                              state.workerPercentageList[i],
                            ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CombinationButton(
                          text: '保存当前比例',
                          click: () =>logic.savePercentage(),
                          combination: Combination.left,
                        ),
                      ),
                      Expanded(
                        child: CombinationButton(
                          text: '应用上次比例',
                          click: () =>logic.usePercentage(),
                          combination: Combination.right,
                        ),
                      ),
                    ],
                  )
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}
