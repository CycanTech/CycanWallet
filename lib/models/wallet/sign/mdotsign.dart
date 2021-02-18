import 'package:flutter_coinid/channel/channel_native.dart';
import 'package:flutter_coinid/utils/json_util.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../public.dart';
import '../mh_wallet.dart';

part 'mdotsign.g.dart';

@JsonSerializable()
class DotSignParams {
  final String chain;
  final String version; //json结构版本
  final int blockNumber; //最新块高度
  final String blockHash; //最新块的hash
  final int eraPeriod;
  final String address; //对方地址
  final String value; //金额
  final String tip; //小费
  final String genesisHash; //创世块的hash
  final int nonce;
  final int txVersion;
  final int specVersion;

  DotSignParams(
      this.chain,
      this.version,
      this.blockNumber,
      this.blockHash,
      this.eraPeriod,
      this.address,
      this.value,
      this.tip,
      this.genesisHash,
      this.nonce,
      this.txVersion,
      this.specVersion);

  factory DotSignParams.fromJson(Map<String, dynamic> json) =>
      _$DotSignParamsFromJson(json);
  Map<String, dynamic> toJson() => _$DotSignParamsToJson(this);
}

extension MDOTSign on MHWallet {
  Future<String> dotsign({
    @required String pin,
    @required DotSignParams params,
  }) async {
    try {
      String jsonTrans = JsonUtil.encodeObj(params.toJson());
      final String prvStr = await this.exportPrv(pin: pin);
      if (prvStr == null) {
        return null;
      }
      LogUtil.v(
          "dotsign jsonTrans $jsonTrans this.pubKey ${this.pubKey} prvKey $prvKey");
      String sign = await ChannelNative.sigPolkadotTransaction(
          jsonTrans, prvStr, this.pubKey);
      sign = "0x" + sign;
      return sign;
    } catch (e) {
      LogUtil.v("dotsign交易失败\n");
      LogUtil.v(e);
      return null;
    }
  }
}
