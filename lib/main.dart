
//flutter emulators --launch Pixel XL API 24
//flutter run -d emulator-5554
import 'package:easy_localization/easy_localization.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_coinid/models/assets/currency_asset.dart';
import 'package:flutter_coinid/pages/app.dart';
import 'package:flutter_coinid/routers/app_routers.dart';
import 'package:flutter_coinid/routers/routers.dart';

void main() {
  final router = FluroRouter();
  Routers.configureRoutes(router);
  AppRouters.router = router;
  WidgetsFlutterBinding.ensureInitialized(); //不加这个强制横/竖屏会报错
  SystemChrome.setPreferredOrientations([
    // 强制竖屏
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  CurrencyAssetModel.configCurrencyTokens();
  runApp(EasyLocalization(
    child: MyApp(),
    // 支持的语言
    supportedLocales: [Locale('zh', 'CN'), Locale('en', 'US')],
    // 语言资源包目录
    path: 'resources/langs',
  ));
}
