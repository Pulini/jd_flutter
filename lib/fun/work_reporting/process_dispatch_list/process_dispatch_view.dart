import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/process_work_card_list_info.dart';
import 'package:jd_flutter/fun/work_reporting/process_dispatch_list/process_dispatch_logic.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/scanner.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

class ProcessDispatchPage extends StatefulWidget {
  const ProcessDispatchPage({super.key});

  @override
  State<ProcessDispatchPage> createState() => _ProcessDispatchPageState();
}

class _ProcessDispatchPageState extends State<ProcessDispatchPage> {
  final logic = Get.put(ProcessDispatchLogic());
  final state = Get.find<ProcessDispatchLogic>().state;

  _item1(ProcessWorkCardListInfo data, int position) {
    return GestureDetector(
      onTap: () => logic.selectData(position),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: data.select
                ? [Colors.red.shade100, Colors.white]
                : [Colors.blue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        foregroundDecoration: RotatedCornerDecoration.withColor(
          color: data.hasBarcode == true ? Colors.green : Colors.red,
          badgeCornerRadius: const Radius.circular(8),
          badgeSize: const Size(55, 55),
          textSpan: TextSpan(
            text: data.hasBarcode == true
                ? 'process_dispatch_have_barcode'.tr
                : 'process_dispatch_no_barcode'.tr,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textSpan(
                hint: 'process_dispatch_dispatch_no'.tr,
                text: data.number ?? ''),
            textSpan(
                maxLines: 1,
                hint: 'process_dispatch_sale_order'.tr,
                text: data.getSales()),
            textSpan(
                hint: 'process_dispatch_factory_body'.tr,
                text: data.productNumber ?? ''),
            textSpan(
                maxLines: 1,
                hint: 'process_dispatch_part_name'.tr,
                text: data.getParts()),
            textSpan(
                maxLines: 1,
                hint: 'process_dispatch_job_name'.tr,
                text: data.getPersonal()),
            textSpan(
                maxLines: 1,
                hint: 'process_dispatch_job_total'.tr,
                text: data.getProcess())
          ],
        ),
      ),
    );
  }

  //日期选择器的控制器
  var dispatchDate = DatePickerController(
    buttonName: 'process_dispatch_dispatch_date'.tr,
    PickerType.date,
    saveKey: '${RouteConfig.processDispatchList.name}${PickerType.date}',
  );

  var controller = TextEditingController();
  var numberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      queryWidgets: [
        EditTextSearch(
            hint: 'process_dispatch_work_ticket'.tr,
            onChanged: (v) => state.workTicket = v, //工票
            controller: controller,
            onSearch: () => {}),
        Center(child: Text('process_dispatch_or'.tr)),
        DatePicker(pickerController: dispatchDate),
        NumberEditText(
          hint: 'process_dispatch_work_number'.tr,
          onChanged: (s) {
            state.personalNumber = s;
          },
          controller: numberController,
        )
      ],
      query: () => logic.getWorkCardList(
          workTicket: controller.text,
          date: dispatchDate.getDateFormatYMD(),
          empNumber: numberController.text),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.dataList.length,
                  itemBuilder: (context, index) =>
                      _item1(state.dataList[index], index),
                )),
          ),
          Row(
            children: [
              Expanded(
                child: CombinationButton(
                  text: 'process_dispatch_part_split'.tr,
                  click: () {
                    if (logic.selectOnlyOne()) {
                      askDialog(
                        content: 'process_dispatch_sure_split_part'.tr,
                        confirm: () => logic.splitPart(success: (mes) {
                          successDialog(
                              content: mes,
                              back: () => {
                                    logic.getWorkCardList(
                                        workTicket: controller.text,
                                        date: dispatchDate.getDateFormatYMD(),
                                        empNumber: numberController.text)
                                  });
                        }),
                      );
                    }
                  },
                  combination: Combination.left,
                ),
              ),
              Expanded(
                child: CombinationButton(
                  text: 'process_dispatch_part_merge'.tr,
                  click: () {
                    if (logic.selectSame()) {
                      askDialog(
                        content: 'process_dispatch_sure_merge_part'.tr,
                        confirm: () => logic.mergePart(success: (mes) {
                          successDialog(
                              content: mes,
                              back: () => logic.getWorkCardList(
                                  workTicket: controller.text,
                                  date: dispatchDate.getDateFormatYMD(),
                                  empNumber: numberController.text));
                        }),
                      );
                    }
                  },
                  combination: Combination.middle,
                ),
              ),
              Expanded(
                child: CombinationButton(
                  text: 'process_dispatch_generate_label'.tr,
                  click: () {
                    logic.getDetail(toPage: true);
                  },
                  combination: Combination.right,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    pdaScanner(
      scan: (code) => {
        if (code.isNotEmpty)
          {
            controller.text = code,
            logic.getWorkCardList(
                workTicket: code,
                date: dispatchDate.getDateFormatYMD(),
                empNumber: '')
          }
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<ProcessDispatchLogic>();
    super.dispose();
  }
}
