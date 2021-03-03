import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
import 'package:flutter_coinid/net/chain_services.dart';
import 'package:flutter_coinid/net/wallet_services.dart';
import 'package:flutter_coinid/public.dart';
import 'package:flutter_coinid/utils/sharedPrefer.dart';
import 'package:provider/provider.dart';

// class CreateWallet with ChangeNotifier {
//   String _walletName = "";
//   String _password = "";
//   String _passwordTip = "";
//   String _content = "";
//   CreateWallet(this._walletName, this._password, this._passwordTip);

// }

class CurrentChooseWalletState with ChangeNotifier {
  MHWallet _mhWallet;
  List _collectionTokens = []; //我的资产
  List _allTokens = []; //我的所有资产
  Map _mainToken = {}; //主币的价格和数量

  void loadWallet() async {
    _mhWallet = await MHWallet.findChooseWallet();
    notifyListeners();
    findMainTokenCount();
  }

  void updateChoose(MHWallet wallet) {
    LogUtil.v("updateChoose");
    _mhWallet = wallet;
    MHWallet.updateChoose(wallet);
    notifyListeners();
    findMainTokenCount();
  }

  void updateWalletDescName(String newName) {
    _mhWallet.descName = newName;
    MHWallet.updateWallet(_mhWallet);
    notifyListeners();
  }

  void findMainTokenCount() {
    if (_mhWallet == null) return;
    final String walletAaddress = _mhWallet.walletAaddress;
    final String symbol = _mhWallet.symbol.toUpperCase();
    ChainServices.requestAssets(
      chainType: symbol,
      from: walletAaddress,
      contract: null,
      token: null,
      block: (result, code) {
        if (code == 200) {
          _mainToken = result as Map;
          notifyListeners();
        }
        _findMyCollectionTokens();
        _findCurrencyTokenPriceAndTokenCount();
      },
    );
  }

  void _findMyCollectionTokens() async {
    if (_mhWallet == null) return;

    final String convert = (await getAmountValue()) == 0 ? "CNY" : "USD";
    final String walletAaddress = _mhWallet.walletAaddress;
    final String symbol = _mhWallet.symbol.toUpperCase();
    final int chainType = _mhWallet.chainType;

    WalletServices.requestMyCollectionTokens(walletAaddress, convert, symbol,
        (result, code) {
      Map<String, dynamic> map = Map();
      if (result == null || result.length == 0) {
        result = [];
        map["id"] = "";
        map["contract"] = "";
        map["token"] = symbol;
        map["coinType"] = symbol;
        map["iconPath"] = "";
        map["state"] = "";
        if (chainType == MCoinType.MCoinType_BTC.index) {
          map["decimals"] = "8";
        } else if (chainType == MCoinType.MCoinType_ETH.index) {
          map["decimals"] = "18";
        } else if (chainType == MCoinType.MCoinType_DOT.index) {
          map["decimals"] = "10";
        }
        if (convert == "CNY") {
          map["price"] = _mainToken["p"];
        } else {
          map["price"] = _mainToken["up"];
        }
        map["balance"] = _mainToken["c"].toString();
        result.add(map);
      } else {
        map = result[0];
        if (convert == "CNY") {
          map["price"] = _mainToken["p"];
        } else {
          map["price"] = _mainToken["up"];
        }
        map["balance"] = _mainToken["c"].toString();
      }
      _collectionTokens = result;
      notifyListeners();
    });
  }

  void _findCurrencyTokenPriceAndTokenCount() async {
    if (_mhWallet == null) return;
    final String convert = (await getAmountValue()) == 0 ? "CNY" : "USD";

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
          map["price"] = _mainToken["p"].toString();
        } else {
          map["price"] = _mainToken["up"].toString();
        }
        map["balance"] = _mainToken["c"].toString();
        result.add(map);
      } else {
        map = result[0];
        if (convert == "CNY") {
          map["price"] = _mainToken["p"].toString();
        } else {
          map["price"] = _mainToken["up"].toString();
        }
        map["balance"] = _mainToken["c"].toString();
      }
      _allTokens = result;
      notifyListeners();
    });
  }

  MHWallet get currentWallet => _mhWallet;
  List get collectionTokens => _collectionTokens;
  List get allTokens => _allTokens;
}

class SystemSettings with ChangeNotifier {
  MCurrencyType _currencyType;
  MLanguage _mLanguage;

  void loadSystemSettings() async {
    int type = await getAmountValue();
    int language = await getLanguageValue();
    _currencyType = type == 0 ? MCurrencyType.CNY : MCurrencyType.USD;
    _mLanguage = language == 0 ? MLanguage.zh_hans : MLanguage.en;
    notifyListeners();
  }

  void changeCurrencyType(MCurrencyType mCurrencyType) {
    _currencyType = mCurrencyType;
    updateAmountValue(mCurrencyType == MCurrencyType.CNY);
    notifyListeners();
  }

  void changeLanguageType(MLanguage language) {
    _mLanguage = language;
    updateLanguageValue(language.index);
    notifyListeners();
  }

  String get currencyTypeStr =>
      _currencyType == MCurrencyType.CNY ? "CNY" : "USD";

  String get currencySymbolStr =>
      _currencyType == MCurrencyType.CNY ? "￥" : "\$";

  MCurrencyType get currencyType => _currencyType;
}
