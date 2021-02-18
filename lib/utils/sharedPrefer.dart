import 'package:flutter_coinid/utils/date_util.dart';
import 'package:flutter_coinid/utils/json_util.dart';
import 'package:flutter_coinid/utils/log_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String LANGUAGE_SET = "LANGUAGE_SET";
const String AMOUNT_SET = "AMOUNT_SET";
const String Assets_updateTime = "Assets_updateTime";
const String Assets_OriginAssets = "Assets_OriginAssets";


void updateLanguageValue(int value) async {
  final fres = await SharedPreferences.getInstance();
  fres.setInt(LANGUAGE_SET, value);
}

Future<int> getLanguageValue() async {
  final prefs = await SharedPreferences.getInstance();
  int object = prefs.getInt(LANGUAGE_SET);
  object ??= 0;
  return Future.value(object);
}

///默认cny
void updateAmountValue(bool isCNY) async {
  final fres = await SharedPreferences.getInstance();
  fres.setInt(AMOUNT_SET, isCNY == true ? 0 : 1);
}

///0 cny 1 en
Future<int> getAmountValue() async {
  final prefs = await SharedPreferences.getInstance();
  int object = prefs.getInt(AMOUNT_SET);
  object ??= 0;
  if (object == 0) {
    return 0;
  }
  return 1;
}

void saveOriginMoney(String cnyAssets, String usdAssets) async {
  final prefs = await SharedPreferences.getInstance();
  int oldTime = prefs.getInt(Assets_updateTime);
  oldTime ??= 0;
  int nowTime = DateUtil.getNowDateMs();
  LogUtil.v(
      "oldTime $oldTime nowTime $nowTime offset ${(nowTime - oldTime) / (1000 * 24 * 3600)} day");
  if (nowTime - oldTime >= 3600 * 24 * 1000) {
    LogUtil.v("saveOriginMoney 更新成功");
    prefs.setInt(Assets_updateTime, nowTime);
    prefs.setString(Assets_OriginAssets,
        JsonUtil.encodeObj({"cnyAssets": cnyAssets, "usdAssets": usdAssets}));
  }
}

Future<String> getOriginMoney(bool isCny) async {
  final prefs = await SharedPreferences.getInstance();
  String origin = prefs.getString(Assets_OriginAssets);
  Map params = JsonUtil.getObj(origin);
  params ??= {"cnyAssets": "0", "usdAssets": "0"};
  return isCny == true ? params["cnyAssets"] : params["usdAssets"];
}
