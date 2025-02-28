import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/production_dispatch_order_detail_info.dart';
import 'package:jd_flutter/fun/dispatching/production_dispatch/production_dispatch_dialogs.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';
import 'production_dispatch_logic.dart';

class ProductionDispatchDetailPage extends StatefulWidget {
  const ProductionDispatchDetailPage({super.key});

  @override
  State<ProductionDispatchDetailPage> createState() =>
      _ProductionDispatchDetailPageState();
}

class _ProductionDispatchDetailPageState
    extends State<ProductionDispatchDetailPage> {
  final logic = Get.find<ProductionDispatchLogic>();
  final state = Get.find<ProductionDispatchLogic>().state;

  _titleDetails() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: Text(
                  state.workCardTitle.value.getDispatchTotal(),
                ),
              ),
              Expanded(
                child: Text(
                  state.workCardTitle.value.getTodayGoal(),
                ),
              ),
              Expanded(
                child: Text(
                  state.workCardTitle.value.getReported(),
                ),
              ),
              Expanded(
                child: Text(
                  state.workCardTitle.value.getUnderCount(),
                ),
              ),
              Expanded(
                child: Text(
                  state.workCardTitle.value.getAccumulateReportCount(),
                ),
              ),
              Expanded(
                child: Text(
                  state.workCardTitle.value.getReportedCount(),
                ),
              ),
            ],
          )),
    );
  }

  _operationButtons() {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: [
                CheckBox(
                  onChanged: (c) => setState(() => logic.checkAutoCount(c)),
                  name: 'production_dispatch_detail_sharing'.tr,
                  value: state.isCheckedAutoCount,
                ),
                CheckBox(
                  onChanged: (c) => setState(() => logic.checkDivideEqually(c)),
                  name: 'production_dispatch_detail_round_up'.tr,
                  value: state.isCheckedDivideEqually,
                ),
                CheckBox(
                  onChanged: (c) => setState(() => logic.checkRounding(c)),
                  name: 'production_dispatch_detail_next_process'.tr,
                  value: state.isCheckedRounding,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Obx(() => CombinationButton(
                combination: Combination.left,
                text: 'production_dispatch_detail_batch_record_working'.tr,
                isEnabled: state.isEnabledNextWorkProcedure.value,
                click: () => logic.detailViewNextWorkProcedure(),
              )),
          Obx(() => CombinationButton(
                combination: Combination.right,
                isEnabled: state.isEnabledBatchDispatch.value,
                text: 'production_dispatch_detail_add_worker'.tr,
                click: () => logic.detailViewBatchModifyDispatchClick(
                  (v1, v2) => batchModifyDispatchQtyDialog(
                    state.isCheckedDivideEqually,
                    state.isCheckedRounding,
                    v1,
                    v2,
                    (v3) => logic.detailViewBatchModifyDispatch(v1, v3),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  _workProcedure() {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade600,
            width: 2,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(5),
          itemCount: state.workProcedure.length,
          itemBuilder: (BuildContext context, int index) =>
              _workProcedureItem(state.workProcedure[index], index),
        ),
      ),
    );
  }

  _workProcedureItem(WorkCardList data, int index) {
    return Obx(() => Container(
          margin: const EdgeInsets.only(bottom: 5),
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade200,
                data.isOpen == 1 ? Colors.blue.shade200 : Colors.red.shade200
              ],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
            border: Border.all(
              color: state.workProcedureSelect.value == index
                  ? Colors.green
                  : Colors.grey.shade600,
              width: state.workProcedureSelect.value == index ? 4 : 2,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(
                  state.workProcedureSelect.value == index ? 12 : 10),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => logic.detailViewWorkProcedureLock(index),
                child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: data.isOpen == 1 ? Colors.blueAccent : Colors.red,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: Icon(
                    size: 30,
                    data.isOpen == 1
                        ? Icons.lock_open_outlined
                        : Icons.lock_outline,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => logic.detailViewWorkProcedureClick(index),
                  child: Container(
                    padding: const EdgeInsets.only(left: 10),
                    foregroundDecoration: data.isShowFlag()
                        ? const RotatedCornerDecoration.withColor(
                            color: Colors.orange,
                            badgeCornerRadius: Radius.circular(8),
                            badgeSize: Size(40, 40),
                            isEmoji: true,
                            textSpan: TextSpan(
                              text: '⭐️',
                              style: TextStyle(fontSize: 16, height: 1.3),
                            ),
                          )
                        : null,
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  data.getProcess(),
                                  style: TextStyle(
                                    color: data.isOpen == 1
                                        ? Colors.blue.shade900
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (data.isShowWarning())
                                const Expanded(
                                  child: Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.orange,
                                  ),
                                )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  data.getTotalString(),
                                  style: TextStyle(
                                    color: data.isOpen == 1
                                        ? Colors.grey.shade600
                                        : Colors.red,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  data.getFinishQtyString(),
                                  style: TextStyle(
                                    color: data.isOpen == 1
                                        ? Colors.grey.shade600
                                        : Colors.red,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  data.getSurplusQtyString(),
                                  style: TextStyle(
                                    color: data.isOpen == 1
                                        ? Colors.grey.shade600
                                        : Colors.red,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  _dispatch() {
    return Obx(() => Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade600,
                width: 2,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: 45,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: state.workProcedureSelect.value == -1
                          ? Colors.grey.shade500
                          : Colors.blue,
                      width: 4,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Obx(() => CombinationButton(
                            text: 'production_dispatch_detail_clean_tips'.tr,
                            isEnabled: state.isEnabledAddOne.value,
                            click: () => addWorkerDialog(
                              state.workerList,
                              logic.detailViewGetSelectedWorkerList(),
                              (v) => logic.detailViewModifyDispatch(works: v),
                            ),
                          )),
                      CheckBox(
                        onChanged: (c) {
                          logic.detailViewAddAllWorker(
                            () => askDialog(
                              content:
                                  'production_dispatch_detail_add_all_worker'
                                      .tr,
                              confirm: () =>
                                  logic.cleanDispatchFromWorkProcedure(),
                            ),
                          );
                        },
                        needSave: false,
                        name: 'production_dispatch_detail_select_all_worker'.tr,
                        isEnabled: state.isEnabledAddAllDispatch,
                        value: state.isCheckedAddAllDispatch,
                      ),
                      CheckBox(
                        onChanged: (c) => logic.checkSelectAllDispatch(c),
                        needSave: false,
                        name: 'production_dispatch_detail_close_all_process'.tr,
                        isEnabled: state.isEnabledSelectAllDispatch,
                        value: state.isCheckedSelectAllDispatch,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.count(
                      padding: const EdgeInsets.all(5),
                      crossAxisSpacing: 5.0,
                      mainAxisSpacing: 5.0,
                      crossAxisCount: 3,
                      childAspectRatio: 4 / 1,
                      children: state.dispatchInfo
                          .map((item) => _dispatchItem(item))
                          .toList()),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _dispatchItem(DispatchInfo data) {
    return GestureDetector(
      onTap: () => logic.detailViewDispatchItemClick(
        data,
        (surplus) =>
            modifyDispatchQtyDialog(data, surplus, (di) => setState(() => di)),
      ),
      onLongPress: () {
        setState(() => data.select = !data.select!);
        state.isCheckedSelectAllDispatch =
            !state.dispatchInfo.any((v) => !v.select!);
        state.isEnabledBatchDispatch.value =
            state.dispatchInfo.where((v) => v.select!).length > 1;
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade200, Colors.blue.shade100],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          border: Border.all(
            color: data.select! ? Colors.green : Colors.grey.shade600,
            width: data.select! ? 4 : 2,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(data.select! ? 12 : 10),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        data.getName(),
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        data.getQty(),
                        style: TextStyle(
                          color:
                              data.qty == 0 ? Colors.red : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => logic.detailViewDispatchItemDeleteClick(data),
              child: Container(
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: const Icon(
                  size: 30,
                  Icons.delete_forever,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _bottomButtons() {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: [
                Obx(() => CombinationButton(
                      combination: Combination.left,
                      text: state.isOpenedAllWorkProcedure.value
                          ? 'production_dispatch_detail_open_all_process'.tr
                          : 'production_dispatch_detail_last_dispatch'.tr,
                      click: () => logic.detailViewWorkProcedureLockAll(),
                    )),
                CombinationButton(
                  combination: Combination.middle,
                  text: 'production_dispatch_detail_now_dispatch'.tr,
                  click: () => showDispatchList(
                      context,
                      true,
                      state.batchWorkProcedure.isNotEmpty
                          ? state.batchWorkProcedure
                          : state.workProcedure, (i1, i2) {
                    logic.detailViewJumpToDispatchOnWorkProcedure(
                      i1,
                      i2,
                      (data, surplus) => modifyDispatchQtyDialog(
                        data,
                        surplus,
                        (di) => setState(() => di),
                      ),
                    );
                  }),
                ),
                CombinationButton(
                  combination: Combination.middle,
                  text: 'production_dispatch_detail_save_dispatch'.tr,
                  click: () => showDispatchList(
                      context, false, state.workProcedure, (i1, i2) {
                    logic.detailViewJumpToDispatchOnWorkProcedure(
                      i1,
                      i2,
                      (data, surplus) => modifyDispatchQtyDialog(
                        data,
                        surplus,
                        (di) => setState(() => di),
                      ),
                    );
                  }),
                ),
                if (GetPlatform.isMobile)
                  CombinationButton(
                    combination: Combination.middle,
                    text: 'production_dispatch_detail_apply_dispatch'.tr,
                    click: () => logic.saveDispatch(),
                  ),
                if (GetPlatform.isMobile)
                  CombinationButton(
                    combination: Combination.middle,
                    text: 'production_dispatch_detail_manual'.tr,
                    click: () => SaveWorkProcedure.getSave(
                      state.workCardTitle.value.plantBody ?? '',
                      (list) => typeBodySaveDialog(
                        list,
                        () => logic.saveWorkProcedure(),
                        (v) => logic.applySaveWorkProcedure(v),
                      ),
                    ),
                  ),
                CombinationButton(
                  combination: Combination.middle,
                  text: 'production_dispatch_detail_material_list'.tr,
                  click: () => logic.detailViewGetManufactureInstructions(
                    (list) => manufactureInstructionsDialog(list),
                  ),
                ),
                CombinationButton(
                  combination: Combination.right,
                  text: 'production_dispatch_detail_process_check'.tr,
                  click: () => logic.getWorkPlanMaterial(
                      (list) => workPlanMaterialDialog(list)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          CombinationButton(
            combination: Combination.left,
            text: 'production_dispatch_detail_auto_input'.tr,
            click: () => logic.getPrdRouteInfo(),
          ),
          CombinationButton(
            combination: Combination.middle,
            text: 'production_dispatch_detail_worker_check'.tr,
            click: () =>
                logic.checkDispatch(() => logic.sendDispatchToWechat()),
          ),
          CombinationButton(
            combination: Combination.right,
            text: 'production_dispatch_detail_process_dispatch'.tr,
            click: () => logic.checkDispatch(() => logic.productionDispatch()),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    state.detailViewGetWorkerList();
    SaveDispatch.getSave(
      state.workCardTitle.value.processBillNumber ?? '',
      (v) => askDialog(
        content: 'production_dispatch_detail_has_save_tips'.tr,
        confirm: () => logic.applySaveDispatch(v),
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        title: 'production_dispatch_detail_dispatch'.tr,
        body: Column(
          children: [
            _titleDetails(),
            _operationButtons(),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: _workProcedure(),
                  ),
                  Expanded(
                    flex: 7,
                    child: _dispatch(),
                  ),
                ],
              ),
            ),
            state.isSelectedMergeOrder ? Container() : _bottomButtons()
          ],
        ),
        actions: [
          if (state.workCardTitle.value.cardNoReportStatus == 1)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                'production_dispatch_detail_outsourcing'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                  fontSize: 20,
                ),
              ),
            )
        ]);
  }

  @override
  void dispose() {
    state.remake();
    super.dispose();
  }
}
