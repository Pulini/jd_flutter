
bluetooth(){

}
// _showBle() {
//   var size = MediaQuery.of(Get.overlayContext!).size;
//   var bkg = const BoxDecoration(
//     borderRadius: BorderRadius.only(
//       topLeft: Radius.circular(20),
//       topRight: Radius.circular(20),
//     ),
//     gradient: LinearGradient(
//       colors: [Colors.lightBlueAccent, Colors.blueAccent],
//       begin: Alignment.bottomLeft,
//       end: Alignment.topRight,
//     ),
//   );
//
//   var titleTextStyle = const TextStyle(
//     fontSize: 22,
//     color: Colors.white,
//     decoration: TextDecoration.none,
//   );
//
//   var back = IconButton(
//     onPressed: () {
//       streamSubscription?.cancel();
//       Get.back();
//     },
//     icon: const Icon(Icons.close, color: Colors.white),
//   );
//
//   var title = Obx(() => isScanning.value
//       ? Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const CupertinoActivityIndicator(
//               color: CupertinoColors.white,
//               radius: 13,
//             ),
//             const SizedBox(width: 5),
//             Text(
//               '正在搜索蓝牙...',
//               style: titleTextStyle,
//             )
//           ],
//         )
//       : Text(
//           '连接蓝牙',
//           style: titleTextStyle,
//         ));
//
//   var deviceList = Container(
//     width: size.width - 40,
//     height: size.height * 0.6,
//     decoration: BoxDecoration(
//       borderRadius: const BorderRadius.all(Radius.circular(10)),
//       color: Colors.grey.shade200,
//     ),
//     child: Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Obx(() => ListView.builder(
//             padding: const EdgeInsets.all(8),
//             itemCount: scanDeviceList.length,
//             itemBuilder: (BuildContext context, int index) => Container(
//               margin: const EdgeInsets.only(bottom: 8),
//               decoration: const BoxDecoration(
//                 borderRadius: BorderRadius.all(Radius.circular(10)),
//                 color: Colors.white,
//               ),
//               child: ListTile(
//                 title: Text(scanDeviceList[index].name),
//                 subtitle: Text(scanDeviceList[index].id),
//                 trailing: ElevatedButton(
//                   onPressed: () {},
//                   child: const Text('CONNECT'),
//                 ),
//               ),
//             ),
//           )),
//     ),
//   );
//   var searchButton = ElevatedButton(
//     style: ElevatedButton.styleFrom(
//       minimumSize: Size(size.width - 60, 50),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(25),
//       ),
//     ),
//     onPressed: () async {
//       if (isScanning.value) {
//         streamSubscription?.cancel();
//         isScanning.value = false;
//       } else {
//         _startScan();
//       }
//     },
//     child: Obx(() => Text(
//           isScanning.value ? '结束搜索' : '开始搜索',
//           style: const TextStyle(fontSize: 20),
//         )),
//   );
//
//   showCupertinoModalPopup(
//     context: Get.overlayContext!,
//     barrierDismissible: false,
//     builder: (BuildContext context) => PopScope(
//       //拦截返回键
//       canPop: false,
//       child: SingleChildScrollView(
//         primary: true,
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: Container(
//           width: size.width,
//           padding: const EdgeInsets.all(8.0),
//           decoration: bkg,
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               Positioned(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const SizedBox(height: 10),
//                     title,
//                     const SizedBox(height: 30),
//                     deviceList,
//                     const SizedBox(height: 30),
//                     searchButton,
//                     const SizedBox(height: 10)
//                   ],
//                 ),
//               ),
//               Positioned(right: 0, top: 0, child: back),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
//   _startScan();
// }
//
// _startScan() {
//   scanDeviceList.clear();
//   isScanning.value = true;
//   streamSubscription = ble.scanForDevices(
//     withServices: [],
//   ).listen((device) {
//     if (device.name.isNotEmpty) {
//       print('device=${device.toString()}');
//       final index = scanDeviceList.indexWhere((d) => d.id == device.id);
//       if (index >= 0) {
//         scanDeviceList[index] = device;
//       } else {
//         scanDeviceList.add(device);
//       }
//     }
//   }, onError: (e) {
//     showSnackBar(title: '蓝牙异常', message: e);
//     isScanning.value = false;
//   }, onDone: () {
//     showSnackBar(title: '搜索', message: "搜索蓝牙结束");
//     isScanning.value = false;
//   });
// }
