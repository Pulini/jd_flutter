/// 非 Web 平台空实现，Android/iOS 编译时走这个文件
class LarkWebHelper {
  ///非web平台，不做任何处理，但必须保持方法一致
  static void initIframeWebListener(void Function(String) onMessage) {}
}
