// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_asset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrencyAssetModel _$CurrencyAssetModelFromJson(Map<String, dynamic> json) {
  return CurrencyAssetModel(
    json['chainType'] as int,
    json['coinType'] as String,
    json['token'] as String,
    json['decimal'] as String,
    json['balance'] as String,
    json['cnyprice'] as String,
    json['usdprice'] as String,
    json['cnyassets'] as String,
    json['usdassets'] as String,
    json['tokenContract'] as String,
  );
}

Map<String, dynamic> _$CurrencyAssetModelToJson(CurrencyAssetModel instance) =>
    <String, dynamic>{
      'chainType': instance.chainType,
      'coinType': instance.coinType,
      'token': instance.token,
      'decimal': instance.decimal,
      'balance': instance.balance,
      'cnyprice': instance.cnyprice,
      'usdprice': instance.usdprice,
      'cnyassets': instance.cnyassets,
      'usdassets': instance.usdassets,
      'tokenContract': instance.tokenContract,
    };
