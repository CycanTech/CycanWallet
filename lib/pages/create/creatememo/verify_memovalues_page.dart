import 'dart:ffi';
import 'dart:math';

import 'package:flutter_coinid/channel/channel_wallet.dart';
import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
import 'package:flutter_coinid/public.dart';
import 'package:flutter_coinid/utils/date_util.dart';
import 'package:flutter_coinid/utils/screenutil.dart';

class VerifyMemoPage extends StatefulWidget {
  VerifyMemoPage({
    Key key,
    this.params,
  }) : super(key: key);
  Map params = Map();
  @override
  _VerifyMemoPageState createState() => _VerifyMemoPageState();
}

class _VerifyMemoPageState extends State<VerifyMemoPage> {
  List verifiedList = []; //已经验证的
  List verifingList = []; //正在验证的
  String verifyStatus = "";
  List walletName = [];
  List password = [];
  List pwdTip = [];
  List memoType = [];
  List originList = [];
  bool isBackUp = false;
  @override
  void initState() {
    super.initState();
    List list = widget.params["paramsLists"];
    walletName = widget.params["walletName"];
    password = widget.params["password"];
    pwdTip = widget.params["pwdTip"];
    memoType = widget.params["memoType"];
    originList = widget.params["paramsLists"];
    isBackUp = (widget.params["isBackUp"][0]) == "true" ? true : false;
    verifingList = [];
    verifingList.addAll(list);
    verifingList.shuffle(Random());
  }

  _createWallets() async {
    if (verifingList.length > 0) {
      return;
    }
    if (isBackUp == true) {
      Routers.push(context, Routers.tabbarPage, clearStack: true);
      return;
    }

    String content = verifiedList.join(" ");
    String pwd = password[0];
    String name = walletName[0];
    String tip = pwdTip[0];
    MLeadType leadType = MLeadType.MLeadType_StandardMemo;
    if (content.length == 0) {
      HWToast.showText(text: "input_memos".local());
      return;
    }
    if (name.length == 0) {
      HWToast.showText(text: "input_name".local());
      return;
    }
    if (pwd.checkPassword() == false) {
      HWToast.showText(text: "input_pwd_regexp".local());
      return;
    }
    HWToast.showLoading(
      clickClose: false,
    );
    MStatusCode v = await MHWallet.importWallet(
        content: content,
        pin: pwd,
        pintip: tip,
        walletName: name,
        mCoinType: MCoinType.MCoinType_All,
        mLeadType: leadType,
        mOriginType: MOriginType.MOriginType_Create);
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

  Widget _getVerifyMemoContentWidget() {
    Map params = widget.params;
    if (params == null) {
      return Text("data");
    }
    List values = [];
    values = verifiedList;
    int row = originList.length == 12 ? 3 : 6;
    double spacing = 10;
    double leftoffset = 20;
    double width =
        (ScreenUtil.screenWidth - leftoffset * 4 - ((row - 1) * spacing)) / row;
    List<Widget> singleTexts = [];
    for (String item in values) {
      singleTexts.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _verifyWidgetItemAction(item);
          },
          child: Container(
            constraints: BoxConstraints(
              minWidth: width,
            ),
            child: Text(
              item,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF000000),
              ),
            ),
          ),
        ),
      );
    }
    return Container(
      margin: EdgeInsets.only(top: 15, left: leftoffset, right: leftoffset),
      padding: EdgeInsets.only(
          top: 15, left: leftoffset, bottom: 15, right: leftoffset),
      constraints: BoxConstraints(minHeight: OffsetWidget.setSc(170)),
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Color(0xffD3D3D3),
                offset: Offset(3, 3),
                blurRadius: 3.0,
                spreadRadius: 1.0)
          ]),
      child: Wrap(
        spacing: spacing, // 主轴(水平)方向间距
        runSpacing: 11.0, // 纵轴（垂直）方向间距
        alignment: WrapAlignment.start, //沿主轴方向居中
        children: singleTexts,
      ),
    );
  }

  void _verifyWidgetItemAction(String item) {
    setState(() {
      verifiedList.remove(item);
      verifingList.add(item);
    });
  }

  Widget _getMemoContentWidget() {
    Map params = widget.params;
    if (params == null) {
      return Text("data");
    }
    List values = verifingList;
    int row = originList.length == 12 ? 3 : 6;
    double spacing = 10;
    double leftoffset = 20;
    double width =
        (ScreenUtil.screenWidth - leftoffset * 4 - ((row - 1) * spacing)) / row;
    List<Widget> singleTexts = [];
    for (String item in values) {
      singleTexts.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _contentWidgetItemAction(item);
          },
          child: Container(
            constraints: BoxConstraints(
              minWidth: width,
            ),
            child: Text(
              item,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF000000),
              ),
            ),
          ),
        ),
      );
    }
    return values.length == 0
        ? Container()
        : Container(
            margin:
                EdgeInsets.only(top: 15, left: leftoffset, right: leftoffset),
            padding: EdgeInsets.only(
                top: 15, left: leftoffset, bottom: 15, right: leftoffset),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Color(0xffD3D3D3),
                      offset: Offset(3, 3),
                      blurRadius: 3.0,
                      spreadRadius: 1.0)
                ]),
            child: Wrap(
              spacing: spacing, // 主轴(水平)方向间距
              runSpacing: 11.0, // 纵轴（垂直）方向间距
              alignment: WrapAlignment.start, //沿主轴方向居中
              children: singleTexts,
            ),
          );
  }

  void _contentWidgetItemAction(String item) {
    int count = verifiedList.length;

    LogUtil.v("object  item $item" +
        (originList.elementAt(count)) +
        "originList = $originList");

    if (originList.elementAt(count) == item) {
      setState(() {
        verifingList.remove(item);
        verifingList.shuffle();
        verifiedList.add(item);
        verifyStatus = "";
      });
    } else {
      // showSuccessToast("status");
      setState(() {
        verifyStatus = "create_verifyerrtip".local();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
      child: Column(
        children: <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: OffsetWidget.setSc(65)),
              child: Image.asset(
                Constant.ASSETS_IMG + "icon/create_memo.png",
                width: OffsetWidget.setSc(50),
                height: OffsetWidget.setSc(50),
                fit: BoxFit.contain,
              ),
            ),
          ),
          OffsetWidget.vGap(15),
          Text(
            "create_verifymemo".local(),
            style: TextStyle(
                color: Color(0xFF000000),
                fontSize: OffsetWidget.setSp(18),
                fontWeight: FontWeight.w400),
          ),
          OffsetWidget.vGap(15),
          Text(
            verifyStatus,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(0xFF1308FE),
                fontSize: OffsetWidget.setSp(12),
                fontWeight: FontWeight.w400),
          ),
          OffsetWidget.vGap(15),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Text(
              "create_verifymemodesc".local(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xff9B9B9B),
                  fontSize: OffsetWidget.setSp(12),
                  fontWeight: FontWeight.w400),
            ),
          ),
          _getVerifyMemoContentWidget(),
          OffsetWidget.vGap(12),
          _getMemoContentWidget(),
          OffsetWidget.vGap(20),
          GestureDetector(
            onTap: () => _createWallets(),
            child: Container(
              height: OffsetWidget.setSc(40),
              width: OffsetWidget.setSc(162),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(OffsetWidget.setSc(50)),
                  color: Color(0xFF1308FE)),
              child: Text(
                "create_verifyok".local(),
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
