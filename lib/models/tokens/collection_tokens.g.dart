// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_tokens.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MCollectionTokens _$MCollectionTokensFromJson(Map<String, dynamic> json) {
  return MCollectionTokens(
    id: json['id'] as int,
    contract: json['contract'] as String,
    token: json['token'] as String,
    coinType: json['coinType'] as String,
    balance: json['balance'] as num,
    state: json['state'] as int,
    decimals: json['decimals'] as int,
    iconPath: json['iconPath'] as String,
    price: json['price'] as num,
  );
}

Map<String, dynamic> _$MCollectionTokensToJson(MCollectionTokens instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contract': instance.contract,
      'token': instance.token,
      'coinType': instance.coinType,
      'iconPath': instance.iconPath,
      'state': instance.state,
      'decimals': instance.decimals,
      'price': instance.price,
      'balance': instance.balance,
    };
