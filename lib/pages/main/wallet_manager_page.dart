import 'package:flutter/rendering.dart';
import 'package:flutter_coinid/channel/channel_dapp.dart';
import 'package:flutter_coinid/models/assets/currency_asset.dart';
import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
import 'package:flutter_coinid/public.dart';
import 'package:flutter_coinid/utils/screenutil.dart';
import 'package:flutter_coinid/utils/sharedPrefer.dart';

class WalletManager extends StatefulWidget {
  WalletManager({Key key}) : super(key: key);

  @override
  _WalletManagerState createState() => _WalletManagerState();
}

class _WalletManagerState extends State<WalletManager> {
  final List<MCoinType> coinDatas = [
    MCoinType.MCoinType_All,
    MCoinType.MCoinType_BTC,
    MCoinType.MCoinType_ETH,
    MCoinType.MCoinType_DOT,
    MCoinType.MCoinType_BSC,
    MCoinType.MCoinType_KSM,
  ];
  List<MHWallet> datas = [];
  MCoinType currentType = MCoinType.MCoinType_All;
  TextEditingController _tokenEC = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initData();
    _findWalletsWithDB(MCoinType.MCoinType_All);
  }

  initData() async {}

  void _findWalletsWithDB(MCoinType _cointType) async {
    List currents = [];
    if (_cointType == MCoinType.MCoinType_All) {
      currents = await MHWallet.findAllWallets();
    } else {
      currents = await MHWallet.findWalletsByChainType(_cointType.index);
    }
    setState(() {
      datas = currents;
      currentType = _cointType;
    });
  }

  void _cellContentSelectRowAt(MHWallet wallet) async {
    LogUtil.v("点击钱包整体");
    Provider.of<CurrentChooseWalletState>(context, listen: false)
        .updateChoose(wallet);
    Routers.goBackWithParams(context, {"walletID": wallet.walletID});
  }

  void _cellDetailDidSelect(int index) {
    MHWallet wallet = datas[index];
    MHWallet.updateChoose(wallet);
    // Routers.push(context, Routers.walletInfoPagePage,
    //         params: {"walletID": wallet.walletID})
    //     .then((value) => {_findWalletsWithDB(currentPage)});
  }

  Widget _itemBuilder(int index) {
    final MCoinType mCoinType = coinDatas[index];
    String typeStr = Constant.getChainSymbol(mCoinType.index);
    if (mCoinType == MCoinType.MCoinType_All) {
      typeStr = "wallets_all".local();
    }
    if (mCoinType == MCoinType.MCoinType_BSC) {
      typeStr = "BSC";
    }
    Color bgColor = Color(0xFFF6F9FC);
    Color textColor = Color(0xFF586883);
    if (mCoinType == currentType) {
      bgColor = Color(0xFF586883);
      textColor = Color(0xFFFFFFFF);
    }
    return Container(
      alignment: Alignment.center,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _findWalletsWithDB(mCoinType),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
          ),
          height: OffsetWidget.setSc(25),
          width: OffsetWidget.setSc(45),
          child: Text(
            typeStr,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWightHelper.medium,
              fontSize: OffsetWidget.setSp(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cellBuilder(MHWallet wallet) {
    String logoPath = Constant.getChainLogo(wallet.chainType);
    String name = Constant.getChainSymbol(wallet.chainType);
    String address = wallet?.walletAaddress;
    String bgPath = Constant.ASSETS_IMG +
        "wallet/wallet_" +
        wallet.symbol.toLowerCase() +
        "_card.png";

    return Container(
      key: Key(wallet.walletID),
      alignment: Alignment.center,
      padding: EdgeInsets.only(bottom: OffsetWidget.setSc(12)),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _cellContentSelectRowAt(wallet),
            child: Container(
              height: OffsetWidget.setSc(60),
              alignment: Alignment.center,
              // color: Colors.amber,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    bgPath,
                  ),
                  fit: BoxFit.contain,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: OffsetWidget.setSc(23)),
                    child: LoadAssetsImage(
                      logoPath,
                      width: OffsetWidget.setSc(36),
                      height: OffsetWidget.setSc(36),
                      fit: BoxFit.contain,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: OffsetWidget.setSc(9)),
                    width: OffsetWidget.setSc(116),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                              fontSize: OffsetWidget.setSp(16),
                              fontWeight: FontWightHelper.medium,
                              color: Colors.white),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                        OffsetWidget.vGap(3),
                        Text(
                          address,
                          style: TextStyle(
                              fontSize: OffsetWidget.setSp(10),
                              fontWeight: FontWightHelper.regular,
                              color: Colors.white),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getRightBarAction() {
    return <Widget>[
      GestureDetector(
        onTap: () => {
          Routers.push(context, Routers.chooseTypePage).then((value) => {
                LogUtil.v("收到返回的数据 " + value.toString()),
              }),
        },
        child: LoadAssetsImage(
          Constant.ASSETS_IMG + "icon/wallet_insert.png",
          width: OffsetWidget.setSc(45),
          height: OffsetWidget.setSc(45),
          fit: null,
          scale: 2,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
      hiddenScrollView: true,
      actions: _getRightBarAction(),
      title: CustomPageView.getDefaultTitle(
        titleStr: "wallet_management".local(),
      ),
      child: Container(
        padding: EdgeInsets.only(
          left: OffsetWidget.setSc(20),
          right: OffsetWidget.setSc(20),
          top: OffsetWidget.setSc(20),
        ),
        child: Column(
          children: [
            Container(
              height: OffsetWidget.setSc(36),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFFEAEFF2),
                ),
                borderRadius: BorderRadius.circular(
                  OffsetWidget.setSc(18),
                ),
              ),
              child: Row(
                children: [
                  OffsetWidget.hGap(10),
                  Icon(
                    Icons.search,
                    color: Color(0xFFC5C7D8),
                  ),
                  Expanded(
                    child: CustomTextField(
                      controller: _tokenEC,
                      maxLines: 1,
                      onSubmitted: (value) {},
                      onChange: (value) async {
                        print("onChange" + value);
                        List<MHWallet> wallets =
                            await MHWallet.findWalletsBySymbol(
                                value.toUpperCase());
                        setState(() {
                          datas = wallets;
                        });
                      },
                      decoration: CustomTextField.getBorderLineDecoration(
                        hintText: "wallets_inputName".local(),
                        borderColor: Colors.transparent,
                        hintStyle: TextStyle(
                            fontSize: OffsetWidget.setSp(12),
                            fontWeight: FontWightHelper.medium,
                            color: Color(0xFF929695)),
                      ),

                      // hintText: "wallets_inputName".local(),
                      // hintStyle: TextStyle(
                      //     fontSize: OffsetWidget.setSp(12),
                      //     fontWeight: FontWightHelper.medium,
                      //     color: Color(0xFF929695)),
                      // contentPadding: EdgeInsets.all(OffsetWidget.setSp(4)),
                    ),
                  ),
                  GestureDetector(
                    child: Icon(
                      Icons.cancel,
                      color: Color(0xFFC5C7D8),
                    ),
                    onTap: () {
                      _tokenEC.clear();
                    },
                  ),
                  OffsetWidget.hGap(10),
                ],
              ),
            ),
            Container(
              height: OffsetWidget.setSc(52),
              alignment: Alignment.center,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: coinDatas.length,
                separatorBuilder: (BuildContext context, int index) {
                  return OffsetWidget.hGap(7);
                },
                itemBuilder: (BuildContext context, int index) {
                  return _itemBuilder(index);
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: datas.length,
                itemBuilder: (BuildContext context, int index) {
                  var temp = datas[index];
                  return _cellBuilder(temp);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
