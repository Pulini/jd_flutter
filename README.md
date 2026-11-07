# 金帝 ERP 移动端（jd_flutter）

金帝集团生产制造执行（MES）客户端，覆盖 **派工、报工、仓储出入库、生产报表、行政事务** 等现场业务。
同时运行在 Android 手机/PDA、iOS 与 Web 浏览器上，深度依赖现场硬件：标签打印机（TSC 蓝牙/USB）、扫码枪/PDA 广播扫码、电子地磅、人脸识别终端。

- 包名：`com.jd.pzx.jd_flutter`，当前版本见 `pubspec.yaml`（`version: 2.5.1+251`）
- 分支：`master`
- 支持语言：简体中文 / English / Indonesian / မြန်မာ

---

## 1. 功能概览

| 业务域 | 目录 | 主要内容 |
| --- | --- | --- |
| 派工 | `lib/fun/dispatching` | 生产派工、机台派工、材料车间派工、部件派工（订单/班组/打包方式）、工单列表、工序派工登记、注塑扫码报工 |
| 仓储 | `lib/fun/warehouse` | 入库（送货单、来料稽查、暂收、采购入库、SAP 无标/注塑/生产入库、上架、跨库、供应商扫码、防伪标）、出库（领料、备料、销售出库、SAP 拣配过账、装柜、打印领料、移库领料）、库内管理（箱标扫码、部件标签打印、盘点、调拨、标签重打/拆分/绑定、智能配送、即时库存、巡线、品检、托盘打印） |
| 报工 | `lib/fun/work_reporting` | 工序报工、派工单列表、部件扫码报工/取消报工、部件交接、交接报表、生产任务、车间计划 |
| 报表 | `lib/fun/report` | 扫码日产量、生产日报、产量汇总、员工计件产量/明细、打包区报表、成型后段看板、生产用料表、指令明细、工艺说明书、部件补料申请、订单生产执行表 |
| 行政 | `lib/fun/management` | 财产（固定资产验收）、来访登记、考勤看板 |
| 设备 | `lib/fun/maintenance` | SAP 油墨调色单 |
| 其它 | `lib/fun/other` | 设备维修记录、水电超标、标签维护 |

---

## 2. 技术栈

| 类别 | 方案 |
| --- | --- |
| 框架 | Flutter（Dart SDK `>=3.4.3 <4.0.0`），Material 3 |
| 架构/状态 | GetX（fork: `luis901101/getx_fork@old-4.7.0`）、`Obx` + `Rx*` |
| 网络 | Dio（`lib/utils/dio_manager.dart` 多实例 + DNS 缓存 + 自动重试） |
| 本地存储 | SharedPreferences（配置/登录态）、sqflite（`jd_app.db`，离线缓存 6 张表） |
| 扫码 | `mobile_scanner`（相机识别）、PDA 广播扫码（原生通道） |
| 打印 | TSC 指令直连打印机（蓝牙/USB）、A4 报表 PDF（`pdf` 包）、服务端在线打印 |
| 实时通信 | `mqtt_client`（分平台工厂：native / web） |
| 推送 | 极光推送 `jpush_flutter` |
| 其它 | `webview_flutter`、`camera`、`image`/`image_cropper`、`hand_signature`、`qr_flutter`、`decimal`、`easy_refresh` |

---

## 3. 快速开始

### 3.1 环境要求

- Flutter stable（Dart 版本需满足 `pubspec.yaml` 的 SDK 约束）
- Android：JDK **17**、AGP **9.0.1**、Kotlin **2.3.20**（见 `android/settings.gradle`）
- iOS：Xcode，部署目标 **iOS 15.0**
- Web：Chrome 等现代浏览器（部分原生能力不可用）

### 3.2 运行

```bash
flutter pub get
flutter devices                 # 查看设备
flutter run -d <deviceId>       # 多设备时必须用 -d 指定，否则报 more than one device
```

### 3.3 打包

```bash
# Android（签名信息读取 android/key.properties，未配置则无法出正式包）
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ipa --release

# Web
flutter build web --release

# 修改启动图后重新生成原生启动页
flutter pub run flutter_native_splash:create
```

---

## 4. 目录结构

```
lib/
├── main.dart              # 入口：GetMaterialApp、多语言、主题、初始路由 /login
├── route.dart             # 全部路由集中注册（GetPage + FunctionID 版本号）
├── translation.dart       # 4 语言文案表（体积较大，按业务前缀分组）
├── constant.dart          # MethodChannel 名、SharedPreferences key、数据库名
├── bean/                  # 数据模型：接口响应体 bean/http/response/*，本地库表实体
├── login/                 # 登录（工号/手机/人脸/机台/飞书），含 MES/SAP 环境切换
├── home/                  # 首页（功能按钮宫格）与设置页
├── message_center/        # 站内消息
├── forgot_password/       # 忘记密码
├── fun/                   # 业务功能页（见第 1 节）
├── utils/                 # 基础设施：web_api / dio_manager / app_init / utils
│   ├── printer/           # TSC 指令、蓝牙与 USB 通道、PDF/A4、在线打印
│   └── mqtt/              # MQTT 客户端（分平台实现）
└── widget/                # 通用组件：页面骨架、弹窗、Loading、扫码、选择器、下载、预览
```

---

## 5. 架构约定

### 5.1 页面三段式（必须遵守）

每个业务模块拆成 `*_view.dart` / `*_logic.dart` / `*_state.dart`，另外常用 `*_dialog.dart` 放页面内的弹窗：

| 文件 | 职责 | 约定 |
| --- | --- | --- |
| `xxx_state.dart` | 纯 Dart 类（**不继承 Controller**） | 持有全部 `Rx*` 状态，并封装该页所有接口调用（`httpGet/httpPost` + `resultCode` 判断 + `error` 回调） |
| `xxx_logic.dart` | `extends GetxController` | 持有 `final XxxState state = XxxState();` 与选择器控制器，只做流程编排，不写 UI、不写 http 细节 |
| `xxx_view.dart` | `StatefulWidget` | `final logic = Get.put(XxxLogic()); final state = Get.find<XxxLogic>().state;`，UI 用 `Obx` 绑定，骨架用 `pageBody` / `pageBodyWithDrawer` |

```dart
// logic
class DailyReportLogic extends GetxController {
  final DailyReportState state = DailyReportState();

  void query() => state.getDayOutput(
        departmentID: pickerControllerDepartment.selectedId.value,
        error: (msg) => errorDialog(content: msg),
      );
}

// view
class _DailyReportPageState extends State<DailyReportPage> {
  final logic = Get.put(DailyReportLogic());
  final state = Get.find<DailyReportLogic>().state;

  @override
  Widget build(BuildContext context) => pageBodyWithDrawer(
        queryWidgets: [OptionsPicker(pickerController: logic.pickerControllerDepartment)],
        query: () => logic.query(),
        body: Obx(() => ...),
      );
}
```

### 5.2 路由

所有页面在 `lib/route.dart` 的 `RouteConfig` 里登记，条目由 `Routes(name, version, page)` 三元组构成，`version` 即该功能在 MES 服务端的 **FunctionID 版本号**，随接口请求头一起发送：

```dart
static Routes dailyReport = Routes('/daily_report', 201, const DailyReportPage());
```

- 登录后由菜单下发功能列表（`home_*`），跳转统一 `Get.toNamed(RouteConfig.xxx.name)`，返回用 `Get.back(result: ...)`
- 新增页面：**登记路由 → 后端配置菜单功能号 → 页面里 `Get.put(Logic())`**

### 5.3 网络层（`lib/utils/web_api.dart`）

统一入口只有四个，返回 `BaseData`：

```dart
httpPost(method: 'api/xxx', loading: 'xxx_loading'.tr, body: {...}).then((res) {
  if (res.resultCode == resultSuccess) { ... } else { errorDialog(content: res.message); }
});
```

| 约定 | 说明 |
| --- | --- |
| `httpPost` / `httpGet` | MES 服务 |
| `sapPost` / `sapGet` | SAP 服务 |
| `springBootPost` / `springBootGet` | Spring Boot 服务 |
| `resultCode` | `0` 失败、`1` 成功、`2` 重新登录、`3` 版本升级（后两者由 Dio 拦截器统一处理） |
| `loading` | 传了文案就自动 `loadingShow()` / `loadingDismiss()` |
| 请求头 | `Token`、`FunctionID`/`Version`（按当前路由反查）、`Language`、`GUID`、`Authorization` |
| 环境 | `enum BaseUrl` 内置 MES/SAP/Spring Boot 正式库及 ECC/S4 测试库，选择结果存 SharedPreferences，登录页与设置页可切换 |

注意：`BaseData.data` 必须保留原始 JSON 类型，不要转成 String（否则各 bean 的 `fromJson` 会报 `type 'String' is not a subtype of type 'int' of 'index'`）。

### 5.4 国际化（强制）

- 文案表在 `lib/translation.dart`，四段：`localeChinese` / `localeEnglish` / `localeIndonesian` / `localeBurmese`
- **所有面向用户的文案必须写 `.tr`，禁止硬编码中文**（含弹窗、SnackBar、Loading、表头、Hint）
- key 命名：`<模块前缀>_<语义>`，如 `part_process_scan_report_submit`、`suppliers_scan_submitting`
- 新增文案要**一次性补齐四种语言**，位置放在同前缀的相邻行，便于比对

```dart
Text('part_process_scan_report_tab_process'.tr)
```

### 5.5 数据模型

`lib/bean/http/response/*.dart`，手写 `fromJson(dynamic json)` 与 `toJson()`，统一用 `JsonParse.str/toInt/toDouble/toBool/list` 做空安全转换；命名与后端字段保持 `PascalCase` 映射。

---

## 6. 原生能力（MethodChannel）

通道名集中定义在 `lib/constant.dart`：

| 常量 | 通道 | 用途 |
| --- | --- | --- |
| `channelScan` | `channel_scan` | PDA 硬扫广播（`nlscan.action.SCANNER_RESULT`）转 Flutter 回调 |
| `channelBluetooth` | `channel_bluetooth` | 蓝牙标签打印机（TSC） |
| `channelUsbTsc` | `channel_usb_tsc` | USB 标签打印机（优先于蓝牙） |
| `channelUsb` | `channel_usb` | USB 插拔监听 |
| `channelPrinter` | `channel_printer` | A4 报表预览/打印 |
| `channelWeighbridge` | `channel_weighbridge` | 电子地磅读数 |
| `channelFaceVerification` | `channel_face_verification` | 人脸识别 |
| `channelOther` | `channel_other` | 设备信息、DPI、关闭硬件加速等 |

打印返回码约定：`1000` 成功、`1003` 失败、`1006` 无设备、`1007` 蓝牙断开、`1008` USB 断开（自动等待重连）、`-1` 用户中止。

---

## 7. 扫码

`lib/widget/scanner.dart` 提供两种入口，内部共用**全局唯一** `MobileScannerController`（引用计数 + 串行启停 + 栈顶消费），避免多个扫描界面同时开启相机导致原生报
`The MobileScannerController is already running`：

```dart
// 整页扫描，返回结果
final code = await Get.to(() => const Scanner());

// 弹窗扫描，一次性回调
scannerDialog(detect: (code) { ... });

// PDA 硬扫（需在页面 initState 注册、dispose 注销）
pdaScanner(scan: (code) { ... });
closePdaScanner();
```

---

## 8. 打印

- `utils/printer/tsc_util.dart`：TSC 指令原语（`SIZE/SPEED/DENSITY/GAP`、`BOX/LINE/QRCODE/BITMAP`、切刀/撕裂模式），标签模板函数（如 `labelMultipurposeFixed`）按票据拼装 `List<Uint8List>`
- `utils/printer/print_util.dart`：单例，USB 优先、否则蓝牙；支持批量打印进度、断线重连续打
- `utils/printer/pdf_paper_template.dart`：A4 报表 PDF（内嵌思源黑体）
- `utils/printer/online_print_util.dart`：走服务端在线打印机（label / jpg / pdf）

---

## 9. 启动流程与离线能力

`lib/utils/app_init.dart`（`GetxService`）依次完成：极光推送初始化 → SharedPreferences → 语言 → 安装包/设备信息（含鸿蒙识别）→ 屏幕 DPI → 相机可用性 → 登录态与服务器地址恢复 → sqflite 建表，最后跳转登录页或首页。

本地库 `jd_app.db`（version 5）表：`SaveDispatch`、`SaveWorkProcedure`、`BarCodeInfo`、`SurplusMaterialLabelInfo`、`WorkshopPlanningWorkersCache`、`MessageInfo`，用于断网/弱网下的扫码与派工缓存。

---

## 10. 开发规范

1. 文案一律 `.tr`，新增 key 必须补全 4 种语言
2. 能加 `const` 就加（`prefer_const_constructors` 等 4 条已开启，见 `analysis_options.yaml`）
3. 页面按 View / Logic / State 拆分，不把请求写在 View 里
4. 目录按业务域分层，新增功能放对应 `lib/fun/<域>/<模块>/`
5. `packages/**` 是本地 fork 的第三方插件，已从分析器排除，不做风格要求
6. 提交前执行 `flutter analyze`，保持零警告

---

## 11. 常见问题

**`adb: more than one device/emulator`**
连了真机又开了模拟器，用 `flutter run -d <deviceId>` 或 `adb -s <serial> ...` 指定；也可 `export ANDROID_SERIAL=<serial>` 设为默认。

**App 连不上服务器 / 提示重新登录**
检查登录页 / 设置页里的环境选择（`lib/login/login_dialog.dart`，MES/SAP/Spring Boot 正式库或测试库），以及账号 Token 是否失效（`resultCode=2` 会自动踢回登录页）。

**打印空白、标签内容缺失**
标签中空文本不会生成位图指令；若某字段业务上不允许为空，应在提交前校验，而不是依赖打印端兜底。

**`webcontent_converter` 为什么放在 `packages/`**
原插件 0.0.14 已停止维护，其 `android/build.gradle` 使用 Gradle 9 已移除的 `jcenter()` 且锁死 AGP 8.7.0，无法适配本项目的 AGP 9；因此 fork 到本地仅修改 Android 构建配置，Dart 代码未改动。
