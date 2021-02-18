// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mh_wallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MHWallet _$MHWalletFromJson(Map<String, dynamic> json) {
  return MHWallet(
    json['walletID'] as String,
    json['walletAaddress'] as String,
    json['pin'] as String,
    json['pinTip'] as String,
    json['createTime'] as String,
    json['updateTime'] as String,
    json['symbol'] as String,
    json['fullName'] as String,
    json['isChoose'] as bool,
    json['prvKey'] as String,
    json['pubKey'] as String,
    json['chainType'] as int,
    json['isWegwit'] as bool,
    json['leadType'] as int,
    json['originType'] as int,
    json['subPrvKey'] as String,
    json['subPubKey'] as String,
    json['masterPubKey'] as String,
    json['macUUID'] as String,
    json['descName'] as String,
    json['didChoose'] as bool,
  );
}

Map<String, dynamic> _$MHWalletToJson(MHWallet instance) => <String, dynamic>{
      'walletID': instance.walletID,
      'walletAaddress': instance.walletAaddress,
      'pin': instance.pin,
      'pinTip': instance.pinTip,
      'createTime': instance.createTime,
      'updateTime': instance.updateTime,
      'symbol': instance.symbol,
      'fullName': instance.fullName,
      'isChoose': instance.isChoose,
      'prvKey': instance.prvKey,
      'pubKey': instance.pubKey,
      'chainType': instance.chainType,
      'isWegwit': instance.isWegwit,
      'leadType': instance.leadType,
      'originType': instance.originType,
      'subPrvKey': instance.subPrvKey,
      'subPubKey': instance.subPubKey,
      'masterPubKey': instance.masterPubKey,
      'macUUID': instance.macUUID,
      'descName': instance.descName,
      'didChoose': instance.didChoose,
    };
