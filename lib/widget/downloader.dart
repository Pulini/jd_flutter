import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:path_provider/path_provider.dart';

class Downloader {
  var url = '';
  late String fileName;
  String savePath = '';
  var progress = 0.0.obs;
  final cancel = CancelToken();
  final Function(String filePath) completed;
  var isDownloading = false.obs;

  Downloader({required this.url, required this.completed}) {
    fileName = url.substring(url.lastIndexOf('/') + 1);
    var height = MediaQuery.of(Get.overlayContext!).size.height;
    var width = MediaQuery.of(Get.overlayContext!).size.width;
    final double widgetWidth = min(height, width) * 0.618;

    showDialog<String>(
      context: Get.overlayContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          //拦截返回键
          canPop: false,
          child: Dialog(
            child: SizedBox(
              width: widgetWidth,
              height: 160,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text('正在下载<$fileName>...'),
                    const SizedBox(height: 15),
                    Obx(() => Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: LinearProgressIndicator(
                                backgroundColor: Colors.grey,
                                color: Colors.blue,
                                value: progress.value,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('${(progress.value * 1000).ceil() / 10}%'),
                          ],
                        )),
                    const SizedBox(height: 15),
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!isDownloading.value)
                              TextButton(
                                onPressed: () => completed.call(savePath),
                                child: const Text(
                                  '安装',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            if (!isDownloading.value)
                              TextButton(
                                onPressed: () => startDownload(),
                                child: const Text(
                                  '重新下载',
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                            TextButton(
                              onPressed: () {
                                if (isDownloading.value) cancel.cancel();
                                Get.back();
                              },
                              child: const Text(
                                '取消',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ))
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    getApkSavePath(url).then((path) async {
      savePath = path;
      var file = File(path);
      if (await file.exists() && await file.length() > 0) {
        progress.value = 1;
        completed.call(savePath);
      } else {
        startDownload();
      }
    });
  }

  Future<String> getApkSavePath(String url) async {
    var fileName = url.substring(url.lastIndexOf('/') + 1);
    var temporary = await getTemporaryDirectory();
    var savePath = '${temporary.path}/$fileName';
    logger.i('url:$url \nsavePath：$savePath\nfileName：$fileName');
    return savePath;
  }

  //下載文件
  startDownload() async {
    isDownloading.value = true;
    progress.value = 0.0;
    try {
      await Dio().download(
        url,
        savePath,
        cancelToken: cancel,
        options: Options(
          receiveTimeout: const Duration(minutes: 2),
          contentType: Headers.jsonContentType,
        ),
        onReceiveProgress: (int count, int total) {
          progress.value = count / total;
        },
      ).then((value) {
        isDownloading.value = false;
        Get.back();
        completed.call(savePath);
      });
    } on DioException catch (e) {
      isDownloading.value = false;
      logger.e('error:$e');
      if (e.type != DioExceptionType.cancel) {
        errorDialog(content: '下载异常：$e');
      }
    } on Exception catch (e) {
      isDownloading.value = false;
      logger.e('error:${e.toString()}');
      errorDialog(content: '发生错误：$e');
    } on Error catch (e) {
      isDownloading.value = false;
      logger.e('error:${e.toString()}');
      errorDialog(content: '发生异常：${e.toString()}');
    }
  }
}
