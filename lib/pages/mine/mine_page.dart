import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
import 'package:flutter_coinid/models/wallet/user.dart';
import 'package:flutter_coinid/pages/shared/shared_sheet_page.dart';
import '../../public.dart';

class MinePage extends StatefulWidget {
  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  String walletName = "";

  static String _kImageName = "kImageName";
  static String _kContent = "kContent";

  bool isShow = false; //app钱包已删除

  List<Map> _datas = [
    {_kImageName: "menu_wallet.png", _kContent: "wallet_management".local()},
    {_kImageName: "menu_wallet.png", _kContent: "wallet_management".local()},
    {_kImageName: "menu_message.png", _kContent: "my_message".local()},
    {_kImageName: "menu_set.png", _kContent: "system_settings".local()},
    {_kImageName: "menu_back.png", _kContent: "backup_identity".local()},
    {
      _kImageName: "menu_recommended.png",
      _kContent: "recommend_friends".local()
    },
    {_kImageName: "menu_about.png", _kContent: "about_us".local()},
    {_kImageName: "menu_about.png", _kContent: "about_us".local()},
  ];

  Future<void> _getWalletName() async {
    List<MHWallet> wallets =
        await MHWallet.findWalletsByType(MOriginType.MOriginType_Create.index);
    if (wallets == null || wallets.length == 0) {
      wallets = await MHWallet.findWalletsByType(
          MOriginType.MOriginType_Restore.index);
    }

    if (wallets != null && wallets.length > 0) {
      UserModel userModel =
          await UserModel.findUsersByMasterPubKey(wallets.first.masterPubKey);
      if (userModel != null) {
        walletName = userModel.walletName;
        isShow = true;
        setState(() {});
      }
    }
  }

  Future<void> _shared() async {
    _sharedImage(Constant.ASSETS_IMG.replaceAll("./", "") +
        "wallet/share_coinid_app.png");
  }

  _sharedImage(String image) {
    showDialog(
        context: context,
        builder: (context) {
          return SharedSheetPage(
            imageByte: image,
            isPath: true,
          );
        });
  }

  Future<void> _deleteWallet(BuildContext mContext) async {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text("exit_status".local()),
            content: Column(
              children: [
                OffsetWidget.vGap(5),
                Text("exit_status_tips1".local()),
              ],
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("dialog_cancel".local()),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                  child: Text("dialog_confirm".local()),
                  onPressed: () async {
                    Navigator.pop(context);
                    List<MHWallet> wallets = await MHWallet.findWalletsByType(
                        MOriginType.MOriginType_Create.index);
                    if (wallets == null || wallets.length == 0) {
                      wallets = await MHWallet.findWalletsByType(
                          MOriginType.MOriginType_Restore.index);
                    }
                    if (wallets != null && wallets.length > 0) {
                      MHWallet mhWallet = wallets.first;
                      UserModel user = await UserModel.findUsersByMasterPubKey(
                          mhWallet.masterPubKey);
                      if (user == null) return;
                      mhWallet?.showLockPinDialog(
                          context: mContext,
                          tips: "exit_status_tips2".local(),
                          ok: (value) async {
                            List<MHWallet> allWallets = [];

                            List<MHWallet> createWallets =
                                await MHWallet.findWalletsByType(
                                    MOriginType.MOriginType_Create.index);
                            List<MHWallet> restoreWallets =
                                await MHWallet.findWalletsByType(
                                    MOriginType.MOriginType_Restore.index);

                            if (createWallets != null &&
                                createWallets.length > 0) {
                              allWallets.addAll(createWallets);
                            }

                            if (restoreWallets != null &&
                                restoreWallets.length > 0) {
                              allWallets.addAll(restoreWallets);
                            }

                            await UserModel.deleteWallet(user);

                            if (allWallets != null && allWallets.length > 0) {
                              bool flag =
                                  await MHWallet.deleteWallets(allWallets);
                              if (flag) {
                                List<MHWallet> wallets =
                                    await MHWallet.findAllWallets();
                                if (wallets != null && wallets.length > 0) {
                                  MHWallet wallet = wallets[0];
                                  wallet.isChoose = true;
                                  flag = await MHWallet.updateWallet(wallet);
                                  if (flag) {
                                    //跳回首页
                                    Routers.push(mContext, Routers.tabbarPage,
                                        clearStack: true);
                                  }
                                } else {
                                  Routers.push(mContext, Routers.chooseTypePage,
                                      clearStack: true);
                                }
                              }
                            }
                          },
                          cancle: null,
                          wrong: null);
                    }
                  }),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _getWalletName();
  }

  Widget _getCellWidget(int index, BuildContext context) {
    Map map = _datas[index];
    if (index == 0) {
      return Container(
        height: OffsetWidget.setSc(160),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            LoadAssetsImage(Constant.ASSETS_IMG + "icon/icon_app.png",
                width: OffsetWidget.setSc(73), height: OffsetWidget.setSc(73)),
            OffsetWidget.vGap(6),
            Text(walletName,
                style: TextStyle(
                    color: Color(0xFF000000),
                    fontSize: OffsetWidget.setSp(12))),
          ],
        ),
      );
    } else if (index == _datas.length - 1) {
      return Visibility(
          visible: isShow,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => {
              _cellTap(index, context),
            },
            child: Container(
              height: OffsetWidget.setSc(48),
              alignment: Alignment.center,
              margin: EdgeInsets.only(
                  left: OffsetWidget.setSc(29),
                  right: OffsetWidget.setSc(29),
                  top: OffsetWidget.setSc(15)),
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage(
                    Constant.ASSETS_IMG + "background/bg_delet_wallet.png",
                  ),
                  fit: BoxFit.fill,
                ),
              ),
              child: Text("delete_wallet".local(),
                  style: TextStyle(
                      color: Color(0xFF4A4A4A),
                      fontSize: OffsetWidget.setSp(13))),
            ),
          ));
    } else {
      if (index == 4 && !isShow) {
        //app钱包已删除
        return Container(
            child: OffsetWidget.vLineWhitColor(1, Color(0xFFD7DDE1)));
      }
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => {
          _cellTap(index, context),
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(
                  left: OffsetWidget.setSc(27),
                  right: OffsetWidget.setSc(24),
                  top: OffsetWidget.setSc(10),
                  bottom: OffsetWidget.setSc(10)),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Image.asset(
                          Constant.ASSETS_IMG + "icon/" + map[_kImageName],
                          fit: BoxFit.cover,
                          scale: 2,
                        ),
                        OffsetWidget.hGap(9),
                        Text(
                          map[_kContent],
                          style: TextStyle(
                            color: Color(0xFF444444),
                            fontSize: OffsetWidget.setSp(12),
                          ),
                        ),
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
            Visibility(
                visible: (index == 2 || index == 4) ? true : false,
                child: OffsetWidget.vLineWhitColor(1, Color(0xFFD7DDE1))),
          ],
        ),
      );
    }
  }

  void _cellTap(int index, BuildContext context) async {
    if (index == 1) {
      Routers.push(context, Routers.walletManagerPage);
    } else if (index == 2) {
      Routers.push(context, Routers.systemPage);
    } else if (index == 3) {
      Routers.push(context, Routers.systemSetPage);
    } else if (index == 4) {
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
            wrong: null);
      }
    } else if (index == 5) {
      _shared();
    } else if (index == 6) {
      Routers.push(context, Routers.aboutUsPage);
    } else if (index == _datas.length - 1) {
      _deleteWallet(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    OffsetWidget.screenInit(context, 360);
    return CustomPageView(
      hiddenScrollView: true,
      hiddenAppBar: true,
      hiddenResizeToAvoidBottomInset: false,
      child: ListView.builder(
        itemCount: _datas.length,
        itemBuilder: (BuildContext context, int index) {
          return _getCellWidget(index, context);
        },
      ),
    );
  }
}
