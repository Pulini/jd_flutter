import 'dart:convert';
import 'dart:core';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/feishu_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/web_page.dart';
import 'package:webview_flutter/webview_flutter.dart';

const String appID = 'cli_a646a42958f2d00b'; //飞书 App ID
const String appSecret = 'Tr2EIogECpQtJh8ToQELHglDXCKbVHsb'; //飞书 App ID

const String authorizeUri =
    'https://accounts.feishu.cn/open-apis/authen/v1/authorize'; //获取授权码

const String redirectUri =
    'https://geapp.goldemperor.com:1226/Pages/FeiShu/FeiShuCallBack.aspx'; //重定向地址

const String getUserTokenUrl =
    'https://open.feishu.cn/open-apis/authen/v2/oauth/token'; //获取 user_access_token

const String wikiSearchUrl =
    'https://open.feishu.cn/open-apis/wiki/v1/nodes/search'; //wiki搜索


/// 飞书授权并查看知识库文件
feishuViewFiles({required String query}) {
  if (query.isEmpty) {
    showSnackBar(message: 'view_process_specification_query_hint'.tr);
  } else {
    feishuAuthorizeCheck(
      notAuthorize: () => Get.to(() => FeishuAuthorize())?.then((token) {
        if (token != null) {
          feishuWikiSearch(
            token: token,
            query: query,
            success: (files) => pickFilePopup(files),
            failed: (msg) => errorDialog(content: msg),
          );
        }
      }),
      authorized: (token) => feishuWikiSearch(
        token: token,
        query: query,
        success: (files) => pickFilePopup(files),
        failed: (msg) => errorDialog(content: msg),
      ),
    );
  }
}

/// 飞书文件选择popup
pickFilePopup(List<FeishuWikiSearchItemInfo> list) {
  showCupertinoModalPopup(
    context: Get.overlayContext!,
    barrierDismissible: false,
    builder: (BuildContext context) => PopScope(
      canPop: true,
      child: SingleChildScrollView(
        primary: true,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.35,
          padding: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            gradient: LinearGradient(
              colors: [Colors.lightBlueAccent, Colors.blueAccent],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'production_tasks_manuel_list'.tr,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      Icons.cancel_rounded,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (c, i) => Card(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        children: [
                          Expanded(child: Text(list[i].title ?? '')),
                          IconButton(
                            onPressed: () {
                              Get.back();
                              Get.to(() => WebPage(
                                    title: list[i].title ?? '',
                                    url: list[i].url ?? '',
                                  ));
                            },
                            icon: const Icon(
                              Icons.chevron_right,
                              color: Colors.blueAccent,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// 飞书授权检查
feishuAuthorizeCheck({
  required Function() notAuthorize,
  required Function(String token) authorized,
}) {
  String feishuLoginCache = spGet(feishuUserTokenData) ?? '';
  if (feishuLoginCache.isEmpty) {
    notAuthorize.call();
  } else {
    var tokenInfo =
        FeishuUserTokenInfo.fromSaveJson(jsonDecode(feishuLoginCache));
    if (tokenInfo.isTimeout()) {
      notAuthorize.call();
    } else {
      authorized.call(tokenInfo.accessToken ?? '');
    }
  }
}

/// 飞书wiki搜索
feishuWikiSearch({
  required String token,
  required String query,
  required Function(List<FeishuWikiSearchItemInfo> list) success,
  required Function(String error) failed,
}) {
  loadingDialog('正在搜索...');
  Dio()
    ..interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      options.print();
      handler.next(options);
    }, onResponse: (response, handler) {
      loggerF(response.data);
      handler.next(response);
    }, onError: (DioException e, handler) {
      logger.e('error:$e');
      handler.next(e);
    }))
    ..post(
      wikiSearchUrl,
      queryParameters: {
        'page_size': 20,
      },
      data: {
        'query': query,
        // 'space_id': '7401026939613921283',//限制查询范围id
        // 'node_id': '',
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      ),
    ).then(
      (response) {
        loadingDismiss();
        var searchInfo = FeishuWikiSearchInfo.fromJson(response.data);
        if (searchInfo.code == 0) {
          if (searchInfo.data?.items?.isEmpty == true) {
            failed.call('找不到相应的文件');
          } else {
            success.call(searchInfo.data?.items ?? []);
          }
        } else {
          failed.call('wiki 搜索失败：${searchInfo.code}  ${searchInfo.msg}');
        }
      },
      onError: (e) {
        loadingDismiss();
        failed.call(
            'wiki 访问失败：${(e as DioException).response?.statusCode}  ${e.response?.statusMessage}');
      },
    );
}

class FeishuAuthorize extends StatelessWidget {
  FeishuAuthorize({super.key});

  final String authUrl = '$authorizeUri?'
      'client_id=$appID'
      '&redirect_uri=${Uri.decodeComponent(redirectUri)}'
      '&scope=wiki:wiki:readonly'
      '&state=RANDOMSTRING';

  final WebViewController webViewController = WebViewController();

  _getUserAccessToken(String code) {
    loadingDialog('正在获取用户Token...');
    Dio()
      ..interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          options.print();
          handler.next(options);
        },
        onResponse: (response, handler) {
          loggerF(response.data);
          handler.next(response);
        },
        onError: (DioException e, handler) {
          logger.e('error:$e');
          handler.next(e);
        },
      ))
      ..post(
        getUserTokenUrl,
        data: {
          'grant_type': 'authorization_code',
          'client_id': appID,
          'client_secret': appSecret,
          'code': code,
          'redirect_uri': redirectUri,
          'app_id': appID,
          'app_secret': appSecret,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
          },
        ),
      ).then(
        (response) {
          loadingDismiss();
          var feishu = FeishuUserTokenInfo.fromJson(response.data);
          spSave(feishuUserTokenData, jsonEncode(feishu));
          if (feishu.code == 0) {
            successDialog(
              content: '授权成功',
              back: () => Get.back(result: feishu.accessToken),
            );
          } else {
            errorDialog(
              content: '获取token失败：飞书错误码：${feishu.code} ',
              back: () {
                spSave(feishuUserTokenData, '');
                Get.back();
              },
            );
          }
        },
        onError: (e) {
          loadingDismiss();
          errorDialog(
            content:
                '获取token失败：${(e as DioException).response?.statusCode} ${e.response?.statusMessage}',
            back: () {
              spSave(feishuUserTokenData, '');
              Get.back();
            },
          );
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    if (GetPlatform.isMobile) {
      webViewController
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              debugPrint('onPageStarted------$url');
            },
            onPageFinished: (String url) {
              debugPrint('onPageFinished------$url');
              loadingDismiss();
              if (url.startsWith(redirectUri)) {
                // 提取授权码
                final code = Uri.parse(url).queryParameters['code'];
                debugPrint(code);
                if (code != null) {
                  _getUserAccessToken(code);
                } else {
                  errorDialog(content: '获取授权码失败！', back: () => Get.back());
                }
              }
            },
            onHttpError: (HttpResponseError error) {
              debugPrint('onHttpError------${error.response?.statusCode}');
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('onWebResourceError------${error.description}');
            },
          ),
        );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // if(GetPlatform.isWeb){
      //   goLaunch(Uri.parse(authUrl));
      // }else if(GetPlatform.isMobile){
      //   webViewController.loadRequest(Uri.parse(authUrl));
      // }
      webViewController.loadRequest(Uri.parse(authUrl));
    });
    return Container(
      decoration: backgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('feishu_authorize_login'.tr),
        ),
        body: GetPlatform.isAndroid || GetPlatform.isIOS
            ? WebViewWidget(controller: webViewController)
            : null,
      ),
    );
  }
}
