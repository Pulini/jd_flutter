import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/stuff_quality_inspection_info.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_list_colors_view.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_list_detail_view.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_list_dialog.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_list_logic.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_list_state.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_list_reverse_color_view.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/spinner_widget.dart';

class QualityInspectionListPage extends StatefulWidget {
  const QualityInspectionListPage({super.key});

  @override
  State<QualityInspectionListPage> createState() =>
      _QualityInspectionListPageState();
}

class _QualityInspectionListPageState extends State<QualityInspectionListPage> {
  final QualityInspectionListLogic logic =
      Get.put(QualityInspectionListLogic());
  final QualityInspectionListState state =
      Get.find<QualityInspectionListLogic>().state;

  //公司
  var sapCompanyController = OptionsPickerController(
    hasAll: true,
    PickerType.sapCompany,
    buttonName: 'quality_inspection_select_company'.tr,
    saveKey:
        '${RouteConfig.qualityInspectionList.name}${PickerType.sapCompany}',
  );

  //工厂
  var factoryController = OptionsPickerController(
    PickerType.sapFactory,
    buttonName: 'quality_inspection_select_factory'.tr,
    saveKey:
        '${RouteConfig.qualityInspectionList.name}${PickerType.sapFactory}',
  );

  //供应商
  var supplierController = OptionsPickerController(
    hasAll: true,
    buttonName: 'quality_inspection_select_supplier'.tr,
    PickerType.sapSupplier,
    saveKey:
        '${RouteConfig.qualityInspectionList.name}${PickerType.sapSupplier}',
  );

  //日期选择器 开始时间
  var dpcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.qualityInspectionList.name}${PickerType.startDate}',
  );

  //日期选择器 结束时间
  var dpcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.qualityInspectionList.name}${PickerType.endDate}',
  );

  //选择搜索按钮条件
  late SpinnerController scOrderType;

  var typeBodyController = TextEditingController();
  var materialCodeController = TextEditingController();
  var instructionController = TextEditingController();
  var inspectionOrderController = TextEditingController();
  var temporaryReceiptController = TextEditingController();
  var receiptVoucherController = TextEditingController();
  var trackingNumberController = TextEditingController();

  Widget _subItem(StuffQualityInspectionInfo data) {
    var subTextStyle = TextStyle(color: Colors.blue.shade900);
    return Container(
      height: 40,
      padding: const EdgeInsets.only(right: 10),
      margin: const EdgeInsets.only(left: 16, right: 55),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
              flex: 7,
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() => Checkbox(
                          activeColor: Colors.blue,
                          side: const BorderSide(color: Colors.red, width: 2),
                          value: data.isSelected.value,
                          onChanged: (v) => data.isSelected.value = v!,
                        )),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      data.salesAndDistributionVoucherNumber ?? '',
                      style: subTextStyle,
                    ),
                  ),
                  expandedTextSpan(
                    flex: 4,
                    isBold: false,
                    hint: 'quality_inspection_factory_type'.tr,
                    text: data.factoryType ?? '',
                    textColor: Colors.blue.shade900,
                  ),
                  expandedTextSpan(
                    flex: 4,
                    isBold: false,
                    hint: 'quality_inspection_inspection_order_sub'.tr,
                    text: data.inspectionOrderNo ?? '',
                    textColor: Colors.blue.shade900,
                  )
                ],
              )),
          Expanded(
            child: Text(
              data.inspectionQuantity.toDoubleTry().toShowString(),
              textAlign: TextAlign.end,
              style: subTextStyle,
            ),
          ),
          Expanded(
            child: Text(
              data.samplingQuantity.toDoubleTry().toShowString(),
              textAlign: TextAlign.end,
              style: subTextStyle,
            ),
          ),
          Expanded(
            child: Text(
              data.unqualifiedQuantity.toDoubleTry().toShowString(),
              textAlign: TextAlign.end,
              style: subTextStyle,
            ),
          ),
          Expanded(
            child: Text(
              data.shortCodesNumber.toDoubleTry().toShowString(),
              textAlign: TextAlign.end,
              style: subTextStyle,
            ),
          ),
          Expanded(
            child: Text(
              data.qualifiedQuantity.toDoubleTry().toShowString(),
              textAlign: TextAlign.end,
              style: subTextStyle,
            ),
          ),
          Expanded(
            child: Text(
              data.storageQuantity.toDoubleTry().toShowString(),
              textAlign: TextAlign.end,
              style: subTextStyle,
            ),
          ),
        ],
      ),
    );
  }

  Container _item(int index) {
    var data = state.showDataList[index];
    itemSubTitle({required String title, required String data}) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(data)
            ],
          ),
        );
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey, width: 2),
      ),
      child: Obx(() => ExpansionTile(
            initiallyExpanded: data.every((v) => v.isSelected.value),
            onExpansionChanged: (v) {
              for (var item in data) {
                item.isSelected.value = v;
              }
            },
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  maxLines: 2,
                  '(${data[0].materialCode}) ${data[0].materialDescription}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                Row(
                  children: [
                    expandedTextSpan(
                      isBold: true,
                      hint: 'quality_inspection_command'.tr,
                      text: data[0].salesAndDistributionVoucherNumber ?? '',
                      textColor: Colors.redAccent,
                    ),
                    expandedTextSpan(
                      isBold: true,
                      hint: 'quality_inspection_factory_type'.tr,
                      text: data[0].factoryType ?? '',
                      textColor: Colors.redAccent,
                    )
                  ],
                )
              ],
            ),
            subtitle: Row(
              children: [
                Expanded(
                  flex: 7,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('(${data[0].supplierNumber}) ${data[0].name1}'),
                      TextButton(
                        onPressed: () => Get.to(
                            () => const QualityInspectionListDetailPage(),
                            arguments: {'index': index}),
                        child: Text(
                          'quality_inspection_view_detail'.tr,
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                itemSubTitle(
                  title: 'quality_inspection_inspection_quantity'.tr,
                  data: logic.inspectionTotalQtyText(data),
                ),
                itemSubTitle(
                  title: 'quality_inspection_sampling_quantity'.tr,
                  data: logic.samplingTotalQtyText(data),
                ),
                itemSubTitle(
                  title: 'quality_inspection_unqualified_quantity'.tr,
                  data: logic.unqualifiedTotalQtyText(data),
                ),
                itemSubTitle(
                  title: 'quality_inspection_short_quantity'.tr,
                  data: logic.shortCodesTotalQtyText(data),
                ),
                itemSubTitle(
                  title: 'quality_inspection_qualified_quantity'.tr,
                  data: logic.qualifiedTotalQtyText(data),
                ),
                itemSubTitle(
                  title: 'quality_inspection_inventory_quantity'.tr,
                  data: logic.storageTotalQtyText(data),
                ),
              ],
            ),
            children: [
              for (var sub in data) _subItem(sub),
              const SizedBox(height: 10),
            ],
          )),
    );
  }

  void _query() {
    logic.getInspectionList(
      orderType: scOrderType.selectIndex,
      typeBody: typeBodyController.text,
      //型体
      materialCode: materialCodeController.text,
      //物料编号
      instruction: instructionController.text,
      //指令
      inspectionOrder: inspectionOrderController.text,
      //检验单号
      temporaryReceipt: temporaryReceiptController.text,
      //暂收单号
      receiptVoucher: receiptVoucherController.text,
      trackingNumber: trackingNumberController.text,
      startDate: dpcStartDate.getDateFormatYMD(),
      endDate: dpcEndDate.getDateFormatYMD(),
      supplier: supplierController.selectedId.value,
      sapCompany: sapCompanyController.selectedId.value,
      factory: factoryController.selectedId.value,
    );
    state.allSelect.value = false;
  }

  void _deleteOrder() {
    logic.checkDelete(
      success: () => reasonInputPopup(
        title: [
          Center(
            child: Text(
              'quality_inspection_delete_btn'.tr,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          )
        ],
        hintText: 'quality_inspection_input_delete_reason'.tr,
        isCanCancel: true,
        confirm: (s) {
          Get.back();
          logic.deleteData(
            reason: s,
            refresh: () => _query(),
          );
        },
      ),
    );
  }

  void _orderReverse() {
    logic.receiptReversal(reason: () {
      reasonInputPopup(
        title: [
          Center(
            child: Text(
              'quality_inspection_reverse'.tr,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          )
        ],
        hintText: 'quality_inspection_reversal_reason'.tr,
        isCanCancel: true,
        confirm: (reason) {
          Get.back();
          logic.colorSubmit(
              reason: reason,
              success: () {
                _query();
              });
        },
      );
    }, toReverseColor: () {
      Get.to(() => const QualityInspectionReverseColorPage())?.then((v) {
        if (v != null && v as bool) _query();
      });
    });
  }

  void _location() {
    logic.checkSame(
      success: () => qualityInspectionListLocationDialog(
        success: (location) => logic.getLocation(
          store: location,
          success: (locationList) => reasonInputPopup(
            title: [
              Center(
                child: Text(
                  'quality_inspection_change_location_title'.tr,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
              )
            ],
            hintText: 'quality_inspection_input_location'.tr,
            tips: locationList[0].location,
            isCanCancel: true,
            confirm: (reason) {
              Get.back();
              logic.changeLocation(
                location: reason,
                locationList: locationList,
                refresh: () => _query(),
              );
            },
          ),
        ),
      ),
    );
  }

  void _stockIn() {
    logic.checkOrderType(
      stockIn: () => qualityInspectionListStoreDialog(
        success: (date, store1) => logic.store(
          date: date,
          store1: store1,
          refresh: () => _query(),
        ),
      ),
      bindingLabel: () =>
          Get.to(() => const QualityInspectionColorListPage())?.then((v) {
        if (v != null && v as bool) _query();
      }),
    );
  }

  @override
  void initState() {
    scOrderType = SpinnerController(
      dataList: state.orderTypeList.keys.toList(),
      onChanged: (i) => _query(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
        actions: [
          Obx(() => CheckBox(
                onChanged: (c) {
                  state.allSelect.value = c;
                  logic.selectAllData(c);
                },
                name: state.allSelect.value
                    ? 'quality_inspection_no_all_select'.tr
                    : 'quality_inspection_all_select'.tr,
                value: state.allSelect.value,
              )),
        ],
        queryWidgets: [
          EditText(
            controller: typeBodyController,
            hint: 'quality_inspection_type_body'.tr,
          ),
          EditText(
            controller: materialCodeController,
            hint: 'quality_inspection_material_code'.tr,
          ),
          EditText(
            controller: instructionController,
            hint: 'quality_inspection_instruction'.tr,
          ),
          EditText(
            controller: inspectionOrderController,
            hint: 'quality_inspection_inspection_order'.tr,
          ),
          EditText(
            controller: temporaryReceiptController,
            hint: 'quality_inspection_temporary_receipt'.tr,
          ),
          EditText(
            controller: receiptVoucherController,
            hint: 'quality_inspection_receipt_voucher'.tr,
          ),
          EditText(
            controller: trackingNumberController,
            hint: 'quality_inspection_tracking_number'.tr,
          ),
          OptionsPicker(pickerController: sapCompanyController),
          OptionsPicker(pickerController: factoryController),
          OptionsPicker(pickerController: supplierController),
          DatePicker(pickerController: dpcStartDate),
          DatePicker(pickerController: dpcEndDate),
          Spinner(controller: scOrderType),
        ],
        query: _query,
        body: Column(
          children: [
            Expanded(
              child: Obx(() => ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.showDataList.length,
                    itemBuilder: (context, index) => _item(index),
                  )),
            ),
            Row(
              children: [
                Expanded(
                    child: Obx(() => CombinationButton(
                          //冲销
                          isEnabled: state.orderType.value == 1,
                          text: 'quality_inspection_reverse'.tr,
                          click: () => _orderReverse(),
                          combination: Combination.left,
                        ))),
                Expanded(
                  child: Obx(() => CombinationButton(
                        //入库
                        isEnabled: state.orderType.value == 0,
                        text: 'quality_inspection_store'.tr,
                        click: () => _stockIn(),
                        combination: Combination.middle,
                      )),
                ),
                Expanded(
                  child: Obx(() => CombinationButton(
                        //删除
                        isEnabled: state.orderType.value == 0 ||
                            state.orderType.value == 3 ||
                            state.orderType.value == 4,
                        text: 'quality_inspection_delete_btn'.tr,
                        click: () => _deleteOrder(),
                        combination: Combination.middle,
                      )),
                ),
                Expanded(
                  child: Obx(() => CombinationButton(
                        //修改
                        isEnabled: state.orderType.value == 0 ||
                            state.orderType.value == 3 ||
                            state.orderType.value == 4,
                        text: 'quality_inspection_change'.tr,
                        click: () => logic.inspection(refresh: () => _query()),
                        combination: Combination.middle,
                      )),
                ),
                Expanded(
                  child: CombinationButton(
                    //货位
                    text: 'quality_inspection_location'.tr,
                    click: () => _location(),
                    combination: Combination.middle,
                  ),
                ),
                Expanded(
                  child: CombinationButton(
                    //分色
                    text: 'quality_inspection_color'.tr,
                    click: () => logic.checkSame(
                      success: () => logic.getColor(
                        callback: (list) => showColor(list),
                      ),
                    ),
                    combination: Combination.right,
                  ),
                )
              ],
            ),
          ],
        ));
  }
}
