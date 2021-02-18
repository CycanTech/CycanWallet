import 'package:flutter_coinid/channel/channel_native.dart';
import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
import 'package:flutter_coinid/utils/json_util.dart';
import '../../../public.dart';

///支持btc ltc usdt 签名
extension MBTCSign on MHWallet {
  Future<String> btcsign({
    String jsonTran,
    String to,
    String pin,
  }) async {
    try {
      final String prvStr = await this.exportPrv(pin: pin);
      if (prvStr == null) {
        return null;
      }
      String pushStr = await ChannelNative.sigtBTCTransaction(jsonTran, prvStr);
      bool isValid = await MBTCSign.checkBTCpushValid(
          jsonTran: jsonTran, to: to, pushStr: pushStr);
      return isValid ? pushStr : null;
    } catch (e) {
      LogUtil.v("btcsign交易失败" + e.toString());
      return null;
    }
  }

  static Future<bool> checkBTCpushValid(
      {String jsonTran, String to, String pushStr}) async {
    try {
      Map jsonObj = JsonUtil.getObj(jsonTran);
      List outputsArr = jsonObj["outputs"];
      String outsputs = "";
      String outputsMoney = "";
      String inputs = "";
      String inpusMoney = "";
      String usdtMoney = "";
      String coinType = jsonObj["cointype"] as String;
      bool isSegwit = jsonObj["segwit"] as int == 0 ? false : true;
      for (Map outsDic in outputsArr) {
        String address = outsDic["address"] as String;
        String value = BigInt.from(outsDic["value"]).toString();
        if (address == to) {
          outsputs = address;
          outputsMoney = value;
        } else if (address == null || address.length == 0) {
          usdtMoney = value;
        } else {
          inputs = address;
          inpusMoney = value;
        }
      }
      if (coinType == null || coinType.length == 0) {
        coinType = "btc";
      }
      bool isValid = await ChannelNative.checkBTCpushValid(pushStr, outsputs,
          outputsMoney, inputs, inpusMoney, usdtMoney, coinType, isSegwit);
      LogUtil.v("btc sign " + isValid.toString());
      return isValid;
    } catch (e) {
      LogUtil.v("btccheck失败" + e.toString());
      return false;
    }
  }
}
