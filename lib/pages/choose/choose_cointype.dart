import '../../public.dart';

class ChooseCoinTypePage extends StatefulWidget {
  ChooseCoinTypePage({Key key}) : super(key: key);

  @override
  _ChooseCoinTypePageState createState() => _ChooseCoinTypePageState();
}

class _ChooseCoinTypePageState extends State<ChooseCoinTypePage> {
  List _datas = [
    // {
    //   "image": "wallet_btc.png",
    //   "name": "BTC-Wallet",
    //   "type": MCoinType.MCoinType_BTC
    // },
    {
      "image": "wallet_eth.png",
      "name": "ETH-Wallet",
      "type": MCoinType.MCoinType_ETH
    },
    {
      "image": "wallet_dot.png",
      "name": "DOT-Wallet",
      "type": MCoinType.MCoinType_DOT
    },
    {
      "image": "wallet_bnb.png",
      "name": "BSC-Wallet",
      "type": MCoinType.MCoinType_BSC,
    },
    {
      "image": "wallet_ksm.png",
      "name": "KSM-Wallet",
      "type": MCoinType.MCoinType_KSM,
    },
  ];

  void cellTap(MCoinType coinType) {
    String mcoinType = Constant.getChainSymbol(coinType.index);
    Routers.push(context, Routers.importPage, params: {"coinType": mcoinType});
  }

  Widget buildCell(int index) {
    Map params = _datas[index];
    return GestureDetector(
      onTap: () => cellTap(params["type"]),
      child: Container(
        alignment: Alignment.center,
        height: OffsetWidget.setSc(54),
        decoration: BoxDecoration(
            color: Color(0xFFF2F3F4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(0xFFCFCFCF))),
        margin: EdgeInsets.only(
            left: OffsetWidget.setSc(40), right: OffsetWidget.setSc(40)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadAssetsImage(
              Constant.ASSETS_IMG + "wallet/" + params["image"],
              width: OffsetWidget.setSc(34),
              height: OffsetWidget.setSc(34),
              fit: BoxFit.cover,
            ),
            OffsetWidget.hGap(11),
            Text(params["name"]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
      hiddenScrollView: true,
      title: CustomPageView.getDefaultTitle(
        titleStr: "import_page".local() + "import_wallet".local(),
      ),
      child: Container(
        padding: EdgeInsets.only(top: OffsetWidget.setSc(60)),
        child: ListView.separated(
          itemCount: _datas.length,
          separatorBuilder: (BuildContext context, int index) {
            return OffsetWidget.vGap(15);
          },
          itemBuilder: (BuildContext context, int index) {
            return buildCell(index);
          },
        ),
      ),
    );
  }
}
