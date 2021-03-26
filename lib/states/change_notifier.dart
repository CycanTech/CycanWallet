import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_coinid/models/tokens/collection_tokens.dart';
import 'package:flutter_coinid/models/transrecord/trans_record.dart';
import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
import 'package:flutter_coinid/net/chain_services.dart';
import 'package:flutter_coinid/net/wallet_services.dart';
import 'package:flutter_coinid/public.dart';
import 'package:flutter_coinid/utils/sharedPrefer.dart';
import 'package:provider/provider.dart';

class CurrentChooseWalletState with ChangeNotifier {
  MHWallet _mhWallet;
  Map<String, List<MCollectionTokens>> _collectionTokens = {}; //我的资产
  Map<String, List> _allTokens = {}; //我的所有资产
  Map<String, Map> _mainToken = {}; //主币的价格和数量
  Map<String, String> _totalAssets = {}; //资产数额
  MCurrencyType _currencyType;
  MCollectionTokens _chooseTokens;

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

  void updateTokenChoose(int index) {
    if (index < collectionTokens.length && index != -1) {
      _chooseTokens = collectionTokens[index];
    } else {
      _chooseTokens = null;
    }
    LogUtil.v(
        "updateTokenChoose index $index " + _chooseTokens?.toJson().toString());
  }

  void requestAssets() {
    if (_mhWallet == null) return;
    final String walletAaddress = _mhWallet.walletAaddress;
    final String walletID = _mhWallet.walletID;
    final String symbol = _mhWallet.symbol.toUpperCase();
    final int chainType = _mhWallet.chainType;
    final String convert = currencyTypeStr;
    Map cachePrice = _mainToken[walletID];
    if (cachePrice == null) {
      _mainToken[walletID] = {};
    }
    List cacheValue = _collectionTokens[walletID];
    if (cacheValue == null) {
      num mainCNYPrice =
          num.tryParse(_mainToken[walletID]["p"].toString());
      num mainUSDPrice =
          num.tryParse(_mainToken[walletID]["up"].toString());
      num mainBalance =
          num.tryParse(_mainToken[walletID]["c"].toString());
      MCollectionTokens cacheMap = MCollectionTokens();
      cacheMap.token = symbol;
      cacheMap.coinType = symbol;
      cacheMap.decimals = Constant.getChainDecimals(chainType);
      if (convert == "CNY") {
        cacheMap.price = mainCNYPrice;
      } else {
        cacheMap.price = mainUSDPrice;
      }
      cacheMap.balance = mainBalance;
      _collectionTokens[walletID] = [cacheMap];
      notifyListeners();
    }
    ChainServices.requestAssets(
      chainType: symbol,
      from: walletAaddress,
      contract: null,
      token: null,
      block: (result, code) {
        if (code == 200) {
          Map value = result as Map;
          _mainToken[walletID] = value;
          notifyListeners();
          _findMyCollectionTokens();
          _findCurrencyTokenPriceAndTokenCount();
        }
      },
    );
  }

  void _findMyCollectionTokens() async {
    if (_mhWallet == null) return;

    final String convert = currencyTypeStr;
    final String walletAaddress = _mhWallet.walletAaddress;
    final String walletID = _mhWallet.walletID;
    final String symbol = _mhWallet.symbol.toUpperCase();
    final int chainType = _mhWallet.chainType;
    num mainCNYPrice = num.tryParse(_mainToken[walletID]["p"].toString());
    num mainUSDPrice =
        num.tryParse(_mainToken[walletID]["up"].toString());
    num mainBalance = num.tryParse(_mainToken[walletID]["c"].toString());
    WalletServices.requestMyCollectionTokens(walletAaddress, convert, symbol,
        (result, code) {
      MCollectionTokens tokens;
      if (result == null || result.length == 0) {
        result = [];
        result = _collectionTokens[walletID];
        tokens = result[0] as MCollectionTokens;
      } else {
        tokens = result[0] as MCollectionTokens;
      }
      if (convert == "CNY") {
        tokens.price = mainCNYPrice;
      } else {
        tokens.price = mainUSDPrice;
      }
      tokens.balance = mainBalance;
      tokens.decimals = Constant.getChainDecimals(chainType);
      result[0] = tokens;
      _collectionTokens[walletID] = result;
      notifyListeners();
    });
  }

  void _findCurrencyTokenPriceAndTokenCount() async {
    if (_mhWallet == null) return;
    final String convert = currencyTypeStr;
    final String walletAaddress = _mhWallet.walletAaddress;
    final String walletID = _mhWallet.walletID;
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
          map["price"] = _mainToken[walletID]["p"].toString();
        } else {
          map["price"] = _mainToken[walletID]["up"].toString();
        }
        map["balance"] = _mainToken[walletID]["c"].toString();
        result.add(map);
      } else {
        map = result[0];
        if (convert == "CNY") {
          map["price"] = _mainToken[walletID]["p"].toString();
        } else {
          map["price"] = _mainToken[walletID]["up"].toString();
        }
        map["balance"] = _mainToken[walletID]["c"].toString();
      }
      _allTokens[walletID] = result;
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
      _totalAssets[walletID] = "≈$currencySymbolStr" + total;
      notifyListeners();
    });
  }

  MHWallet get currentWallet => _mhWallet;
  List<MCollectionTokens> get collectionTokens => _mhWallet != null
      ? _collectionTokens[_mhWallet.walletID] ??= []
      : [];
  List get allTokens =>
      _mhWallet != null ? _allTokens[_mhWallet.walletID] ??= [] : [];
  String get totalAssets => _mhWallet != null
      ? _mhWallet.hiddenAssets == true
          ? "******"
          : _totalAssets[_mhWallet.walletID] ??=
              "≈${currencySymbolStr}0.00"
      : "≈{$currencySymbolStr}0.00";
  String get currencyTypeStr =>
      _currencyType == MCurrencyType.CNY ? "CNY" : "USD";
  String get currencySymbolStr =>
      _currencyType == MCurrencyType.CNY ? "￥" : "\$";
  MCurrencyType get currencyType => _currencyType;
  MCollectionTokens get chooseTokens => _chooseTokens;
}

class TransListState with ChangeNotifier {
  List<MHTransRecordModel> _pendingDatas;
  List<MHTransRecordModel> _transDats;

  void initData() {
    notifyListeners();
  }

  List<MHTransRecordModel> get datas {
    return _transDats;
  }
}
