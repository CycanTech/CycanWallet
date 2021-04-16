import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
import 'package:flutter_coinid/models/wallet/user.dart';
import 'package:flutter_coinid/pages/shared/shared_sheet_page.dart';
import '../../public.dart';

class MinePage extends StatefulWidget {
  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  static String _kImageName = "kImageName";
  static String _kContent = "kContent";

  List<Map> get _datas => [
        {
          _kImageName: "menu_wallet.png",
          _kContent: "wallet_management".local(context: context)
        },
        {
          _kImageName: "menu_message.png",
          _kContent: "my_message".local(context: context)
        },
        {
          _kImageName: "menu_set.png",
          _kContent: "system_settings".local(context: context)
        },
        {
          _kImageName: "menu_back.png",
          _kContent: "backup_identity".local(context: context)
        },
        {
          _kImageName: "menu_recommended.png",
          _kContent: "recommend_friends".local(context: context)
        },
        {
          _kImageName: "menu_about.png",
          _kContent: "about_us".local(context: context)
        },
      ];

  Future<void> _shared() async {
    _sharedImage(Constant.ASSETS_IMG.replaceAll("./", "") +
        "wallet/share_coinid_app.png");
  }

  _sharedImage(String image) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        elevation: 0,
        isDismissible: true,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        builder: (context) {
          return SafeArea(
              child: SharedSheetPage(
            imageByte: image,
            isPath: true,
          ));
        });
  }

  @override
  void initState() {
    super.initState();
  }

  Widget _getCellWidget(int index) {
    Map map = _datas[index];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => {
        _cellTap(index),
      },
      child: Container(
        // color: Colors.blue,
        padding: EdgeInsets.only(
          left: OffsetWidget.setSc(20),
          right: OffsetWidget.setSc(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                LoadAssetsImage(
                  Constant.ASSETS_IMG + "icon/" + map[_kImageName],
                  // scale: 1,
                  width: OffsetWidget.setSc(22),
                  height: OffsetWidget.setSc(20),
                ),
                OffsetWidget.hGap(11),
                Text(
                  map[_kContent],
                  style: TextStyle(
                    color: Color(0xFF161D2D),
                    fontWeight: FontWightHelper.semiBold,
                    fontSize: OffsetWidget.setSp(15),
                  ),
                ),
              ],
            ),
            LoadAssetsImage(
              Constant.ASSETS_IMG + "icon/arrow_black_right.png",
              width: OffsetWidget.setSc(8),
              height: OffsetWidget.setSc(15),
              // scale: 3,
            ),
          ],
        ),
      ),
    );
  }

  void _cellTap(int index) async {
    if (index == 0) {
      Routers.push(context, Routers.walletManagerPage);
    } else if (index == 1) {
      Routers.push(context, Routers.systemPage);
    } else if (index == 2) {
      Routers.push(context, Routers.systemSetPage);
    } else if (index == 3) {
      List<MHWallet> wallets = await MHWallet.findWalletsByType(
          MOriginType.MOriginType_Create.index);
      if (wallets == null || wallets.length == 0) {
        wallets = await MHWallet.findWalletsByType(
            MOriginType.MOriginType_Restore.index);
      }
      if (wallets != null && wallets.length > 0) {
        MHWallet mhWallet = wallets.first;
        UserModel user =
            await UserModel.findUsersByMasterPubKey(mhWallet.masterPubKey);
        if (user == null) return;
        mhWallet?.showLockPinDialog(
            context: context,
            ok: (value) async {
              String memo = await user?.exportMemo(pin: value);
              if (memo.isValid() == true) {
                Map<String, dynamic> params = Map();
                params["memo"] = memo;
                params["leadType"] = user.leadType;
                Routers.push(context, Routers.backupMemosPage, params: params);
              }
            },
            cancle: null,
            wrong: () => {HWToast.showText(text: "payment_pwdwrong".local())});
      }
    } else if (index == 4) {
      _shared();
    } else if (index == 5) {
      Routers.push(context, Routers.aboutUsPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
      hiddenAppBar: true,
      hiddenLeading: true,
      hiddenResizeToAvoidBottomInset: false,
      safeAreaTop: false,
      child: Column(
        children: [
          Container(
            height: OffsetWidget.setSc(207),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  Constant.ASSETS_IMG + "background/bg_mine.png",
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
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
                        color: Color(0xFF171F24),
                        fontWeight: FontWightHelper.regular,
                        fontSize: OffsetWidget.setSp(16))),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: OffsetWidget.setSc(32)),
            child: _getCellWidget(0),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: OffsetWidget.setSc(36),
              bottom: OffsetWidget.setSc(33),
            ),
            child: _getCellWidget(1),
          ),
          Container(
            height: 5,
            color: Color(0xFFFAFCFC),
          ),
          Padding(
            padding: EdgeInsets.only(top: OffsetWidget.setSc(30)),
            child: _getCellWidget(2),
          ),
          Padding(
            padding: EdgeInsets.only(top: OffsetWidget.setSc(32)),
            child: _getCellWidget(3),
          ),
          Padding(
            padding: EdgeInsets.only(top: OffsetWidget.setSc(36)),
            child: _getCellWidget(4),
          ),
          Padding(
            padding: EdgeInsets.only(top: OffsetWidget.setSc(32)),
            child: _getCellWidget(5),
          ),
        ],
      ),
    );
  }
}
