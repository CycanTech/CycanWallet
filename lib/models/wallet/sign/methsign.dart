import 'dart:math';

import 'package:flutter_coinid/channel/channel_native.dart';
import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
import '../../../public.dart';
import '../mh_abi.dart';

extension METHSign on MHWallet {
  Future<String> ethsign(
      {@required String pin,
      @required String nonce,
      @required String gasPrice,
      @required String gasLimit,
      @required String to,
      @required String value,
      @required String data,
      @required String chainID,
      @required String contract,
      @required MSignType signType,
      @required int decimal}) async {
    try {
      to = to.replaceAll("0x", "");
      BigInt bigdecimal = BigInt.from(10).pow(decimal);
      BigInt newValue = bigdecimal * BigInt.tryParse(value);
      final String prvKey = await this.exportPrv(pin: pin);
      if (prvKey == null) {
        return null;
      }
      BigInt newGas = BigInt.from(10).pow(9) * BigInt.tryParse(gasPrice);
      LogUtil.v(
          "nonce $nonce gasPrice $newGas   gasLimit $gasLimit to $to value $value data $data $chainID");

      if (signType == MSignType.MSignType_Token) {
        ETHAbiModel model1 = ETHAbiModel(addrType: true, value: to);
        ETHAbiModel model2 =
            ETHAbiModel(numberType: true, value: newValue.toString());
        data = "a9059cbb" + ETHAbiModel.abiDataWithAbiModel([model1, model2]);
        to = contract;
        value = "0";
      }

      String sign = await ChannelNative.sigETHTranByStr(
          nonce: nonce,
          gasprice: newGas.toString(),
          startgas: gasLimit,
          to: to,
          value: newValue.toString(),
          data: data.isValid() == false ? "0x" : data,
          chainId: chainID,
          prvKey: prvKey);
      //只在主代币交易中校验有效性
      if (signType == MSignType.MSignType_Main ||
          signType == MSignType.MSignType_Token ||
          signType == MSignType.MSignType_BancorBuy ||
          signType == MSignType.MSignType_BancorSell) {
        bool isValid = false;
        if (signType == MSignType.MSignType_Main) {
          isValid = await ChannelNative.checkETHpushValid(
              sign, to, value, decimal, "");
        } else {
          isValid = await ChannelNative.checkETHpushValid(
              sign, to, value, decimal, to);
        }
        LogUtil.v("eth 签名 check $isValid sign $sign");
        return isValid == true ? sign : null;
      }
      return sign;
    } catch (e) {
      LogUtil.v("ethsign交易失败\n");
      LogUtil.v(e);
      return null;
    }
  }
}
