/// 条件导出：Web 编译时走 web 实现，Android/iOS 编译时走 stub 空实现
library;
export 'login_lark_web_helper_stub.dart'
    if (dart.library.js_interop) 'login_lark_web_helper_web.dart';
