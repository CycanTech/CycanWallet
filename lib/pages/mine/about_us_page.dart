import 'package:flutter_coinid/channel/channel_wallet.dart';
import 'package:flutter_coinid/net/chain_services.dart';
import 'package:flutter_coinid/net/wallet_services.dart';
import 'package:flutter_coinid/upgrade/app_upgrade.dart';
import 'package:flutter_coinid/upgrade/download_status.dart';
import 'package:flutter_coinid/upgrade/flutter_upgrade.dart';

import '../../public.dart';

class AboutUsPage extends StatefulWidget {
  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  static String _kImageName = "kImageName";
  static String _kContent = "kContent";
  static String _kValue = "kValue";
  String _imei = "";
  bool isLastVersion = false;
  AppInfo _appInfo = AppInfo(versionName: "");
  Map<String, dynamic> updateMap = Map();

  List<Map> _datas = [
    {
      _kImageName: "about_WEB.png",
      _kContent: "Website",
      _kValue: "https://www.coinid.pro"
    },
    {
      _kImageName: "about_Email.png",
      _kContent: "Email",
      _kValue: "mwtech@coinid.pro"
    },
    {
      _kImageName: "about_twitter.png",
      _kContent: "Twitter",
      _kValue: "CoinID Official"
    },
    {_kImageName: "about_wechat.png", _kContent: "Wechat", _kValue: "CoinID"},
  ];

  @override
  void initState() {
    super.initState();
    _getAppInfo();
  }

  void _getAppInfo() async {
    var appInfo = await FlutterUpgrade.appInfo;
    _imei = await ChannelWallet.deviceImei();
    setState(() {
      _appInfo = appInfo;
      _getUpdateInfo();
    });
  }

  void _getUpdateInfo() {
    String appType = "android";
    if (Constant.isAndroid) {
      appType = "android";
    } else if (Constant.isIOS) {
      appType = "ios";
    }
    WalletServices.requestUpdateInfo(
        _imei, _appInfo.versionName, _appInfo.packageName, appType, null,
        (result, code) {
      if (code == 200 && mounted) {
        setState(() {
          updateMap = result;
          if (StringUtil.compare(updateMap["version"], _appInfo.versionName) >=
              0) {
            isLastVersion = true;
          } else {
            isLastVersion = false;
          }
        });
      }
    });
  }

  void _showUpdateDialog() {
    AppUpgrade.appUpgrade(
      context,
      _checkAppInfo(),
      iosAppId: '1524891382',
      onCancel: () {
        
      },
      onOk: () {
        
      },
      downloadProgress: (count, total) {
        
      },
      downloadStatusChange: (DownloadStatus status, {dynamic error}) {
        
      },
    );
  }

  Future<AppUpgradeInfo> _checkAppInfo() async {
    return AppUpgradeInfo(
      title: "about_new_version".local() + updateMap["version"],
      contents: [
        updateMap["description"],
      ],
      force: updateMap["alwaysUpdate"],
      gotoWeb: true,
      apkDownloadUrl: updateMap["downloadURl"],
    );
  }

  Widget _buildCell(int index) {
    Map map = _datas[index];
    return Container(
      padding: EdgeInsets.all(OffsetWidget.setSc(19)),
      child: Column(
        children: [
          Row(
            children: [
              LoadAssetsImage(
                Constant.ASSETS_IMG + "icon/" + map[_kImageName],
                width: OffsetWidget.setSc(12),
                height: OffsetWidget.setSc(12),
                fit: BoxFit.contain,
              ),
              OffsetWidget.hGap(7),
              Text(map[_kContent],
                  style: TextStyle(
                      fontSize: OffsetWidget.setSp(12),
                      color: Color(0xFFACBBCF)))
            ],
          ),
          Row(
            children: [
              OffsetWidget.hGap(20),
              Text(map[_kValue],
                  style: TextStyle(
                      fontSize: OffsetWidget.setSp(12),
                      color: Color(0xFF586883)))
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    OffsetWidget.screenInit(context, 360);
    return CustomPageView(
      hiddenScrollView: true,
      title: Text("about_title".local(),
          style: TextStyle(
              fontSize: OffsetWidget.setSp(17), color: Color(0xFF4A4A4A))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          OffsetWidget.vGap(31),
          LoadAssetsImage(
            Constant.ASSETS_IMG + "icon/icon_app.png",
            width: OffsetWidget.setSc(59),
            height: OffsetWidget.setSc(59),
            fit: BoxFit.contain,
          ),
          OffsetWidget.vGap(9),
          Text(_appInfo.versionName,
              style: TextStyle(
                  fontSize: OffsetWidget.setSp(12), color: Color(0xFFACBBCF))),
          OffsetWidget.vGap(30),
          Center(
            child: GestureDetector(
              onTap: () {
                if(isLastVersion){
                  _showUpdateDialog();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xFFF6F9FC),
                ),
                width: OffsetWidget.setSc(322),
                height: OffsetWidget.setSc(48),
                padding: EdgeInsets.fromLTRB(
                    OffsetWidget.setSc(19),
                    OffsetWidget.setSc(15),
                    OffsetWidget.setSc(19),
                    OffsetWidget.setSc(15)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        LoadAssetsImage(
                          Constant.ASSETS_IMG + "icon/about_version.png",
                          width: OffsetWidget.setSc(12),
                          height: OffsetWidget.setSc(12),
                          fit: BoxFit.contain,
                        ),
                        OffsetWidget.hGap(7),
                        Text("about_upgrade".local(),
                            style: TextStyle(
                                fontSize: OffsetWidget.setSp(12),
                                color: Color(0xFF586883)))
                      ],
                    ),
                    Image.asset(
                      Constant.ASSETS_IMG + "icon/arrow_black_right.png",
                      fit: BoxFit.cover,
                      scale: 2.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          OffsetWidget.vGap(10),
          Center(
            child: GestureDetector(
              onTap: () {
                Routers.push(context, Routers.versionLogPage);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xFFF6F9FC),
                ),
                width: OffsetWidget.setSc(322),
                height: OffsetWidget.setSc(48),
                padding: EdgeInsets.fromLTRB(
                    OffsetWidget.setSc(19),
                    OffsetWidget.setSc(15),
                    OffsetWidget.setSc(19),
                    OffsetWidget.setSc(15)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        LoadAssetsImage(
                          Constant.ASSETS_IMG + "icon/about_version.png",
                          width: OffsetWidget.setSc(12),
                          height: OffsetWidget.setSc(12),
                          fit: BoxFit.contain,
                        ),
                        OffsetWidget.hGap(7),
                        Text("about_ver_log".local(),
                            style: TextStyle(
                                fontSize: OffsetWidget.setSp(12),
                                color: Color(0xFF586883)))
                      ],
                    ),
                    Image.asset(
                      Constant.ASSETS_IMG + "icon/arrow_black_right.png",
                      fit: BoxFit.cover,
                      scale: 2.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          OffsetWidget.vGap(10),
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xFFF6F9FC),
              ),
              width: OffsetWidget.setSc(322),
              height: OffsetWidget.setSc(263),
              child: ListView.builder(
                itemCount: _datas.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildCell(index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
