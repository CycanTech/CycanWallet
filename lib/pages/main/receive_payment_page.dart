import 'package:flutter_coinid/channel/channel_native.dart';
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
  int onlyAddress; //1: 只包含地址信息

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.params != null) {
      walletAddress = widget.params["walletAddress"][0];
      contractAddressStr = widget.params["contract"][0];
      token = widget.params["token"][0].toUpperCase();
      decimalStr = widget.params["decimals"][0];
      chainType = int.parse(widget.params["chainType"][0]);
      onlyAddress = int.parse(widget.params["onlyAddress"][0]);
      buildRecerveStr();
    }
  }

  buildRecerveStr() async {
    if (chainType == MCoinType.MCoinType_EOS.index) {
      if ("EOS" == token) {
        //例 eos:txwknzm3hz4b?contractAddress=EOS%40eosio.token&decimal=0&value=0
        if (onlyAddress != 1) {
          qrCodeStr = "eos:" +
              walletAddress +
              "?contractAddress=" +
              token +
              "%40" +
              contractAddressStr +
              "&decimal=" +
              decimalStr +
              "&value=0";
        } else {
          qrCodeStr = walletAddress;
        }
      } else {
        //例 eos:txwknzm3hz4b?contractAddress=IPOS%40oo1122334455&decimal=0&value=0
        qrCodeStr = "eos:" +
            walletAddress +
            "?contractAddress=" +
            token +
            "%40" +
            contractAddressStr +
            "&decimal=" +
            decimalStr +
            "&value=0";
      }
    } else if (chainType == MCoinType.MCoinType_ETH.index) {
      if ("ETH" == token) {
        //例 ethereum:0xb9af7a63b5fcef11c35891ef033dec6db7a4562b&decimal=18&value=0
        if (onlyAddress != 1) {
          qrCodeStr = "ethereum:" +
              "0x" +
              await ChannelNative.cvtAddrByEIP55(
                  walletAddress.replaceAll("0x", "")) +
              "&decimal=" +
              decimalStr +
              "&value=0";
        } else {
          qrCodeStr = "0x" +
              await ChannelNative.cvtAddrByEIP55(
                  walletAddress.replaceAll("0x", ""));
        }
      } else {
        //例 ethereum:0xb9af7a63b5fcef11c35891ef033dec6db7a4562b?contractAddress=0x0f8c45b896784a1e408526b9300519ef8660209c&decimal=8&value=0&token=xmx
        qrCodeStr = "ethereum:" +
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
    } else if (chainType == MCoinType.MCoinType_VNS.index) {
      if ("VNS" == token) {
        //例 vns:0xb9af7a63b5fcef11c35891ef033dec6db7a4562b&decimal=18&value=0
        if (onlyAddress != 1) {
          qrCodeStr = "vns:" +
              "0x" +
              await ChannelNative.cvtAddrByEIP55(
                  walletAddress.replaceAll("0x", "")) +
              "&decimal=" +
              decimalStr +
              "&value=0";
        } else {
          qrCodeStr = "0x" +
              await ChannelNative.cvtAddrByEIP55(
                  walletAddress.replaceAll("0x", ""));
        }
      } else {
        //例 vns:0xb9af7a63b5fcef11c35891ef033dec6db7a4562b?contractAddress=0x0f8c45b896784a1e408526b9300519ef8660209c&decimal=8&value=0&token=xmx
        qrCodeStr = "vns:" +
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
      if (onlyAddress != 1) {
        qrCodeStr =
            "bitcoin:" + walletAddress + "&decimal=" + decimalStr + "&value=0";
      } else {
        qrCodeStr = walletAddress;
      }
    } else if (chainType == MCoinType.MCoinType_BTM.index) {
      //例 btm:1PX7MaEHU4e2Lrv1vSVdYzWBq6chNY6U7Z&decimal=0&value=0
      if (onlyAddress != 1) {
        qrCodeStr =
            "btm:" + walletAddress + "&decimal=" + decimalStr + "&value=0";
      } else {
        qrCodeStr = walletAddress;
      }
    } else if (chainType == MCoinType.MCoinType_LTC.index) {
      //例 ltc:1PX7MaEHU4e2Lrv1vSVdYzWBq6chNY6U7Z&decimal=0&value=0
      if (onlyAddress != 1) {
        qrCodeStr =
            "ltc:" + walletAddress + "&decimal=" + decimalStr + "&value=0";
      } else {
        qrCodeStr = walletAddress;
      }
    } else if (chainType == MCoinType.MCoinType_USDT.index) {
      //例 usdt:1PX7MaEHU4e2Lrv1vSVdYzWBq6chNY6U7Z&decimal=0&value=0
      if (onlyAddress != 1) {
        qrCodeStr =
            "usdt:" + walletAddress + "&decimal=" + decimalStr + "&value=0";
      } else {
        qrCodeStr = walletAddress;
      }
    } else if (chainType == MCoinType.MCoinType_GPS.index) {
      if ("GPS" == token) {
        //例 gps:0xb9af7a63b5fcef11c35891ef033dec6db7a4562b&decimal=18&value=0
        if (onlyAddress != 1) {
          qrCodeStr =
              "gps:" + walletAddress + "&decimal=" + decimalStr + "&value=0";
        } else {
          qrCodeStr = walletAddress;
        }
      } else {
        //例 gps:0xb9af7a63b5fcef11c35891ef033dec6db7a4562b?contractAddress=0x0f8c45b896784a1e408526b9300519ef8660209c&decimal=8&value=0&token=xmx
        qrCodeStr = "gps:" +
            walletAddress +
            "?contractAddress=" +
            contractAddressStr +
            "&decimal=" +
            decimalStr +
            "&value=0" +
            "&token=" +
            token;
      }
    } else if(chainType == MCoinType.MCoinType_DOT.index) {
      qrCodeStr = "待实现";
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    OffsetWidget.screenInit(context, 360);
    return CustomPageView(
      hiddenScrollView: true,
      title: Text(
        "receive_payment".local(),
        style: TextStyle(
            fontSize: OffsetWidget.setSp(17), color: Color(0xFF4A4A4A)),
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              height: OffsetWidget.setSc(289),
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage(
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
                  Container(
                    width: OffsetWidget.setSc(200),
                    child: Text(
                      walletAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: OffsetWidget.setSp(13),
                          color: Color(0xFF444444)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}
