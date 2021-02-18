import 'package:flutter_coinid/utils/json_util.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trans_record.g.dart';

@JsonSerializable()
class MHTransRecordModel {
  String txid; //交易ID
  String to; //to
  String from;
  String date; //时间
  String amount;
  String remarks;
  String blocknumber; //区块高度
  String confirmations; //确认数
  String fee; //手续费
  String gasPrice;
  String gasLimit;
  int transStatus; //0失败 1成功
  String token;
  String coinType;
  //自定义字段
  bool isOut; //0 in 1 out
  int transType; //类型 0 net转账 1

  factory MHTransRecordModel.fromString(String json) =>
      _$MHTransRecordModelFromJson(JsonUtil.getObj(json));

  factory MHTransRecordModel.fromJson(Map<String, dynamic> json) =>
      _$MHTransRecordModelFromJson(json);
  Map<String, dynamic> toJson() => _$MHTransRecordModelToJson(this);

  MHTransRecordModel({
    this.txid,
    this.to,
    this.from,
    this.date,
    this.amount,
    this.remarks,
    this.blocknumber,
    this.confirmations,
    this.fee,
    this.transStatus,
    this.token,
    this.coinType,
    this.gasLimit,
    this.gasPrice,
    this.isOut,
    this.transType,
  });

  @override
  String toString() {
    // TODO: implement toString

    return JsonUtil.encodeObj(this.toJson());
  }
}
