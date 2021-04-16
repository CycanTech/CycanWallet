import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

import '../../../public.dart';

class CreatePage extends StatefulWidget {
  CreatePage({Key key}) : super(key: key);

  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final TextEditingController _nameEC = new TextEditingController();
  final TextEditingController _passwordEC = new TextEditingController();
  final TextEditingController _againPasswordEC = new TextEditingController();
  final TextEditingController _passwordTipEC = new TextEditingController();
  // EdgeInsets padding = EdgeInsets.only(
  //     left: OffsetWidget.setSc(20),
  //     right: OffsetWidget.setSc(20),
  //     top: OffsetWidget.setSc(20));
  bool eyeisOpen = false;
  bool isAgreement = false;

  TapGestureRecognizer _tapGestureRecognizer;

  @override
  void initState() {
    super.initState();
    _tapGestureRecognizer = TapGestureRecognizer()..onTap = jumpToAgreement;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tapGestureRecognizer.dispose();
  }

  void sssssss() {}

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

  void _createAction() {
    final String walletName = _nameEC.text;
    final String password = _passwordEC.text;
    final String againPwd = _againPasswordEC.text;
    final String pwdTip = _passwordTipEC.text;
    FocusScope.of(context).requestFocus(FocusNode());
    if (walletName.length == 0) {
      HWToast.showText(text: "input_name".local());
      return;
    }
    if (password.length == 0 || password.length == 0) {
      HWToast.showText(text: "input_pwd".local());
      return;
    }
    if (password != againPwd) {
      HWToast.showText(text: "input_pwd_wrong".local());
      return;
    }
    if (password.checkPassword() == false) {
      HWToast.showText(text: "input_pwd_regexp".local());
      return;
    }

    if (isAgreement == false) {
      HWToast.showText(text: "import_readagreement".local());
      return;
    }

    showMHAlertView(
      context: context,
      title: "confirm_password".local(),
      content: "memo_create_tip".local(),
      confirmPressed: () {
        Map<String, dynamic> object = Map();
        object["walletName"] = walletName;
        object["password"] = password;
        object["pwdTip"] = pwdTip;
        object["memoCount"] = MemoCount.MemoCount_12;
        Routers.push(context, Routers.backupMemosPage, params: object);
      },
    );
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
                      fontSize: OffsetWidget.setSp(18),
                      fontWeight: FontWightHelper.regular),
                ),
              ),
              CustomTextField(
                controller: controller,
                obscureText: obscureText,
                maxLength: maxLength,
                style: TextStyle(
                  color: Color(0xFF000000),
                  fontSize: OffsetWidget.setSp(18),
                  fontWeight: FontWightHelper.regular,
                ),
                decoration: CustomTextField.getUnderLineDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Color(0xFFACBBCF),
                    fontSize: OffsetWidget.setSp(16),
                    fontWeight: FontWightHelper.regular,
                  ),
                ),
              ),
            ]));
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
      title: CustomPageView.getDefaultTitle(
        titleStr: "create_wallet".local(),
        fontSize: 20,
      ),
      child: Container(
        padding: EdgeInsets.only(
            left: OffsetWidget.setSc(20),
            right: OffsetWidget.setSc(20),
            top: OffsetWidget.setSc(27)),
        child: Column(
          children: <Widget>[
            Text(
              "create_wallettip".local(),
              style: TextStyle(
                color: Color(0xFFF15F4A),
                fontSize: OffsetWidget.setSp(14),
                fontWeight: FontWightHelper.regular,
              ),
            ),
            _getInputTextField(
                controller: _nameEC,
                hintText: "import_walletname".local(),
                titleText: "wallet_name".local(),
                maxLength: 25,
                padding: EdgeInsets.only(top: 14)),
            _getInputTextField(
              controller: _passwordEC,
              obscureText: !eyeisOpen,
              hintText: "import_pwddetail".local(),
              titleText: "import_pwd".local(),
            ),
            _getInputTextField(
              controller: _againPasswordEC,
              obscureText: !eyeisOpen,
              hintText: "confirm_password".local(),
              titleText: "import_pwdagain".local(),
            ),
            _getInputTextField(
              controller: _passwordTipEC,
              hintText: "import_pwddesc".local(),
              titleText: "wallet_update_tip_title".local(),
            ),
            Container(
              padding: EdgeInsets.only(
                top: OffsetWidget.setSc(34),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
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
                  GestureDetector(
                    onTap: updateAgreement,
                    child: Container(
                      constraints:
                          BoxConstraints(maxWidth: OffsetWidget.setSc(300)),
                      child: RichText(
                        maxLines: 10,
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          text: 'readagrementinfo'.local(),
                          style: TextStyle(
                            color: Color(0xFF999EA5),
                            fontSize: OffsetWidget.setSp(14),
                            fontWeight: FontWightHelper.regular,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                                text: 'agrementinfo'.local(),
                                recognizer: _tapGestureRecognizer,
                                style: TextStyle(
                                  color: Color(0xFF586883),
                                  fontSize: OffsetWidget.setSp(14),
                                  fontWeight: FontWightHelper.regular,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _createAction,
              child: Container(
                margin: EdgeInsets.only(
                    left: OffsetWidget.setSc(22),
                    top: OffsetWidget.setSc(36),
                    right: OffsetWidget.setSc(22)),
                height: OffsetWidget.setSc(40),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xFF586883)),
                child: Text(
                  "create_wallet".local(),
                  style: TextStyle(
                      fontWeight: FontWightHelper.semiBold,
                      fontSize: OffsetWidget.setSp(18),
                      color: Colors.white),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Routers.push(context, Routers.restorePage);
              },
              child: Container(
                margin: EdgeInsets.only(
                  top: OffsetWidget.setSc(23),
                ),
                alignment: Alignment.center,
                child: Text(
                  "restore_wallet".local(),
                  style: TextStyle(
                      fontWeight: FontWightHelper.semiBold,
                      fontSize: OffsetWidget.setSp(18),
                      color: Color(0xFF4F7BF2)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
