import 'dart:async';
import 'dart:ui';

class GlobalTimer {
  static final GlobalTimer _instance = GlobalTimer._internal();
  Timer? _timer;

  factory GlobalTimer() {
    return _instance;
  }

  GlobalTimer._internal();

  void startTimer({
    required Duration delay,
    required VoidCallback action,
  }) {
    _timer?.cancel(); // 取消之前的计时器（如果存在）
    _timer = Timer(delay, () {
      action();
      // 计时器执行完成后释放资源
      _timer?.cancel();
      _timer = null;
    });
  }

  void pauseTimer() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
  }

  void resumeTimer({
    required Duration delay,
    required VoidCallback action,
  }) {
    pauseTimer(); // 先暂停计时器
    startTimer(delay: delay, action: action); // 重新开始计时器
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  bool isTimerActive() {
    return _timer?.isActive ?? false;
  }
}