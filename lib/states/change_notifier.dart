import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
import 'package:flutter_coinid/net/chain_services.dart';
import 'package:flutter_coinid/net/wallet_services.dart';
import 'package:flutter_coinid/public.dart';
import 'package:flutter_coinid/utils/sharedPrefer.dart';
import 'package:provider/provider.dart';

class CurrentChooseWalletState with ChangeNotifier {
  MHWallet _mhWallet;
  Map<String, List> _collectionTokens = {}; //我的资产
  Map<String, List> _allTokens = {}; //我的所有资产
  Map<String, Map> _mainToken = {}; //主币的价格和数量
  Map<String, String> _totalAssets = {}; //资产数额
  MCurrencyType _currencyType;

  void loadWallet() async {
    _mhWallet = await MHWallet.findChooseWallet();
    int type = await getAmountValue();
    _currencyType = type == 0 ? MCurrencyType.CNY : MCurrencyType.USD;
    notifyListeners();
    requestAssets();
  }

  void updateChoose(MHWallet wallet) {
    LogUtil.v("updateChoose");
    _mhWallet = wallet;
    MHWallet.updateChoose(wallet);
    notifyListeners();
    requestAssets();
  }

  void updateWalletDescName(String newName) {
    _mhWallet.descName = newName;
    MHWallet.updateWallet(_mhWallet);
    notifyListeners();
  }

  void updateWalletAssetsState(bool newState) {
    _mhWallet.hiddenAssets = newState;
    MHWallet.updateWallet(_mhWallet);
    notifyListeners();
  }

  void updateCurrencyType(MCurrencyType mCurrencyType) {
    _currencyType = mCurrencyType;
    updateAmountValue(mCurrencyType == MCurrencyType.CNY);
    _findMyCollectionTokens();
    _findCurrencyTokenPriceAndTokenCount();
  }

  void requestAssets() {
    if (_mhWallet == null) return;
    final String walletAaddress = _mhWallet.walletAaddress;
    final String symbol = _mhWallet.symbol.toUpperCase();
    Map cacheValue = _mainToken[walletAaddress];
    if (cacheValue == null) {
      _mainToken[walletAaddress] = {};
    }
    ChainServices.requestAssets(
      chainType: symbol,
      from: walletAaddress,
      contract: null,
      token: null,
      block: (result, code) {
        if (code == 200) {
          Map value = result as Map;
          _mainToken[walletAaddress] = value;
          notifyListeners();
          _findMyCollectionTokens();
          _findCurrencyTokenPriceAndTokenCount();
        }
      },
    );
    _findMyCollectionTokens();
  }

  void _findMyCollectionTokens() async {
    if (_mhWallet == null) return;

    final String convert = currencyTypeStr;
    final String walletAaddress = _mhWallet.walletAaddress;
    final String symbol = _mhWallet.symbol.toUpperCase();
    final int chainType = _mhWallet.chainType;
    List cacheValue = _collectionTokens[walletAaddress];
    Map<String, dynamic> cacheMap = Map();
    cacheMap["id"] = "";
    cacheMap["contract"] = "";
    cacheMap["token"] = symbol;
    cacheMap["coinType"] = symbol;
    cacheMap["iconPath"] = null;
    cacheMap["state"] = "";
    if (chainType == MCoinType.MCoinType_BTC.index) {
      cacheMap["decimals"] = "8";
    } else if (chainType == MCoinType.MCoinType_ETH.index) {
      cacheMap["decimals"] = "18";
    } else if (chainType == MCoinType.MCoinType_DOT.index) {
      cacheMap["decimals"] = "10";
    }
    if (convert == "CNY") {
      cacheMap["price"] = _mainToken[walletAaddress]["p"];
    } else {
      cacheMap["price"] = _mainToken[walletAaddress]["up"];
    }
    cacheMap["balance"] = _mainToken[walletAaddress]["c"].toString();
    if (cacheValue == null) {
      _collectionTokens[walletAaddress] = [cacheMap];
      notifyListeners();
    }
    WalletServices.requestMyCollectionTokens(walletAaddress, convert, symbol,
        (result, code) {
      if (result == null || result.length == 0) {
        result = [];
        result.add(cacheMap);
      } else {
        if (convert == "CNY") {
          result[0]["price"] = _mainToken[walletAaddress]["p"];
        } else {
          result[0]["price"] = _mainToken[walletAaddress]["up"];
        }
        result[0]["balance"] = _mainToken[walletAaddress]["c"].toString();
      }
      _collectionTokens[walletAaddress] = result;
      notifyListeners();
    });
  }

  void _findCurrencyTokenPriceAndTokenCount() async {
    if (_mhWallet == null) return;
    final String convert = currencyTypeStr;
    final String walletAaddress = _mhWallet.walletAaddress;
    final String symbol = _mhWallet.symbol.toUpperCase();
    WalletServices.requestGetCurrencyTokenPriceAndTokenCount(
        walletAaddress, convert, symbol, (result, code) {
      Map<String, dynamic> map = Map();
      if (result == null || result.length == 0) {
        //没有数据返回，自己补上主币数据
        result = [];
        map["symbol"] = symbol;
        map["code"] = "";
        if (convert == "CNY") {
          map["price"] = _mainToken[walletAaddress]["p"].toString();
        } else {
          map["price"] = _mainToken[walletAaddress]["up"].toString();
        }
        map["balance"] = _mainToken[walletAaddress]["c"].toString();
        result.add(map);
      } else {
        map = result[0];
        if (convert == "CNY") {
          map["price"] = _mainToken[walletAaddress]["p"].toString();
        } else {
          map["price"] = _mainToken[walletAaddress]["up"].toString();
        }
        map["balance"] = _mainToken[walletAaddress]["c"].toString();
      }
      _allTokens[walletAaddress] = result;
      double sumAssets = 0;
      int i = 0;
      for (i = 0; i < allTokens.length; i++) {
        Map<String, dynamic> map = allTokens[i];
        if (StringUtil.isNotEmpty(map["balance"]) &&
            StringUtil.isNotEmpty(map["price"])) {
          sumAssets +=
              double.parse(map["balance"]) * double.parse(map["price"]);
        }
      }
      String total = StringUtil.dataFormat(sumAssets, 2);
      _totalAssets[walletAaddress] = "≈$currencySymbolStr" + total;
      notifyListeners();
    });
  }

  MHWallet get currentWallet => _mhWallet;
  List get collectionTokens => _mhWallet != null
      ? _collectionTokens[_mhWallet.walletAaddress] ??= []
      : [];
  List get allTokens =>
      _mhWallet != null ? _allTokens[_mhWallet.walletAaddress] ??= [] : [];
  String get totalAssets => _mhWallet != null
      ? _mhWallet.hiddenAssets == true
          ? "******"
          : _totalAssets[_mhWallet.walletAaddress] ??=
              "≈${currencySymbolStr}0.00"
      : "≈{$currencySymbolStr}0.00";
  String get currencyTypeStr =>
      _currencyType == MCurrencyType.CNY ? "CNY" : "USD";
  String get currencySymbolStr =>
      _currencyType == MCurrencyType.CNY ? "￥" : "\$";
  MCurrencyType get currencyType => _currencyType;
}

class TransListState with ChangeNotifier {
  void initData() {
    notifyListeners();
  }
}
