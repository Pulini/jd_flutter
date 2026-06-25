/// 按钮点击防抖，全局可用
/// onPressed: submit.throttled,               // 默认 600ms 冷却
/// onPressed: () => doX(id)).throttled,       // 闭包也支持
/// onPressed: submit.throttleWith(ms: 1000),   // 自定义冷却
class ThrottleUtil {
  static final Map<String, DateTime> _lastRuns = {};

  static String _callSite() {
    final trace = StackTrace.current.toString().split('\n');
    final frame = trace.length > 2 ? trace[2] : trace.last;
    final extracted = frame.trimLeft();
    final start = extracted.indexOf('package:');
    return start > 0 ? extracted.substring(start) : extracted;
  }

  static void Function() throttle(void Function() fn, {int ms = 1000}) {
    final key = _callSite();
    return () {
      final now = DateTime.now();
      final last = _lastRuns[key];
      if (last != null && now.difference(last) < Duration(milliseconds: ms)) return;
      _lastRuns[key] = now;
      fn();
    };
  }

  static void dispose() => _lastRuns.clear();
}

