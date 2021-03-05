import 'package:flutter_coinid/channel/channel_native.dart';
import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../public.dart';

class RecervePaymentPage extends StatefulWidget {
  RecervePaymentPage({
    Key key,
    this.params,
  }) : super(key: key);
  Map params = Map();

  @override
  _RecervePaymentPageState createState() => _RecervePaymentPageState();
}

class _RecervePaymentPageState extends State<RecervePaymentPage> {
  String qrCodeStr = "";
  String walletAddress = "";
  String contractAddressStr = "";
  String token;
  String decimalStr;
  int chainType;
  int onlyAddress = 1; //1: 只包含地址信息

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    MHWallet wallet =
        Provider.of<CurrentChooseWalletState>(context, listen: false)
            .currentWallet;
    if (wallet != null) {
      walletAddress = wallet.walletAaddress;
      chainType = wallet.chainType;
      if (widget.params.containsKey("contract")) {
        contractAddressStr = widget.params["contract"][0];
      }
      if (widget.params.containsKey("token")) {
        token = widget.params["token"][0];
      }
      if (widget.params.containsKey("decimals")) {
        decimalStr = widget.params["decimals"][0];
      }
      if (widget.params.containsKey("onlyAddress")) {
        onlyAddress = int.tryParse(widget.params["onlyAddress"][0]);
      }
      buildRecerveStr();
    }
  }

  void buildRecerveStr() async {
    String value = "";
    if (onlyAddress == 1) {
      if (chainType == MCoinType.MCoinType_ETH.index) {
        value = "0x" +
            await ChannelNative.cvtAddrByEIP55(
                walletAddress.replaceAll("0x", ""));
      } else {
        value = walletAddress;
      }
    } else {
      if (chainType == MCoinType.MCoinType_ETH.index) {
        if ("ETH" == token) {
          //例 ethereum:0xb9af7a63b5fcef11c35891ef033dec6db7a4562b&decimal=18&value=0
          value = "ethereum:" +
              "0x" +
              await ChannelNative.cvtAddrByEIP55(
                  walletAddress.replaceAll("0x", "")) +
              "&decimal=18" +
              "&value=0";
        } else {
          //例 ethereum:0xb9af7a63b5fcef11c35891ef033dec6db7a4562b?contractAddress=0x0f8c45b896784a1e408526b9300519ef8660209c&decimal=8&value=0&token=xmx
          value = "ethereum:" +
              "0x" +
              await ChannelNative.cvtAddrByEIP55(
                  walletAddress.replaceAll("0x", "")) +
              "?contractAddress=" +
              contractAddressStr +
              "&decimal=" +
              decimalStr +
              "&value=0" +
              "&token=" +
              token;
        }
      } else if (chainType == MCoinType.MCoinType_BTC.index) {
        //例 bitcoin:1PX7MaEHU4e2Lrv1vSVdYzWBq6chNY6U7Z&decimal=0&value=0
        value = "bitcoin:" + walletAddress + "&decimal=8" + "&value=0";
      } else if (chainType == MCoinType.MCoinType_DOT.index) {
        value = "dot:" + walletAddress + "&decimal=10" + "&value=0";
      }
    }

    setState(() {
      qrCodeStr = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
      hiddenScrollView: true,
      title: Text(
        "receive_payment".local(),
        style: TextStyle(
            fontSize: OffsetWidget.setSp(17), color: Color(0xFF4A4A4A)),
      ),
      child: Center(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 25, right: 25),
          height: OffsetWidget.setSc(290),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                Constant.ASSETS_IMG + "background/bg_group.png",
              ),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              QrImage(
                data: qrCodeStr,
                size: OffsetWidget.setSc(140),
              ),
              OffsetWidget.vGap(5),
              Text(
                walletAddress,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                    fontSize: OffsetWidget.setSp(13), color: Color(0xFF444444)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
