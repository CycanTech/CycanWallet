import 'package:flutter_coinid/models/wallet/mh_wallet.dart';

import '../../public.dart';

class WalletUpdateTipsPage extends StatefulWidget {
  WalletUpdateTipsPage({
    Key key,
    this.params,
  }) : super(key: key);
  Map params = Map();
  @override
  _WalletUpdateTipsPageState createState() => _WalletUpdateTipsPageState();
}

class _WalletUpdateTipsPageState extends State<WalletUpdateTipsPage> {
  bool obscureText = true;
  TextEditingController tipsEC = TextEditingController();
  String walletID;
  String hitTip = "";
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
        setState(() {
          tipsEC.text = wallet.pinTip;
          mwallet = wallet;
        });
      }
    }
  }

  _updateWalletTip(String tip) async {
    mwallet.pinTip = tip;
    bool flag = await MHWallet.updateWallet(mwallet);
    if (flag) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    OffsetWidget.screenInit(context, 360);
    return CustomPageView(
      hiddenResizeToAvoidBottomInset: false,
      title: Text(
        "wallet_update_tip_title".local(),
        style: TextStyle(
            fontSize: OffsetWidget.setSp(17), color: Color(0xFF4A4A4A)),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            _updateWalletTip(tipsEC.text);
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
      child: Container(
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
              Container(
                width: OffsetWidget.setSc(260),
                child: CustomTextField(
                  controller: tipsEC,
                  maxLines: 1,
                  obscureText: obscureText,
                ),
              ),
              GestureDetector(
                onTap: () {
                  obscureText = !obscureText;
                  setState(() {});
                },
                child: LoadAssetsImage(
                  obscureText
                      ? Constant.ASSETS_IMG + "icon/icon_close_eye.png"
                      : Constant.ASSETS_IMG + "icon/icon_open_eye.png",
                  width: OffsetWidget.setSc(20),
                  height: OffsetWidget.setSc(48),
                  fit: BoxFit.contain,
                ),
              ),
            ],
          )),
    );
  }
}
