import 'package:floor/floor.dart';
import 'package:flutter_coinid/db/database.dart';
import 'package:flutter_coinid/models/assets/currency_list.dart';
import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
import 'package:flutter_coinid/net/chain_services.dart';
import 'package:flutter_coinid/net/wallet_services.dart';
import 'package:flutter_coinid/utils/sharedPrefer.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../public.dart';
import '../base_model.dart';

part 'currency_asset.g.dart';

const String tableName = "currencyAsset_table";

@Entity(tableName: tableName, primaryKeys: ["coinType", "token"])
@JsonSerializable()
class CurrencyAssetModel extends BaseModel {
  int chainType;
  String coinType;
  String token;
  String decimal;
  String balance;
  String cnyprice;
  String usdprice;
  String cnyassets;
  String usdassets;
  String tokenContract;

  CurrencyAssetModel(
    this.chainType,
    this.coinType,
    this.token,
    this.decimal,
    this.balance,
    this.cnyprice,
    this.usdprice,
    this.cnyassets,
    this.usdassets,
    this.tokenContract,
  );
  static int lastUpdateTime = 0;

  factory CurrencyAssetModel.fromJson(Map<String, dynamic> json) =>
      _$CurrencyAssetModelFromJson(json);
  Map<String, dynamic> toJson() => _$CurrencyAssetModelToJson(this);

  static Future<List<CurrencyAssetModel>> findCurrencyInfo(
      String coinType, String token) async {
    try {
      FlutterDatabase database = await BaseModel.getDataBae();
      return database.assetDao.findCurrencyInfo(coinType, token);
    } catch (e) {
      LogUtil.v("失败" + e.toString());
      return [];
    }
  }

  static Future<List<CurrencyAssetModel>> findAllChainCurrency(
      int chainType) async {
    try {
      FlutterDatabase database = await BaseModel.getDataBae();
      return database.assetDao.findAllChainCurrency(chainType);
    } catch (e) {
      LogUtil.v("失败" + e.toString());
      return [];
    }
  }

  static Future<List<CurrencyAssetModel>> findAllCurrencyAssets() async {
    try {
      FlutterDatabase database = await BaseModel.getDataBae();
      return database.assetDao.findAllCurrencyAssets();
    } catch (e) {
      LogUtil.v("失败" + e.toString());
      return [];
    }
  }

  static Future<bool> insertWallets(List<CurrencyAssetModel> currencys) async {
    try {
      FlutterDatabase database = await BaseModel.getDataBae();
      database.assetDao.insertWallets(currencys);
      return true;
    } catch (e) {
      LogUtil.v("失败" + e.toString());
      return false;
    }
  }

  static Future<bool> updateWallets(List<CurrencyAssetModel> currency) async {
    try {
      FlutterDatabase database = await BaseModel.getDataBae();
      database.assetDao.updateWallets(currency);
      return true;
    } catch (e) {
      LogUtil.v("失败" + e.toString());
      return false;
    }
  }

  static Future configCurrencyTokens() async {
    List<CurrencyAssetModel> models = [];
    for (Map<String, dynamic> jsonObj in currency_List) {
      String coinType = jsonObj["coinType"];
      String token = jsonObj["token"];
      List<CurrencyAssetModel> datas =
          await CurrencyAssetModel.findCurrencyInfo(coinType, token);
      if (datas.length > 0) {
        continue;
      }

      CurrencyAssetModel model = CurrencyAssetModel.fromJson(jsonObj);
      models.add(model);
    }
    if (models.length > 0) {
      CurrencyAssetModel.insertWallets(models);
    }
  }

  ///获得总和
  static Future<String> fetchAllChainAssetsValue({bool isCny = true}) async {
    List<CurrencyAssetModel> models =
        await CurrencyAssetModel.findAllCurrencyAssets();
    double sum = 0;
    for (CurrencyAssetModel item in models) {
      String assets = isCny ? item.cnyassets : item.usdassets;
      assets ??= "0";
      double value = double.tryParse(assets);
      sum += value;
    }
    return sum.toStringAsFixed(2);
  }

  ///获得各个链数据占比
  static Future<Map<String, Map<String, dynamic>>> fetchChainAssetsPercents(
      {bool isCny = true}) async {
    List<CurrencyAssetModel> models =
        await CurrencyAssetModel.findAllCurrencyAssets();
    String keyassets = "assets";
    String keypercent = "percent";

    Map<String, Map<String, dynamic>> params = Map();
    double sum = 0.0;
    for (CurrencyAssetModel model in models) {
      String coinType = model.coinType;
      String assets = isCny == true ? model.cnyassets : model.usdassets;
      assets ??= "0";
      Map coinParams = params[coinType] ??= Map();
      double originValue = coinParams["$keyassets"] ??= 0.0;
      originValue += double.tryParse(assets);
      coinParams["$keyassets"] = originValue;
      coinParams["$keypercent"] = 0.0;
      params[coinType] = coinParams;
      sum += double.tryParse(assets);
    }
    params.forEach((key, newCoin) {
      newCoin.forEach((newkey, value) {
        if (newkey.contains("$keyassets") == true) {
          double percent = value / (sum == 0 ? 1.0 : sum);
          newCoin.update(("$keypercent"), (value) => (percent));
        }
      });
    });
    LogUtil.v("fetchChainAssetsPercents " + params.toString());
    LogUtil.v("sum " + sum.toString());
    return params;
  }

  static Future _syncCurrentAssets() async {
    List ethWallets =
        await MHWallet.findWalletsByChainType(MCoinType.MCoinType_ETH.index);
    List vnsWallets =
        await MHWallet.findWalletsByChainType(MCoinType.MCoinType_VNS.index);
    List eosWallets =
        await MHWallet.findWalletsByChainType(MCoinType.MCoinType_EOS.index);
  }

  ///更新资产
  static Future<Map> updateAllTokenAssets() async {
    //先更新有资产的列表
    //取出本地数据列表
    if (DateUtil.getNowDateMs() - lastUpdateTime < 3600) {
      LogUtil.v("当前更新过快");
      return null;
    }
    lastUpdateTime = DateUtil.getNowDateMs();
    List<CurrencyAssetModel> currencys =
        await CurrencyAssetModel.findAllCurrencyAssets();
    int currencyLen = 0;
    double cnysum = 0;
    double usdsum = 0;
    for (CurrencyAssetModel currency in currencys) {
      String coinType = currency.coinType;
      String contract = currency.tokenContract;
      String decimal = currency.decimal;
      String token = currency.token;
      int chinType = currency.chainType;
      String id = "coinType$coinType token|$token";
      List<MHWallet> wallets = await MHWallet.findWalletsByChainType(chinType);
      double currencyBalance = 0;
      int walletsLen = 0;
      for (MHWallet wallet in wallets) {
        String from = wallet.walletAaddress;
        var result = await ChainServices.requestAssets(
            chainType: coinType,
            from: from,
            contract: contract,
            tokenDecimal: int.tryParse(decimal),
            token: token,
            neePrice: false,
            block: null);
        LogUtil.v("requestAssets $coinType  $result");
        if (result != null) {
          currencyBalance += double.tryParse(result["c"]);
        }
        walletsLen += 1;
        if (walletsLen == wallets.length) {
          currencyLen += 1;
          var priceresult = await WalletServices.requestTokenPrice(token, null);
          String cnyprice = priceresult["p"];
          String usdprice = priceresult["up"];
          currency.cnyprice = cnyprice;
          currency.usdprice = usdprice;
          currency.balance = currencyBalance.toString();
          currency.cnyassets =
              (double.tryParse(cnyprice) * currencyBalance).toString();
          currency.usdassets =
              (double.tryParse(usdprice) * currencyBalance).toString();
          cnysum += (double.tryParse(currency.cnyassets));
          usdsum += double.tryParse(currency.usdassets);
          LogUtil.v(
              "coinType $coinType token $token 余额是 $currencyBalance 单价是 $priceresult  currLen $currencyLen");
          CurrencyAssetModel.updateWallets([currency]);
        }
        LogUtil.v("currencyLen $currencyLen " + currencys.length.toString());
        if (currencyLen == currencys.length) {
          LogUtil.v("全部资产计算完毕");
          saveOriginMoney(cnysum.toString(), usdsum.toString());
          return {
            "cnysum": cnysum.toStringAsFixed(2),
            "usdsum": usdsum.toStringAsFixed(2)
          };
        }
      }
    }
  }
}

@dao
abstract class CurrencyAssetDao {
  @Query('SELECT * FROM ' + tableName)
  Future<List<CurrencyAssetModel>> findAllCurrencyAssets();

  @Query('SELECT * FROM ' + tableName + ' WHERE chainType = :chainType')
  Future<List<CurrencyAssetModel>> findAllChainCurrency(int chainType);

  @Query('SELECT * FROM ' +
      tableName +
      ' WHERE coinType = :coinType and token = :token')
  Future<List<CurrencyAssetModel>> findCurrencyInfo(
      String coinType, String token);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertWallets(List<CurrencyAssetModel> currencys);

  @update
  Future<void> updateWallets(List<CurrencyAssetModel> currency);
}
