import 'package:json_annotation/json_annotation.dart';

part 'collection_tokens.g.dart';

@JsonSerializable()
class MCollectionTokens {
  int id;
  String contract;
  String token;
  String coinType;
  String iconPath;
  int state;
  int decimals;
  num price;
  num balance;

  MCollectionTokens({
    this.id,
    this.contract,
    this.token,
    this.coinType,
    this.balance,
    this.state,
    this.decimals,
    this.iconPath,
    this.price,
  });
  factory MCollectionTokens.fromJson(Map<String, dynamic> json) =>
      _$MCollectionTokensFromJson(json);
  Map<String, dynamic> toJson() => _$MCollectionTokensToJson(this);

  String get assets => ((price ??= 0) * (balance ??= 0)).toStringAsFixed(2);

  bool get isToken =>
      coinType?.toLowerCase() == token?.toLowerCase() ? false : true;
}
