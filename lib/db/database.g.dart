// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorFlutterDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$FlutterDatabaseBuilder databaseBuilder(String name) =>
      _$FlutterDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$FlutterDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$FlutterDatabaseBuilder(null);
}

class _$FlutterDatabaseBuilder {
  _$FlutterDatabaseBuilder(this.name);

  final String name;

  final List<Migration> _migrations = [];

  Callback _callback;

  /// Adds migrations to the builder.
  _$FlutterDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$FlutterDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<FlutterDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name)
        : ':memory:';
    final database = _$FlutterDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$FlutterDatabase extends FlutterDatabase {
  _$FlutterDatabase([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  MHWalletDao _walletDaoInstance;

  UserModelDao _userDaoInstance;

  CurrencyAssetDao _assetDaoInstance;

  NodeDao _nodeDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `wallet_table` (`walletID` TEXT, `walletAaddress` TEXT, `pin` TEXT, `pinTip` TEXT, `createTime` TEXT, `updateTime` TEXT, `isChoose` INTEGER, `prvKey` TEXT, `pubKey` TEXT, `chainType` INTEGER, `isWegwit` INTEGER, `leadType` INTEGER, `originType` INTEGER, `subPrvKey` TEXT, `subPubKey` TEXT, `masterPubKey` TEXT, `macUUID` TEXT, `descName` TEXT, `didChoose` INTEGER, `hiddenAssets` INTEGER, `index` INTEGER, PRIMARY KEY (`walletID`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `userid_table` (`walletName` TEXT, `pwd` TEXT, `tip` TEXT, `masterPubKey` TEXT, `memos` TEXT, `leadType` INTEGER, `mOriginType` INTEGER, PRIMARY KEY (`masterPubKey`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `currencyAsset_table` (`chainType` INTEGER, `coinType` TEXT, `token` TEXT, `decimal` TEXT, `balance` TEXT, `cnyprice` TEXT, `usdprice` TEXT, `cnyassets` TEXT, `usdassets` TEXT, `tokenContract` TEXT, PRIMARY KEY (`coinType`, `token`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `nodes_table` (`content` TEXT, `chainType` INTEGER, `isChoose` INTEGER, `isOrigin` INTEGER, `netType` INTEGER, PRIMARY KEY (`content`, `chainType`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  MHWalletDao get walletDao {
    return _walletDaoInstance ??= _$MHWalletDao(database, changeListener);
  }

  @override
  UserModelDao get userDao {
    return _userDaoInstance ??= _$UserModelDao(database, changeListener);
  }

  @override
  CurrencyAssetDao get assetDao {
    return _assetDaoInstance ??= _$CurrencyAssetDao(database, changeListener);
  }

  @override
  NodeDao get nodeDao {
    return _nodeDaoInstance ??= _$NodeDao(database, changeListener);
  }
}

class _$MHWalletDao extends MHWalletDao {
  _$MHWalletDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _mHWalletInsertionAdapter = InsertionAdapter(
            database,
            'wallet_table',
            (MHWallet item) => <String, dynamic>{
                  'walletID': item.walletID,
                  'walletAaddress': item.walletAaddress,
                  'pin': item.pin,
                  'pinTip': item.pinTip,
                  'createTime': item.createTime,
                  'updateTime': item.updateTime,
                  'isChoose':
                      item.isChoose == null ? null : (item.isChoose ? 1 : 0),
                  'prvKey': item.prvKey,
                  'pubKey': item.pubKey,
                  'chainType': item.chainType,
                  'isWegwit':
                      item.isWegwit == null ? null : (item.isWegwit ? 1 : 0),
                  'leadType': item.leadType,
                  'originType': item.originType,
                  'subPrvKey': item.subPrvKey,
                  'subPubKey': item.subPubKey,
                  'masterPubKey': item.masterPubKey,
                  'macUUID': item.macUUID,
                  'descName': item.descName,
                  'didChoose':
                      item.didChoose == null ? null : (item.didChoose ? 1 : 0),
                  'hiddenAssets': item.hiddenAssets == null
                      ? null
                      : (item.hiddenAssets ? 1 : 0),
                  'index': item.index
                },
            changeListener),
        _mHWalletUpdateAdapter = UpdateAdapter(
            database,
            'wallet_table',
            ['walletID'],
            (MHWallet item) => <String, dynamic>{
                  'walletID': item.walletID,
                  'walletAaddress': item.walletAaddress,
                  'pin': item.pin,
                  'pinTip': item.pinTip,
                  'createTime': item.createTime,
                  'updateTime': item.updateTime,
                  'isChoose':
                      item.isChoose == null ? null : (item.isChoose ? 1 : 0),
                  'prvKey': item.prvKey,
                  'pubKey': item.pubKey,
                  'chainType': item.chainType,
                  'isWegwit':
                      item.isWegwit == null ? null : (item.isWegwit ? 1 : 0),
                  'leadType': item.leadType,
                  'originType': item.originType,
                  'subPrvKey': item.subPrvKey,
                  'subPubKey': item.subPubKey,
                  'masterPubKey': item.masterPubKey,
                  'macUUID': item.macUUID,
                  'descName': item.descName,
                  'didChoose':
                      item.didChoose == null ? null : (item.didChoose ? 1 : 0),
                  'hiddenAssets': item.hiddenAssets == null
                      ? null
                      : (item.hiddenAssets ? 1 : 0),
                  'index': item.index
                },
            changeListener),
        _mHWalletDeletionAdapter = DeletionAdapter(
            database,
            'wallet_table',
            ['walletID'],
            (MHWallet item) => <String, dynamic>{
                  'walletID': item.walletID,
                  'walletAaddress': item.walletAaddress,
                  'pin': item.pin,
                  'pinTip': item.pinTip,
                  'createTime': item.createTime,
                  'updateTime': item.updateTime,
                  'isChoose':
                      item.isChoose == null ? null : (item.isChoose ? 1 : 0),
                  'prvKey': item.prvKey,
                  'pubKey': item.pubKey,
                  'chainType': item.chainType,
                  'isWegwit':
                      item.isWegwit == null ? null : (item.isWegwit ? 1 : 0),
                  'leadType': item.leadType,
                  'originType': item.originType,
                  'subPrvKey': item.subPrvKey,
                  'subPubKey': item.subPubKey,
                  'masterPubKey': item.masterPubKey,
                  'macUUID': item.macUUID,
                  'descName': item.descName,
                  'didChoose':
                      item.didChoose == null ? null : (item.didChoose ? 1 : 0),
                  'hiddenAssets': item.hiddenAssets == null
                      ? null
                      : (item.hiddenAssets ? 1 : 0),
                  'index': item.index
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<MHWallet> _mHWalletInsertionAdapter;

  final UpdateAdapter<MHWallet> _mHWalletUpdateAdapter;

  final DeletionAdapter<MHWallet> _mHWalletDeletionAdapter;

  @override
  Future<MHWallet> findWalletByWalletID(String walletID) async {
    return _queryAdapter.query('SELECT * FROM wallet_table WHERE walletID = ?',
        arguments: <dynamic>[walletID],
        mapper: (Map<String, dynamic> row) => MHWallet(
            row['walletID'] as String,
            row['walletAaddress'] as String,
            row['pin'] as String,
            row['pinTip'] as String,
            row['createTime'] as String,
            row['updateTime'] as String,
            row['isChoose'] == null ? null : (row['isChoose'] as int) != 0,
            row['prvKey'] as String,
            row['pubKey'] as String,
            row['chainType'] as int,
            row['isWegwit'] == null ? null : (row['isWegwit'] as int) != 0,
            row['leadType'] as int,
            row['originType'] as int,
            row['subPrvKey'] as String,
            row['subPubKey'] as String,
            row['masterPubKey'] as String,
            row['macUUID'] as String,
            row['descName'] as String,
            row['didChoose'] == null ? null : (row['didChoose'] as int) != 0,
            row['hiddenAssets'] == null
                ? null
                : (row['hiddenAssets'] as int) != 0,
            row['index'] as int));
  }

  @override
  Future<MHWallet> findChooseWallet() async {
    return _queryAdapter.query('SELECT * FROM wallet_table WHERE isChoose = 1',
        mapper: (Map<String, dynamic> row) => MHWallet(
            row['walletID'] as String,
            row['walletAaddress'] as String,
            row['pin'] as String,
            row['pinTip'] as String,
            row['createTime'] as String,
            row['updateTime'] as String,
            row['isChoose'] == null ? null : (row['isChoose'] as int) != 0,
            row['prvKey'] as String,
            row['pubKey'] as String,
            row['chainType'] as int,
            row['isWegwit'] == null ? null : (row['isWegwit'] as int) != 0,
            row['leadType'] as int,
            row['originType'] as int,
            row['subPrvKey'] as String,
            row['subPubKey'] as String,
            row['masterPubKey'] as String,
            row['macUUID'] as String,
            row['descName'] as String,
            row['didChoose'] == null ? null : (row['didChoose'] as int) != 0,
            row['hiddenAssets'] == null
                ? null
                : (row['hiddenAssets'] as int) != 0,
            row['index'] as int));
  }

  @override
  Future<MHWallet> finDidChooseWallet() async {
    return _queryAdapter.query('SELECT * FROM wallet_table WHERE didChoose = 1',
        mapper: (Map<String, dynamic> row) => MHWallet(
            row['walletID'] as String,
            row['walletAaddress'] as String,
            row['pin'] as String,
            row['pinTip'] as String,
            row['createTime'] as String,
            row['updateTime'] as String,
            row['isChoose'] == null ? null : (row['isChoose'] as int) != 0,
            row['prvKey'] as String,
            row['pubKey'] as String,
            row['chainType'] as int,
            row['isWegwit'] == null ? null : (row['isWegwit'] as int) != 0,
            row['leadType'] as int,
            row['originType'] as int,
            row['subPrvKey'] as String,
            row['subPubKey'] as String,
            row['masterPubKey'] as String,
            row['macUUID'] as String,
            row['descName'] as String,
            row['didChoose'] == null ? null : (row['didChoose'] as int) != 0,
            row['hiddenAssets'] == null
                ? null
                : (row['hiddenAssets'] as int) != 0,
            row['index'] as int));
  }

  @override
  Future<List<MHWallet>> findWalletsByChainType(int chainType) async {
    return _queryAdapter.queryList(
        'SELECT * FROM wallet_table WHERE chainType = ? ORDER BY "index"',
        arguments: <dynamic>[chainType],
        mapper: (Map<String, dynamic> row) => MHWallet(
            row['walletID'] as String,
            row['walletAaddress'] as String,
            row['pin'] as String,
            row['pinTip'] as String,
            row['createTime'] as String,
            row['updateTime'] as String,
            row['isChoose'] == null ? null : (row['isChoose'] as int) != 0,
            row['prvKey'] as String,
            row['pubKey'] as String,
            row['chainType'] as int,
            row['isWegwit'] == null ? null : (row['isWegwit'] as int) != 0,
            row['leadType'] as int,
            row['originType'] as int,
            row['subPrvKey'] as String,
            row['subPubKey'] as String,
            row['masterPubKey'] as String,
            row['macUUID'] as String,
            row['descName'] as String,
            row['didChoose'] == null ? null : (row['didChoose'] as int) != 0,
            row['hiddenAssets'] == null
                ? null
                : (row['hiddenAssets'] as int) != 0,
            row['index'] as int));
  }

  @override
  Future<List<MHWallet>> findWalletsByType(int originType) async {
    return _queryAdapter.queryList(
        'SELECT * FROM wallet_table WHERE originType = ? ORDER BY "index"',
        arguments: <dynamic>[originType],
        mapper: (Map<String, dynamic> row) => MHWallet(
            row['walletID'] as String,
            row['walletAaddress'] as String,
            row['pin'] as String,
            row['pinTip'] as String,
            row['createTime'] as String,
            row['updateTime'] as String,
            row['isChoose'] == null ? null : (row['isChoose'] as int) != 0,
            row['prvKey'] as String,
            row['pubKey'] as String,
            row['chainType'] as int,
            row['isWegwit'] == null ? null : (row['isWegwit'] as int) != 0,
            row['leadType'] as int,
            row['originType'] as int,
            row['subPrvKey'] as String,
            row['subPubKey'] as String,
            row['masterPubKey'] as String,
            row['macUUID'] as String,
            row['descName'] as String,
            row['didChoose'] == null ? null : (row['didChoose'] as int) != 0,
            row['hiddenAssets'] == null
                ? null
                : (row['hiddenAssets'] as int) != 0,
            row['index'] as int));
  }

  @override
  Future<List<MHWallet>> findWalletsByAddress(
      String walletAaddress, int chainType) async {
    return _queryAdapter.queryList(
        'SELECT * FROM wallet_table WHERE walletAaddress = ? and chainType = ?',
        arguments: <dynamic>[walletAaddress, chainType],
        mapper: (Map<String, dynamic> row) => MHWallet(
            row['walletID'] as String,
            row['walletAaddress'] as String,
            row['pin'] as String,
            row['pinTip'] as String,
            row['createTime'] as String,
            row['updateTime'] as String,
            row['isChoose'] == null ? null : (row['isChoose'] as int) != 0,
            row['prvKey'] as String,
            row['pubKey'] as String,
            row['chainType'] as int,
            row['isWegwit'] == null ? null : (row['isWegwit'] as int) != 0,
            row['leadType'] as int,
            row['originType'] as int,
            row['subPrvKey'] as String,
            row['subPubKey'] as String,
            row['masterPubKey'] as String,
            row['macUUID'] as String,
            row['descName'] as String,
            row['didChoose'] == null ? null : (row['didChoose'] as int) != 0,
            row['hiddenAssets'] == null
                ? null
                : (row['hiddenAssets'] as int) != 0,
            row['index'] as int));
  }

  @override
  Future<List<MHWallet>> findWalletsBySQL(String sql) async {
    return _queryAdapter.queryList(
        'SELECT * FROM wallet_table WHERE $sql ORDER BY "index"',
        // arguments: <dynamic>[sql],
        mapper: (Map<String, dynamic> row) => MHWallet(
            row['walletID'] as String,
            row['walletAaddress'] as String,
            row['pin'] as String,
            row['pinTip'] as String,
            row['createTime'] as String,
            row['updateTime'] as String,
            row['isChoose'] == null ? null : (row['isChoose'] as int) != 0,
            row['prvKey'] as String,
            row['pubKey'] as String,
            row['chainType'] as int,
            row['isWegwit'] == null ? null : (row['isWegwit'] as int) != 0,
            row['leadType'] as int,
            row['originType'] as int,
            row['subPrvKey'] as String,
            row['subPubKey'] as String,
            row['masterPubKey'] as String,
            row['macUUID'] as String,
            row['descName'] as String,
            row['didChoose'] == null ? null : (row['didChoose'] as int) != 0,
            row['hiddenAssets'] == null
                ? null
                : (row['hiddenAssets'] as int) != 0,
            row['index'] as int));
  }

  @override
  Future<List<MHWallet>> findAllWallets() async {
    return _queryAdapter.queryList(
        'SELECT * FROM wallet_table ORDER BY "index"',
        mapper: (Map<String, dynamic> row) => MHWallet(
            row['walletID'] as String,
            row['walletAaddress'] as String,
            row['pin'] as String,
            row['pinTip'] as String,
            row['createTime'] as String,
            row['updateTime'] as String,
            row['isChoose'] == null ? null : (row['isChoose'] as int) != 0,
            row['prvKey'] as String,
            row['pubKey'] as String,
            row['chainType'] as int,
            row['isWegwit'] == null ? null : (row['isWegwit'] as int) != 0,
            row['leadType'] as int,
            row['originType'] as int,
            row['subPrvKey'] as String,
            row['subPubKey'] as String,
            row['masterPubKey'] as String,
            row['macUUID'] as String,
            row['descName'] as String,
            row['didChoose'] == null ? null : (row['didChoose'] as int) != 0,
            row['hiddenAssets'] == null
                ? null
                : (row['hiddenAssets'] as int) != 0,
            row['index'] as int));
  }

  @override
  Stream<List<MHWallet>> findAllWalletsAsStream() {
    return _queryAdapter.queryListStream('SELECT * FROM wallet_table',
        queryableName: 'wallet_table',
        isView: false,
        mapper: (Map<String, dynamic> row) => MHWallet(
            row['walletID'] as String,
            row['walletAaddress'] as String,
            row['pin'] as String,
            row['pinTip'] as String,
            row['createTime'] as String,
            row['updateTime'] as String,
            row['isChoose'] == null ? null : (row['isChoose'] as int) != 0,
            row['prvKey'] as String,
            row['pubKey'] as String,
            row['chainType'] as int,
            row['isWegwit'] == null ? null : (row['isWegwit'] as int) != 0,
            row['leadType'] as int,
            row['originType'] as int,
            row['subPrvKey'] as String,
            row['subPubKey'] as String,
            row['masterPubKey'] as String,
            row['macUUID'] as String,
            row['descName'] as String,
            row['didChoose'] == null ? null : (row['didChoose'] as int) != 0,
            row['hiddenAssets'] == null
                ? null
                : (row['hiddenAssets'] as int) != 0,
            row['index'] as int));
  }

  @override
  Future<void> insertWallet(MHWallet wallet) async {
    await _mHWalletInsertionAdapter.insert(wallet, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertWallets(List<MHWallet> wallet) async {
    await _mHWalletInsertionAdapter.insertList(
        wallet, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateWallet(MHWallet wallet) async {
    await _mHWalletUpdateAdapter.update(wallet, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateWallets(List<MHWallet> wallet) async {
    await _mHWalletUpdateAdapter.updateList(wallet, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteWallet(MHWallet wallet) async {
    await _mHWalletDeletionAdapter.delete(wallet);
  }

  @override
  Future<void> deleteWallets(List<MHWallet> wallet) async {
    await _mHWalletDeletionAdapter.deleteList(wallet);
  }
}

class _$UserModelDao extends UserModelDao {
  _$UserModelDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _userModelInsertionAdapter = InsertionAdapter(
            database,
            'userid_table',
            (UserModel item) => <String, dynamic>{
                  'walletName': item.walletName,
                  'pwd': item.pwd,
                  'tip': item.tip,
                  'masterPubKey': item.masterPubKey,
                  'memos': item.memos,
                  'leadType': item.leadType,
                  'mOriginType': item.mOriginType
                }),
        _userModelUpdateAdapter = UpdateAdapter(
            database,
            'userid_table',
            ['masterPubKey'],
            (UserModel item) => <String, dynamic>{
                  'walletName': item.walletName,
                  'pwd': item.pwd,
                  'tip': item.tip,
                  'masterPubKey': item.masterPubKey,
                  'memos': item.memos,
                  'leadType': item.leadType,
                  'mOriginType': item.mOriginType
                }),
        _userModelDeletionAdapter = DeletionAdapter(
            database,
            'userid_table',
            ['masterPubKey'],
            (UserModel item) => <String, dynamic>{
                  'walletName': item.walletName,
                  'pwd': item.pwd,
                  'tip': item.tip,
                  'masterPubKey': item.masterPubKey,
                  'memos': item.memos,
                  'leadType': item.leadType,
                  'mOriginType': item.mOriginType
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<UserModel> _userModelInsertionAdapter;

  final UpdateAdapter<UserModel> _userModelUpdateAdapter;

  final DeletionAdapter<UserModel> _userModelDeletionAdapter;

  @override
  Future<UserModel> findUsersByMasterPubKey(String masterPubKey) async {
    return _queryAdapter.query(
        'SELECT * FROM userid_table WHERE masterPubKey = ?',
        arguments: <dynamic>[masterPubKey],
        mapper: (Map<String, dynamic> row) => UserModel(
            row['walletName'] as String,
            row['pwd'] as String,
            row['tip'] as String,
            row['masterPubKey'] as String,
            row['memos'] as String,
            row['leadType'] as int,
            row['mOriginType'] as int));
  }

  @override
  Future<UserModel> findUsersByOriginType(int mOriginType) async {
    return _queryAdapter.query(
        'SELECT * FROM userid_table WHERE mOriginType = ?',
        arguments: <dynamic>[mOriginType],
        mapper: (Map<String, dynamic> row) => UserModel(
            row['walletName'] as String,
            row['pwd'] as String,
            row['tip'] as String,
            row['masterPubKey'] as String,
            row['memos'] as String,
            row['leadType'] as int,
            row['mOriginType'] as int));
  }

  @override
  Future<List<UserModel>> findAllUsers() async {
    return _queryAdapter.queryList('SELECT * FROM userid_table',
        mapper: (Map<String, dynamic> row) => UserModel(
            row['walletName'] as String,
            row['pwd'] as String,
            row['tip'] as String,
            row['masterPubKey'] as String,
            row['memos'] as String,
            row['leadType'] as int,
            row['mOriginType'] as int));
  }

  @override
  Future<void> insertWallet(UserModel user) async {
    await _userModelInsertionAdapter.insert(user, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertWallets(List<UserModel> users) async {
    await _userModelInsertionAdapter.insertList(
        users, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateWallet(UserModel user) async {
    await _userModelUpdateAdapter.update(user, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateWallets(List<UserModel> users) async {
    await _userModelUpdateAdapter.updateList(users, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteWallet(UserModel user) async {
    await _userModelDeletionAdapter.delete(user);
  }

  @override
  Future<void> deleteWallets(List<UserModel> users) async {
    await _userModelDeletionAdapter.deleteList(users);
  }
}

class _$CurrencyAssetDao extends CurrencyAssetDao {
  _$CurrencyAssetDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _currencyAssetModelInsertionAdapter = InsertionAdapter(
            database,
            'currencyAsset_table',
            (CurrencyAssetModel item) => <String, dynamic>{
                  'chainType': item.chainType,
                  'coinType': item.coinType,
                  'token': item.token,
                  'decimal': item.decimal,
                  'balance': item.balance,
                  'cnyprice': item.cnyprice,
                  'usdprice': item.usdprice,
                  'cnyassets': item.cnyassets,
                  'usdassets': item.usdassets,
                  'tokenContract': item.tokenContract
                }),
        _currencyAssetModelUpdateAdapter = UpdateAdapter(
            database,
            'currencyAsset_table',
            ['coinType', 'token'],
            (CurrencyAssetModel item) => <String, dynamic>{
                  'chainType': item.chainType,
                  'coinType': item.coinType,
                  'token': item.token,
                  'decimal': item.decimal,
                  'balance': item.balance,
                  'cnyprice': item.cnyprice,
                  'usdprice': item.usdprice,
                  'cnyassets': item.cnyassets,
                  'usdassets': item.usdassets,
                  'tokenContract': item.tokenContract
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<CurrencyAssetModel>
      _currencyAssetModelInsertionAdapter;

  final UpdateAdapter<CurrencyAssetModel> _currencyAssetModelUpdateAdapter;

  @override
  Future<List<CurrencyAssetModel>> findAllCurrencyAssets() async {
    return _queryAdapter.queryList('SELECT * FROM currencyAsset_table',
        mapper: (Map<String, dynamic> row) => CurrencyAssetModel(
            row['chainType'] as int,
            row['coinType'] as String,
            row['token'] as String,
            row['decimal'] as String,
            row['balance'] as String,
            row['cnyprice'] as String,
            row['usdprice'] as String,
            row['cnyassets'] as String,
            row['usdassets'] as String,
            row['tokenContract'] as String));
  }

  @override
  Future<List<CurrencyAssetModel>> findAllChainCurrency(int chainType) async {
    return _queryAdapter.queryList(
        'SELECT * FROM currencyAsset_table WHERE chainType = ?',
        arguments: <dynamic>[chainType],
        mapper: (Map<String, dynamic> row) => CurrencyAssetModel(
            row['chainType'] as int,
            row['coinType'] as String,
            row['token'] as String,
            row['decimal'] as String,
            row['balance'] as String,
            row['cnyprice'] as String,
            row['usdprice'] as String,
            row['cnyassets'] as String,
            row['usdassets'] as String,
            row['tokenContract'] as String));
  }

  @override
  Future<List<CurrencyAssetModel>> findCurrencyInfo(
      String coinType, String token) async {
    return _queryAdapter.queryList(
        'SELECT * FROM currencyAsset_table WHERE coinType = ? and token = ?',
        arguments: <dynamic>[coinType, token],
        mapper: (Map<String, dynamic> row) => CurrencyAssetModel(
            row['chainType'] as int,
            row['coinType'] as String,
            row['token'] as String,
            row['decimal'] as String,
            row['balance'] as String,
            row['cnyprice'] as String,
            row['usdprice'] as String,
            row['cnyassets'] as String,
            row['usdassets'] as String,
            row['tokenContract'] as String));
  }

  @override
  Future<void> insertWallets(List<CurrencyAssetModel> currencys) async {
    await _currencyAssetModelInsertionAdapter.insertList(
        currencys, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateWallets(List<CurrencyAssetModel> currency) async {
    await _currencyAssetModelUpdateAdapter.updateList(
        currency, OnConflictStrategy.abort);
  }
}

class _$NodeDao extends NodeDao {
  _$NodeDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _nodeModelInsertionAdapter = InsertionAdapter(
            database,
            'nodes_table',
            (NodeModel item) => <String, dynamic>{
                  'content': item.content,
                  'chainType': item.chainType,
                  'isChoose':
                      item.isChoose == null ? null : (item.isChoose ? 1 : 0),
                  'isOrigin':
                      item.isOrigin == null ? null : (item.isOrigin ? 1 : 0),
                  'netType': item.netType
                }),
        _nodeModelUpdateAdapter = UpdateAdapter(
            database,
            'nodes_table',
            ['content', 'chainType'],
            (NodeModel item) => <String, dynamic>{
                  'content': item.content,
                  'chainType': item.chainType,
                  'isChoose':
                      item.isChoose == null ? null : (item.isChoose ? 1 : 0),
                  'isOrigin':
                      item.isOrigin == null ? null : (item.isOrigin ? 1 : 0),
                  'netType': item.netType
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<NodeModel> _nodeModelInsertionAdapter;

  final UpdateAdapter<NodeModel> _nodeModelUpdateAdapter;

  @override
  Future<List<NodeModel>> queryNodeByIsChoose(bool isChoose) async {
    return _queryAdapter.queryList(
        'SELECT * FROM nodes_table WHERE isChoose = ?',
        arguments: <dynamic>[isChoose == null ? null : (isChoose ? 1 : 0)],
        mapper: (Map<String, dynamic> row) => NodeModel(
            row['content'] as String,
            row['chainType'] as int,
            row['isChoose'] == null ? null : (row['isChoose'] as int) != 0,
            row['isOrigin'] == null ? null : (row['isOrigin'] as int) != 0,
            row['netType'] as int));
  }

  @override
  Future<List<NodeModel>> queryNodeByChainType(int chainType) async {
    return _queryAdapter.queryList(
        'SELECT * FROM nodes_table WHERE chainType = ?',
        arguments: <dynamic>[chainType],
        mapper: (Map<String, dynamic> row) => NodeModel(
            row['content'] as String,
            row['chainType'] as int,
            row['isChoose'] == null ? null : (row['isChoose'] as int) != 0,
            row['isOrigin'] == null ? null : (row['isOrigin'] as int) != 0,
            row['netType'] as int));
  }

  @override
  Future<List<NodeModel>> queryNodeByContent(String content) async {
    return _queryAdapter.queryList(
        'SELECT * FROM nodes_table WHERE content = ?',
        arguments: <dynamic>[content],
        mapper: (Map<String, dynamic> row) => NodeModel(
            row['content'] as String,
            row['chainType'] as int,
            row['isChoose'] == null ? null : (row['isChoose'] as int) != 0,
            row['isOrigin'] == null ? null : (row['isOrigin'] as int) != 0,
            row['netType'] as int));
  }

  @override
  Future<List<NodeModel>> queryNodeByIsOriginAndChainType(
      bool isOrigin, int chainType) async {
    return _queryAdapter.queryList(
        'SELECT * FROM nodes_table WHERE isOrigin = ? And chainType = ?',
        arguments: <dynamic>[
          isOrigin == null ? null : (isOrigin ? 1 : 0),
          chainType
        ],
        mapper: (Map<String, dynamic> row) => NodeModel(
            row['content'] as String,
            row['chainType'] as int,
            row['isChoose'] == null ? null : (row['isChoose'] as int) != 0,
            row['isOrigin'] == null ? null : (row['isOrigin'] as int) != 0,
            row['netType'] as int));
  }

  @override
  Future<List<NodeModel>> queryNodeByContentAndChainType(
      String content, int chainType) async {
    return _queryAdapter.queryList(
        'SELECT * FROM nodes_table WHERE content = ? And chainType = ?',
        arguments: <dynamic>[content, chainType],
        mapper: (Map<String, dynamic> row) => NodeModel(
            row['content'] as String,
            row['chainType'] as int,
            row['isChoose'] == null ? null : (row['isChoose'] as int) != 0,
            row['isOrigin'] == null ? null : (row['isOrigin'] as int) != 0,
            row['netType'] as int));
  }

  @override
  Future<void> insertNodeDatas(List<NodeModel> list) async {
    await _nodeModelInsertionAdapter.insertList(list, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertNodeData(NodeModel model) async {
    await _nodeModelInsertionAdapter.insert(model, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateNode(NodeModel model) async {
    await _nodeModelUpdateAdapter.update(model, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateNodes(List<NodeModel> models) async {
    await _nodeModelUpdateAdapter.updateList(models, OnConflictStrategy.abort);
  }
}
