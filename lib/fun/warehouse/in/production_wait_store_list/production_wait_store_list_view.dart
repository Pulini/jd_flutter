import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/in/production_wait_store_list/production_wait_store_list_logic.dart';
import 'package:jd_flutter/fun/warehouse/in/production_wait_store_list/production_wait_store_list_state.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

class ProductionWaitStoreListPage extends StatefulWidget {
  const ProductionWaitStoreListPage({super.key});

  @override
  State<ProductionWaitStoreListPage> createState() =>
      _ProductionWaitStoreListPageState();
}

class _ProductionWaitStoreListPageState
    extends State<ProductionWaitStoreListPage> {
  final ProductionWaitStoreListLogic logic =
      Get.put(ProductionWaitStoreListLogic());
  final ProductionWaitStoreListState state =
      Get.find<ProductionWaitStoreListLogic>().state;

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      queryWidgets: [


      ],
      query: (){

      },
      body: Column(
        children: [
          // Expanded(
          //   child: Obx(() => ListView.builder(
          //     padding: const EdgeInsets.all(8),
          //     itemCount: state.dataList.length,
          //     itemBuilder: (context, index) =>
          //         _item1(state.dataList[index], index),
          //   )),
          // ),
        ],
      ),
    );
  }
}
