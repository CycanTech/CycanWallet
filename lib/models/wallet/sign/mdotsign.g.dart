// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mdotsign.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DotSignParams _$DotSignParamsFromJson(Map<String, dynamic> json) {
  return DotSignParams(
    json['chain'] as String,
    json['version'] as String,
    json['blockNumber'] as int,
    json['blockHash'] as String,
    json['eraPeriod'] as int,
    json['address'] as String,
    json['value'] as String,
    json['tip'] as String,
    json['genesisHash'] as String,
    json['nonce'] as int,
    json['txVersion'] as int,
    json['specVersion'] as int,
  );
}

Map<String, dynamic> _$DotSignParamsToJson(DotSignParams instance) =>
    <String, dynamic>{
      'chain': instance.chain,
      'version': instance.version,
      'blockNumber': instance.blockNumber,
      'blockHash': instance.blockHash,
      'eraPeriod': instance.eraPeriod,
      'address': instance.address,
      'value': instance.value,
      'tip': instance.tip,
      'genesisHash': instance.genesisHash,
      'nonce': instance.nonce,
      'txVersion': instance.txVersion,
      'specVersion': instance.specVersion,
    };
