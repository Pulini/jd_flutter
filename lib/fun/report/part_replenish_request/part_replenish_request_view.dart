import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'package:jd_flutter/bean/http/response/part_replenish_request_info.dart';
import 'package:jd_flutter/widget/view_photo.dart';
import 'part_replenish_request_logic.dart';
import 'part_replenish_request_state.dart';

class PartReplenishRequestPage extends StatefulWidget {
  const PartReplenishRequestPage({super.key});

  @override
  State<PartReplenishRequestPage> createState() =>
      _PartReplenishRequestPageState();
}

class _PartReplenishRequestPageState extends State<PartReplenishRequestPage>
    with TickerProviderStateMixin {
  final PartReplenishRequestLogic logic = Get.put(PartReplenishRequestLogic());
  final PartReplenishRequestState state =
      Get.find<PartReplenishRequestLogic>().state;
  late var tabController = TabController(length: 2, vsync: this);
  var pageController = PageController();

  @override
  void initState() {
    pdaScanner(scan: (code) => logic.scanCode(code));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        CombinationButton(
          text: '预补',
          combination: Combination.left,
          backgroundColor: Colors.orangeAccent,
          click: () {},
        ),
        CombinationButton(
          text: '实补',
          combination: Combination.right,
          backgroundColor: Colors.green,
          click: () {},
        ),
      ],
      body: Column(
        children: [
          TabBar(
            dividerColor: Colors.blueAccent,
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            controller: tabController,
            tabs: [
              Tab(text: '部件表'),
              Tab(text: '补料表'),
            ],
            onTap: (i) => pageController.jumpToPage(i),
          ),
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: (i) {
                tabController.animateTo(i);
              },
              scrollDirection: Axis.horizontal,
              children: [
                Obx(() => ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: state.partList.length,
                      itemBuilder: (c, i) =>
                          _PartReplenishItem(data: state.partList[i]),
                    )),
                Obx(() => ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount:
                          state.partList.where((v) => v.hasSelect()).length,
                      itemBuilder: (c, i) => _PartReplenishSubItem(
                        part: state.partList
                            .where((v) => v.hasSelect())
                            .toList()[i],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    pageController.dispose();
    Get.delete<PartReplenishRequestLogic>();
    super.dispose();
  }
}

class _PartReplenishItem extends StatelessWidget {
  final PartInfo data;
  const _PartReplenishItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Card(
          color: data.hasSelect()
              ? Colors.greenAccent.shade100
              : Colors.white,
          child: ExpansionTile(
            leading: _PartPicture(url: data.partPicture ?? '', width: 70, height: 70),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            title: Text(
              data.partNumber ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: data.hasSelect() ? Colors.green : Colors.black87,
              ),
            ),
            subtitle: AutoSizeText(
              data.partName.allowWordTruncation(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: data.hasSelect() ? Colors.green : Colors.black87,
              ),
              maxLines: 1,
              minFontSize: 8,
              maxFontSize: 18,
            ),
            children: [
              Divider(indent: 10, endIndent: 10),
              for (var sizeItem in data.sizeList ?? <PartSizeInfo>[]) ...[
                _PartSizeItem(sizeItem: sizeItem),
                Divider(indent: 15, endIndent: 15),
              ],
            ],
          ),
        ));
  }
}

class _PartSizeItem extends StatelessWidget {
  final PartSizeInfo sizeItem;
  const _PartSizeItem({required this.sizeItem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.only(left: 20, right: 5),
      child: Row(
        children: [
          textSpan(hint: '尺码：', text: '${sizeItem.size}'),
          Spacer(),
          SizedBox(
            width: 150,
            child: Obx(() => NumberDecimalEditText(
                  controller: TextEditingController(
                    text: sizeItem.replenishRequest.value > 0
                        ? sizeItem.replenishRequest.value.toShowString()
                        : '',
                  ),
                  hint: '补货数',
                  onChanged: (d) => sizeItem.replenishRequest.value = d,
                )),
          ),
        ],
      ),
    );
  }
}

class _PartReplenishSubItem extends StatelessWidget {
  final PartInfo part;
  const _PartReplenishSubItem({required this.part});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey, width: 2),
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textSpan(
            hint: '部件号：',
            text: part.partNumber ?? '',
            hintColor: Colors.black54,
            textColor: Colors.black87,
          ),
          textSpan(
            hint: '部件名：',
            text: part.partName.allowWordTruncation(),
            maxLines: 2,
            hintColor: Colors.black54,
            textColor: Colors.black87,
          ),
          Center(
            child: _PartPicture(
              url: part.partPicture ?? '',
              width: MediaQuery.of(context).size.width * 0.88,
              height: MediaQuery.of(context).size.width * 0.88 / 2,
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.only(left: 10, top: 10, right: 10),
            child: Row(
              children: [
                ExpandedFrameText(
                  text: '尺码',
                  textColor: Colors.white,
                  isBold: true,
                  alignment: Alignment.center,
                  backgroundColor: Colors.blue.shade300,
                ),
                ExpandedFrameText(
                  text: '补料数',
                  textColor: Colors.white,
                  isBold: true,
                  alignment: Alignment.center,
                  backgroundColor: Colors.blue.shade300,
                ),
              ],
            ),
          ),
          for (var sizeItem in (part.sizeList ?? <PartSizeInfo>[])
              .where((v) => v.replenishRequest.value > 0))
            Padding(
              padding: EdgeInsetsGeometry.only(left: 10, right: 10),
              child: Row(
                children: [
                  ExpandedFrameText(
                    text: '${sizeItem.size}',
                    alignment: Alignment.center,
                  ),
                  ExpandedFrameText(
                    text: sizeItem.replenishRequest.value.toShowString(),
                    alignment: Alignment.center,
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsetsGeometry.only(left: 10, right: 10, bottom: 10),
            child: Row(
              children: [
                ExpandedFrameText(
                  text: '共计补料数',
                  textColor: Colors.white,
                  isBold: true,
                  backgroundColor: Colors.green.shade200,
                  alignment: Alignment.center,
                ),
                ExpandedFrameText(
                  text: (part.sizeList ?? <PartSizeInfo>[])
                      .where((v) => v.replenishRequest.value > 0)
                      .map((v) => v.replenishRequest.value)
                      .reduce((a, b) => a.add(b))
                      .toShowString(),
                  textColor: Colors.white,
                  isBold: true,
                  backgroundColor: Colors.green.shade200,
                  alignment: Alignment.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PartPicture extends StatelessWidget {
  final String url;
  final double width;
  final double height;

  const _PartPicture({
    required this.url,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => ViewNetPhoto(photos: [url])),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: url.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: url,
                  width: width,
                  height: height,
                  fit: BoxFit.cover,
                  errorWidget: (ctx, err, st) => Image.asset(
                    'assets/images/ic_logo.png',
                    color: Colors.blue.shade200,
                  ),
                )
              : Image.asset(
                  'assets/images/ic_logo.png',
                  color: Colors.blue.shade200,
                ),
        ),
      ),
    );
  }
}
