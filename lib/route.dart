import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

import '../home/home_view.dart';
import '../login/login_view.dart';
import '../report/daily_report/daily_report_view.dart';

class RouteConfig {
  static const String main = '/';
  static const String login = '/login';
  static const String dailyReport = '/daily_report';

  static List<GetPage> appRoutes = [
    GetPage(name: main, page: () => const Home(), transition: Transition.fadeIn),
    GetPage(name: login, page: () => const Login()),
    GetPage(name: dailyReport, page: () => const DailyReport()),
  ];

}
