import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_coinid/channel/channel_wallet.dart';
import 'package:flutter_coinid/net/chain_services.dart';
import 'package:flutter_coinid/upgrade/flutter_upgrade.dart';
import 'package:flutter_coinid/utils/sharedPrefer.dart';
import '../public.dart';


class LogsInterceptors extends InterceptorsWrapper {
  @override
  Future onRequest(RequestOptions options) {
    String url = options.path;
    addHeadersParams(url, options);
    LogUtil.v('request url: ${options.path}');
    LogUtil.v('request header: ${options.headers.toString()} \n');
    if (options.data != null) {
      LogUtil.v('request params: ${options.data.toString()} \n');
    }
    return super.onRequest(options);
  }

  @override
  Future onResponse(Response response) {
    // TODO: implement onResponse
    if (response != null) {
      LogUtil.v('response: ${response.toString()} \n');
    }
    return super.onResponse(response);
  }

  @override
  Future onError(DioError err) {
    // TODO: implement onError
    LogUtil.v('request error: ${err.toString()} \n');
    LogUtil.v('request error info: ${err.response?.toString() ?? ""} \n');
    return super.onError(err);
  }

  addHeadersParams(String url, RequestOptions options) async {
    if (url.contains(ChainServices.host)) {
      List<int> datas = List.filled(104, 0, growable: true);
      var appInfo = await FlutterUpgrade.appInfo;
      String uuid = await ChannelWallet.deviceImei();
      String version = appInfo.versionName;
      List<int> listu = utf8.encode(version);
      // String uuid = "ee62fb0d4cb3496881a02bb4862eae1c";
      List<int> listuuid = utf8.encode(uuid);
      // String bundleid = "com.newmingwahhk.coinidplus";
      String bundleid = appInfo.packageName;
      List<int> listid = utf8.encode(bundleid);
      String fileM =
          md5.convert(listuuid).toString(); //934a8959aebe4de881c7fa71361bba9c
      List<int> listflie = utf8.encode(fileM);
      datas.replaceRange(0, listu.length, listu);
      datas.replaceRange(8, 8 + listuuid.length, listuuid);
      datas.replaceRange(40, 40 + listid.length, listid);
      datas.replaceRange(72, 72 + listflie.length, listflie);
      String info = base64Encode(datas);
      int lan = await getLanguageValue();
      String language = lan == 0 ? "zh" : "en";
      Map<String, dynamic> headers = options.headers;
      headers["info"] = info;
      headers["language"] = language;
      options.headers = headers;
    }
  }
}
