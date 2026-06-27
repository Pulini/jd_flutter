import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/http/response/feishu_info.dart';
import 'package:jd_flutter/utils/dio_manager.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/feishu_authorize.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LarkLoginWidget extends StatefulWidget {
  final Function(String userId) login;

  const LarkLoginWidget({super.key, required this.login});

  @override
  State<LarkLoginWidget> createState() => _LarkLoginWidgetState();
}

class _LarkLoginWidgetState extends State<LarkLoginWidget> {
  late var webViewController = WebViewController()
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
          larkAuthorize(url);
        },
        onHttpError: (HttpResponseError error) {
          debugPrint('onHttpError------${error.response?.statusCode}');
          loadingDismiss();
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('onWebResourceError------${error.description}');
          loadingDismiss();
        },
      ),
    );

  void _loadAssetUrl() =>
      webViewController.loadFlutterAsset('assets/web/feishu.html');

  var dio = Dio()..interceptors.add(DioManager.simpleInterceptors);

  void larkAuthorize(String url) {
    if (url.startsWith(redirectUri)) {
      final code = Uri.parse(url).queryParameters['code'];
      if (code != null) {
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
      } else {
        errorDialog(
          content: 'getting_lark_authorization_code_failed'.tr,
          back: () => _loadAssetUrl(),
        );
      }
    }
  }

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
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      ),
    )
        .then(
      (response) {
        loadingDismiss();
        var token = LarkUserTokenInfo.fromJson(response.data);
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
          'getting_lark_token_failed'.trArgs(
            [
              '${(e as DioException).response?.statusCode} ${e.response?.statusMessage}'
            ],
          ),
        );
      },
    );
  }

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
        var code = response.data['code'];
        if (code == 0) {
          success.call(LarkUserInfo.fromJson(response.data['data']));
        } else {
          error.call('getting_lark_user_info_failed'.trArgs([code]));
        }
      },
      onError: (e) {
        loadingDismiss();
        error.call(
          'getting_lark_user_info_failed'.trArgs(
            [
              '${(e as DioException).response?.statusCode} ${e.response?.statusMessage}'
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAssetUrl());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        color: Colors.white,
        border: Border.all(color: Colors.blueAccent, width: 4),
      ),
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
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
