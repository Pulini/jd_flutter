import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/abnormal_quality_list_info.dart';
import 'package:jd_flutter/fun/management/quality_management/quality_management_logic.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/global_timer.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/switch_button_widget.dart';
import 'package:jd_flutter/widget/worker_check_widget.dart';

class QualityRestrictionPage extends StatefulWidget {
  const QualityRestrictionPage({super.key});

  @override
  State<QualityRestrictionPage> createState() => _QualityRestrictionPageState();
}

class _QualityRestrictionPageState extends State<QualityRestrictionPage> {
  final logic = Get.put(QualityManagementLogic());
  final state = Get.find<QualityManagementLogic>().state;
  final timeDown = GlobalTimer();

  _leftListView() {
    return ExpansionPanelList.radio(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          state.headIndex = index;
        });
      },
      children: state.orderShowSubDataList
          .map<ExpansionPanel>((AbnormalQualityListInfo item) {
        return ExpansionPanelRadio(
          backgroundColor: const Color(0xffB4FDFF),
          canTapOnHeader: true,
          //整个面板都可以点击
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(
                  'quality_management_sale_order_number'.tr+item.orderNumber.toString(),
                style: const TextStyle(fontSize: 13),
              ),
            );
          },
          body: ListView.builder(
            padding: const EdgeInsets.all(0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: item.abnormalQualityInfo!.length,
            itemExtent: 100.0,
            itemBuilder: (c, index) => Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: item.abnormalQualityInfo![index].select
                      ? Colors.red
                      : Colors.white,
                  width: 3,
                ),
              ),
              child: InkWell(
                  onTap: () {
                    state.arrangementData(index);
                    state.itemId = "-1";
                    state.getProcessFlowEXTypes(
                        index: index,
                        error: (msg) => {errorDialog(content: msg)});
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        expandedTextSpan(
                            hint: 'quality_management_group'.tr,
                            text: item.abnormalQualityInfo![index].deptName ??
                                ''),
                        expandedTextSpan(
                            hint: 'quality_management_type_body'.tr,
                            text:
                                item.abnormalQualityInfo![index].productName ??
                                    ''),
                        expandedTextSpan(
                            hint: 'quality_management_quantity'.tr,
                            text: item.abnormalQualityInfo![index].qty
                                .toString()),
                        expandedTextSpan(
                            hint: 'quality_management_line_number'.tr,
                            text: item.abnormalQualityInfo![index].entryID
                                .toString())
                      ],
                    ),
                  )),
            ),
          ),
          value: item.orderNumber!,
        );
      }).toList(),
    );
  }

  _rightListView() {
    return SingleChildScrollView(
      child: ListView.builder(
        padding: const EdgeInsets.all(0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.showEntryDataList.length,
        itemExtent: 160.0,
        itemBuilder: (c, index) => Container(
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: const Color(0xFFCCFEFF),
            border: Border.all(
              color: const Color(0xFF54BCBD),
              width: 3,
            ),
          ),
          child: GestureDetector(
            onLongPress: ()=>{
              askDialog(
                content: 'quality_management_sure_delete_abnormal'.tr,
                confirm: () {
                  state.delBill(
                    position: index,
                    success: (msg, position) => successDialog(
                        content: msg, back: state.removeBill(position)),
                    error: (msg) => errorDialog(content: msg),
                  );
                },
              ),
            },
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    expandedTextSpan(
                        hint: 'quality_management_serial_number'.tr,
                        text: state.showEntryDataList[index].exNumber ?? ''),
                    expandedTextSpan(
                        hint: 'quality_management_quality_inspection_time'.tr,
                        text: state.showEntryDataList[index].billDate ?? ''),
                    expandedTextSpan(
                        hint: 'quality_management_quality_inspector'.tr,
                        text:
                            "${state.showEntryDataList[index].empName}(${state.showEntryDataList[index].empNumber})"),
                    expandedTextSpan(
                        textColor:
                            state.showEntryDataList[index].reCheck == "合格"
                                ? Colors.green.shade900
                                : Colors.red,
                        hint: 'quality_management_quality_state'.tr,
                        text: state.showEntryDataList[index].reCheck ?? ''),
                    expandedTextSpan(
                        hint: 'quality_management_quantity'.tr,
                        text:
                            "${state.showEntryDataList[index].qty.toShowString()} <${state.showEntryDataList[index].exceptionLevel == "0" ? '轻微' : '严重'}>"),
                    expandedTextSpan(
                        hint: 'quality_management_quality_defect：',
                        text:
                            "<${state.showEntryDataList[index].exceptionName}>"),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  _gridViewType() {
    return GridView.builder(
      itemCount: state.exceptionDataList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // 网格的列数
      ),
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: (){
            state.selected.value = index;
            state.dialogMiss.value = false;
            state.itemId = state.exceptionDataList[index].fItemID.toString();
            if (state.isAutomatic)
              {
                Future.delayed(const Duration(seconds: 1), () {
                  state.countTimerNumber.value = '3';
                  state.timeDown();
                  _timeDownDialog();
                  Future.delayed(const Duration(seconds: 3), () {
                    if (state.dialogMiss.value == false) {
                      state.submitReview(
                        error: (msg) => {
                          errorDialog(content: msg),
                        },
                      );
                      Get.back();
                    }
                  });
                });
              }
          },
          child: Obx(() => Card(
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    side: BorderSide(
                        color: state.selected.value == index
                            ? Colors.red
                            : Colors.white70,
                        width: 2.0)),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                            '${state.exceptionDataList[index].fExPercentage! * 100}%'),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                            state.exceptionDataList[index].fName.toString()),
                      ),
                    ],
                  ),
                ),
              )),
        );
      },
    );
  }

  _clickNumber({
    required IconData icon,
    required Function click,
  }) {
    return GestureDetector(
        onTap: () {
          click.call();
        },
        child: Container(
          margin: const EdgeInsets.only(left: 15, top: 5, right: 5, bottom: 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue, width: 3)),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: Colors.black,
            size: 30,
          ),
        ));
  }

  _seriousOrSlight({
    required String type,
    required bool valueBool,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.red,
          width: 3,
        ),
      ),
      alignment: Alignment.center,
      child: CheckboxListTile(
        activeColor: Colors.red,
        title: Text(
          type,
          style: const TextStyle(
            fontSize: 30,
            color: Colors.red,
          ),
        ),
        value: valueBool,
        // 复选框的当前状态
        onChanged: (c) {
          onChanged.call(c!);
        },
      ),
    );
  }

  var inputNumber = [
    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
  ];

  //  输入数量
  _inputDialog({
    required String title,
    Function()? confirm,
    Function()? cancel,
  }) {
    Get.dialog(
      PopScope(
        //拦截返回键
        canPop: false,
        child: AlertDialog(
          title: Text(title,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold)),
          content: CupertinoTextField(
            inputFormatters: inputNumber,
            controller: logic.textNumber,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (logic.textNumber.text.toString().isEmpty) {
                  state.number.value = "1";
                } else {
                  state.number.value = logic.textNumber.text.toString();
                }

                Get.back();
                confirm?.call();
              },
              child: Text('dialog_default_confirm'.tr),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                cancel?.call();
              },
              child: Text(
                'dialog_default_cancel'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false, //拦截dialog外部点击
    );
  }

  //  根据工号搜索员工信息
  _searchDialog() {
    Get.dialog(
      PopScope(
        //拦截返回键
        canPop: false,
        child: AlertDialog(
          title:  Text('quality_management_modify_personnel'.tr,
              style:
                  const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          content: WorkerCheck(onChanged: (worker) {
            state.searchPeople = "${"${worker!.empName!}(${worker.empID}"})";
            state.searchPeopleEmpId = worker.empID.toString();
            state.searchPeopleDepartmentID = worker.empDepartID.toString();
          }),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                state.personal.value = state.searchPeople;
                state.departmentID = state.searchPeopleDepartmentID;
                state.empID = state.searchPeopleEmpId;
                Get.back();
              },
              child: Text('dialog_default_confirm'.tr),
            ),
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                'dialog_default_cancel'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false, //拦截dialog外部点击
    );
  }

  _people({
    required String title,
  }) {
    return InkWell(
      onTap: () => {_searchDialog()},
      child: Container(
        margin: const EdgeInsets.only(left: 15, top: 5, right: 5, bottom: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue, width: 3)),
        alignment: Alignment.center,
        child: Text.rich(
          TextSpan(
              style: const TextStyle(fontSize: 20, color: Colors.lightBlue),
              children: [
                TextSpan(text: title),
                const WidgetSpan(
                    child: SizedBox(
                  width: 10,
                )),
                const WidgetSpan(
                    child: Icon(
                  Icons.ads_click,
                  color: Colors.lightBlue,
                  size: 20,
                ))
              ]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  _number({required String number}) {
    return InkWell(
        onTap: (){_inputDialog(title: 'quality_management_manual_input'.tr);},
        child: Text.rich(
          TextSpan(
              style: const TextStyle(
                fontSize: 30,
                color: Colors.black,
              ),
              children: [
                const WidgetSpan(child: SizedBox(width: 15)),
                TextSpan(text: number),
                const WidgetSpan(
                    child: Icon(
                  Icons.ads_click,
                  color: Colors.black,
                  size: 20,
                ))
              ]),
          textAlign: TextAlign.center,
        ));
  }

  _clickSubmit({
    required Function click,
  }) {
    return GestureDetector(
        onTap: () {
          click.call();
        },
        child: Center(
            child: Container(
          margin: const EdgeInsets.only(left: 5, top: 5, right: 0, bottom: 5),
          decoration: BoxDecoration(
              color: Colors.red, borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          child:  Text(
            "quality_management_submit".tr,
            style: const TextStyle(fontSize: 100, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        )));
  }

  //  输入数量
  _timeDownDialog() {
    Get.dialog(
      PopScope(
        //拦截返回键
        canPop: false,
        child: AlertDialog(
          title:  Text('quality_management_three_seconds'.tr,
              style:
                  const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          content: Obx(
            () => SizedBox(
                height: 120,
                width: 100,
                child: Center(
                    child: Text(
                  state.countTimerNumber.value,
                  style: const TextStyle(fontSize: 100, color: Colors.red),
                ))),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                state.dialogMiss.value = true;
                Get.back();
              },
              child: Text(
                'dialog_default_cancel'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false, //拦截dialog外部点击
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
        title: 'quality_restriction_title'.tr,
        queryWidgets: [
          EditText(hint: 'quality_management_enter_tracking_number'.tr, onChanged: (s) => {state.order = s}),
          DatePicker(pickerController: logic.pcStartDate),
          DatePicker(pickerController: logic.pcEndDate),
          OptionsPicker(pickerController: logic.pickerControllerDepartment),
          SwitchButton(
            onChanged: (isSelect) {
              setState(() => state.isAutomatic = isSelect);
              spSave('${Get.currentRoute}/QualityAutomatic', isSelect);
            },
            name: 'quality_management_autocommit'.tr,
            value: state.isAutomatic,
          )
        ],
        query: () => {
              state.itemId = "-1",
              state.getProductionProcessInfo(
                deptID: logic.pickerControllerDepartment.selectedId.value,
                mtoNo: state.order,
                startTime: logic.pcStartDate.getDateFormatYMD(),
                endTime: logic.pcEndDate.getDateFormatYMD(),
                error: (msg) => {
                  errorDialog(content: msg),
                },
              ),
            },
        body: Obx(() => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 10),
                Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Container(
                        child: _leftListView(),
                      ),
                    )),
                Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Expanded(
                            child: Row(
                          children: [
                            Expanded(
                                child: Column(
                              children: [
                                Expanded(
                                  child: _people(title: state.personal.value),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _clickNumber(
                                          icon: Icons.remove,
                                          click: () =>
                                              logic.addOrReduceNumber(false),
                                        ),
                                      ),
                                      Expanded(
                                        child:
                                            _number(number: state.number.value),
                                      ),
                                      Expanded(
                                        child: _clickNumber(
                                          icon: Icons.add,
                                          click: () =>
                                              logic.addOrReduceNumber(true),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: _seriousOrSlight(
                                          type: 'quality_management_slight'.tr,
                                          valueBool: state.slight.value,
                                          onChanged: (bool c) {
                                            state.serious.value = !c;
                                            state.slight.value = c;
                                          }),
                                    ),
                                    Expanded(
                                      child: _seriousOrSlight(
                                          type: 'quality_management_serious'.tr,
                                          valueBool: state.serious.value,
                                          onChanged: (bool c) {
                                            state.serious.value = c;
                                            state.slight.value = !c;
                                          }),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: _clickSubmit(
                                click: () => {
                                  state.submitReview(
                                    error: (msg) => {
                                      errorDialog(content: msg),
                                    },
                                  )
                                },
                              ),
                            ),
                            const SizedBox(width: 20)
                          ],
                        )),
                        Expanded(
                          flex: 3,
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: _gridViewType()),
                        )
                      ],
                    )),
                Expanded(flex: 1, child: _rightListView()),
                const SizedBox(width: 10),
              ],
            )));
  }

  @override
  void dispose() {
    Get.delete<QualityManagementLogic>();
    super.dispose();
  }
}
