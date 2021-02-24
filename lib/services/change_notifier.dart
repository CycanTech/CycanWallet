import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
import 'package:flutter_coinid/public.dart';
import 'package:flutter_coinid/utils/sharedPrefer.dart';

// class CreateWallet with ChangeNotifier {
//   String _walletName = "";
//   String _password = "";
//   String _passwordTip = "";
//   String _content = "";
//   CreateWallet(this._walletName, this._password, this._passwordTip);

// }

class CurrentChooseWalletState with ChangeNotifier {
  MHWallet _mhWallet;

  CurrentChooseWalletState(this._mhWallet);

  void changeChooseWallet(MHWallet wallet) {
    _mhWallet = wallet;
    MHWallet.updateChoose(wallet);
    notifyListeners();
  }

  MHWallet get currentWallet => _mhWallet;
}

class CurrencyTypeState with ChangeNotifier {
  MCurrencyType _currencyType;

  CurrencyTypeState(this._currencyType);

  void changeCurrencyType(MCurrencyType mCurrencyType) {
    _currencyType = mCurrencyType;
    updateAmountValue(mCurrencyType == MCurrencyType.CNY);
    notifyListeners();
  }

  String get currencyTypeStr =>
      _currencyType == MCurrencyType.CNY ? "CNY" : "USD";

  MCurrencyType get currencyType => _currencyType;
}
