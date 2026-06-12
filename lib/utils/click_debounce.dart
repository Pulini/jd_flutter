import 'dart:ui';

import 'package:flutter/cupertino.dart';

/// 点击防抖工具，防止快速连续点击触发多次操作
class ClickDebouncer {
  final Duration duration;
  DateTime _lastClick = DateTime(2000);

  ClickDebouncer({this.duration = const Duration(milliseconds: 500)});

  /// 执行带防抖的操作，如果在 duration 时间内重复调用则忽略
  void run(VoidCallback action) {
    final now = DateTime.now();
    if (now.difference(_lastClick) < duration) return;
    _lastClick = now;
    action();
  }

  /// 重置防抖计时器
  void reset() {
    _lastClick = DateTime(2000);
  }
}

/// 扩展方法：一行代码给 VoidCallback 添加防抖
///
/// 用法：
/// ```dart
/// // 直接加 .debounced 即可
/// onPressed: (() => logic.submit()).debounced,
/// onTap: (() => logic.deleteItem(data)).debounced,
/// ```
///
/// 注意：每次调用 .debounced 都创建新的 ClickDebouncer。适用于点击后
/// 会跳转页面/弹出弹窗等场景。如果点击后频繁 rebuild，建议改用
/// [ClickDebounceState] mixin。
extension VoidCallbackDebounce on VoidCallback {
  /// 返回一个带防抖的闭包，连续点击间隔小于 500ms 会自动忽略
  VoidCallback get debounced {
    final d = ClickDebouncer();
    return () => d.run(this);
  }
}

/// Mixin：在 StatefulWidget 的 State 中零样板使用防抖
///
/// 用法：
/// ```dart
/// class _MyPageState extends State<MyPage> with ClickDebounceState {
///   Widget build(BuildContext context) {
///     return ElevatedButton(
///       onPressed: () => debounceRun(() => logic.submit()),
///     );
///   }
/// }
/// ```
///
/// 相比手动声明 `final _debouncer = ClickDebouncer()`，只需加一个 mixin
/// 就能直接调用 debounceRun()。
mixin ClickDebounceState<T extends StatefulWidget> on State<T> {
  final ClickDebouncer _clickDebouncer = ClickDebouncer();

  /// 以带防抖的方式执行 action，自动绑定 State 生命周期
  void debounceRun(VoidCallback action) => _clickDebouncer.run(action);
}
