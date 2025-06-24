import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/scan_barcode_info.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/fun/work_reporting/part_process_scan/part_process_scan_logic.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/worker_check_widget.dart';

class PartProcessScanDispatchPage extends StatefulWidget {
  const PartProcessScanDispatchPage({super.key});

  @override
  State<PartProcessScanDispatchPage> createState() =>
      _PartProcessScanDispatchPageState();
}

addWorkerItem(
  RxList<WorkerInfo> workerList, {
  Function(WorkerInfo)? callback,
}) {
  WorkerInfo? newWorker;
  var picUrl = ''.obs;
  var icon = const Icon(
    Icons.add_reaction_outlined,
    color: Colors.blue,
    size: 80,
  );
  return Obx(
    () => Container(
      decoration: BoxDecoration(
        color: newWorker != null &&
                !workerList.any((v) => v.empID == newWorker!.empID)
            ? Colors.blue.shade100
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const SizedBox(height: 5),
          Row(
            children: [
              const SizedBox(width: 10),
              SizedBox(
                width: 100,
                child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: picUrl.isNotEmpty
                        ? Image.network(
                            fit: BoxFit.fill,
                            picUrl.value,
                            errorBuilder: (ctx, err, stackTrace) => icon,
                          )
                        : icon,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        newWorker == null
                            ? 'part_process_scan_dispatch_add_temp'.tr
                            : workerList.any((v) => v.empID == newWorker!.empID)
                                ? 'part_process_scan_dispatch_members_exists'.tr
                                : 'part_process_scan_dispatch_members_can_add'
                                    .tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: newWorker == null
                              ? Colors.black87
                              : workerList
                                      .any((v) => v.empID == newWorker!.empID)
                                  ? Colors.red
                                  : Colors.green.shade900,
                        ),
                      ),
                    ),
                    WorkerCheck(
                      onChanged: (w) {
                        newWorker = w;
                        if (newWorker != null) {
                          picUrl.value = newWorker!.picUrl ?? '';
                        } else {
                          picUrl.value = '';
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              color: newWorker != null &&
                      !workerList.any((v) => v.empID == newWorker!.empID)
                  ? Colors.green.shade200
                  : Colors.red.shade100,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Center(
              child: TextButton(
                  onPressed: () {
                    if (newWorker == null) {
                      showSnackBar(
                        message:
                            'part_process_scan_dispatch_input_worker_number_tips'
                                .tr,
                        isWarning: true,
                      );
                      return;
                    }
                    if (workerList.any((v) => v.empID == newWorker!.empID)) {
                      showSnackBar(
                        message: 'part_process_scan_dispatch_worker_exists'.tr,
                        isWarning: true,
                      );
                      return;
                    }
                    workerList.add(newWorker!);
                    callback?.call(newWorker!);
                  },
                  child: Text(
                    'part_process_scan_dispatch_add'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: newWorker != null &&
                              !workerList
                                  .any((v) => v.empID == newWorker!.empID)
                          ? Colors.blue.shade900
                          : Colors.grey,
                    ),
                  )),
            ),
          )
        ],
      ),
    ),
  );
}

class _PartProcessScanDispatchPageState
    extends State<PartProcessScanDispatchPage> {
  final logic = Get.find<PartProcessScanLogic>();
  final state = Get.find<PartProcessScanLogic>().state;
  var index = Get.arguments['Index'];
  bool isSharing = spGet('${Get.currentRoute}/isSharing') ?? false;

  _workerItem(WorkerInfo wi) {
    var surplus =
        state.modifyDistributionList[index].getSurplusQty(wi.empID ?? 0);
    var dis = state.modifyDistributionList[index]
        .getDistributionWorker(wi.empID ?? 0);
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() {
            if (dis == null) {
              if (isSharing) {
                state.modifyDistributionList[index].distribution
                    .add(Distribution(
                  name: wi.empName ?? '',
                  number: wi.empCode ?? '',
                  empId: wi.empID ?? 0,
                  distributionQty: surplus,
                ));
                state.modifyDistributionList[index].sharingDistribution();
              } else {
                if (surplus > 0) {
                  state.modifyDistributionList[index].distribution
                      .add(Distribution(
                    name: wi.empName ?? '',
                    number: wi.empCode ?? '',
                    empId: wi.empID ?? 0,
                    distributionQty: surplus,
                  ));
                } else {
                  showSnackBar(
                    message:
                        'part_process_scan_dispatch_allocation_qty_zero_tips'
                            .tr,
                    isWarning: true,
                  );
                }
              }
            } else {
              state.modifyDistributionList[index].distribution.remove(dis);
              if (isSharing) {
                state.modifyDistributionList[index].sharingDistribution();
              }
            }
          }),
          child: Container(
            height: 100,
            margin: EdgeInsets.only(bottom: dis != null ? 0 : 15),
            decoration: BoxDecoration(
              color: dis != null ? Colors.green.shade100 : Colors.grey.shade200,
              borderRadius: dis != null
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    )
                  : const BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: avatarPhoto(wi.picUrl),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            textSpan(
                              hint: 'part_process_scan_dispatch_worker'.tr,
                              text: '${wi.empName}<${wi.empCode}>',
                              textColor: Colors.blue.shade900,
                              fontSize: 18,
                            ),
                            dis != null
                                ? NumberDecimalEditText(
                                    initQty: dis.distributionQty,
                                    max: surplus,
                                    hint:
                                        'part_process_scan_dispatch_input_allocation_qty_tips'
                                            .tr,
                                    onChanged: (d) {
                                      setState(() {
                                        dis.distributionQty = d;
                                      });
                                      state.modifyDistributionList[index]
                                          .reportList
                                          .refresh();
                                    },
                                  )
                                : Text(
                                    'part_process_scan_dispatch_allocation_this_worker'
                                        .tr),
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
        if (dis != null)
          Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: (dis.distributionQty.div(state
                            .modifyDistributionList[index]
                            .getProcessMax()))
                        .mul(100),
                    max: 100,
                    divisions: 1000,
                    label:
                        '${(dis.distributionQty.div(state.modifyDistributionList[index].getProcessMax())).mul(10000).round().toDouble().div(100).toShowString()}%',
                    secondaryTrackValue: (surplus.div(state
                            .modifyDistributionList[index]
                            .getProcessMax()))
                        .mul(100),
                    onChanged: (v) {
                      if (!isSharing) {}
                      setState(() {
                        var max = (surplus.div(state
                                .modifyDistributionList[index]
                                .getProcessMax()))
                            .mul(100);
                        dis.distributionQty = state
                            .modifyDistributionList[index]
                            .getProcessMax()
                            .mul(v > max ? max : v)
                            .round()
                            .toDouble()
                            .div(100);
                      });
                      state.modifyDistributionList[index].reportList.refresh();
                    },
                  ),
                ),
                Text(
                    '${(dis.distributionQty.div(state.modifyDistributionList[index].getProcessMax())).mul(10000).round().toDouble().div(100).toShowString()}%'),
                const SizedBox(width: 10)
              ],
            ),
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'part_process_scan_dispatch_allocation_report'.tr,
      actions: [
        CheckBox(
          onChanged: (c) => setState(() {
            isSharing = c;
            spSave('${Get.currentRoute}/isSharing', c);
          }),
          name: 'part_process_scan_dispatch_sharing'.tr,
          value: isSharing,
        )
      ],
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.modifyDistributionList[index].reportList[0].name ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.blue.shade900,
              ),
            ),
            textSpan(
              hint: 'part_process_scan_dispatch_surplus_allocation_qty'.tr,
              text: state.modifyDistributionList[index]
                  .getProcessSurplus()
                  .toShowString(),
              textColor:
                  state.modifyDistributionList[index].getProcessSurplus() > 0
                      ? Colors.green
                      : Colors.red,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: state.workerList.length + 1,
                  itemBuilder: (c, i) => i == state.workerList.length
                      ? addWorkerItem(state.workerList)
                      : _workerItem(state.workerList[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
