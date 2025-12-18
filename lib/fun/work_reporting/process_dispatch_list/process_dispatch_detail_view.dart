import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/process_work_card_detail_info.dart';
import 'package:jd_flutter/fun/work_reporting/process_dispatch_list/process_dispatch_logic.dart';
import 'package:jd_flutter/utils/printer/print_util.dart';
import 'package:jd_flutter/utils/printer/tsc_util.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';

class ProcessDispatchDetailPage extends StatefulWidget {
  const ProcessDispatchDetailPage({super.key});

  @override
  State<ProcessDispatchDetailPage> createState() =>
      _ProcessDispatchDetailPageState();
}

class _ProcessDispatchDetailPageState extends State<ProcessDispatchDetailPage> {
  final logic = Get.find<ProcessDispatchLogic>();
  final state = Get.find<ProcessDispatchLogic>().state;

  final PrintUtil pu = PrintUtil();

  Future<void> printLabel(bool batch, int position) async {
    //是否批量打印
    var labelList = <List<Uint8List>>[];
    var printList = <Barcodes>[];
    if (batch) {
      printList =
          state.showLabelList.where((data) => data.select == true).toList();
    } else {
      printList = [state.showLabelList[position]];
    }

    for (var print in printList) {
      Map<String, List<List<String>>> tableData = {};
      List<List<String>> subData = [];

      Map<String, List<BarCodeSizes>> groupedBySize =
          groupBy(print.sizes!, (BarCodeSizes size) => size.sAPColorBatch!);

      var allTotal = 0.0;
      var colors = '';
      groupedBySize.forEach((v1, v2) {
        colors = "$colors$v1,";
        for (var c in v2) {
          allTotal = allTotal + c.qty!;
        }
      });

      if (colors.endsWith(',')) {
        colors = colors.substring(0, colors.length - 1);
      }

      Map<String, List<BarCodeSizes>> groupedByInstruction = groupBy(
          print.sizes!, (BarCodeSizes instruction) => instruction.mtono!);
      groupedByInstruction.forEach((v1, v2) {
        v2.sort((a, b) => a.size!.compareTo(b.size!));
        for (var c in v2) {
          subData.add([c.size.toString(), c.qty.toShowString()]);
        }
        tableData[v1] = subData;
      });
      labelList.add(await labelMultipurposeDynamic(
        qrCode: print.barcode ?? '',
        title: state.workCardDetail!.productName ?? '',
        subTitle: state.workCardDetail!.parts ?? '',
        tableTitle: print.deptName ?? '',
        tableTitleTips: allTotal.toShowString() + (print.unit ?? ''),
        tableSubTitle: state.workCardDetail!.processName ?? '',
        tableFirstLineTitle: '尺码',
        tableLastLineTitle: '合计',
        tableData: tableData,
        bottomLeftText1: state.foot.value ? '左脚' : '',
        bottomLeftText2: '色系：$colors',
        bottomRightText1: '序号：${print.index}',
        bottomRightText2: '姓名：${print.emp}',
      ));

      if (state.foot.value) {
        labelList.add(await labelMultipurposeDynamic(
          qrCode: print.barcode ?? '',
          title: state.workCardDetail!.productName ?? '',
          subTitle: state.workCardDetail!.parts ?? '',
          tableTitle: print.deptName ?? '',
          tableTitleTips: allTotal.toShowString() + (print.unit ?? ''),
          tableSubTitle: state.workCardDetail!.processName ?? '',
          tableFirstLineTitle: '尺码',
          tableLastLineTitle: '合计',
          tableData: tableData,
          bottomLeftText1: state.foot.value ? '右脚' : '',
          bottomLeftText2: '色系：$colors',
          bottomRightText1: '序号：${print.index}',
          bottomRightText2: '姓名：${print.emp}',
        ));
      }
    }
    pu.printLabelList(
      labelList: labelList,
      start: () {
        loadingShow('正在下发标签...');
      },
      progress: (i, j) {
        loadingShow('正在下发标签($i/$j)');
      },
      finished: (success, fail) {
        successDialog(
            title: '标签下发结束',
            content: '完成${success.length}张, 失败${fail.length}张',
            back: () {});
      },
    );
  }

  var inputNumber = [
    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
  ];

  //  输入数量
  void _inputDialog({
    required String initNum,
    required String title,
    Function(String)? confirm,
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
                Get.back();
                confirm?.call(logic.textNumber.text);
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

  Row _page1Item(SizeLists data, position) {
    return Row(
      children: [
        Expanded(
            child: _text(
                mes: data.size ?? '',
                head: false,
                isSelect: data.select,
                all: data.size!)),
        Expanded(
            child: _text(
                mes: data.sAPColorBatch ?? '',
                head: false,
                isSelect: data.select,
                all: data.size!)),
        Expanded(
            child: _text(
                mes: data.mtonoQty.toShowString(),
                head: false,
                isSelect: data.select,
                all: data.size!)),
        Expanded(
            child: _text(
                mes: data.createdQty.toShowString(),
                head: false,
                isSelect: data.select,
                all: data.size!)),
        Expanded(
            child: _text(
                mes: data.qty.toShowString(),
                head: false,
                isSelect: data.select,
                all: data.size!)),
        Expanded(
            child: InkWell(
          child: _text(
              mes: data.boxCapacity,
              head: false,
              isSelect: data.select,
              all: data.size!),
          onTap: () {
            if (data.size != '总') {
              _inputDialog(
                  initNum: data.qty.toShowString(),
                  title: '${'process_dispatch_tab1_size'.tr}<${data.size!}>',
                  confirm: (number) => logic.inputCapacity(number, position));
            }
          },
        )),
        Expanded(
            child: InkWell(
          onTap: () {
            logic.selectSize(position);
          },
          child: _text(
              mes: 'process_dispatch_tab1_click'.tr,
              head: false,
              isSelect: data.select,
              all: data.size!),
        )),
      ],
    );
  }

  GestureDetector _page2Item(Barcodes data, position) {
    return GestureDetector(
      onTap: () {
        logic.selectLabel(position);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        height: 140,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.lightBlueAccent.shade100,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            border: data.select
                ? Border.all(color: Colors.red, width: 2)
                : Border.all(color: Colors.grey, width: 1)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textSpan(
                maxLines: 1,
                hint: 'process_dispatch_label_code'.tr,
                text: data.barcode ?? '',
                textColor: Colors.black),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textSpan(
                    hint: 'process_dispatch_label_sale_order'.tr,
                    text: data.mtono ?? '',
                    textColor: Colors.black),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textSpan(
                    hint: 'process_dispatch_label_packing_method'.tr,
                    text: data.packageType == 1 ? '单码装' : '混码装',
                    textColor: Colors.black),
                Text(data.received! ? '已入库' : '未入库',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: data.received! ? Colors.green : Colors.red,
                    )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textSpan(
                    hint: 'process_dispatch_label_code_num'.tr,
                    text: data.index.toString(),
                    textColor: Colors.black),
                Text(data.printTimes! > 0 ? '已打印' : '未打印',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: data.printTimes! > 0 ? Colors.green : Colors.red,
                    )),
              ],
            ),
            InkWell(
              onTap: () {
                showSnackBar(message: data.getMessage());
              },
              child: textSpan(
                  maxLines: 1,
                  hint: 'process_dispatch_label_size_mes'.tr,
                  text: data.getMessage(),
                  textColor: Colors.black),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () {
                    askDialog(
                        content: 'process_dispatch_label_sure_print'.tr,
                        confirm: () {
                          //打印标签
                          logic.updatePartsPrintTimes(
                              select: false,
                              position: position,
                              success: () {
                                printLabel(false, position);
                              });
                        });
                  },
                  child: Text('process_dispatch_label_print'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      )),
                ),
                InkWell(
                  onTap: () {
                    askDialog(
                        content: 'process_dispatch_label_sure_delete'.tr,
                        confirm: () {
                          logic.deleteLabel(
                              batch: false,
                              position: position,
                              success: (mes) {
                                successDialog(
                                    content: mes,
                                    back: () {
                                      logic.getDetail(toPage: false);
                                    });
                              });
                        });
                  },
                  child: Text('process_dispatch_label_delete'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      )),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Container _text({
    required String mes,
    required bool head,
    required String all,
    required bool isSelect,
  }) {
    var textColor = Colors.white;
    Color backColor = Colors.blue;
    if (head) {
      textColor = Colors.white;
      backColor = Colors.blue.shade500;
    } else {
      textColor = Colors.black;
      if (isSelect && all != '总') {
        backColor = Colors.red.shade100;
      } else {
        backColor = Colors.white;
      }
    }
    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: backColor, // 背景颜色
        border: Border.all(
          color: Colors.black, // 边框颜色
          width: 1.0, // 边框宽度
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: Center(
          child: Text(
            maxLines: 1,
            mes,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }

  Row _title() {
    return Row(
      children: [
        Expanded(
            child: _text(
                mes: 'process_dispatch_tab1_size'.tr,
                head: true,
                all: '',
                isSelect: false)),
        Expanded(
            child: _text(
                mes: 'process_dispatch_tab1_color'.tr,
                head: true,
                all: '',
                isSelect: false)),
        Expanded(
            child: _text(
                mes: 'process_dispatch_tab1_quantity'.tr,
                head: true,
                all: '',
                isSelect: false)),
        Expanded(
            child: _text(
                mes: 'process_dispatch_tab1_finished'.tr,
                head: true,
                all: '',
                isSelect: false)),
        Expanded(
            child: _text(
                mes: 'process_dispatch_tab1_unfinished'.tr,
                head: true,
                all: '',
                isSelect: false)),
        Expanded(
            child: _text(
                mes: 'process_dispatch_tab1_capacity'.tr,
                head: true,
                all: '',
                isSelect: false)),
        Expanded(
            child: _text(
                mes: 'process_dispatch_tab1_select'.tr,
                head: true,
                all: '',
                isSelect: false)),
      ],
    );
  }

  Container _tabPage1() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textSpan(
              hint: 'process_dispatch_tab1_factory_body'.tr,
              isSpacing: true,
              text: state.workCardDetail!.productName ?? ''),
          textSpan(
              hint: 'process_dispatch_tab1_sale_order'.tr,
              isSpacing: true,
              text: state.workCardDetail!.mtonos ?? ''),
          textSpan(
              hint: 'process_dispatch_tab1_part_name'.tr,
              isSpacing: true,
              text: state.workCardDetail!.parts ?? ''),
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // 水平居中
            crossAxisAlignment: CrossAxisAlignment.center, // 垂直居中
            children: [
              Expanded(
                  flex: 2,
                  child: NumberEditText(
                    //生成贴标数
                    initQty: 1,
                    hint: 'process_dispatch_tab1_create_label_qty'.tr,
                    onChanged: (qty) {
                      state.createLabelQty = qty;
                    },
                  )),
              Expanded(
                  child: Center(
                child: TextButton(
                    onPressed: () => logic.clickType(),
                    child: Obx(() => Text(
                          state.submitType.value,
                          style: const TextStyle(color: Colors.red),
                        ))),
              )),
              Checkbox(
                value: state.selectAllList.value,
                onChanged: (c) {
                  state.selectAllList.value = !state.selectAllList.value;
                  logic.selectAllData();
                },
              )
            ],
          ),
          _title(),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: state.showDetailList.length,
                itemBuilder: (context, index) =>
                    _page1Item(state.showDetailList[index], index),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                  child: CombinationButton(
                //排序
                text: 'process_dispatch_tab1_sort'.tr,
                click: () {
                  if (state.colorList.isNotEmpty) {
                    logic.sortColorData();
                  }
                },
                combination: Combination.left,
              )),
              Expanded(
                  child: CombinationButton(
                //排序
                text: 'process_dispatch_tab1_all'.tr,
                click: () {
                  if (state.colorList.isNotEmpty) {
                    logic.setSizeList();
                  }
                },
                combination: Combination.middle,
              )),
              Expanded(
                  child: CombinationButton(
                //指令
                text: 'process_dispatch_tab1_instruction'.tr,
                click: () {
                  if (state.instructionList.isNotEmpty) {
                    logic.sortInstructionData();
                  }
                },
                combination: Combination.middle,
              )),
              Expanded(
                  child: CombinationButton(
                //生成贴标
                text: 'process_dispatch_tab1_create'.tr,
                click: () => logic.createLabel(success: (mes) {
                  successDialog(
                      content: mes, back: () => logic.getDetail(toPage: false));
                }),
                combination: Combination.right,
              ))
            ],
          )
        ],
      ),
    );
  }

  Container _tabPage2() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => CheckBox(
                    onChanged: (c) => state.foot.value = c,
                    name: 'process_dispatch_tab1_label_foot'.tr,
                    value: state.foot.value,
                  )),
              Obx(() => CheckBox(
                    onChanged: (c) {
                      state.selectAll.value = c;
                      logic.selectNoPrint(c);
                    },
                    name: 'process_dispatch_tab1_label_no_print'.tr,
                    value: state.selectAll.value,
                  ))
            ],
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.all(5),
                itemCount: state.showLabelList.length,
                itemBuilder: (context, index) =>
                    _page2Item(state.showLabelList[index], index),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                  child: CombinationButton(
                //全选
                text: 'process_dispatch_label_all'.tr,
                click: () {
                  logic.selectAllLabel(true);
                },
                combination: Combination.left,
              )),
              Expanded(
                  child: CombinationButton(
                //取消全选
                text: 'process_dispatch_label_cancel_all'.tr,
                click: () {
                  logic.selectAllLabel(false);
                },
                combination: Combination.middle,
              )),
              Expanded(
                  child: CombinationButton(
                //批量打印
                text: 'process_dispatch_label_batch_print'.tr,
                click: () {
                  if (logic.isBatch()) {
                    askDialog(
                        content: 'process_dispatch_label_sure_print'.tr,
                        confirm: () => logic.updatePartsPrintTimes(
                            select: true,
                            position: 0,
                            success: () {
                              printLabel(true, 0);
                            }));
                  }
                },
                combination: Combination.middle,
              )),
              Expanded(
                  child: CombinationButton(
                //批量删除
                text: 'process_dispatch_label_batch_delete'.tr,
                click: () {
                  if (logic.isBatch()) {
                    askDialog(
                        content: 'process_dispatch_label_sure_print'.tr,
                        confirm: () => logic.deleteLabel(
                            batch: true,
                            position: 0,
                            success: (mes) {
                              successDialog(
                                  content: mes,
                                  back: () {
                                    logic.getDetail(toPage: false);
                                  });
                            }));
                  }
                },
                combination: Combination.right,
              ))
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'process_dispatch_detail'.tr,
      body: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: TabBar(
            controller: logic.tabController,
            dividerColor: Colors.blueAccent,
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            tabs: [
              Tab(text: 'process_dispatch_tab_basic_information'.tr),
              Tab(text: 'process_dispatch_tab_print_label'.tr),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: Obx(() => TabBarView(
                      controller: logic.tabController,
                      children: [_tabPage1(), _tabPage2()],
                    )),
              ),
            ],
          )),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
