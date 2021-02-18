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
  EdgeInsets padding = EdgeInsets.only(
      left: OffsetWidget.setSc(20),
      right: OffsetWidget.setSc(20),
      top: OffsetWidget.setSc(20));
  EdgeInsets contentPadding = EdgeInsets.only(left: 10, right: 10);
  bool eyeisOpen = false;
  bool isAgreement = false;

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

    Map<String, dynamic> object = Map();
    object["walletName"] = walletName;
    object["password"] = password;
    object["pwdTip"] = pwdTip;
    Routers.push(context, Routers.chooseCountPage, params: object);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
      title: Text(
        "create_wallet".local(),
        style: TextStyle(
            color: Color(0xFF000000),
            fontSize: OffsetWidget.setSp(18),
            fontWeight: FontWeight.w400),
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: padding,
            child: Container(
              color: Color.fromARGB(255, 255, 252, 188),
              padding: EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Column(
                  //   children: <Widget>[
                  //     Padding(
                  //       padding: EdgeInsets.only(top: 5),
                  //       child: Image.asset(
                  //         Constant.ASSETS_IMG + "icon/tips@2x.png",
                  //         fit: BoxFit.cover,
                  //         width: 12,
                  //         height: 12,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // OffsetWidget.hGap(10),
                  Expanded(
                      child: Text(
                    "create_wallettip".local(),
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
            controller: _passwordEC,
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
            controller: _againPasswordEC,
            contentPadding: contentPadding,
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
            controller: _passwordTipEC,
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
            onTap: _createAction,
            child: Container(
              margin: EdgeInsets.only(
                  left: OffsetWidget.setSc(30),
                  top: OffsetWidget.setSc(30),
                  right: OffsetWidget.setSc(30)),
              height: OffsetWidget.setSc(50),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(OffsetWidget.setSc(50)),
                  color: Color(0xFF1308FE)),
              child: Text(
                "create_data".local(),
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
