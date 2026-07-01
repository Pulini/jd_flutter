import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/http/response/feishu_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/feishu_authorize.dart';
import 'package:web/web.dart' as web;
import 'package:webview_flutter/webview_flutter.dart';

/// 飞书登录 Widget
/// - 移动端（Android/iOS）：使用 webview_flutter 加载 feishu.html
/// - Web 端：使用 HtmlElementView 嵌入 iframe 加载 feishu.html
///   扫码后 feishu.html 在 iframe 内跳转到飞书授权页，
///   回调页 FeiShuCallBack.aspx 通过 postMessage 将 code 发回 Flutter
class LarkLoginWidget extends StatefulWidget {
  final Function(String userId) login;

  const LarkLoginWidget({super.key, required this.login});

  @override
  State<LarkLoginWidget> createState() => _LarkLoginWidgetState();
}

class _LarkLoginWidgetState extends State<LarkLoginWidget> {
  // ========== 移动端 WebView Controller ==========
  late final WebViewController webViewController;

  // ========== Web 端消息监听（静态，全局只注册一次）==========
  static bool _webListenerRegistered = false;
  static bool _viewFactoryRegistered = false;

  // ========== 网络 ==========
  // var dio = Dio()..interceptors.add(DioManager.simpleInterceptors);

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _ensureWebListener();
      _ensureViewFactoryRegistered();
    } else {
      _initWebView();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAssetUrl());
  }

  void _initWebView() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('onPageStarted------$url');
            loadingShow('加载中...');
          },
          onPageFinished: (String url) {
            debugPrint('onPageFinished------$url');
            loadingDismiss();
            // 移动端：关闭 GPU 加速，避免 Android 7 canvas 空白
            if (!kIsWeb) disableWebViewGpu();
            larkAuthorize(url);
          },
          onHttpError: (HttpResponseError error) {
            debugPrint('onHttpError------${error.response?.statusCode}');
            loadingDismiss();
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint(
              'onWebResourceError------${error.description}'
              '|code:${error.errorCode}|type:${error.errorType}',
            );
            loadingDismiss();
          },
        ),
      );
  }

  /// 注册 Web 端 window message 监听（全局只注册一次）
  void _ensureWebListener() {
    if (_webListenerRegistered) return;
    _webListenerRegistered = true;
    web.window.addEventListener(
      'message',
      ((web.Event e) {
        final msg = (e as web.MessageEvent).data.toString();
        handleWebMessage(msg);
      }).toJS,
    );
  }

  /// 注册 HtmlElementView 的 iframe 工厂（全局只注册一次）
  void _ensureViewFactoryRegistered() {
    if (_viewFactoryRegistered) return;
    _viewFactoryRegistered = true;
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

  /// 处理 Web 端 iframe 发来的 postMessage
  void handleWebMessage(String msg) {
    if (!msg.contains('code=')) return;
    final url = msg.startsWith('?') ? '$redirectUri$msg' : msg;
    if (url.startsWith(redirectUri)) {
      larkAuthorize(url);
    }
  }

  /// 加载 feishu.html
  void _loadAssetUrl() {
    if (!mounted) return;
    if (kIsWeb) {
      // Web 端通过 HtmlElementView 加载，setState 触发重建
      setState(() {});
    } else {
      webViewController.loadFlutterAsset('assets/web/feishu.html');
    }
  }

  // ========== 飞书 OAuth 回调处理 ==========
  void larkAuthorize(String url) {
    if (url.startsWith(redirectUri)) {
      final code = Uri.parse(url).queryParameters['code'];
      debugPrint('code: $code');
      if (code != null && code.isNotEmpty) {
        _loginViaServerProxy(code);
        // 移动端：原生 HTTP 无 CORS 限制，直接调飞书 API
/*
         getLarkUserAccessToken(
          code: code,
          success: (token) => getLarkUserInfo(
            token: token,
            success: (userInfo) => widget.login(userInfo.userId ?? ''),
            error: (String msg) {
              errorDialog(content: msg);
              _loadAssetUrl();
            },
          ),
          error: (String msg) {
            errorDialog(content: msg);
            _loadAssetUrl();
          },
        );
        */
      } else {
        errorDialog(
          content: 'getting_lark_authorization_code_failed'.tr,
          back: () => _loadAssetUrl(),
        );
      }
    }
  }

  // ========== Web 端：通过 MES 服务器代理获取飞书用户信息 ==========
  // 服务器 api/FeiShu/LoginUserInfo 内部完成两步：
  //   1. 用 code 换取 user_access_token
  //   2. 用 token 获取用户信息
  void _loginViaServerProxy(String code) {
    httpPost(
      method: 'api/FeiShu/LoginUserInfo',
      loading: 'getting_lark_user_info'.tr,
      body: {
        'AppNumber': '6',
        'Code': code,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        final userInfo =
            LarkUserInfo.fromJson(jsonDecode(response.data['Datas'] as String));
        widget.login(userInfo.userId ?? '');
      } else {
        errorDialog(content: response.message);
        _loadAssetUrl();
      }
    });
  }

/*

  // ========== 获取飞书 token ==========
  void getLarkUserAccessToken({
    required String code,
    required Function(String accessToken) success,
    required Function(String msg) error,
  }) {
    loadingShow('getting_lark_token'.tr);
    dio
        .post(
      getUserTokenUrl,
      data: {
        'grant_type': 'authorization_code',
        'client_id': appID,
        'client_secret': appSecret,
        'code': code,
        'redirect_uri': redirectUri,
      },
      options: Options(
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      ),
    )
        .then(
      (response) {
        logger.f(response.data);

        loadingDismiss();
        final token = LarkUserTokenInfo.fromJson(response.data);
        if (token.code == 0) {
          success.call(token.accessToken ?? '');
        } else {
          error.call(
            'getting_lark_token_failed'.trArgs([token.code.toString()]),
          );
        }
      },
      onError: (e) {
        loadingDismiss();
        error.call(
          'getting_lark_token_failed'.trArgs([
            '${(e as DioException).response?.statusCode} ${e.response?.statusMessage}'
          ]),
        );
      },
    );
  }

  // ========== 获取飞书用户信息 ==========
  void getLarkUserInfo({
    required String token,
    required Function(LarkUserInfo userInfo) success,
    required Function(String msg) error,
  }) {
    loadingShow('getting_lark_user_info'.tr);
    dio
        .get(
      getUserInfoUrl,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=utf-8',
        },
      ),
    )
        .then(
      (response) {
        loadingDismiss();
        final code = response.data['code'];
        if (code == 0) {
          success.call(LarkUserInfo.fromJson(response.data['data']));
        } else {
          error.call('getting_lark_user_info_failed'.trArgs([code.toString()]));
        }
      },
      onError: (e) {
        loadingDismiss();
        error.call(
          'getting_lark_user_info_failed'.trArgs([
            '${(e as DioException).response?.statusCode} ${e.response?.statusMessage}'
          ]),
        );
      },
    );
  }
*/

  // ========== UI ==========
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        color: Colors.white,
        border: Border.all(color: Colors.blue, width: 4),
      ),
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            if (kIsWeb)
              const HtmlElementView(viewType: 'feishu-login-iframe')
            else
              WebViewWidget(controller: webViewController),
            Positioned(
              top: 10,
              left: 5,
              child: Text(
                'login_hint_lark'.tr,
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () => _loadAssetUrl(),
                icon: const Icon(Icons.refresh),
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
