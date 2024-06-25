import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../route.dart';
import '../../../widget/custom_widget.dart';
import '../../../widget/web_page.dart';
import 'view_process_specification_logic.dart';

class ViewProcessSpecificationPage extends StatefulWidget {
  const ViewProcessSpecificationPage({Key? key}) : super(key: key);

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
    // WebViewWidget(controller: logic.webViewController)
    return pageBodyWithDrawer(
      title: getFunctionTitle(),
      children: [
        EditText(hint: '请输入型体', onChanged: (v) => state.etTypeBody = v),
      ],
      query: () => logic.queryProcessSpecification(),
      body: Obx(
        () => ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: state.pdfList.length,
            itemBuilder: (BuildContext context, int index) => Card(
                  child: ListTile(
                    onTap: () {
                      Get.to(WebPage(
                        title: '',
                        url: state.pdfList[index].fullName ?? '',
                      ));
                    },
                    title: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: '型体：',
                            style: TextStyle(
                              color: Colors.blueAccent,
                            ),
                          ),
                          TextSpan(
                            text: state.pdfList[index].name,
                          ),
                        ],
                      ),
                    ),
                    subtitle: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: '分类：',
                            style: TextStyle(
                              color: Colors.blueAccent,
                            ),
                          ),
                          TextSpan(
                            text: state.pdfList[index].typeName,
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<ViewProcessSpecificationLogic>();
    super.dispose();
  }
}
