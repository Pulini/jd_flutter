import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/production_dispatch_order_detail_info.dart';
import 'package:jd_flutter/fun/dispatching/production_dispatch/production_dispatch_dialogs.dart';
import 'package:jd_flutter/fun/dispatching/production_dispatch/production_dispatch_state.dart';
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

  Widget _titleDetails() =>
      _DispatchDetailTitle(state: state);

  Widget _operationButtons() =>
      _DispatchDetailOperationButtons(logic: logic, state: state, setStateFn: setState);

  Widget _workProcedure() =>
      _DispatchDetailWorkProcedure(
        logic: logic,
        state: state,
        itemBuilder: (data, index) => _workProcedureItem(data, index),
      );

  Widget _workProcedureItem(WorkCardList data, int index) =>
      _DispatchDetailWorkProcedureItem(
        data: data,
        index: index,
        logic: logic,
        state: state,
      );

  Widget _dispatch() =>
      _DispatchDetailDispatch(
        logic: logic,
        state: state,
        itemBuilder: (item) => _dispatchItem(item),
      );

  Widget _dispatchItem(DispatchInfo data) =>
      _DispatchDetailDispatchItem(data: data, logic: logic, state: state);

  Widget _bottomButtons() =>
      _DispatchDetailBottomButtons(logic: logic, state: state, context: context);

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
            state.isSelectedMergeOrder.value ? Container() : _bottomButtons()
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

class _DispatchDetailWorkProcedureItem extends StatelessWidget {
  final WorkCardList data;
  final int index;
  final ProductionDispatchLogic logic;
  final ProductionDispatchState state;

  const _DispatchDetailWorkProcedureItem({
    required this.data,
    required this.index,
    required this.logic,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _DispatchDetailDispatchItem extends StatelessWidget {
  final DispatchInfo data;
  final ProductionDispatchLogic logic;
  final ProductionDispatchState state;

  const _DispatchDetailDispatchItem({
    required this.data,
    required this.logic,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => logic.detailViewDispatchItemClick(
        data,
        (surplus) => modifyDispatchQtyDialog(data, surplus, (di) => di),
      ),
      onLongPress: () {
        data.select = !data.select!;
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
}

class _DispatchDetailTitle extends StatelessWidget {
  final ProductionDispatchState state;

  const _DispatchDetailTitle({required this.state});

  @override
  Widget build(BuildContext context) {
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
}

class _DispatchDetailOperationButtons extends StatelessWidget {
  final ProductionDispatchLogic logic;
  final ProductionDispatchState state;
  final void Function(VoidCallback fn) setStateFn;

  const _DispatchDetailOperationButtons({
    required this.logic,
    required this.state,
    required this.setStateFn,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                CheckBox(
                  onChanged: (c) => setStateFn(() => logic.checkAutoCount(c)),
                  name: 'production_dispatch_detail_auto_input'.tr,
                  value: state.isCheckedAutoCount,
                ),
                CheckBox(
                  onChanged: (c) =>
                      setStateFn(() => logic.checkDivideEqually(c)),
                  name: 'production_dispatch_detail_sharing'.tr,
                  value: state.isCheckedDivideEqually,
                ),
                CheckBox(
                  onChanged: (c) => setStateFn(() => logic.checkRounding(c)),
                  name: 'production_dispatch_detail_round_up'.tr,
                  value: state.isCheckedRounding,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Obx(() => CombinationButton(
                combination: Combination.left,
                text: 'production_dispatch_detail_next_process'.tr,
                isEnabled: state.isEnabledNextWorkProcedure.value,
                click: () => logic.detailViewNextWorkProcedure(),
              )),
          Obx(() => CombinationButton(
                combination: Combination.right,
                isEnabled: state.isEnabledBatchDispatch.value,
                text: 'production_dispatch_detail_batch_record_working'.tr,
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
}

class _DispatchDetailWorkProcedure extends StatelessWidget {
  final ProductionDispatchLogic logic;
  final ProductionDispatchState state;
  final Widget Function(WorkCardList, int) itemBuilder;

  const _DispatchDetailWorkProcedure({
    required this.logic,
    required this.state,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        margin: const EdgeInsets.only(left: 5),
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
              itemBuilder(state.workProcedure[index], index),
        ),
      ),
    );
  }
}

class _DispatchDetailDispatch extends StatelessWidget {
  final ProductionDispatchLogic logic;
  final ProductionDispatchState state;
  final Widget Function(DispatchInfo) itemBuilder;

  const _DispatchDetailDispatch({
    required this.logic,
    required this.state,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
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
                            text: 'production_dispatch_detail_add_worker'.tr,
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
                                  'production_dispatch_detail_clean_tips'.tr,
                              confirm: () =>
                                  logic.cleanDispatchFromWorkProcedure(),
                            ),
                          );
                        },
                        needSave: false,
                        name: 'production_dispatch_detail_add_all_worker'.tr,
                        isEnabled: state.isEnabledAddAllDispatch,
                        value: state.isCheckedAddAllDispatch,
                      ),
                      CheckBox(
                        onChanged: (c) => logic.checkSelectAllDispatch(c),
                        needSave: false,
                        name:
                            'production_dispatch_detail_select_all_worker'.tr,
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
                          .map((item) => itemBuilder(item))
                          .toList()),
                ),
              ],
            ),
          ),
        ));
  }
}

class _DispatchDetailBottomButtons extends StatelessWidget {
  final ProductionDispatchLogic logic;
  final ProductionDispatchState state;
  final BuildContext context;

  const _DispatchDetailBottomButtons({
    required this.logic,
    required this.state,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Obx(() => CombinationButton(
                      combination: Combination.left,
                      text: state.isOpenedAllWorkProcedure.value
                          ? 'production_dispatch_detail_close_all_process'.tr
                          : 'production_dispatch_detail_open_all_process'.tr,
                      click: () => logic.detailViewWorkProcedureLockAll(),
                    )),
                CombinationButton(
                  combination: Combination.middle,
                  text: 'production_dispatch_detail_last_dispatch'.tr,
                  click: () => showDispatchList(
                      this.context,
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
                        (di) => di,
                      ),
                    );
                  }),
                ),
                CombinationButton(
                  combination: Combination.middle,
                  text: 'production_dispatch_detail_now_dispatch'.tr,
                  click: () => showDispatchList(
                      this.context, false, state.workProcedure, (i1, i2) {
                    logic.detailViewJumpToDispatchOnWorkProcedure(
                      i1,
                      i2,
                      (data, surplus) => modifyDispatchQtyDialog(
                        data,
                        surplus,
                        (di) => di,
                      ),
                    );
                  }),
                ),
                if (GetPlatform.isMobile)
                  CombinationButton(
                    combination: Combination.middle,
                    text: 'production_dispatch_detail_save_dispatch'.tr,
                    click: () => logic.saveDispatch(),
                  ),
                if (GetPlatform.isMobile)
                  CombinationButton(
                    combination: Combination.middle,
                    text: 'production_dispatch_detail_apply_dispatch'.tr,
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
                  text: 'production_dispatch_detail_manual'.tr,
                  click: () => logic.detailViewGetManufactureInstructions(
                    (list) => manufactureInstructionsDialog(list),
                  ),
                ),
                CombinationButton(
                  combination: Combination.right,
                  text: 'production_dispatch_detail_material_list'.tr,
                  click: () => logic.getWorkPlanMaterial(
                      (list) => workPlanMaterialDialog(list)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          CombinationButton(
            combination: Combination.left,
            text: 'production_dispatch_detail_process_check'.tr,
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
}
