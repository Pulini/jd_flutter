import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/handover_detail_info.dart';
import 'package:jd_flutter/fun/report/component_handover/component_handover_logic.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class ComponentHandoverSummaryPage extends StatefulWidget {
  const ComponentHandoverSummaryPage({super.key});

  @override
  State<ComponentHandoverSummaryPage> createState() =>
      _ComponentHandoverSummaryPageState();
}

class _ComponentHandoverSummaryPageState
    extends State<ComponentHandoverSummaryPage> {
  final logic = Get.find<ComponentHandoverLogic>();
  final state = Get.find<ComponentHandoverLogic>().state;

  _text({
    required String mes,
    required bool head,
  }) {
    var textColor = Colors.white;
    Color backColor = Colors.blue;
    if (head) {
      textColor = Colors.white;
      backColor = Colors.blue;
    } else {
      textColor = Colors.black;
      backColor = Colors.white;
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

  _title() {
    return Row(
      children: [
        const SizedBox(width: 5),
        Expanded(
          flex: 2,
          child: _text(mes: 'component_handover_summary_part'.tr, head: true),
        ),
        Expanded(
            flex: 2,
            child: _text(
              mes: 'component_handover_summary_instruction_number'.tr,
              head: true,
            )),
        Expanded(
            flex: 2,
            child: _text(
              mes: 'component_handover_summary_type_body'.tr,
              head: true,
            )),
        Expanded(
            child: _text(
          mes: 'component_handover_summary_size'.tr,
          head: true,
        )),
        Expanded(
            child: _text(
          mes: 'component_handover_summary_instruction_count'.tr,
          head: true,
        )),
        Expanded(
            child: _text(
          mes: 'component_handover_summary_qty'.tr,
          head: true,
        )),
        const SizedBox(width: 5),
      ],
    );
  }

  _item1(
    SummaryList data,
  ) {
    return InkWell(
      onTap: () => {
        showSnackBar(
            message: data.partName ??
                'component_handover_summary_part_name_empty'.tr)
      },
      child: Row(
        children: [
          const SizedBox(width: 5),
          Expanded(
            flex: 2,
            child: _text(mes: data.partName ?? '', head: false),
          ),
          Expanded(
              flex: 2,
              child: _text(
                mes: data.mtono ?? '',
                head: false,
              )),
          Expanded(
              flex: 2,
              child: _text(
                mes: data.factoryType ?? '',
                head: false,
              )),
          Expanded(
              child: _text(
            mes: data.size ?? '',
            head: false,
          )),
          Expanded(
              child: _text(
            mes: data.mtonoQty.toShowString(),
            head: false,
          )),
          Expanded(
              child: _text(
            mes: data.qty.toShowString(),
            head: false,
          )),
          const SizedBox(width: 5),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        title: 'component_handover_summary_table'.tr,
        body: Column(
          children: [
            _title(),
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: state.summaryDataList.length,
                    itemBuilder: (context, index) =>
                        _item1(state.summaryDataList[index]),
                  )),
            ),
            SizedBox(
              width: double.maxFinite,
              child: CombinationButton(
                //交接
                text: 'component_handover_summary_submit'.tr,
                click: () => {
                  askDialog(
                    content: 'component_handover_summary_sure_submit'.tr,
                    confirm: () {
                      Get.back(result: true);
                    },
                  )
                },
                combination: Combination.intact,
              ),
            )
          ],
        ));
  }
}
