import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;


class LarkWebHelper {

  /// Web 平台实现：注册 window message 监听 + HtmlElementView 的 iframe 工厂
  static void initIframeWebListener(void Function(String) onMessage) {
    web.window.addEventListener(
      'message',
      ((web.Event e) {
        final msg = (e as web.MessageEvent).data.toString();
        onMessage(msg);
      }).toJS,
    );
    ui_web.platformViewRegistry.registerViewFactory(
      'feishu-login-iframe',
          (int viewId) {
        final iframe =
        web.document.createElement('iframe') as web.HTMLIFrameElement;
        iframe.src = 'feishu.html';
        iframe.style.border = 'none';
        iframe.style.width = '100%';
        iframe.style.height = '100%';
        return iframe;
      },
    );
  }

}
