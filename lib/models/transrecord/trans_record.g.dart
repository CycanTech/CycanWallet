// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trans_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MHTransRecordModel _$MHTransRecordModelFromJson(Map<String, dynamic> json) {
  return MHTransRecordModel(
    txid: json['txid'] as String,
    to: json['to'] as String,
    from: json['from'] as String,
    date: json['date'] as String,
    amount: json['amount'] as String,
    remarks: json['remarks'] as String,
    blocknumber: json['blocknumber'] as String,
    confirmations: json['confirmations'] as String,
    fee: json['fee'] as String,
    transStatus: json['transStatus'] as int,
    token: json['token'] as String,
    coinType: json['coinType'] as String,
    gasLimit: json['gasLimit'] as String,
    gasPrice: json['gasPrice'] as String,
    isOut: json['isOut'] as bool,
    transType: json['transType'] as int,
  );
}

Map<String, dynamic> _$MHTransRecordModelToJson(MHTransRecordModel instance) =>
    <String, dynamic>{
      'txid': instance.txid,
      'to': instance.to,
      'from': instance.from,
      'date': instance.date,
      'amount': instance.amount,
      'remarks': instance.remarks,
      'blocknumber': instance.blocknumber,
      'confirmations': instance.confirmations,
      'fee': instance.fee,
      'gasPrice': instance.gasPrice,
      'gasLimit': instance.gasLimit,
      'transStatus': instance.transStatus,
      'token': instance.token,
      'coinType': instance.coinType,
      'isOut': instance.isOut,
      'transType': instance.transType,
    };
