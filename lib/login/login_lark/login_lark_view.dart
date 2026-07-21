import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:jd_flutter/bean/http/response/feishu_info.dart';
import 'package:jd_flutter/login/login_lark/login_lark_web_helper.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/feishu_authorize.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

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
  late final WebViewController webViewController;

  void _initWebView() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('onPageStarted------$url');
          },
          onPageFinished: (String url) {
            debugPrint('onPageFinished------$url');
            // 移动端：关闭 GPU 加速，避免 Android 7 canvas 空白
            // if (!kIsWeb) disableWebViewGpu();
            larkAuthorize(url);
          },
          onHttpError: (HttpResponseError error) {
            debugPrint('onHttpError------${error.response?.statusCode}');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint(
              'onWebResourceError------${error.description}'
              '|code:${error.errorCode}|type:${error.errorType}',
            );
          },
        ),
      );
  }

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
        //统一改为由MES服务器代理获取飞书用户信息
        _loginViaServerProxy(code);
/*  Web端调用飞书官方接口会被CORS限制跨域，移动端：原生 HTTP 无 CORS 限制
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
  var dio = Dio()..interceptors.add(DioManager.simpleInterceptors);

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

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      LarkWebHelper.initIframeWebListener((msg) {
        if (!msg.contains('code=')) return;
        final url = msg.startsWith('?') ? '$redirectUri$msg' : msg;
        if (url.startsWith(redirectUri)) {
          larkAuthorize(url);
        }
      });
    } else {
      _initWebView();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAssetUrl());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        color: Colors.white,
        border: Border.all(color: Colors.blue, width: 4),
      ),
      margin: const EdgeInsets.all(5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Transform.scale(
              scale: 0.95,
              alignment: Alignment.bottomCenter,
              child: kIsWeb
                  ? const HtmlElementView(viewType: 'feishu-login-iframe')
                  : _webViewWidget(),
            ),
            // WebViewWidget(controller: webViewController),
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
    webViewController.clearLocalStorage();
    super.dispose();
  }
}
