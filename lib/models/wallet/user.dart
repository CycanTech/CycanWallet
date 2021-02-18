import 'package:floor/floor.dart';
import 'package:flutter_coinid/channel/channel_native.dart';
import 'package:flutter_coinid/db/database.dart';
import 'package:flutter_coinid/db/database_config.dart';
import 'package:flutter_coinid/public.dart';
import 'package:flutter_coinid/utils/log_util.dart';

import '../base_model.dart';

const String tableName = "userid_table";

@Entity(tableName: tableName)

//创建，恢复时，产生主公钥
class UserModel extends BaseModel {
  //身份名
  String walletName;
  //密码
  String pwd;
  //密码提示
  String tip;
  //主公钥
  @primaryKey
  String masterPubKey;
  //助记词
  String memos;
  //来源类型
  int leadType;

  int mOriginType;

  UserModel(this.walletName, this.pwd, this.tip, this.masterPubKey, this.memos,
      this.leadType, this.mOriginType);

  static Future<UserModel> findUsersByMasterPubKey(String masterPubKey) async {
    try {
      FlutterDatabase database = await BaseModel.getDataBae();
      return database.userDao.findUsersByMasterPubKey(masterPubKey);
    } catch (e) {
      LogUtil.v("失败" + e.toString());
      return null;
    }
  }

  static Future<List<UserModel>> findAllUsers() async {
    try {
      FlutterDatabase database = await BaseModel.getDataBae();
      return database.userDao.findAllUsers();
    } catch (e) {
      LogUtil.v("失败" + e.toString());
      return null;
    }
  }

  static Future<bool> updateWallets(List<UserModel> users) async {
    try {
      FlutterDatabase database = await BaseModel.getDataBae();
      database.userDao.updateWallets(users);
      return true;
    } catch (e) {
      LogUtil.v("失败" + e.toString());
      return false;
    }
  }

  static Future<bool> deleteWallets(List<UserModel> users) async {
    try {
      FlutterDatabase database = await BaseModel.getDataBae();
      database.userDao.deleteWallets(users);
      return true;
    } catch (e) {
      LogUtil.v("失败" + e.toString());
      return false;
    }
  }

  static Future<bool> deleteWallet(UserModel users) async {
    try {
      FlutterDatabase database = await BaseModel.getDataBae();
      database.userDao.deleteWallet(users);
      return true;
    } catch (e) {
      LogUtil.v("失败" + e.toString());
      return false;
    }
  }

  Future<String> exportMemo({@required String pin}) async {
    try {
      return ChannelNative.decByAES128CBC(this.memos, pin);
    } catch (e) {
      LogUtil.v("exportMemo出错" + e.toString());
      return null;
    }
  }
}

@dao
abstract class UserModelDao {
  @Query('SELECT * FROM ' + tableName + ' WHERE masterPubKey = :masterPubKey')
  Future<UserModel> findUsersByMasterPubKey(String masterPubKey);

  @Query('SELECT * FROM ' + tableName + ' WHERE mOriginType = :mOriginType')
  Future<UserModel> findUsersByOriginType(int mOriginType);

  @Query('SELECT * FROM ' + tableName)
  Future<List<UserModel>> findAllUsers();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertWallet(UserModel user);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertWallets(List<UserModel> users);

  @update
  Future<void> updateWallet(UserModel user);

  @update
  Future<void> updateWallets(List<UserModel> users);

  @delete
  Future<void> deleteWallet(UserModel user);

  @delete
  Future<void> deleteWallets(List<UserModel> users);
}
