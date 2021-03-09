import 'package:json_annotation/json_annotation.dart';

// part 'collection_tokens.g.dart';

@JsonSerializable()
class CollectionTokens {
  String contract;
  String token;
  String coinType;
  String iconPath;
  int state;
  int decimals;
  int price;
  int balance;
}
