import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import 'view_instruction_details_logic.dart';

class ViewInstructionDetailsPage extends StatefulWidget {
  const ViewInstructionDetailsPage({super.key});

  @override
  State<ViewInstructionDetailsPage> createState() =>
      _ViewInstructionDetailsPageState();
}

class _ViewInstructionDetailsPageState
    extends State<ViewInstructionDetailsPage> {
  final logic = Get.put(ViewInstructionDetailsLogic());
  final state = Get.find<ViewInstructionDetailsLogic>().state;
  var tecInstruction = TextEditingController();
  var pickerControllerProcessFlow = OptionsPickerController(
    PickerType.mesProcessFlow,
    saveKey:
        '${RouteConfig.viewInstructionDetails.name}${PickerType.mesProcessFlow}',
  );

  late final WebViewController webViewController;

  @override
  void initState() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            loadingShow('加载中');
          },
          onPageFinished: (String url) {
            loadingDismiss();
          },
          onHttpError: (HttpResponseError error) {
            loadingDismiss();
          },
          onWebResourceError: (WebResourceError error) {
            loadingDismiss();
          },
        ),
      );
    super.initState();
  }

  /// 构建WebView。Android上强制使用Hybrid Composition(displayWithHybridComposition:true)，
  /// 使WebView成为真实原生View、能接收触摸手势并内部滚动——否则默认Surface(虚拟显示)模式下
  /// 原生触摸不转发给WebView，导致"无法拖动"(hwbr等引擎尤为明显)。
  Widget _webViewWidget() {
    if (GetPlatform.isAndroid) {
      return WebViewWidget.fromPlatformCreationParams(
        params: AndroidWebViewWidgetCreationParams(
          controller: webViewController.platform,
          displayWithHybridComposition: true,
        ),
      );
    }
    return WebViewWidget(controller: webViewController);
  }

  void _query() {
    logic.queryFile(
      processFlowID: pickerControllerProcessFlow.selectedId.value,
      instruction: tecInstruction.text,
      toWeb: (html) => webViewController.loadHtmlString(html),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      queryWidgets: [
        EditText(
          hint: 'view_instruction_details_query_hint'.tr,
          controller: tecInstruction,
        ),
        OptionsPicker(pickerController: pickerControllerProcessFlow),
      ],
      query: () => _query(),
      body: GetPlatform.isAndroid || GetPlatform.isIOS
          ? _webViewWidget()
          : Container(),
    );
  }

  @override
  void dispose() {
    if (GetPlatform.isAndroid || GetPlatform.isIOS) {
      webViewController.clearLocalStorage();
    }
    Get.delete<ViewInstructionDetailsLogic>();
    super.dispose();
  }
}
