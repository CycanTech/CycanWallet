import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
import 'package:flutter_coinid/public.dart';

class WalletsSheetPage extends StatefulWidget {
  WalletsSheetPage({Key key}) : super(key: key);

  @override
  _WalletsSheetPageState createState() => _WalletsSheetPageState();
}

class _WalletsSheetPageState extends State<WalletsSheetPage> {
  final List<MCoinType> coinDatas = [
    MCoinType.MCoinType_All,
    MCoinType.MCoinType_BTC,
    MCoinType.MCoinType_ETH,
    MCoinType.MCoinType_DOT
  ];
  List<MHWallet> datas = [];
  MCoinType currentType = MCoinType.MCoinType_All;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _findWalletsWithDB(MCoinType.MCoinType_All);
  }

  void walletsManagetClick() {
    Navigator.pop(context);
    Routers.push(context, Routers.walletManagerPage);
  }

  void sheetClose() {
    Navigator.pop(context);
  }

  void insertWallets() {
    Navigator.pop(context);
    Routers.push(context, Routers.chooseTypePage);
  }

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

  void _cellContentSelectRowAt(int index) async {
    LogUtil.v("点击钱包整体");
    MHWallet wallet = datas[index];
    Provider.of<CurrentChooseWalletState>(context, listen: false)
        .updateChoose(wallet);
    Routers.goBackWithParams(context, {"walletID": wallet.walletID});
  }

  Widget _itemBuilder(int index) {
    final MCoinType mCoinType = coinDatas[index];
    String typeStr = Constant.getChainSymbol(mCoinType.index);
    if (mCoinType == MCoinType.MCoinType_All) {
      typeStr = "wallets_all".local();
    }
    Color bgColor = Color(0XFFF6F9FC);
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

  Widget _cellBuilder(int index) {
    MHWallet wallet = datas[index];
    String logoPath = Constant.getChainLogo(wallet.chainType);
    String name = Constant.getChainSymbol(wallet.chainType);
    String address = wallet?.walletAaddress;
    String bgPath = Constant.ASSETS_IMG +
        "background/bg_" +
        wallet.symbol.toLowerCase() +
        ".png";

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(bottom: OffsetWidget.setSc(12)),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _cellContentSelectRowAt(index),
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

  @override
  Widget build(BuildContext context) {
    OffsetWidget.screenInit(context, 360);
    return Container(
      height: OffsetWidget.setSc(500),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        color: Color(0xFFF6F9FC),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              color: Color(0xFFF6F9FC),
            ),
            height: OffsetWidget.setSc(54),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => {insertWallets()},
                  child: LoadAssetsImage(
                    Constant.ASSETS_IMG + "icon/wallet_insert.png",
                    width: OffsetWidget.setSc(45),
                    height: OffsetWidget.setSc(45),
                    fit: null,
                    scale: 2,
                  ),
                ),
                Text(
                  "wallets_choosewallet".local(),
                  style: TextStyle(
                      color: Color(0xFF586883),
                      fontSize: OffsetWidget.setSp(18),
                      fontWeight: FontWeight.w500),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => {sheetClose()},
                  child: LoadAssetsImage(
                    Constant.ASSETS_IMG + "icon/icon_close.png",
                    width: OffsetWidget.setSc(45),
                    height: OffsetWidget.setSc(45),
                    fit: null,
                    scale: 2,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              margin: EdgeInsets.only(
                left: OffsetWidget.setSc(10),
                right: OffsetWidget.setSc(10),
              ),
              padding: EdgeInsets.only(
                left: OffsetWidget.setSc(10),
                right: OffsetWidget.setSc(10),
              ),
              child: Column(
                children: [
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
                        return _cellBuilder(index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => {walletsManagetClick()},
            child: Container(
              height: OffsetWidget.setSc(68),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      top: BorderSide(
                          color: Color(0XFFEAEFF2),
                          width: 1,
                          style: BorderStyle.solid))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadAssetsImage(
                    Constant.ASSETS_IMG + "icon/icon_walletmanager.png",
                    width: OffsetWidget.setSc(19),
                    height: OffsetWidget.setSc(21),
                  ),
                  OffsetWidget.hGap(7),
                  Text(
                    "wallet_management".local(),
                    style: TextStyle(
                        color: Color(0xFF586883),
                        fontSize: OffsetWidget.setSp(18),
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
