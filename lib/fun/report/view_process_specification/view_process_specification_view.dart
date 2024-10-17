import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widget/custom_widget.dart';
import '../../../widget/edit_text_widget.dart';
import '../../../widget/web_page.dart';
import 'view_process_specification_logic.dart';

class ViewProcessSpecificationPage extends StatefulWidget {
  const ViewProcessSpecificationPage({super.key});

  @override
  State<ViewProcessSpecificationPage> createState() =>
      _ViewProcessSpecificationPageState();
}

class _ViewProcessSpecificationPageState
    extends State<ViewProcessSpecificationPage> {
  final logic = Get.put(ViewProcessSpecificationLogic());
  final state = Get.find<ViewProcessSpecificationLogic>().state;

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      queryWidgets: [
        EditText(
          hint: 'view_process_specification_query_hint'.tr,
          onChanged: (v) => state.etTypeBody = v,
        ),
      ],
      query: () => logic.queryProcessSpecification(),
      body: Obx(
        () => ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: state.pdfList.length,
          itemBuilder: (context, index) => Card(
            child: ListTile(
              onTap: () => Get.to(
                () => WebPage(
                  title:  state.pdfList[index].name ?? '',
                  url: state.pdfList[index].fullName ?? '',
                ),
              ),
              title: textSpan(
                hint: 'view_process_specification_item_hint1'.tr,
                text: state.pdfList[index].name ?? '',
              ),
              subtitle: textSpan(
                hint: 'view_process_specification_item_hint2'.tr,
                text: state.pdfList[index].typeName ?? '',
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<ViewProcessSpecificationLogic>();
    super.dispose();
  }
}
