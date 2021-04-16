import 'package:flutter_coinid/channel/channel_wallet.dart';
import 'package:flutter_coinid/net/chain_services.dart';
import 'package:flutter_coinid/net/wallet_services.dart';
import 'package:flutter_coinid/upgrade/app_upgrade.dart';
import 'package:flutter_coinid/upgrade/download_status.dart';
import 'package:flutter_coinid/upgrade/flutter_upgrade.dart';
import 'package:flutter_coinid/widgets/toast/src/toast_widget/toast_widget.dart';

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
      _kImageName: "about_wechat.png",
      _kContent: "Wechat",
      _kValue: "CoinID",
    },
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
      onCancel: () {},
      onOk: () {},
      downloadProgress: (count, total) {},
      downloadStatusChange: (DownloadStatus status, {dynamic error}) {},
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
      child: Column(
        children: [
          Row(
            children: [
              LoadAssetsImage(
                Constant.ASSETS_IMG + "icon/" + map[_kImageName],
                width: OffsetWidget.setSc(25),
                height: OffsetWidget.setSc(25),
                fit: BoxFit.contain,
              ),
              OffsetWidget.hGap(10),
              Text(map[_kContent],
                  style: TextStyle(
                      fontSize: OffsetWidget.setSp(15),
                      fontWeight: FontWightHelper.semiBold,
                      color: Color(0xFF161D2D)))
            ],
          ),
          Row(
            children: [
              OffsetWidget.hGap(35),
              Text(map[_kValue],
                  style: TextStyle(
                      fontSize: OffsetWidget.setSp(12),
                      fontWeight: FontWightHelper.regular,
                      color: Color(0xFFACBBCF)))
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
      title: CustomPageView.getDefaultTitle(titleStr: "about_title".local()),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          OffsetWidget.vGap(48),
          ClipRRect(
            borderRadius: BorderRadius.circular(OffsetWidget.setSc(35)),
            child: LoadAssetsImage(
              Constant.ASSETS_IMG + "icon/icon_app.png",
              width: OffsetWidget.setSc(70),
              height: OffsetWidget.setSc(70),
              fit: BoxFit.contain,
            ),
          ),
          OffsetWidget.vGap(8),
          Text("AllToken",
              style: TextStyle(
                  fontSize: OffsetWidget.setSp(15),
                  fontWeight: FontWightHelper.regular,
                  color: Color(0xFF161D2D))),
          Text("版本：V" + _appInfo.versionName,
              style: TextStyle(
                  fontSize: OffsetWidget.setSp(14),
                  fontWeight: FontWightHelper.regular,
                  color: Color(0xFFACBBCF))),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (isLastVersion) {
                _showUpdateDialog();
              }
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  OffsetWidget.setSc(20),
                  OffsetWidget.setSc(28),
                  OffsetWidget.setSc(20),
                  OffsetWidget.setSc(0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      LoadAssetsImage(
                        Constant.ASSETS_IMG + "icon/about_version.png",
                        width: OffsetWidget.setSc(22),
                        height: OffsetWidget.setSc(27),
                        fit: BoxFit.contain,
                      ),
                      OffsetWidget.hGap(12),
                      Text("about_upgrade".local(),
                          style: TextStyle(
                              fontSize: OffsetWidget.setSp(15),
                              fontWeight: FontWightHelper.semiBold,
                              color: Color(0xFF161D2D)))
                    ],
                  ),
                  LoadAssetsImage(
                    Constant.ASSETS_IMG + "icon/arrow_black_right.png",
                    width: OffsetWidget.setSc(8),
                    height: OffsetWidget.setSc(15),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Routers.push(context, Routers.versionLogPage);
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  OffsetWidget.setSc(20),
                  OffsetWidget.setSc(36),
                  OffsetWidget.setSc(20),
                  OffsetWidget.setSc(33)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      LoadAssetsImage(
                        Constant.ASSETS_IMG + "icon/about_versionlog.png",
                        width: OffsetWidget.setSc(20),
                        height: OffsetWidget.setSc(25),
                        fit: BoxFit.contain,
                      ),
                      OffsetWidget.hGap(14),
                      Text("about_ver_log".local(),
                          style: TextStyle(
                              fontSize: OffsetWidget.setSp(15),
                              fontWeight: FontWightHelper.semiBold,
                              color: Color(0xFF161D2D)))
                    ],
                  ),
                  LoadAssetsImage(
                    Constant.ASSETS_IMG + "icon/arrow_black_right.png",
                    fit: BoxFit.contain,
                    width: OffsetWidget.setSc(8),
                    height: OffsetWidget.setSc(15),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 5,
            color: Color(0xFFFAFCFC),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: OffsetWidget.setSc(30),
                left: OffsetWidget.setSc(20),
                right: OffsetWidget.setSc(20)),
            child: _buildCell(0),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: OffsetWidget.setSc(19),
                left: OffsetWidget.setSc(20),
                right: OffsetWidget.setSc(20)),
            child: _buildCell(1),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: OffsetWidget.setSc(19),
                left: OffsetWidget.setSc(20),
                right: OffsetWidget.setSc(20)),
            child: _buildCell(2),
          )
        ],
      ),
    );
  }
}
