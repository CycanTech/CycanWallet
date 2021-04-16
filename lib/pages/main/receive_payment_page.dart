import 'package:flutter/services.dart';
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
      title: CustomPageView.getDefaultTitle(
        titleStr: "receive_payment".local(),
      ),
      child: Container(
        alignment: Alignment.center,
        height: OffsetWidget.setSc(450),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              Constant.ASSETS_IMG + "background/bg_receive.png",
            ),
            fit: BoxFit.contain,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            Positioned(
              top: OffsetWidget.setSc(55),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(OffsetWidget.setSc(19)),
                    child: LoadAssetsImage(
                      Constant.ASSETS_IMG + "icon/icon_app.png",
                      width: OffsetWidget.setSc(38),
                      height: OffsetWidget.setSc(38),
                      fit: BoxFit.contain,
                    ),
                  ),
                  Text("AllToken",
                      style: TextStyle(
                          fontSize: OffsetWidget.setSp(15),
                          fontWeight: FontWightHelper.regular,
                          color: Color(0xFF161D2D))),
                ],
              ),
            ),
            Positioned(
              top: OffsetWidget.setSc(144),
              width: OffsetWidget.setSc(197),
              height: OffsetWidget.setSc(197),
              child: QrImage(
                data: qrCodeStr,
                size: OffsetWidget.setSc(197),
              ),
            ),
            Positioned(
              bottom: OffsetWidget.setSc(44),
              width: OffsetWidget.setSc(250),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (walletAddress.isValid() == false) return;
                      Clipboard.setData(ClipboardData(text: walletAddress));
                      HWToast.showText(text: "copy_success".local());
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LoadAssetsImage(
                          Constant.ASSETS_IMG + "icon/icon_whitecopy.png",
                          width: 13,
                          height: 13,
                        ),
                        OffsetWidget.hGap(4),
                        Text(
                          "copy_receiveaddress".local(),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: OffsetWidget.setSp(14),
                            fontWeight: FontWightHelper.regular,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  OffsetWidget.vGap(7),
                  Text(
                    walletAddress,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: OffsetWidget.setSp(10),
                      fontWeight: FontWightHelper.regular,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
