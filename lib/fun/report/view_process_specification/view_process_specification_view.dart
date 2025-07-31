import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/pdf_view.dart';
import 'package:jd_flutter/widget/web_page.dart';

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
  var tecTypeBody = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      queryWidgets: [
        EditText(
          controller: tecTypeBody,
          hint: 'view_process_specification_query_hint'.tr,
        ),
      ],
      query: () => logic.queryProcessSpecification(tecTypeBody.text),
      body: Obx(
        () => ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: state.pdfList.length,
          itemBuilder: (context, index) => Card(
            child: ListTile(
              onTap: () => checkUrlType(
                url: state.pdfList[index].fullName ?? '',
                jdPdf: (url) => PDFViewerCachedFromUrl(
                  title: state.pdfList[index].name ?? '',
                  url: url,
                ),
                web: (url) => WebPage(
                  title: state.pdfList[index].name ?? '',
                  url: url,
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
