import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_coinid/channel/channel_native.dart';
import 'package:flutter_coinid/channel/channel_scan.dart';
import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
import 'package:flutter_coinid/models/wallet/sign/ethsignparams.dart';
import 'package:flutter_coinid/models/wallet/sign/mdotsign.dart';
import 'package:flutter_coinid/net/chain_services.dart';
import 'package:flutter_coinid/pages/main/payment_sheet_page.dart';
import 'package:flutter_coinid/utils/json_util.dart';
import 'package:flutter_coinid/utils/sharedPrefer.dart';
import '../../public.dart';

const btcDefaultSatLen = "500";

class TransParams {
  final dynamic rooDic;
  final String amount;
  final String to;
  final String from;
  final String fee;
  final int coinType;

  TransParams(
      this.rooDic, this.amount, this.to, this.from, this.fee, this.coinType);
}

class PaymentPage extends StatefulWidget {
  PaymentPage({Key key, this.params}) : super(key: key);
  Map params = Map();

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  TextEditingController _addressEC = TextEditingController();
  TextEditingController _valueEC = TextEditingController();
  TextEditingController _remarkEC = TextEditingController();
  TextEditingController _customFeeEC = TextEditingController();
  String remarkText = ""; //备注
  EdgeInsets padding = EdgeInsets.only(left: 26, right: 26, top: 0);
  EdgeInsets contentPadding = EdgeInsets.only(left: 0, right: 0);
  MHWallet _wallet;
  double _balanceNum = 0;
  dynamic chaininfo;
  int _feeBean = 20; //gas or sat
  double _feeValue = 0.0;
  bool _isCustomFee = false; //是否自定义矿工费
  String token = "";
  String chainStr = "";
  String decimals;
  String contract;
  String transToken;
  double tokenPrice = 0;
  double sliderMin = 0;
  double sliderMax = 100;
  String amountConvert = "￥";

  @override
  void initState() {
    super.initState();
    if (widget.params != null) {
      token = widget.params["token"][0];
      decimals = widget.params["decimals"][0];
      contract = widget.params["contract"][0];
      if (widget.params.containsKey("to")) {
        _addressEC.text = widget.params["to"][0];
      }
    }
    _findChooseWallet();
  }

  ///获取钱包数据
  _findChooseWallet() async {
    _wallet = await MHWallet.findChooseWallet();
    _initData(() {});
  }

  _initData(VoidCallback back) async {
    assert(_wallet != null, "钱包数据为空");
    if (_wallet == null) return;
    int chainType = _wallet.chainType;
    if (chainType == MCoinType.MCoinType_ETH.index) {
      sliderMax = 150;
      sliderMin = 1;
    } else {
      sliderMax = 135;
      sliderMin = 6;
    }
    chainStr = Constant.getChainSymbol(chainType);
    String from = _wallet?.walletAaddress;
    int m, n = 1;
    int amountType = await getAmountValue();
    amountConvert = amountType == 0 ? "￥" : "\$";

    ChainServices.requestAssets(
        chainType: chainType,
        from: from,
        contract: contract,
        token: null,
        tokenDecimal: int.tryParse(decimals),
        block: (result, code) {
          if (code == 200 && result is Map && mounted) {
            String balance = result["c"] as String;
            String price = amountType == 0
                ? result["p"] as String
                : result["up"] as String;
            LogUtil.v("requestAssets" + result.toString());
            setState(() {
              tokenPrice = double.tryParse(price);
              _balanceNum = double.tryParse(balance);
            });
          }
        });
    ChainServices.requestChainInfo(
        chainType: chainType,
        from: from,
        amount: "",
        m: m,
        n: n,
        contract: contract,
        block: (result, code) {
          String offsetValue = btcDefaultSatLen;
          int newBean = _feeBean;
          if (code == 200 && result != null) {
            chaininfo = result;
            if (chainType == MCoinType.MCoinType_ETH.index ||
                chainType == MCoinType.MCoinType_VNS.index) {
              String gasPrice = chaininfo["p"] ??= "0";
              newBean = int.tryParse(gasPrice) ~/ pow(10, 9);
              int minv = max(sliderMin.toInt(), newBean);
              newBean = min(sliderMax.toInt(), minv);
              offsetValue = chaininfo["g"] ??= "0";
            }
          }
          String value = MHWallet.configFeeValue(
              cointype: chainType,
              beanValue: newBean.toString(),
              offsetValue: offsetValue);
          if (mounted) {
            setState(() {
              _feeValue = double.tryParse(value);
              _feeBean = newBean;
            });
          }

          if (back != null) {
            back();
          }
        });
  }

  _startScanAddress() async {
    FocusScope.of(context).requestFocus(FocusNode());
    String result = await ChannelScan.scan();
    if (result.isValid() && mounted) {
      setState(() {
        _addressEC.text = result;
      });
    }
  }

  _remarkStringChange(String value) {
    setState(() {
      remarkText = value;
    });
  }

  _customfeeChange(String value) {
    if (_wallet.chainType == MCoinType.MCoinType_ETH.index ||
        _wallet.chainType == MCoinType.MCoinType_VNS.index) {
      if (chaininfo == null) {
        return;
      }
      if (value.isValid() == false) {
        value = "0";
      }
      int fee =
          _feeValue * pow(10, 9) ~/ int.tryParse((chaininfo["g"] as String));
      int minv = max(sliderMin.toInt(), fee);
      int a = min(sliderMax.toInt(), minv);
      setState(() {
        _feeValue = double.tryParse(value);
        _feeBean = a;
      });
      LogUtil.v("_customfeeChange $value   a $_feeBean");
    }
  }

  _sliderChange(double value) {
    int chainType = _wallet.chainType;
    String offsetValue = btcDefaultSatLen;
    if (chaininfo == null) {
      return;
    }
    if (chainType == MCoinType.MCoinType_ETH.index ||
        chainType == MCoinType.MCoinType_VNS.index) {
      offsetValue = chaininfo["g"] ??= "0";
    }
    LogUtil.v("slider change $value");
    _feeBean = value.toInt();
    String newfee = MHWallet.configFeeValue(
        cointype: chainType,
        beanValue: _feeBean.toString(),
        offsetValue: offsetValue.toString());
    setState(() {
      _feeValue = double.tryParse(newfee);
    });
  }

  bool isToken() {
    return token?.toLowerCase() == _wallet.symbol.toLowerCase() ? false : true;
  }

  void _updateFeeWidget() {
    setState(() {
      _isCustomFee = !_isCustomFee;
    });
  }

  void _popupInfo() async {
    //合法性判断
    //余额判断
    //地址判断
    //蓝牙是否连接
    //是否给自己转账
    //余额加矿工费
    //点击全部时余额判断关掉
    String to = _addressEC.text.trim();
    String from = _wallet.walletAaddress;
    String value = _valueEC.text.trim();
    String gas = "";
    int coinType = _wallet.chainType;
    String coinTypeString = Constant.getChainSymbol(coinType);
    int originType = _wallet.originType;
    bool isValid = false;
    bool isWegwit = _wallet.isWegwit;
    if (to.length == 0) {
      HWToast.showText(text: "input_paymentaddress".local());
      return;
    }
    try {
      isValid = await ChannelNative.checkAddressValid(coinType, to);
    } catch (e) {
      LogUtil.v("校验失败" + e.toString());
    }
    if (isValid == false) {
      HWToast.showText(text: "input_addressinvalid".local());
      return;
    }
    if (value.length == 0) {
      HWToast.showText(text: "input_paymentvalue".local());
      return;
    }
    if (double.parse(value) == 0) {
      HWToast.showText(text: "input_paymentvaluezero".local());
      return;
    }
    //判断余额是否充足
    if (double.tryParse(value) > _balanceNum) {
      HWToast.showText(text: "payment_valueshouldlessbal".local());
      return;
    }

    if (from == to) {
      HWToast.showText(text: "input_paymentself".local());
      return;
    }
    //判断代币decimal
    if (isToken() == true &&
        (coinType != MCoinType.MCoinType_EOS.index ||
            coinType != MCoinType.MCoinType_GPS.index)) {
      if (decimals.isValid() == false) {
        HWToast.showText(text: "payment_decimalinvalid".local());
        return;
      }
    }

    if (chaininfo == null) {
      //重新获取数据
      _initData(() {
        if (chaininfo == null) {
          HWToast.showText(text: "request_state_failere".local());
          return;
        }
        _popupInfo();
      });
      return;
    }

    if (originType == MOriginType.MOriginType_Colds.index) {
      //冷端判断是否连接
    }
    if (coinType == MCoinType.MCoinType_EOS.index ||
        coinType == MCoinType.MCoinType_GPS.index) {
      String permission = "active";
      if (_wallet.prvKey.isValid() == false) {
        permission = "owner";
      }
      // String a = "1";
      // balance = balance.replaceAll(" ", "").replaceAll("VNS", "");
      // int decimal = balance.length - balance.lastIndexOf(".") -1 ;
      // print("decimal " + decimal.toString());
      // String newA = double.tryParse(a).toStringAsFixed(decimal);

      // List rootDic = MHWallet.convertEOSParamsJson(
      //     coinType: coinType,
      //     to: to,
      //     from: from,
      //     quantity: null,
      //     permission: permission);

      // _showSheetView(amount: value, fee: null, rootDic: rootDic);
    } else if (coinType == MCoinType.MCoinType_DOT.index) {
      _showSheetView(amount: value, fee: "", rootDic: null);
    } else {
      String feeValue = "0";
      if (coinType == MCoinType.MCoinType_ETH.index ||
          coinType == MCoinType.MCoinType_BSC.index) {
        feeValue = MHWallet.configFeeValue(
            cointype: coinType,
            beanValue: _feeBean.toString(),
            offsetValue: chaininfo["g"] as String);
        if (double.parse(feeValue) == 0) {
          HWToast.showText(text: "payment_highfee".local());
          return;
        }
        if (double.parse(feeValue) + double.tryParse(value) >
            _balanceNum.toDouble()) {
          HWToast.showText(text: "payment_valueshouldlessbal".local());
          return;
        }

        _showSheetView(amount: value, fee: feeValue, rootDic: null);
      } else {
        feeValue = MHWallet.configFeeValue(
          cointype: coinType,
          beanValue: _feeBean.toString(),
          offsetValue: btcDefaultSatLen,
        );
        List utxos = chaininfo as List;
        if (utxos == null || utxos.length == 0) {
          HWToast.showText(text: "payment_valueshouldlessbal".local());
          return;
        }
        if (double.parse(feeValue) == 0) {
          HWToast.showText(text: "payment_highfee".local());
          return;
        }
        if (double.parse(feeValue) + double.tryParse(value) >
            _balanceNum.toDouble()) {
          HWToast.showText(text: "payment_valueshouldlessbal".local());
          return;
        }
        Map rootDic = await MHWallet.convertUTXOWithSpent(
            coinType: coinType,
            utxoList: utxos,
            to: to,
            from: from,
            segwit: isWegwit == true ? 1 : 0,
            transAmount: value,
            feeValue: feeValue,
            newFeeBack: (newfee) {
              feeValue = newfee;
              setState(() {
                _feeValue = (double.tryParse(newfee)) / pow(10, 8);
              });
            });
        if (rootDic == null) {
          HWToast.showText(text: "payment_lessfee".local());
          return;
        }
        _showSheetView(
            amount: value, fee: _feeValue.toString(), rootDic: rootDic);
      }
    }
  }

  ///重新计算后的转账金额，手续费，筛选后的utxo
  _showSheetView({String amount, String fee, dynamic rootDic}) async {
    String from = _wallet.walletAaddress;
    String to = _addressEC.text.trim();
    String remark = _remarkEC.text.trim();
    //弹出sheet
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        elevation: 10,
        isDismissible: true,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        builder: (context) {
          return SafeArea(
            child: PaymentSheet(
              datas: PaymentSheet.getTransStyleList(
                  from: from, amount: amount, to: to, remark: remark, fee: fee),
              nextAction: () {
                _unLockWallet(amount: amount, rootDic: rootDic, fee: fee);
              },
            ),
          );
        });
  }

  ///解锁
  _unLockWallet({String amount, dynamic rootDic, fee}) async {
    String to = _addressEC.text.trim();
    String from = _wallet.walletAaddress;
    int chainType = _wallet.chainType;
    //弹出解锁
    _wallet?.showLockPinDialog(
        context: context,
        ok: (value) {
          TransParams params = TransParams(
            rootDic,
            amount,
            to,
            from,
            fee,
            chainType,
          );
          _startSign(params, value);
        },
        cancle: () {},
        wrong: () {
          HWToast.showText(text: "payment_pwdwrong".local());
        });
  }

  ///开始签名
  _startSign(TransParams params, String pin) async {
    String signValue;

    if (params.coinType == MCoinType.MCoinType_ETH.index ||
        params.coinType == MCoinType.MCoinType_BSC.index) {
      int decimal = 18;
      MSignType signType = MSignType.MSignType_Main;
      if (isToken() == true) {
        signType = MSignType.MSignType_Token;
        decimal = int.tryParse(decimals);
      }
      ETHSignParams ethsign = ETHSignParams(chaininfo["n"], _feeBean.toString(),
          chaininfo["g"], null, chaininfo["v"], decimal, contract, signType);
      signValue = await _wallet.sign(
        to: params.to,
        pin: pin,
        value: params.amount,
        ethSignParams: ethsign,
      );
    } else if (params.coinType == MCoinType.MCoinType_DOT.index) {
      // chaininfo
      int blockNum = chaininfo["blockNumber"] as int;
      String blockHash = chaininfo["blockHash"];
      int eraPeriod = 64;
      String address = params.to;
      String value = (double.tryParse(params.amount) * pow(10, 15)).toString();
      String tip = "10";
      String genesisHash = chaininfo["genesisHash"];
      int nonce = chaininfo["nonce"] as int;
      int txVersion = chaininfo["txVersion"] as int;
      int specVersion = chaininfo["specVersion"] as int;
      DotSignParams dotsign = DotSignParams(
          "polkadot",
          "1",
          blockNum,
          blockHash,
          eraPeriod,
          address,
          value,
          tip,
          genesisHash,
          nonce,
          txVersion,
          specVersion);

      signValue = await _wallet.sign(
          to: params.to,
          pin: pin,
          value: params.amount,
          dotSignParams: dotsign);
    } else {
      signValue = await _wallet.sign(
          to: params.to,
          pin: pin,
          value: params.amount,
          jsonTran: JsonUtil.encodeObj(params.rooDic));
    }
    LogUtil.v("签名数据 $signValue");
    if (signValue.isValid()) {
      ChainServices.pushData(_wallet.chainType, signValue, (result, code) {
        if (code == 200) {
          HWToast.showText(text: "payment_transsuccess".local());
          Future.delayed(Duration(seconds: 3))
              .then((value) => {Routers.goBackWithParams(context, {})});
        } else {
          HWToast.showText(text: "payment_transfailere".local() + result);
        }
      });
    } else {
      HWToast.showText(text: "payment_transfailere".local());
    }
  }

  Widget _getFeeWidget() {
    Widget _getAction() {
      int coinType = _wallet?.chainType;
      if (coinType == MCoinType.MCoinType_ETH.index ||
          coinType == MCoinType.MCoinType_VNS.index) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _updateFeeWidget(),
          child: Container(
            child: Text(
              _isCustomFee == false
                  ? "payment_customfee".local()
                  : "payment_defaultfee".local(),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Color(0xff4A4A4A),
                fontWeight: FontWeight.w500,
                fontSize: OffsetWidget.setSp(14),
              ),
            ),
          ),
        );
      } else {
        return OffsetWidget.hGap(0);
      }
    }

    Widget _getFeeWidget() {
      return _isCustomFee == true
          ? CustomTextField(
              controller: _customFeeEC,
              contentPadding: contentPadding,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              fillColor: Colors.white,
              onChange: (v) => {_customfeeChange(v)},
              style: TextStyle(
                color: Color(0xFF000000),
                fontSize: OffsetWidget.setSp(14),
                fontWeight: FontWeight.w500,
              ),
              decoration: CustomTextField.getUnderLineDecoration(),
            )
          : Container(
              child: Row(
                children: [
                  Text(
                    "payment_slow".local(),
                    style: TextStyle(
                        color: Color(0xFF4A4A4A),
                        fontWeight: FontWeight.w500,
                        fontSize: OffsetWidget.setSp(14)),
                  ),
                  OffsetWidget.hGap(6),
                  Expanded(
                    child: SliderTheme(
                      //自定义风格
                      data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Color(0xff1308FE),
                          inactiveTrackColor: Color(0xffCFCFCF),
                          thumbColor: Color(0xFFFFFFFF),
                          overlayColor: Color(0xFF979797),
                          overlayShape: RoundSliderOverlayShape(
                            overlayRadius: 8,
                          ),
                          thumbShape: RoundSliderThumbShape(
                            disabledThumbRadius: 8,
                            enabledThumbRadius: 8,
                          ),
                          trackHeight: 3),
                      child: Slider(
                          value: _feeBean.toDouble(),
                          onChanged: (v) {
                            _sliderChange(v);
                          },
                          max: sliderMax,
                          min: sliderMin),
                    ),
                  ),
                  OffsetWidget.hGap(6),
                  Text(
                    "payment_high".local(),
                    style: TextStyle(
                        color: Color(0xFF4A4A4A),
                        fontWeight: FontWeight.w500,
                        fontSize: OffsetWidget.setSp(14)),
                  ),
                ],
              ),
            );
    }

    return Container(
      padding: EdgeInsets.only(
          left: padding.left,
          right: padding.right,
          top: OffsetWidget.setSc(30)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: OffsetWidget.setSc(200),
                ),
                child: Row(
                  children: [
                    Text(
                      "payment_fee".local() + ": $_feeValue",
                      style: TextStyle(
                        color: Color(0xFF4A4A4A),
                        fontWeight: FontWeight.w500,
                        fontSize: OffsetWidget.setSp(14),
                      ),
                    ),
                    OffsetWidget.hGap(3),
                    Expanded(
                      child: Text(
                        "≈$amountConvert" +
                            (_feeValue * tokenPrice).toStringAsFixed(2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF9B9B9B),
                          fontWeight: FontWeight.w400,
                          fontSize: OffsetWidget.setSp(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _getAction(),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            color: Color(Constant.TextFileld_FocuseCOlor),
            height: 1,
          ),
          OffsetWidget.vGap(20),
          _getFeeWidget(),
          OffsetWidget.vGap(16),
          Text(
            "$_feeValue ${chainStr.toLowerCase() == "usdt" ? "BTC" : chainStr}",
            style: TextStyle(
              color: Color(0xFF4A4A4A),
              fontWeight: FontWeight.w500,
              fontSize: OffsetWidget.setSp(12),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
        title: Text(
          "trans_payment".local(),
          style: TextStyle(
            color: Color(0xFF000000),
            fontSize: OffsetWidget.setSp(18),
            fontWeight: FontWeight.w400,
          ),
        ),
        child: Column(
          children: [
            OffsetWidget.vGap(10),
            CustomTextField(
                controller: _addressEC,
                contentPadding: contentPadding,
                padding: padding,
                fillColor: Colors.white,
                style: TextStyle(
                  color: Color(0xFF000000),
                  fontSize: OffsetWidget.setSp(14),
                  fontWeight: FontWeight.w500,
                ),
                decoration: CustomTextField.getUnderLineDecoration(
                  hintText: "payment_address".local(),
                  hintStyle: TextStyle(
                      color: Color(0xFF4A4A4A),
                      fontWeight: FontWeight.w400,
                      fontSize: OffsetWidget.setSp(14)),
                  suffixIcon: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => {
                      _startScanAddress(),
                    },
                    child: LoadAssetsImage(
                      Constant.ASSETS_IMG + "icon/home_scan.png",
                      width: OffsetWidget.setSc(34),
                      height: OffsetWidget.setSc(34),
                      fit: BoxFit.contain,
                    ),
                  ),
                )),
            CustomTextField(
              controller: _valueEC,
              contentPadding: contentPadding,
              padding: padding,
              fillColor: Colors.white,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                CustomTextField.decimalInputFormatter(int.tryParse(decimals))
              ],
              style: TextStyle(
                color: Color(0xFF000000),
                fontSize: OffsetWidget.setSp(14),
                fontWeight: FontWeight.w500,
              ),
              decoration: CustomTextField.getUnderLineDecoration(
                  hintText: "payment_value".local(),
                  hintStyle: TextStyle(
                      color: Color(0xFF4A4A4A),
                      fontWeight: FontWeight.w400,
                      fontSize: OffsetWidget.setSp(14)),
                  suffixIconConstraints:
                      BoxConstraints(maxWidth: OffsetWidget.setSc(110)),
                  suffixIcon: Text(
                    "payment_balance".local() + ":\n$_balanceNum",
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    strutStyle: StrutStyle(),
                    style: TextStyle(
                        color: Color(0xFF1308FE),
                        fontWeight: FontWeight.w500,
                        fontSize: OffsetWidget.setSp(14)),
                  )),
            ),
            CustomTextField(
              controller: _remarkEC,
              contentPadding: contentPadding,
              padding: padding,
              fillColor: Colors.white,
              onChange: (value) => {
                _remarkStringChange(value),
              },
              maxLines: 1,
              maxLength: 256,
              style: TextStyle(
                color: Color(0xFF000000),
                fontSize: OffsetWidget.setSp(14),
                fontWeight: FontWeight.w500,
              ),
              decoration: CustomTextField.getUnderLineDecoration(
                hintText: "payment_remark".local(),
                hintStyle: TextStyle(
                    color: Color(0xFF4A4A4A),
                    fontWeight: FontWeight.w400,
                    fontSize: OffsetWidget.setSp(14)),
                suffixIcon: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      remarkText.length.toString() + "/256",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          color: Color(0xFF4A4A4A),
                          fontWeight: FontWeight.w400,
                          fontSize: OffsetWidget.setSp(14)),
                    ),
                    // GestureDetector(
                    //   onTap: () => {},
                    //   child: LoadAssetsImage(
                    //     Constant.ASSETS_IMG + "icon/home_scan.png",
                    //     width: OffsetWidget.setSc(34),
                    //     height: OffsetWidget.setSc(34),
                    //     fit: BoxFit.contain,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            _getFeeWidget(),
            OffsetWidget.vGap(170),
            GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _popupInfo,
                child: Container(
                  margin: EdgeInsets.only(left: 30, right: 30),
                  height: OffsetWidget.setSc(50),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(OffsetWidget.setSc(50)),
                      color: Color(0xFF1308FE)),
                  child: Text(
                    "comfirm_trans_payment".local(),
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: OffsetWidget.setSp(16),
                        color: Colors.white),
                  ),
                )),
          ],
        ));
  }
}
