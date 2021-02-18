import 'package:flutter_coinid/models/wallet/mh_wallet.dart';

import '../../public.dart';

class WalletUpdateNamePage extends StatefulWidget {
  WalletUpdateNamePage({
    Key key,
    this.params,
  }) : super(key: key);
  Map params = Map();
  @override
  _WalletUpdateNamePageState createState() => _WalletUpdateNamePageState();
}

class _WalletUpdateNamePageState extends State<WalletUpdateNamePage> {
  TextEditingController nameEC = TextEditingController();
  String walletID, chain = "", walletName = "Wallet";
  MHWallet mwallet;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _findWalletByWalletID();
  }

  _findWalletByWalletID() async {
    if (widget.params != null) {
      walletID = widget.params["walletID"][0];
      MHWallet wallet = await MHWallet.findWalletByWalletID(walletID);
      if (wallet != null) {
        chain = Constant.getChainSymbol(wallet.chainType) + " -";
        if (wallet.descName != null && wallet.descName.length > 0) {
          walletName = wallet.descName;
        }
        setState(() {
          mwallet = wallet;
        });
      }
    }
  }

  _updateWalletName(String name) async {
    mwallet.descName = name;
    if (await MHWallet.updateWallet(mwallet)) {
      Routers.goBackWithParams(context, {"name": name});
    }
  }

  @override
  Widget build(BuildContext context) {
    OffsetWidget.screenInit(context, 360);
    return CustomPageView(
      hiddenResizeToAvoidBottomInset: false,
      title: Text(
        "wallet_update_name_title".local(),
        style: TextStyle(
            fontSize: OffsetWidget.setSp(17), color: Color(0xFF4A4A4A)),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            _updateWalletName(nameEC.text);
          },
          child: Container(
            width: OffsetWidget.setSc(60),
            height: OffsetWidget.setSc(44),
            alignment: Alignment.center,
            child: Text(
              "wallet_complete".local(),
              style: TextStyle(
                  fontSize: OffsetWidget.setSp(13), color: Color(0xFF4A4A4A)),
            ),
          ),
        ),
      ],
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            width: OffsetWidget.setSc(360),
            height: OffsetWidget.setSc(30),
            margin: EdgeInsets.fromLTRB(
                OffsetWidget.setSc(35),
                OffsetWidget.setSc(23),
                OffsetWidget.setSc(35),
                OffsetWidget.setSc(10)),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Color(0xFFCFCFCF),
                        width: 1,
                        style: BorderStyle.solid))),
            child: Row(
              children: [
                Text(
                  chain,
                  style: TextStyle(
                      fontSize: OffsetWidget.setSp(15),
                      color: Color(0xFF4A4A4A)),
                ),
                OffsetWidget.hGap(5),
                Container(
                  width: OffsetWidget.setSc(220),
                  child: CustomTextField(
                    controller: nameEC,
                    maxLines: 1,
                    hiddenBorderSide: false,
                    hintText: walletName,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(OffsetWidget.setSc(3)),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: OffsetWidget.setSc(34)),
            alignment: Alignment.centerRight,
            child: Text(
              "wallet_input_name_hit_err".local(),
              style: TextStyle(
                  fontSize: OffsetWidget.setSp(12), color: Color(0xFF9B9B9B)),
            ),
          ),
        ],
      ),
    );
  }
}
