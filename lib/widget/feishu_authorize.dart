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

const String cloudDocSearch =
    'https://open.feishu.cn/open-apis/suite/docs-api/search/object'; //云文档搜索

const String cloudDocGetFileInfo =
    'https://open.feishu.cn/open-apis/drive/v1/metas/batch_query'; //云文档获取文件元数据

/// 飞书授权并查看知识库文件
feishuViewWikiFiles({required String query}) {
  if (query.isEmpty) {
    showSnackBar(message: 'feishu_authorize_query_empty'.tr);
  } else {
    querySuccess(List<FeishuWikiSearchItemInfo> files) {
      pickFilePopup(
        fileList: [
          for (var f in files) {'title': f.title, 'url': f.url}
        ],
        viewFile: (file) => Get.to(() => WebPage(
              title: file['title'] ?? '',
              url: file['url'] ?? '',
            )),
      );
    }

    feishuWikiAuthorizeCheck(
      notAuthorize: () => Get.to(
        () => FeishuAuthorize(isWikiPermission: true),
      )?.then((token) {
        if (token != null) {
          feishuWikiSearch(
            token: token,
            query: query,
            success: querySuccess,
            failed: (msg) => errorDialog(content: msg),
          );
        }
      }),
      authorized: (token) => feishuWikiSearch(
        token: token,
        query: query,
        success: querySuccess,
        failed: (msg) => errorDialog(content: msg),
      ),
    );
  }
}

/// 飞书授权并查看知识库文件
feishuViewCloudDocFiles({required String query}) {
  if (query.isEmpty) {
    showSnackBar(message: 'feishu_authorize_query_empty'.tr);
  } else {
    var authorizeToken = '';
    querySuccess(List<FeishuCloudDocSearchItemInfo> files) {
      debugPrint('files=${files.length}');
      pickFilePopup(
        fileList: [
          for (var f in files) {'title': f.title, 'url': f.docsToken}
        ],
        viewFile: (file) => feishuGetCloudDocInfo(
          token: authorizeToken,
          cloudDocInfo: files.firstWhere((v) => v.docsToken == file['url']),
          success: (metasData) => pickFilePopup(
            fileList: [
              for (var f in metasData) {'title': f.title, 'url': f.url}
            ],
            viewFile: (file) => Get.to(() => WebPage(
                  title: file['title'] ?? '',
                  url: file['url'] ?? '',
                )),
          ),
          failed: (msg) => errorDialog(content: msg),
        ),
      );
    }

    feishuCloudDocAuthorizeCheck(
      notAuthorize: () => Get.to(
        () => FeishuAuthorize(isWikiPermission: false),
      )?.then((token) {
        if (token != null) {
          authorizeToken = token;
          feishuCloudDocSearch(
            token: token,
            query: query,
            success: querySuccess,
            failed: (msg) => errorDialog(content: msg),
          );
        }
      }),
      authorized: (token) {
        authorizeToken = token;
        feishuCloudDocSearch(
          token: token,
          query: query,
          success: querySuccess,
          failed: (msg) => errorDialog(content: msg),
        );
      },
    );
  }
}

/// 飞书文件选择popup
pickFilePopup({required List<Map> fileList, required Function(Map) viewFile}) {
  debugPrint(fileList.toString());
  if (fileList.length == 1) {
    viewFile.call(fileList.first);
  } else {
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
            height: context.getScreenSize().height * 0.35,
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
                        'feishu_authorize_file_list'.tr,
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
                    itemCount: fileList.length,
                    itemBuilder: (c, i) => Card(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          children: [
                            Expanded(child: Text(fileList[i]['title'] ?? '')),
                            IconButton(
                              onPressed: () {
                                Get.back();
                                viewFile.call(fileList[i]);
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
}

/// 飞书授权检查
feishuWikiAuthorizeCheck({
  required Function() notAuthorize,
  required Function(String token) authorized,
}) {
  String feishuLoginCache = spGet(spSaveFeishuUserWikiTokenData) ?? '';
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

/// 飞书授权检查
feishuCloudDocAuthorizeCheck({
  required Function() notAuthorize,
  required Function(String token) authorized,
}) {
  String feishuLoginCache = spGet(spSaveFeishuUserCloudDocTokenData) ?? '';
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
  loadingShow('feishu_authorize_wiki_searching'.tr);
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
        var searchInfo = FeishuSearchResultInfo.fromJson(response.data);
        if (searchInfo.code == 0) {
          var wikiInfo = FeishuWikiSearchDataInfo.fromJson(searchInfo.data);
          if (wikiInfo.items?.isEmpty == true) {
            failed.call('feishu_authorize_not_find_file'.tr);
          } else {
            success.call(wikiInfo.items ?? []);
          }
        } else {
          failed.call(
            'feishu_authorize_wiki_search_failed'.trArgs([
              '${searchInfo.code}  ${searchInfo.msg}',
            ]),
          );
        }
      },
      onError: (e) {
        loadingDismiss();
        failed.call(
          'feishu_authorize_wiki_visit_failed'.trArgs([
            '${(e as DioException).response?.statusCode}  ${e.response?.statusMessage}',
          ]),
        );
      },
    );
}

/// 飞书云文档搜索
feishuCloudDocSearch({
  required String token,
  required String query,
  required Function(List<FeishuCloudDocSearchItemInfo> list) success,
  required Function(String error) failed,
}) {
  loadingShow('feishu_authorize_cloud_doc_searching'.tr);
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
      cloudDocSearch,
      data: {
        'search_key': query,
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
        var searchInfo = FeishuSearchResultInfo.fromJson(response.data);
        if (searchInfo.code == 0) {
          var cloudDocInfo = FeishuCloudDocSearchInfo.fromJson(searchInfo.data);
          if (cloudDocInfo.docs?.isEmpty == true) {
            failed.call('feishu_authorize_not_find_file'.tr);
          } else {
            success.call(cloudDocInfo.docs ?? []);
          }
        } else {
          failed.call(
            'feishu_authorize_cloud_doc_search_failed'.trArgs([
              '${searchInfo.code}  ${searchInfo.msg}',
            ]),
          );
        }
      },
      onError: (e) {
        loadingDismiss();
        failed.call(
          'feishu_authorize_cloud_doc_visit_failed'.trArgs([
            '${(e as DioException).response?.statusCode}  ${e.response?.statusMessage}',
          ]),
        );
      },
    );
}

/// 飞书云文档获取文件明细
feishuGetCloudDocInfo({
  required String token,
  required FeishuCloudDocSearchItemInfo cloudDocInfo,
  required Function(List<FeishuCloudDocFileMetasInfo> list) success,
  required Function(String error) failed,
}) {
  loadingShow('feishu_authorize_getting_file_detail'.tr);
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
      cloudDocGetFileInfo,
      data: {
        'request_docs': [
          {
            'doc_token': cloudDocInfo.docsToken,
            'doc_type': cloudDocInfo.docsType,
          }
        ],
        'with_url': true,
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
        var searchInfo = FeishuSearchResultInfo.fromJson(response.data);
        if (searchInfo.code == 0) {
          var cloudDocInfo = FeishuCloudDocFileInfo.fromJson(searchInfo.data);
          if (cloudDocInfo.metas?.isEmpty == true) {
            failed.call('feishu_authorize_not_find_file'.tr);
          } else {
            success.call(cloudDocInfo.metas ?? []);
          }
        } else {
          failed.call(
            'feishu_authorize_cloud_doc_get_metafile_failed'.trArgs([
              '${searchInfo.code}  ${searchInfo.msg}',
            ]),
          );
        }
      },
      onError: (e) {
        loadingDismiss();
        failed.call(
          'feishu_authorize_cloud_doc_visit_failed'.trArgs([
            '${(e as DioException).response?.statusCode}  ${e.response?.statusMessage}',
          ]),
        );
      },
    );
}

class FeishuAuthorize extends StatelessWidget {
  FeishuAuthorize({super.key, required this.isWikiPermission});

  final String permissionWikiSearch = 'wiki:wiki:readonly';
  final String permissionCloudDocSearch = 'drive:drive:readonly';
  final String permissionCloudDocReadonly = 'drive:drive.metadata:readonly';
  final bool isWikiPermission;
  final WebViewController webViewController = WebViewController();

  _getUserAccessToken(String code) {
    loadingShow('feishu_authorize_getting_user_token'.tr);
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
          spSave(
              isWikiPermission
                  ? spSaveFeishuUserWikiTokenData
                  : spSaveFeishuUserCloudDocTokenData,
              jsonEncode(feishu));
          if (feishu.code == 0) {
            successDialog(
              content: 'feishu_authorize_authorize_success'.tr,
              back: () => Get.back(result: feishu.accessToken),
            );
          } else {
            errorDialog(
              content: 'feishu_authorize_authorize_failed_code'.trArgs([
                feishu.code.toString(),
              ]),
              back: () {
                spSave(
                    isWikiPermission
                        ? spSaveFeishuUserWikiTokenData
                        : spSaveFeishuUserCloudDocTokenData,
                    '');
                Get.back();
              },
            );
          }
        },
        onError: (e) {
          loadingDismiss();
          errorDialog(
            content: 'feishu_authorize_authorize_failed'.trArgs([
              '${(e as DioException).response?.statusCode} ${e.response?.statusMessage}',
            ]),
            back: () {
              spSave(
                  isWikiPermission
                      ? spSaveFeishuUserWikiTokenData
                      : spSaveFeishuUserCloudDocTokenData,
                  '');
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
                  errorDialog(
                    content: 'feishu_authorize_get_authorize_code_failed'.tr,
                    back: () => Get.back(),
                  );
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
      webViewController.loadRequest(Uri.parse(
        '$authorizeUri?'
        'client_id=$appID'
        '&redirect_uri=${Uri.decodeComponent(redirectUri)}'
        '${isWikiPermission ? '&scope=$permissionWikiSearch' : '&scope=$permissionCloudDocSearch $permissionCloudDocReadonly'}'
        '&state=RANDOMSTRING',
      ));
    });
    return Container(
      decoration: backgroundColor(),
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
