import 'dart:async';

import 'package:floor/floor.dart';
import 'package:flutter_coinid/models/assets/currency_asset.dart';
import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
import 'package:flutter_coinid/models/wallet/user.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import '../models/node/node_model.dart';
part 'database.g.dart';

//flutter packages pub run build_runner build

const int dbCurrentVersion = 1 ;
@Database(version: dbCurrentVersion, entities: [MHWallet, UserModel, CurrencyAssetModel, NodeModel])
abstract class FlutterDatabase extends FloorDatabase {
  // NodeDao get nodeDao;
  MHWalletDao get walletDao;
  UserModelDao get userDao;
  CurrencyAssetDao get assetDao;
  NodeDao get nodeDao;
}
