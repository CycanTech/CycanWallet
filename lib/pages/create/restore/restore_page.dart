import 'package:flutter_coinid/channel/channel_wallet.dart';
import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
import 'package:flutter_coinid/routers/router_handler.dart';
import 'package:flutter_coinid/utils/date_util.dart';

import '../../../public.dart';

// import 'package:flutter/material.dart';
// import 'package:flutter_coinid/widgets/custom_pageview.dart';

class RestorePage extends StatefulWidget {
  RestorePage({Key key}) : super(key: key);

  @override
  _RestorePageState createState() => _RestorePageState();
}

class _RestorePageState extends State<RestorePage> {
  MLeadType memoType = MLeadType.MLeadType_StandardMemo; //当前默认通用
  final TextEditingController _memoEC = new TextEditingController();
  final TextEditingController _nameEC = new TextEditingController();
  final TextEditingController _pwdEC = new TextEditingController();
  final TextEditingController _pwdAgantEC = new TextEditingController();
  final TextEditingController _pwdTipEC = new TextEditingController();
  EdgeInsets padding = EdgeInsets.only(
      left: OffsetWidget.setSc(20),
      right: OffsetWidget.setSc(20),
      top: OffsetWidget.setSc(20));
  EdgeInsets contentPadding = EdgeInsets.only(left: 10, right: 10);
  bool eyeisOpen = false;
  bool isAgreement = false;
  @override
  void initState() {
    super.initState();

    if (Constant.inProduction == false) {}
  }

  @override
  void dispose() {
    _memoEC.dispose();
    _nameEC.dispose();
    _pwdEC.dispose();
    _pwdAgantEC.dispose();
    _pwdTipEC.dispose();
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

  _restoreWallets() async {
    String content = _memoEC.text.trim();
    String pwd = _pwdEC.text.trim();
    String pwdagain = _pwdAgantEC.text.trim();
    String name = _nameEC.text.trim();
    String tip = _pwdTipEC.text.trim();
    if (content.length == 0) {
      HWToast.showText(text: "input_memos".local());
      return;
    }
    if (name.length == 0) {
      HWToast.showText(text: "input_name".local());
      return;
    }
    if (pwd.length == 0 || pwdagain.length == 0) {
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
    if (isAgreement == false) {
      HWToast.showText(text: "import_readagreement".local());
      return;
    }
    //验证文本内容
    //验证密码  是否一致，是否符合规则
    //验证助记词 CoinID_checkMemoValid

    HWToast.showLoading(
      clickClose: false,
    );
    MStatusCode v = await MHWallet.importWallet(
        content: content,
        pin: pwd,
        pintip: tip,
        walletName: name,
        mCoinType: MCoinType.MCoinType_All,
        mLeadType: memoType,
        mOriginType: MOriginType.MOriginType_Restore);
    if (v == MStatusCode.MStatusCode_Success) {
      HWToast.hiddenAllToast();
      Routers.push(context, Routers.tabbarPage, clearStack: true);
    } else {
      if (v == MStatusCode.MStatusCode_Exist) {
        HWToast.showText(text: "input_wallet_exist".local());
      } else if (v == MStatusCode.MStatusCode_MemoInvalid) {
        HWToast.showText(text: "input_memo_wrong".local());
      } else {
        HWToast.showText(text: "wallet_create_err".local());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
      title: Text(
        "restore_wallet".local(),
        style: TextStyle(
            color: Color(0xFF000000),
            fontSize: OffsetWidget.setSp(18),
            fontWeight: FontWeight.w400),
      ),
      child: Column(
        children: <Widget>[
          CustomTextField(
            padding: padding,
            controller: _memoEC,
            maxLines: 5,
            contentPadding: contentPadding,
            style: TextStyle(
              color: Color(0xFF000000),
              fontSize: OffsetWidget.setSp(14),
              fontWeight: FontWeight.w500,
            ),
            decoration: CustomTextField.getBorderLineDecoration(
              hintText: "import_plainmemo".local(),
              hintStyle: TextStyle(
                color: Color(0xFFC1C1C1),
                fontSize: OffsetWidget.setSp(12),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          CustomTextField(
            padding: padding,
            controller: _nameEC,
            contentPadding: contentPadding,
            style: TextStyle(
              color: Color(0xFF000000),
              fontSize: OffsetWidget.setSp(14),
              fontWeight: FontWeight.w500,
            ),
            decoration: CustomTextField.getUnderLineDecoration(
              hintText: "import_walletname".local(),
              hintStyle: TextStyle(
                color: Color(0xFFCFCFCF),
                fontSize: OffsetWidget.setSp(14),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          CustomTextField(
            padding: padding,
            controller: _pwdEC,
            contentPadding: contentPadding,
            obscureText: !eyeisOpen,
            style: TextStyle(
              color: Color(0xFF000000),
              fontSize: OffsetWidget.setSp(14),
              fontWeight: FontWeight.w500,
            ),
            decoration: CustomTextField.getUnderLineDecoration(
              hintText: "import_pwd".local(),
              helperText: "import_pwddetail".local(),
              helperStyle: TextStyle(
                color: Color(0xFF4A4A4A),
                fontSize: OffsetWidget.setSp(10),
                fontWeight: FontWeight.w400,
              ),
              hintStyle: TextStyle(
                color: Color(0xFFCFCFCF),
                fontSize: OffsetWidget.setSp(14),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          CustomTextField(
            padding: padding,
            controller: _pwdAgantEC,
            obscureText: !eyeisOpen,
            style: TextStyle(
              color: Color(0xFF000000),
              fontSize: OffsetWidget.setSp(14),
              fontWeight: FontWeight.w500,
            ),
            decoration: CustomTextField.getUnderLineDecoration(
              hintText: "import_pwdagain".local(),
              hintStyle: TextStyle(
                color: Color(0xFFCFCFCF),
                fontSize: OffsetWidget.setSp(14),
                fontWeight: FontWeight.w400,
              ),
              suffixIcon: GestureDetector(
                onTap: () => updateEyesState(),
                child: LoadAssetsImage(
                  eyeisOpen == false
                      ? Constant.ASSETS_IMG + "icon/eyes_close.png"
                      : Constant.ASSETS_IMG + "icon/eyes_open.png",
                  width: OffsetWidget.setSc(24),
                  height: OffsetWidget.setSc(24),
                  // fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          CustomTextField(
            padding: padding,
            controller: _pwdTipEC,
            contentPadding: contentPadding,
            style: TextStyle(
              color: Color(0xFF000000),
              fontSize: OffsetWidget.setSp(14),
              fontWeight: FontWeight.w500,
            ),
            decoration: CustomTextField.getUnderLineDecoration(
              hintText: "import_pwddesc".local(),
              hintStyle: TextStyle(
                color: Color(0xFFCFCFCF),
                fontSize: OffsetWidget.setSp(14),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          GestureDetector(
            onTap: jumpToAgreement,
            child: Container(
              padding: EdgeInsets.only(
                  top: OffsetWidget.setSc(36),
                  left: OffsetWidget.setSc(20),
                  right: OffsetWidget.setSc(20)),
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
                    constraints:
                        BoxConstraints(maxWidth: OffsetWidget.setSc(300)),
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
          ),
          OffsetWidget.vGap(24),
          GestureDetector(
            onTap: _restoreWallets,
            child: Container(
              margin: EdgeInsets.only(
                left: OffsetWidget.setSc(30),
                top: OffsetWidget.setSc(30),
                right: OffsetWidget.setSc(30),
                bottom: OffsetWidget.setSc(30),
              ),
              height: OffsetWidget.setSc(50),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(OffsetWidget.setSc(50)),
                  color: Color(0xFF1308FE)),
              child: Text(
                "restore_data".local(),
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: OffsetWidget.setSp(16),
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
