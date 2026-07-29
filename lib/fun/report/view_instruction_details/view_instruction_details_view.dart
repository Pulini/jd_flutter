import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/spinner_widget.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:url_launcher/url_launcher_string.dart';
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
  // 指令号历史下拉（最多保留 6 条，去重、最近优先）
  var spinnerController = SpinnerController(dataList: const []);
  final String _historyKey =
      '${RouteConfig.viewInstructionDetails.name}_instructionHistory';
  final String _spinnerSelectKey =
      '${RouteConfig.viewInstructionDetails.name}_instructionSpinnerSelect';
  var _history = <String>[];

  @override
  void initState() {
    if(GetPlatform.isAndroid || GetPlatform.isIOS){
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
    }
    // 读取已保存的指令号历史，初始化下拉
    final saved = spGet(_historyKey);
    if (saved is List) {
      _history = saved.map((e) => e.toString()).toList();
    }
    spinnerController = SpinnerController(
      dataList: _history,
      saveKey: _spinnerSelectKey,
      onChanged: (index) {
        tecInstruction.text = spinnerController.select.value;
        _query(); // 选中历史项立即查询
      },
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
    final instruction = tecInstruction.text.trim();
    logic.queryFile(
      processFlowID: pickerControllerProcessFlow.selectedId.value,
      instruction: instruction,
      toWeb: (html) {
        if(GetPlatform.isAndroid || GetPlatform.isIOS){
          state.showHtml.value = true; // 先显示 WebView（确保已挂载），再加载内容
          webViewController.loadHtmlString(html);
        }else{
          launchUrlString(html);
        }
        // 查询成功才把指令号加入历史列表
        _saveInstruction(instruction);
      }, errorToWeb: (mes) {
      errorDialog(content: mes,back: (){
        // 查询失败：不显示 html 内容
        state.showHtml.value = false;
      });
    },
    );
  }

  // 保存指令号到历史（最多 6 条，去重、最近优先），并刷新下拉
  void _saveInstruction(String value) {
    value = value.trim();
    if (value.isEmpty) return;
    _history.remove(value); // 去重：先移除已存在的旧记录
    _history.insert(0, value); // 最近查询的排在最前
    if (_history.length > 6) _history.length = 6;
    spSave(_historyKey, _history); // 持久化，下次进入页面自动加载
    spinnerController = SpinnerController(
      dataList: _history,
      saveKey: _spinnerSelectKey,
      onChanged: (index) {
        tecInstruction.text = spinnerController.select.value;
        _query(); // 选中历史项立即查询
      },
    );
    setState(() {});
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
        SizedBox(child: Spinner(controller: spinnerController)),
      ],
      query: () => _query(),
      body: GetPlatform.isAndroid || GetPlatform.isIOS
          ? Obx(
              () => Offstage(
                offstage: !state.showHtml.value,
                child: _webViewWidget(),
              ),
            )
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
