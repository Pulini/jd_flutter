import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/smart_delivery/smart_delivery_logic.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';


class CreateDeliveryOrderPage extends StatefulWidget {
  const CreateDeliveryOrderPage({super.key});

  @override
  State<CreateDeliveryOrderPage> createState() =>
      _CreateDeliveryOrderPageState();
}

class _CreateDeliveryOrderPageState extends State<CreateDeliveryOrderPage> {
  final logic = Get.find<SmartDeliveryLogic>();
  final state = Get.find<SmartDeliveryLogic>().state;
  var controller = TextEditingController(text: '0');

  @override
  void initState() {
    logic.setDeliveryLines(controller.text.toIntTry());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '创建配送单',
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            Row(
              children: [
                expandedTextSpan(
                    hint: '工厂型体：', text: state.deliveryDetail!.typeBody ?? ''),
                expandedTextSpan(
                    hint: '销售订单：', text: state.deliveryDetail!.seOrders ?? ''),
                expandedTextSpan(
                    hint: 'PO号：',
                    text: state.deliveryDetail!.clientOrderNumber ?? ''),
              ],
            ),
            Row(
              children: [
                expandedTextSpan(
                    hint: '部位：', text: state.deliveryDetail!.partName ?? ''),
                expandedTextSpan(
                    hint: '货号：', text: state.deliveryDetail!.mapNumber ?? ''),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        '预留楦头',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () {
                          if (controller.text.toIntTry() > 0) {
                            controller.text =
                                (controller.text.toIntTry() - 1).toString();
                          }
                        },
                        icon: Icon(Icons.remove_circle_outline,
                            color: Colors.red),
                      ),
                      Expanded(
                        child: TextField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (c) {
                            controller.text = c.toIntTry().toString();
                            controller.selection = TextSelection.fromPosition(
                              TextPosition(
                                offset: controller.text.length,
                              ),
                            );
                          },
                          controller: controller,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[300],
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          controller.text =
                              (controller.text.toIntTry() + 1).toString();
                        },
                        icon:
                            Icon(Icons.add_circle_outline, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: (state.deliveryDetail!.partsSizeList!.length + 3) * 50,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // for(SizeInfo s in state.deliveryDetailList[0]!!.sendSizeList!!)
                          // expandedFrameText(text: s),
                        ],
                      ),
                      Container(
                        color: Colors.greenAccent,
                        margin: EdgeInsets.all(8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(state.deliveryDetailList[0].round ?? ''),
                            Text(state.deliveryDetailList[1].round ?? '')
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    state.deliveryDetail = null;
    super.dispose();
  }
}
