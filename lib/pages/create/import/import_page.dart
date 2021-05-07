// import 'package:flutter_coinid/public.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_coinid/channel/channel_wallet.dart';
import 'package:flutter_coinid/constant/constant.dart';
import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
import 'package:flutter_coinid/public.dart';
import 'package:flutter_coinid/utils/json_util.dart';
import 'package:flutter_coinid/utils/offset.dart';
import 'package:flutter_coinid/widgets/custom_pageview.dart';
import 'package:flutter_coinid/widgets/custom_textfield.dart';
// import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:path_provider/path_provider.dart';

class ImportPage extends StatefulWidget {
  ImportPage({
    Key key,
    this.params,
  }) : super(key: key);
  Map params = Map();

  @override
  _ImportPageState createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  MLeadType mLeadType = MLeadType.MLeadType_Prvkey; //导入钱包类型
  MCoinType mcoinType = MCoinType.MCoinType_BTC; //链类型
  TextEditingController contentEC = TextEditingController();
  TextEditingController nameEC = TextEditingController();
  TextEditingController pwdEC = TextEditingController();
  TextEditingController pwdAganEC = TextEditingController();
  TextEditingController pwdTipEC = TextEditingController();
  EdgeInsets padding = EdgeInsets.only(
      left: OffsetWidget.setSc(20),
      right: OffsetWidget.setSc(20),
      top: OffsetWidget.setSc(20));
  EdgeInsets contentPadding = EdgeInsets.only(left: 0, right: 0);
  List<Tab> _myTabs = [];
  bool eyeisOpen = false;
  bool isAgreement = false;
  @override
  void initState() {
    super.initState();
    mcoinType = Constant.getCoinType(widget.params["coinType"][0]);
    LogUtil.v("initState coinType $mcoinType");
    _myTabs.add(Tab(text: 'import_prv'.local()));
    if (mcoinType != MCoinType.MCoinType_BTM) {
      _myTabs.add(Tab(text: 'KeyStore'));
    }
    _myTabs.add(Tab(text: 'import_memo'.local()));

    if (Constant.inProduction == false) {
      
    }
  }

  @override
  void dispose() {
    contentEC.dispose();
    nameEC.dispose();
    pwdEC.dispose();
    pwdAganEC.dispose();
    pwdTipEC.dispose();
    super.dispose();
  }

  void updateEyesState() {
    setState(() {
      eyeisOpen = !eyeisOpen;
    });
  }

  void updateAgreement() {
    setState(() {
      isAgreement = !isAgreement;
    });
  }

  void jumpToAgreement() async {
    LogUtil.v("jumpToAgreement");
    String path = await Constant.getAgreementPath();
    Routers.push(context, Routers.pdfScreen, params: {"path": path});
  }

  void _importWallets() async {
    // 0 content name password againtext tip
    // 1 content name password
    // 2 content memotype name password again tip
    //agreement
    String content = contentEC.text.trim();
    String walletName = nameEC.text.trim();
    String pwd = pwdEC.text.trim();
    String pwdagain = pwdAganEC.text.trim();
    String tip = pwdTipEC.text.trim();

    if (content.length == 0) {
      if (MLeadType.MLeadType_KeyStore == mLeadType) {
        HWToast.showText(text: "input_keystore".local());
      } else if (MLeadType.MLeadType_Prvkey == mLeadType) {
        HWToast.showText(text: "input_prvkey".local());
      } else {
        HWToast.showText(text: "input_memos".local());
      }
      return;
    }
    if (walletName.length == 0) {
      HWToast.showText(text: "input_name".local());
      return;
    }
    if (pwd.length == 0) {
      HWToast.showText(text: "input_pwd".local());
      return;
    }
    if (mLeadType != MLeadType.MLeadType_KeyStore) {
      if (pwdagain.length == 0) {
        HWToast.showText(text: "input_pwd".local());
        return;
      }
      if (pwd != pwdagain) {
        HWToast.showText(text: "input_pwd_wrong".local());
        return;
      }
      if (pwd.checkPassword() == false) {
        HWToast.showText(text: "input_pwd_regexp".local());
        return;
      }
      if (mLeadType == MLeadType.MLeadType_Prvkey &&
          content.checkPrv(mcoinType) == false) {
        HWToast.showText(text: "import_prvwrong".local());
        return;
      }
    } else {
      Map object = JsonUtil.getObj(content);
      if (object == null) {
        HWToast.showText(text: "input_keystorevalid".local());
        return;
      }
    }

    if (isAgreement == false) {
      HWToast.showText(text: "import_readagreement".local());
      return;
    }

    HWToast.showLoading(
      clickClose: false,
    );
    MStatusCode v = await MHWallet.importWallet(
        content: content,
        pin: pwd,
        pintip: tip,
        walletName: walletName,
        mCoinType: mcoinType,
        mLeadType: mLeadType,
        mOriginType: MOriginType.MOriginType_LeadIn);
    if (v == MStatusCode.MStatusCode_Success) {
      HWToast.hiddenAllToast();
      Routers.push(context, Routers.tabbarPage, clearStack: true);
    } else {
      if (v == MStatusCode.MStatusCode_Exist) {
        HWToast.showText(text: "input_wallet_exist".local());
      } else if (v == MStatusCode.MStatusCode_MemoInvalid) {
        HWToast.showText(text: "input_memo_wrong".local());
      } else if (v == MStatusCode.MStatusCode_KeystorePwdInvalid) {
        HWToast.showText(text: "input_keystoreorpassword".local());
      } else {
        HWToast.showText(text: "wallet_create_err".local());
      }
    }
  }

  _changeLeadType(int value) {
    FocusScope.of(context).requestFocus(FocusNode());
    MLeadType type = mLeadType;
    MLeadType.values.forEach((element) {
      if (element.index == value) {
        type = element;
        if (type == MLeadType.MLeadType_Memo) {
          type = MLeadType.MLeadType_StandardMemo;
        }
      }
    });
    Future.delayed(Duration(milliseconds: 500)).then((value) => {
          setState(() {
            mLeadType = type;
            LogUtil.v("点击element $mLeadType");
          }),
        });

    // contentEC.clear();
    // nameEC.clear();
    // pwdEC.clear();
    // pwdAganEC.clear();
    // pwdTipEC.clear();
  }

  Widget _getInputTextField({
    TextEditingController controller,
    String hintText,
    String titleText,
    bool obscureText = false,
    EdgeInsetsGeometry padding = const EdgeInsets.only(top: 22),
    int maxLength,
  }) {
    return Padding(
        padding: padding,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  titleText,
                  style: TextStyle(
                      color: Color(0xFF161D2D),
                      fontSize: OffsetWidget.setSp(15),
                      fontWeight: FontWightHelper.regular),
                ),
              ),
              CustomTextField(
                controller: controller,
                obscureText: obscureText,
                maxLength: maxLength,
                style: TextStyle(
                  color: Color(0xFF000000),
                  fontSize: OffsetWidget.setSp(15),
                  fontWeight: FontWightHelper.regular,
                ),
                decoration: CustomTextField.getUnderLineDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Color(0xFFACBBCF),
                    fontSize: OffsetWidget.setSp(15),
                    fontWeight: FontWightHelper.regular,
                  ),
                ),
              ),
            ]));
  }

  Widget _getPageViewWidget(int leadtype) {
    Widget content;
    Widget name = _getInputTextField(
        controller: nameEC,
        hintText: "import_walletname".local(),
        titleText: "wallet_name".local(),
        maxLength: 25,
        padding: EdgeInsets.only(top: 14));

    Widget password = _getInputTextField(
      controller: pwdEC,
      obscureText: !eyeisOpen,
      hintText: "import_pwddetail".local(),
      titleText: "import_pwd".local(),
    );
    Widget againPwd = _getInputTextField(
      controller: pwdAganEC,
      obscureText: !eyeisOpen,
      hintText: "confirm_password".local(),
      titleText: "import_pwdagain".local(),
    );

    Widget passwordTip = _getInputTextField(
      controller: pwdTipEC,
      hintText: "import_pwddesc".local(),
      titleText: "wallet_update_tip_title".local(),
    );

    List<Widget> children = List();
    if (leadtype == MLeadType.MLeadType_Prvkey.index) {
      content = Container(
        height: OffsetWidget.setSc(106),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Color(0xFFF6F8F9),
          border: Border.all(
            color: Color(0XFFEFF3F5),
          ),
        ),
        child: CustomTextField(
          controller: contentEC,
          maxLines: 3,
          style: TextStyle(
            color: Color(0xFF161D2D),
            fontSize: OffsetWidget.setSp(16),
            fontWeight: FontWightHelper.regular,
          ),
          decoration: CustomTextField.getBorderLineDecoration(
            hintText: "import_plainprv".local(),
            fillColor: Color(0xFFF6F8F9),
            borderColor: Colors.transparent,
            contentPadding: EdgeInsets.only(
                left: OffsetWidget.setSc(10),
                right: OffsetWidget.setSc(10),
                top: OffsetWidget.setSc(8)),
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
      );

      children.add(content);
      children.add(name);
      children.add(password);
      children.add(againPwd);
      children.add(passwordTip);
    } else if (leadtype == MLeadType.MLeadType_KeyStore.index) {
      content = Container(
        height: OffsetWidget.setSc(106),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Color(0xFFF6F8F9),
          border: Border.all(
            color: Color(0XFFEFF3F5),
          ),
        ),
        child: CustomTextField(
          controller: contentEC,
          maxLines: 3,
          style: TextStyle(
            color: Color(0xFF161D2D),
            fontSize: OffsetWidget.setSp(16),
            fontWeight: FontWightHelper.regular,
          ),
          decoration: CustomTextField.getBorderLineDecoration(
            hintText: "import_plainkeystore".local(),
            fillColor: Color(0xFFF6F8F9),
            borderColor: Colors.transparent,
            contentPadding: EdgeInsets.only(
                left: OffsetWidget.setSc(10),
                right: OffsetWidget.setSc(10),
                top: OffsetWidget.setSc(8)),
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
      );
      password = _getInputTextField(
        controller: pwdEC,
        obscureText: !eyeisOpen,
        hintText: "import_pwddetail".local(),
        titleText: "import_pwd".local(),
      );
      children.add(
        Container(
          child: Container(
            color: Color.fromARGB(255, 255, 252, 188),
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: Text(
                  ("import_copy".local() +
                      Constant.getChainSymbol(mcoinType.index) +
                      "import_keystoredetail".local()),
                  style: TextStyle(
                    color: Color(0xff586883),
                    fontSize: OffsetWidget.setSp(10),
                    fontWeight: FontWeight.w400,
                  ),
                )),
              ],
            ),
          ),
        ),
      );
      children.add(content);
      children.add(name);
      children.add(password);
    } else {
      content = Container(
        height: OffsetWidget.setSc(106),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Color(0xFFF6F8F9),
          border: Border.all(
            color: Color(0XFFEFF3F5),
          ),
        ),
        child: CustomTextField(
          controller: contentEC,
          maxLines: 3,
          style: TextStyle(
            color: Color(0xFF161D2D),
            fontSize: OffsetWidget.setSp(16),
            fontWeight: FontWightHelper.regular,
          ),
          decoration: CustomTextField.getBorderLineDecoration(
            hintText: "import_plainmemo".local(),
            fillColor: Color(0xFFF6F8F9),
            borderColor: Colors.transparent,
            contentPadding: EdgeInsets.only(
                left: OffsetWidget.setSc(10),
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
      );
      children.add(content);
      children.add(name);
      children.add(password);
      children.add(againPwd);
      children.add(passwordTip);
    }

    GestureDetector agrmentInfo = GestureDetector(
      onTap: jumpToAgreement,
      child: Container(
        padding: EdgeInsets.only(
            top: OffsetWidget.setSc(36),
            left: OffsetWidget.setSc(0),
            right: OffsetWidget.setSc(0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: updateAgreement,
              child: Image.asset(
                isAgreement == false
                    ? Constant.ASSETS_IMG + "icon/icon_unselect.png"
                    : Constant.ASSETS_IMG + "icon/icon_select.png",
                fit: BoxFit.cover,
                width: 16,
                height: 16,
              ),
            ),
            OffsetWidget.hGap(5),
            Container(
              constraints: BoxConstraints(maxWidth: OffsetWidget.setSc(300)),
              child: RichText(
                maxLines: 10,
                textAlign: TextAlign.left,
                text: TextSpan(
                  text: 'readagrementinfo'.local(),
                  style: TextStyle(
                    color: Color(0xFF979797),
                    fontSize: OffsetWidget.setSp(12),
                    fontWeight: FontWeight.w400,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        text: 'agrementinfo'.local(),
                        style: TextStyle(
                          color: Color(0xFF4A4A4A),
                          fontSize: OffsetWidget.setSp(13),
                          fontWeight: FontWeight.w400,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    GestureDetector startImportBtn = GestureDetector(
      onTap: _importWallets,
      child: Container(
        margin: EdgeInsets.only(
            left: OffsetWidget.setSc(22),
            top: OffsetWidget.setSc(36),
            bottom: OffsetWidget.setSc(36),
            right: OffsetWidget.setSc(22)),
        height: OffsetWidget.setSc(40),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8), color: Color(0xFF586883)),
        child: Text(
          "comfirm_trans_payment".local(),
          style: TextStyle(
              fontWeight: FontWightHelper.semiBold,
              fontSize: OffsetWidget.setSp(15),
              color: Colors.white),
        ),
      ),
    );

    children.add(agrmentInfo);
    children.add(OffsetWidget.vGap(24));
    children.add(startImportBtn);

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
            left: OffsetWidget.setSc(20),
            right: OffsetWidget.setSc(20),
            top: OffsetWidget.setSc(27)),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _myTabs.length,
      child: CustomPageView(
        title: CustomPageView.getDefaultTitle(
          titleStr: ("import_page".local() +
              Constant.getChainSymbol(mcoinType.index) +
              "import_wallet".local()),
        ),
        hiddenScrollView: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Material(
            color: Colors.white,
            child: Theme(
              data: ThemeData(
                  splashColor: Color.fromRGBO(0, 0, 0, 0),
                  highlightColor: Color.fromRGBO(0, 0, 0, 0)),
              child: TabBar(
                tabs: _myTabs,
                indicatorColor: Color(0xFF4A4A4A),
                indicatorWeight: 2,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Color(0xFF4A4A4A),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: OffsetWidget.setSp(14),
                ),
                unselectedLabelColor: Color(0xFF9B9B9B),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: OffsetWidget.setSp(14),
                ),
                onTap: (value) {
                  _changeLeadType(value);
                },
              ),
            ),
          ),
        ),
        child: TabBarView(
          physics: NeverScrollableScrollPhysics(), //禁止左右滑动
          children: _myTabs.map((Tab tab) {
            int leadType = _myTabs.indexOf(tab);
            if (mcoinType == MCoinType.MCoinType_BTM) {
              if (leadType == MLeadType.MLeadType_KeyStore.index) {
                leadType = MLeadType.MLeadType_Memo.index;
              }
            }
            return _getPageViewWidget(leadType);
          }).toList(),
        ),
      ),
    );
  }
}
