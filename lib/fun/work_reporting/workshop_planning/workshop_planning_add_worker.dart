import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_logic.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

class WorkshopPlanningAddWorkerPage extends StatefulWidget {
  const WorkshopPlanningAddWorkerPage({super.key});

  @override
  State<WorkshopPlanningAddWorkerPage> createState() =>
      _WorkshopPlanningAddWorkerPageState();
}

class _WorkshopPlanningAddWorkerPageState
    extends State<WorkshopPlanningAddWorkerPage> {
  final WorkshopPlanningLogic logic = Get.find<WorkshopPlanningLogic>();
  final WorkshopPlanningState state = Get.find<WorkshopPlanningLogic>().state;
  var cWorkerType = FixedExtentScrollController();
  var tecWorkerNumber = TextEditingController();
  var tecManHours = TextEditingController();
  var tecCoefficient = TextEditingController();
  String flowProcessID = Get.arguments['flowProcessID'];
  String date = Get.arguments['date'];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logic.initAddWorker(
        workerType: cWorkerType,
        workerNumber: tecWorkerNumber,
        manHours: tecManHours,
        coefficient: tecCoefficient,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: state.worker == null ? '添加员工' : '修改员工',
      actions: [
        CombinationButton(
          text: state.worker == null ? '添加' : '修改',
          click: () => logic.addOrModifyWorkerData(
            workerType: cWorkerType,
            workerNumber: tecWorkerNumber,
            manHours: tecManHours,
            coefficient: tecCoefficient,
          ),
        )
      ],
      body: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  flex: 7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 40,
                        margin: const EdgeInsets.only(left: 5, right: 5),
                        padding: const EdgeInsets.only(top: 3, bottom: 3),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                controller: tecWorkerNumber,
                                onChanged: (v) => logic.getWorkerInfo(
                                  flowProcessID: flowProcessID,
                                  number: v,
                                  date: date,
                                  workerType: cWorkerType,
                                  workerNumber: tecWorkerNumber,
                                  manHours: tecManHours,
                                  coefficient: tecCoefficient,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(
                                    top: 0,
                                    bottom: 0,
                                    left: 10,
                                    right: 10,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[300],
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  ),
                                  labelText: '工号',
                                  labelStyle:
                                      const TextStyle(color: Colors.black54),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            SizedBox(
                              width: 80,
                              child: TextField(
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp('[0-9.]'))
                                ],
                                controller: tecManHours,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(
                                    top: 0,
                                    bottom: 0,
                                    left: 10,
                                    right: 10,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[300],
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  ),
                                  labelText: '工时',
                                  labelStyle:
                                      const TextStyle(color: Colors.black54),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 40,
                        margin: const EdgeInsets.only(left: 5, right: 5),
                        padding: const EdgeInsets.only(
                          left: 5,
                          right: 5,
                          top: 3,
                          bottom: 3,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey.shade200,
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Obx(() => Text(
                                    state.minCoefficient.value.toShowString(),
                                    textAlign: TextAlign.center,
                                  )),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp('[0-9.]'))
                                ],
                                controller: tecCoefficient,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(
                                    top: 0,
                                    bottom: 0,
                                    left: 10,
                                    right: 10,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[300],
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  ),
                                  labelText: '基数',
                                  labelStyle:
                                      const TextStyle(color: Colors.black54),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Obx(() => Text(
                                    state.maxCoefficient.value.toShowString(),
                                    textAlign: TextAlign.center,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 6,
                  child:SelectView(
                        list: state.workTypeList,
                        controller: cWorkerType,
                        hint: '选择工种',
                        select: (i) => logic.changeWorkerType(
                          coefficient: tecCoefficient,
                          index: i,
                        ),
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() => GridView.builder(
                  padding: const EdgeInsets.all(5),
                  itemCount: state.workerList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 5 / 3,
                  ),
                  itemBuilder: (c, i) => _AddWorkerGridItem(
                    index: i,
                    logic: logic,
                    state: state,
                    cWorkerType: cWorkerType,
                    tecWorkerNumber: tecWorkerNumber,
                    tecManHours: tecManHours,
                    tecCoefficient: tecCoefficient,
                  ),
                )),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cWorkerType.dispose();
    tecWorkerNumber.dispose();
    tecManHours.dispose();
    tecCoefficient.dispose();
    super.dispose();
  }
}

class _AddWorkerGridItem extends StatelessWidget {
  final int index;
  final WorkshopPlanningLogic logic;
  final WorkshopPlanningState state;
  final FixedExtentScrollController cWorkerType;
  final TextEditingController tecWorkerNumber;
  final TextEditingController tecManHours;
  final TextEditingController tecCoefficient;

  const _AddWorkerGridItem({
    required this.index,
    required this.logic,
    required this.state,
    required this.cWorkerType,
    required this.tecWorkerNumber,
    required this.tecManHours,
    required this.tecCoefficient,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
          onTap: () => logic.selectWorker(
            worker: state.workerList[index].deepCopy(),
            workerType: cWorkerType,
            workerNumber: tecWorkerNumber,
            manHours: tecManHours,
            coefficient: tecCoefficient,
          ),
          child: Container(
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [Colors.green.shade100, Colors.blue.shade200],
                begin: Alignment.topCenter,
                end: Alignment.bottomRight,
              ),
              border: state.workerListSelectedIndex.value == index
                  ? Border.all(
                      color: Colors.green,
                      width: 2,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '(${state.workerList[index].number})',
                  style: const TextStyle(fontSize: 10),
                ),
                Text(state.workerList[index].name ?? ''),
              ],
            ),
          ),
        ));
  }
}
