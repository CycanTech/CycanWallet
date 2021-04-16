import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_coinid/channel/channel_native.dart';
import 'package:flutter_coinid/channel/channel_scan.dart';
import 'package:flutter_coinid/models/tokens/collection_tokens.dart';
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
  final dynamic transParams;
  final String amount;
  final String to;
  final String from;
  final String fee;
  TransParams(this.transParams, this.amount, this.to, this.from, this.fee);
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
  EdgeInsets padding = EdgeInsets.only(
      left: OffsetWidget.setSc(26), right: OffsetWidget.setSc(26), top: 0);
  EdgeInsets contentPadding = EdgeInsets.only(left: 0, right: 0);
  double _balanceNum = 0;
  dynamic chaininfo;
  int _feeOffset = 20; //gas or sat
  double _feeValue = 0.0;
  bool _isCustomFee = false; //是否自定义矿工费
  double tokenPrice = 0;
  double sliderMin = 0;
  double sliderMax = 100;
  MHWallet _wallet;
  @override
  void initState() {
    super.initState();
    if (widget.params != null) {
      if (widget.params.containsKey("to")) {
        _addressEC.text = widget.params["to"][0];
      }
    }
    _initData(() {});
  }

  _initData(VoidCallback back) async {
    _wallet = Provider.of<CurrentChooseWalletState>(context, listen: false)
        .currentWallet;
    MCollectionTokens tokens =
        Provider.of<CurrentChooseWalletState>(context, listen: false)
            .chooseTokens;
    MCurrencyType amountType =
        Provider.of<CurrentChooseWalletState>(context, listen: false)
            .currencyType;
    assert(_wallet != null, "钱包数据为空");
    if (_wallet == null) return;

    tokenPrice = tokens.price.toDouble();
    _balanceNum = tokens.balance.toDouble();
    int chainType = _wallet.chainType;
    String contract = tokens.contract;
    String token = tokens.token;
    int decimal = tokens.decimals;
    if (chainType == MCoinType.MCoinType_ETH.index ||
        chainType == MCoinType.MCoinType_BSC.index) {
      sliderMax = 150;
      sliderMin = 1;
    } else {
      sliderMax = 135;
      sliderMin = 6;
    }
    String from = _wallet?.walletAaddress;
    ChainServices.requestAssets(
        chainType: chainType,
        from: from,
        contract: contract,
        token: token,
        tokenDecimal: decimal,
        block: (result, code) {
          if (code == 200 && result is Map && mounted) {
            String balance = result["c"] as String;
            String price = amountType.index == 0
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
        m: 1,
        n: 1,
        contract: contract,
        block: (result, code) {
          String newBean = btcDefaultSatLen;
          int offset = _feeOffset;
          if (code == 200 && result != null) {
            chaininfo = result;
            if (chainType == MCoinType.MCoinType_ETH.index ||
                chainType == MCoinType.MCoinType_BSC.index) {
              String gasPrice = chaininfo["p"] ??= "0";
              int gasFee = int.tryParse(gasPrice) ~/ pow(10, 9);
              int minv = max(sliderMin.toInt(), gasFee);
              gasFee = min(sliderMax.toInt(), minv);
              offset = gasFee;
              newBean = chaininfo["g"] ??= "0";
            }
          }
          String value = MHWallet.configFeeValue(
              cointype: chainType,
              beanValue: newBean,
              offsetValue: offset.toString());
          if (mounted) {
            setState(() {
              _feeValue = double.tryParse(value);
              _feeOffset = offset;
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
    MHWallet _wallet =
        Provider.of<CurrentChooseWalletState>(context, listen: false)
            .currentWallet;
    if (_wallet.chainType == MCoinType.MCoinType_ETH.index ||
        _wallet.chainType == MCoinType.MCoinType_BSC.index) {
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
        _feeOffset = a;
      });
      LogUtil.v("_customfeeChange $value   a $_feeOffset");
    }
  }

  _sliderChange(double value) {
    MHWallet _wallet =
        Provider.of<CurrentChooseWalletState>(context, listen: false)
            .currentWallet;
    int chainType = _wallet?.chainType;
    String bean = btcDefaultSatLen;
    setState(() {
      _feeOffset = value.toInt();
    });
    LogUtil.v("chaininfo $chaininfo change $value");
    if (chainType == MCoinType.MCoinType_ETH.index ||
        chainType == MCoinType.MCoinType_BSC.index) {
      bean = chaininfo["g"] ??= "0";
    }
    LogUtil.v("slider change $value");
    String newfee = MHWallet.configFeeValue(
        cointype: chainType,
        beanValue: bean.toString(),
        offsetValue: _feeOffset.toString());
    setState(() {
      _feeValue = double.tryParse(newfee);
    });
  }

  void _updateFeeWidget() {
    setState(() {
      _isCustomFee = !_isCustomFee;
    });
  }

  void _popupInfo() async {
    MHWallet _wallet =
        Provider.of<CurrentChooseWalletState>(context, listen: false)
            .currentWallet;
    MCollectionTokens tokens =
        Provider.of<CurrentChooseWalletState>(context, listen: false)
            .chooseTokens;

    bool isToken = tokens.isToken;
    int decimals = tokens.decimals ??= 0;
    String contract = tokens.contract;
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
    if (isToken == true || decimals == 0) {
      HWToast.showText(text: "payment_decimalinvalid".local());
      return;
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
    if (coinType == MCoinType.MCoinType_DOT.index ||
        coinType == MCoinType.MCoinType_KSM.index) {
      int blockNum = chaininfo["blockNumber"] as int;
      String blockHash = chaininfo["blockHash"];
      int eraPeriod = 64;
      String transValue =
          (double.tryParse(value) * pow(10, 12)).toInt().toString();
      String tip = "10";
      String genesisHash = chaininfo["genesisHash"];
      int nonce = chaininfo["nonce"] as int;
      int txVersion = chaininfo["txVersion"] as int;
      int specVersion = chaininfo["specVersion"] as int;
      DotSignParams dotsign = DotSignParams(
          coinType == MCoinType.MCoinType_DOT.index ? 0 : 1,
          "1",
          blockNum,
          blockHash,
          eraPeriod,
          to,
          transValue,
          tip,
          genesisHash,
          nonce,
          txVersion,
          specVersion);
      _showSheetView(amount: value, fee: "", transParams: dotsign);
    } else {
      String feeValue = "0";
      if (coinType == MCoinType.MCoinType_ETH.index ||
          coinType == MCoinType.MCoinType_BSC.index) {
        feeValue = MHWallet.configFeeValue(
          cointype: coinType,
          beanValue: chaininfo["g"] as String,
          offsetValue: _feeOffset.toString(),
        );
        if (double.parse(feeValue) == 0) {
          HWToast.showText(text: "payment_highfee".local());
          return;
        }
        if (double.parse(feeValue) + double.tryParse(value) >
            _balanceNum.toDouble()) {
          HWToast.showText(text: "payment_valueshouldlessbal".local());
          return;
        }
        MSignType signType = MSignType.MSignType_Main;
        if (isToken == true) {
          signType = MSignType.MSignType_Token;
        }
        ETHSignParams ethsign = ETHSignParams(
            chaininfo["n"],
            _feeOffset.toString(),
            chaininfo["g"],
            null,
            chaininfo["v"],
            decimals,
            contract,
            signType);
        _showSheetView(amount: value, fee: feeValue, transParams: ethsign);
      } else {
        feeValue = MHWallet.configFeeValue(
          cointype: coinType,
          beanValue: btcDefaultSatLen,
          offsetValue: _feeOffset.toString(),
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
            amount: value, fee: _feeValue.toString(), transParams: rootDic);
      }
    }
  }

  ///重新计算后的转账金额，手续费，筛选后的utxo
  _showSheetView({String amount, String fee, dynamic transParams}) async {
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
                _unLockWallet(
                    amount: amount, transParams: transParams, fee: fee);
              },
            ),
          );
        });
  }

  ///解锁
  _unLockWallet({String amount, dynamic transParams, fee}) async {
    String to = _addressEC.text.trim();
    String from = _wallet.walletAaddress;
    //弹出解锁
    _wallet?.showLockPinDialog(
        context: context,
        ok: (value) {
          TransParams params = TransParams(
            transParams,
            amount,
            to,
            from,
            fee,
          );
          //构造参数
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
    if (_wallet.chainType == MCoinType.MCoinType_ETH.index ||
        _wallet.chainType == MCoinType.MCoinType_BSC.index) {
      signValue = await _wallet.sign(
        to: params.to,
        pin: pin,
        value: params.amount,
        ethSignParams: params.transParams as ETHSignParams,
      );
    } else if (_wallet.chainType == MCoinType.MCoinType_DOT.index) {
      signValue = await _wallet.sign(
          to: params.to,
          pin: pin,
          value: params.amount,
          dotSignParams: params.transParams as DotSignParams);
    } else {
      signValue = await _wallet.sign(
          to: params.to,
          pin: pin,
          value: params.amount,
          jsonTran: JsonUtil.encodeObj(params.transParams as Map));
    }
    LogUtil.v("签名数据 $signValue");
    HWToast.showLoading(
      clickClose: false,
    );
    if (signValue.isValid()) {
      ChainServices.pushData(_wallet.chainType, signValue, (result, code) {
        HWToast.hiddenAllToast();
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
    MCollectionTokens tokens = Provider.of<CurrentChooseWalletState>(
      context,
    ).chooseTokens;
    String amountType =
        Provider.of<CurrentChooseWalletState>(context, listen: false)
            .currencySymbolStr;
    String coinType = tokens?.coinType;
    coinType ??= "";
    // Widget _getAction() {
    //   int coinType = _wallet?.chainType;
    //   if (coinType == MCoinType.MCoinType_ETH.index ||
    //       coinType == MCoinType.MCoinType_VNS.index) {
    //     return GestureDetector(
    //       behavior: HitTestBehavior.opaque,
    //       onTap: () => _updateFeeWidget(),
    //       child: Container(
    //         child: Text(
    //           _isCustomFee == false
    //               ? "payment_customfee".local()
    //               : "payment_defaultfee".local(),
    //           textAlign: TextAlign.right,
    //           style: TextStyle(
    //             color: Color(0xff4A4A4A),
    //             fontWeight: FontWeight.w500,
    //             fontSize: OffsetWidget.setSp(14),
    //           ),
    //         ),
    //       ),
    //     );
    //   } else {
    //     return OffsetWidget.hGap(0);
    //   }
    // }

    Widget _getFeeWidget() {
      return
          //  _isCustomFee == true
          //     ? CustomTextField(
          //         controller: _customFeeEC,
          //         keyboardType: TextInputType.numberWithOptions(decimal: true),
          //         onChange: (v) => {_customfeeChange(v)},
          //         style: TextStyle(
          //           color: Color(0xFF000000),
          //           fontSize: OffsetWidget.setSp(14),
          //           fontWeight: FontWeight.w500,
          //         ),
          //         decoration: CustomTextField.getUnderLineDecoration(
          //           contentPadding: contentPadding,
          //         ),
          //       )
          //     :

          Row(
        children: [
          Text(
            "payment_slow".local(),
            style: TextStyle(
                color: Color(0xFF161D2D),
                fontWeight: FontWightHelper.regular,
                fontSize: OffsetWidget.setSp(16)),
          ),
          OffsetWidget.hGap(6),
          Expanded(
            child: SliderTheme(
              //自定义风格
              data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Color(0xFF586883),
                  inactiveTrackColor: Color(0xFFF6F8F9),
                  thumbColor: Color(0xFFFFFFFF),
                  overlayColor: Color(0xFFFFFFFF),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: 12,
                  ),
                  thumbShape: RoundSliderThumbShape(
                    disabledThumbRadius: 12,
                    enabledThumbRadius: 12,
                  ),
                  trackHeight: 6),
              child: Slider(
                  value: _feeOffset.toDouble(),
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
                color: Color(0xFF161D2D),
                fontWeight: FontWightHelper.regular,
                fontSize: OffsetWidget.setSp(16)),
          ),
        ],
      );
    }

    return Container(
      padding: EdgeInsets.only(top: OffsetWidget.setSc(33)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: OffsetWidget.setSc(300),
                ),
                // alignment: Alignment.center,
                // color: Colors.red,
                child: Row(
                  children: [
                    Text(
                      "payment_fee".local() + ": $_feeValue",
                      style: TextStyle(
                        color: Color(0xFF161D2D),
                        fontWeight: FontWightHelper.regular,
                        fontSize: OffsetWidget.setSp(15),
                      ),
                    ),
                    OffsetWidget.hGap(3),
                    Expanded(
                      child: Text(
                        "≈$amountType" +
                            (_feeValue * tokenPrice).toStringAsFixed(2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFFACBBCF),
                          fontWeight: FontWightHelper.regular,
                          fontSize: OffsetWidget.setSp(15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // _getAction(),
            ],
          ),
          OffsetWidget.vGap(15),
          _getFeeWidget(),
          OffsetWidget.vGap(8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "payment_slow".local(),
                style: TextStyle(
                    color: Colors.transparent,
                    fontWeight: FontWightHelper.regular,
                    fontSize: OffsetWidget.setSp(16)),
              ),
              OffsetWidget.hGap(20),
              Text(
                "$_feeValue $coinType",
                style: TextStyle(
                  color: Color(0xFF161D2D),
                  fontWeight: FontWightHelper.regular,
                  fontSize: OffsetWidget.setSp(15),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    MCollectionTokens tokens = Provider.of<CurrentChooseWalletState>(
      context,
    ).chooseTokens;
    int decimals = tokens?.decimals;
    String token = tokens?.token;
    token ??= "";
    return CustomPageView(
      title: CustomPageView.getDefaultTitle(
        titleStr: token + "trans_payment".local(),
      ),
      child: Container(
          padding: EdgeInsets.only(
              left: OffsetWidget.setSc(20),
              top: OffsetWidget.setSc(20),
              right: OffsetWidget.setSc(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: OffsetWidget.setSc(54),
                        minHeight: OffsetWidget.setSc(54),
                      ),
                      child: CustomTextField(
                        controller: _addressEC,
                        maxLines: 2,
                        style: TextStyle(
                          color: Color(0xFF161D2D),
                          fontSize: OffsetWidget.setSp(12),
                          fontWeight: FontWightHelper.regular,
                        ),
                        decoration: CustomTextField.getBorderLineDecoration(
                          borderColor: Color(0xFFEFF3F5),
                          borderRadius: 8,
                          hintText: "payment_address".local(),
                          fillColor: Color(0xFFF6F8F9),
                          contentPadding: EdgeInsets.only(
                            left: OffsetWidget.setSc(16),
                            top: OffsetWidget.setSc(10),
                            bottom: OffsetWidget.setSc(10),
                          ),
                          hintStyle: TextStyle(
                              color: Color(0xFFACBBCF),
                              fontWeight: FontWightHelper.regular,
                              fontSize: OffsetWidget.setSp(16)),
                          suffixIconConstraints: BoxConstraints(
                            maxWidth: OffsetWidget.setSc(97),
                            minWidth: OffsetWidget.setSc(97),
                          ),
                          suffixIcon: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () async {
                              ClipboardData data =
                                  await Clipboard.getData(Clipboard.kTextPlain);
                              if (data != null && data.text != null) {
                                _addressEC.text = data.text;
                              }
                            },
                            child: Center(
                              child: Container(
                                alignment: Alignment.center,
                                width: OffsetWidget.setSc(69),
                                height: OffsetWidget.setSc(32),
                                child: Text(
                                  "wallettrans_copys".local(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: OffsetWidget.setSp(16),
                                      fontWeight: FontWightHelper.regular),
                                ),
                                decoration: BoxDecoration(
                                    color: Color(0xFF586883),
                                    borderRadius: BorderRadius.circular(
                                        OffsetWidget.setSc(21.5))),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  OffsetWidget.hGap(14),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => {
                      _startScanAddress(),
                    },
                    child: LoadAssetsImage(
                      Constant.ASSETS_IMG + "icon/home_scan.png",
                      width: OffsetWidget.setSc(20),
                      height: OffsetWidget.setSc(20),
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              CustomTextField(
                padding: EdgeInsets.only(top: OffsetWidget.setSc(33)),
                controller: _valueEC,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  CustomTextField.decimalInputFormatter(decimals),
                ],
                style: TextStyle(
                  color: Color(0xFF282828),
                  fontSize: OffsetWidget.setSp(28),
                  fontWeight: FontWightHelper.semiBold,
                ),
                decoration: CustomTextField.getBorderLineDecoration(
                  borderColor: Color(0xFFACBBCF),
                  borderRadius: 8,
                  hintText: "payment_value".local(),
                  contentPadding: EdgeInsets.only(
                      left: OffsetWidget.setSc(22),
                      // right: OffsetWidget.setSc(16),
                      bottom: OffsetWidget.setSc(16),
                      top: OffsetWidget.setSc(16)),
                  hintStyle: TextStyle(
                      color: Color(0xFFACBBCF),
                      fontWeight: FontWightHelper.regular,
                      fontSize: OffsetWidget.setSp(18)),
                  suffixIconConstraints: BoxConstraints(
                      minWidth: OffsetWidget.setSc(72),
                      maxWidth: OffsetWidget.setSc(72)),
                  suffixIcon: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                          width: 1,
                          padding: EdgeInsets.only(
                              top: OffsetWidget.setSc(22),
                              bottom: OffsetWidget.setSc(19)),
                          color: Color(0xFF586883)),
                      Text(
                        token,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            color: Color(0xFF586883),
                            fontWeight: FontWightHelper.semiBold,
                            fontSize: OffsetWidget.setSp(18)),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                    top: OffsetWidget.setSc(16),
                    bottom: OffsetWidget.setSc(29)),
                alignment: Alignment.centerRight,
                child: Text(
                  "payment_balance".local() + "：$_balanceNum",
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      color: Color(0xFF161D2D),
                      fontWeight: FontWightHelper.regular,
                      fontSize: OffsetWidget.setSp(15)),
                ),
              ),
              Text(
                "payment_remark".local(),
                style: TextStyle(
                    color: Color(0xFF161D2D),
                    fontSize: OffsetWidget.setSp(15),
                    fontWeight: FontWightHelper.regular),
              ),
              Container(
                height: OffsetWidget.setSc(106),
                margin: EdgeInsets.only(top: OffsetWidget.setSc(13)),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Color(0xFFF6F8F9),
                  border: Border.all(
                    color: Color(0XFFEFF3F5),
                  ),
                ),
                child: CustomTextField(
                  controller: _remarkEC,
                  onChange: (value) => {
                    _remarkStringChange(value),
                  },
                  maxLines: 3,
                  maxLength: 256,
                  style: TextStyle(
                    color: Color(0xFF161D2D),
                    fontSize: OffsetWidget.setSp(16),
                    fontWeight: FontWightHelper.regular,
                  ),
                  decoration: CustomTextField.getBorderLineDecoration(
                    hintText: "wallet_transdesc".local(),
                    fillColor: Color(0xFFF6F8F9),
                    borderColor: Colors.transparent,
                    contentPadding: EdgeInsets.only(
                        left: OffsetWidget.setSc(25),
                        right: OffsetWidget.setSc(10),
                        top: OffsetWidget.setSc(18)),
                    helperStyle: TextStyle(
                      color: Color(0xFF171F24),
                      fontWeight: FontWightHelper.regular,
                      fontSize: OffsetWidget.setSp(12),
                    ),
                    hintStyle: TextStyle(
                        color: Color(0xFFACBBCF),
                        fontWeight: FontWightHelper.regular,
                        fontSize: OffsetWidget.setSp(18)),
                  ),
                ),
              ),
              _getFeeWidget(),
              OffsetWidget.vGap(84),
              GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _popupInfo,
                  child: Container(
                    margin: EdgeInsets.only(
                        left: OffsetWidget.setSc(22),
                        right: OffsetWidget.setSc(22)),
                    height: OffsetWidget.setSc(40),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(OffsetWidget.setSc(8)),
                        color: Color(0xFF586883)),
                    child: Text(
                      "comfirm_trans_payment".local(),
                      style: TextStyle(
                          fontWeight: FontWightHelper.semiBold,
                          fontSize: OffsetWidget.setSp(14),
                          color: Colors.white),
                    ),
                  )),
            ],
          )),
    );
  }
}
