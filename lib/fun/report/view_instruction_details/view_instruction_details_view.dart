import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/app_init.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/web_page.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  // 内容等比缩放后的显示高度，用于Flutter纵向滚动；初始值仅为避免首帧空白
  double _contentHeight = 600;

  // Flutter实际给WebView的宽度(=SizedBox宽)，作为缩放基准avail最可靠
  double _webViewWidth = 0;

  // 最近一次JS回传的高度，用于判断缩放是否稳定(连续两次一致才关闭loading)
  double _lastRawHeight = -1;

  @override
  void initState() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel(
        'FlutterWebView',
        onMessageReceived: (message) {
          // 上报格式: "1,缩放后显示高,内容自然宽cw,可用宽avail,缩放比s"
          final p = message.message.split(',');
          final h = double.tryParse(p.length > 1 ? p[1] : '') ?? 0;
          if (p.isNotEmpty && p[0] == '1') {
            debugPrint('[_fit] h=$h cw=${p.length > 2 ? p[2] : '?'} '
                'avail=${p.length > 3 ? p[3] : '?'} s=${p.length > 4 ? p[4] : '?'}');
          }
          // if (h > 0 && mounted) {
          //   // JS侧fit()会多次回传(立即+600ms+图片load)，仅在高度变化时setState，避免重复重绘/日志
          //   if (h != _contentHeight) {
          //     setState(() => _contentHeight = h);
          //   }
          //   // 仅当高度连续两次一致(缩放已稳定、图片已基本就绪)才关闭loading，
          //   // 避免首屏提前回传就关闭弹窗、页面尚未完美加载
          //   if (h == _lastRawHeight) {
          //     loadingDismiss();
          //   }
          //   _lastRawHeight = h;
          // }
          if (h > 0 && mounted) {
            setState(() => _contentHeight = h);
          }
          if (h == _lastRawHeight) {
            loadingDismiss();
          }
          _lastRawHeight = h;
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            loadingShow('加载中');
          },
          onPageFinished: (String url) {
            if (needServerLoadHtml()) {
              _fit();
            } else {
              loadingDismiss();
            }
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

  // 等比缩放内容到屏幕宽度(只缩不放)，并把缩放后高度回传Flutter用于纵向滚动。
  // 关键：仅在“加载完成 / 图片load / 延迟600ms”各跑一次——这些都是有限事件。
  // 切勿用ResizeObserver监听body/documentElement：fit会改这两个节点的DOM，会触发
  // resize→再fit→再改DOM的死循环，使hwbr_engine反复重建渲染surface(日志platform view 2→8)，
  // 导致卡顿数秒、且页面常停在未缩放的中间态(右侧溢出、高度未缩)。
  void _fit() {
    // 缩放基准avail=Flutter实际给WebView的宽度(=屏幕可用宽)，最可靠。
    final avail = _webViewWidth > 0 ? _webViewWidth : 360.0;
    final js = '''
(function(){
  var b=document.body, clip=document.getElementById('__clip__'), wrap=document.getElementById('__w__');
  if(!clip){
    clip=document.createElement('div'); clip.id='__clip__';
    wrap=document.createElement('div'); wrap.id='__w__';
    while(b.firstChild) wrap.appendChild(b.firstChild);
    clip.appendChild(wrap); b.appendChild(clip);
    var st=document.createElement('style');
    st.textContent='html,body{overflow:hidden!important;margin:0!important;padding:0!important;height:auto!important}'
      +'#__clip__{overflow:hidden!important}#__w__{width:auto;transform-origin:top left}';
    document.documentElement.appendChild(st);
  }
  function fit(){
    var avail=$avail;
    wrap.style.transform='none';
    // wrap为块级(宽=avail)，scrollWidth天然含溢出内容的完整宽度，不受overflow-x:hidden/回流影响
    var cw=Math.max(wrap.scrollWidth, avail);
    var s=cw>avail ? avail/cw : 1;
    wrap.style.transform='scale('+s+')';
    var vh=Math.round(wrap.offsetHeight*s);
    clip.style.width=(cw>avail?avail:cw)+'px';
    clip.style.height=vh+'px';
    if(window.FlutterWebView) FlutterWebView.postMessage('1,'+vh+','+Math.round(cw)+','+avail+','+s);
  }
  fit();
  var imgs=document.getElementsByTagName('img');
  for(var i=0;i<imgs.length;i++) if(!imgs[i].complete){ imgs[i].addEventListener('load',fit); imgs[i].addEventListener('error',fit); }
  setTimeout(fit,600);
})();
''';
    webViewController.runJavaScript(js).catchError((e) {
      debugPrint('[_fit] js error: $e');
      return null;
    });
  }

  void _query() {
    logic.queryFile(
      processFlowID: pickerControllerProcessFlow.selectedId.value,
      instruction: tecInstruction.text,
      // 鸿蒙2.0 hwbr_engine: 本地HTTP Server加载HTML(loadHtmlString会触发"url has no host"空白)
      toWeb: (html) => needServerLoadHtml()
          ? loadFixedHtml(webViewController, html)
          : webViewController.loadHtmlString(html),
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
          ? needServerLoadHtml()
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    // 记录Flutter实际给WebView的宽度，作为JS缩放基准avail(=屏幕可用宽)
                    final width = constraints.maxWidth;
                    if (width > 0) _webViewWidth = width;
                    return SingleChildScrollView(
                      child: SizedBox(
                        width: width > 0 ? width : 360.0,
                        height: _contentHeight,
                        child: WebViewWidget(controller: webViewController),
                      ),
                    );
                  },
                )
              : WebViewWidget(controller: webViewController)
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
