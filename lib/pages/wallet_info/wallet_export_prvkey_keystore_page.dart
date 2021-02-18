import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../public.dart';

class WalletExportPrikeyKeystorePage extends StatefulWidget {
  WalletExportPrikeyKeystorePage({
    Key key,
    this.params,
  }) : super(key: key);
  Map params = Map();

  @override
  _WalletExportPrikeyKeystorePageState createState() =>
      _WalletExportPrikeyKeystorePageState();
}

class _WalletExportPrikeyKeystorePageState
    extends State<WalletExportPrikeyKeystorePage> {
  bool show2Code = false;
  int exportType = 0; //0:prvKey 1:keystore
  String content = "";

  List<Tab> _myTabs = <Tab>[];

  @override
  void initState() {
    super.initState();
    if (widget.params != null) {
      exportType = int.parse(widget.params["exportType"][0]);
      content = widget.params["content"][0];
    }
    if (exportType == 1) {
      _myTabs.add(Tab(text: "Keystore".local()));
    } else {
      _myTabs.add(Tab(text: "import_prv".local()));
    }
    _myTabs.add(Tab(text: "qr_code".local()));

    setState(() {});
  }

  void _clickCopy(String value) {
    LogUtil.v("_clickCopy " + value);
    if (value.isValid() == false) return;
    Clipboard.setData(ClipboardData(text: value));
    HWToast.showText(text: "copy_success".local());
  }

  Widget _getPageViewWidget(int page) {
    if (page == 1) {
      return build2CodePage();
    } else {
      return buildTxtPage();
    }
  }

  Widget buildTxtPage() {
    return Column(
      children: [
        OffsetWidget.vGap(11),
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          child: Container(
            color: Color(0xFFF6F9FC),
            width: OffsetWidget.setSc(322),
            padding: EdgeInsets.only(
                left: OffsetWidget.setSc(13),
                top: OffsetWidget.setSc(11),
                right: OffsetWidget.setSc(13),
                bottom: OffsetWidget.setSc(11)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "export_tip1".local(),
                  style: TextStyle(
                      fontSize: OffsetWidget.setSp(12),
                      color: Color(0xFF586883)),
                ),
                Text(
                  "export_tip2".local(),
                  style: TextStyle(
                      fontSize: OffsetWidget.setSp(10),
                      color: Color(0xFFACBBCF)),
                ),
                OffsetWidget.vGap(18),
                Text(
                  "export_tip3".local(),
                  style: TextStyle(
                      fontSize: OffsetWidget.setSp(12),
                      color: Color(0xFFACBBCF)),
                ),
                Text(
                  "export_tip4".local(),
                  style: TextStyle(
                      fontSize: OffsetWidget.setSp(10),
                      color: Color(0xFFACBBCF)),
                ),
                OffsetWidget.vGap(18),
                Text(
                  "export_tip5".local(),
                  style: TextStyle(
                      fontSize: OffsetWidget.setSp(12),
                      color: Color(0xFFACBBCF)),
                ),
                Text(
                  "export_tip6".local(),
                  style: TextStyle(
                      fontSize: OffsetWidget.setSp(10),
                      color: Color(0xFFACBBCF)),
                ),
              ],
            ),
          ),
        ),
        OffsetWidget.vGap(29),
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          child: Container(
            color: Color(0xFFFFFBC8),
            width: OffsetWidget.setSc(322),
            padding: EdgeInsets.fromLTRB(
                OffsetWidget.setSc(13),
                OffsetWidget.setSc(11),
                OffsetWidget.setSc(13),
                OffsetWidget.setSc(12)),
            child: Text(
              content,
              style: TextStyle(
                  fontSize: OffsetWidget.setSp(11), color: Color(0xFF586883)),
            ),
          ),
        ),
        OffsetWidget.vGap(29),
        CustomRadiusButton(
          width: OffsetWidget.setSc(156),
          height: OffsetWidget.setSc(38),
          textStr: exportType == 1 ? "export_copy".local() + " Keystore" : "export_copy".local() + " Private Key",
          fontSize: OffsetWidget.setSp(12),
          textColor: Color(0xFFFFFFFF),
          background: Color(0xFF1308FE),
          topLeftBorderRadius: 19,
          topRightBorderRadius: 19,
          bottomLeftBorderRadius: 19,
          bottomRightBorderRadius: 19,
          onTap: () {
            _clickCopy(content);
          },
        ),
      ],
    );
  }

  Widget build2CodePage() {
    return Column(
      children: [
        OffsetWidget.vGap(11),
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          child: Container(
            color: Color(0xFFF6F9FC),
            width: OffsetWidget.setSc(322),
            padding: EdgeInsets.only(
                left: OffsetWidget.setSc(13),
                top: OffsetWidget.setSc(11),
                right: OffsetWidget.setSc(13),
                bottom: OffsetWidget.setSc(48)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "export_tip7".local(),
                  style: TextStyle(
                      fontSize: OffsetWidget.setSp(12),
                      color: Color(0xFF586883)),
                ),
                Text(
                  "export_tip8".local(),
                  style: TextStyle(
                      fontSize: OffsetWidget.setSp(10),
                      color: Color(0xFFACBBCF)),
                ),
                OffsetWidget.vGap(18),
                Text(
                  "export_tip9".local(),
                  style: TextStyle(
                      fontSize: OffsetWidget.setSp(12),
                      color: Color(0xFF586883)),
                ),
                Text(
                  "export_tip10".local(),
                  style: TextStyle(
                      fontSize: OffsetWidget.setSp(10),
                      color: Color(0xFFACBBCF)),
                ),
              ],
            ),
          ),
        ),
        OffsetWidget.vGap(35),
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          child: Container(
              width: OffsetWidget.setSc(173),
              height: OffsetWidget.setSc(173),
              child: Stack(
                children: [
                  Positioned(
                    child: Visibility(
                      child: QrImage(
                        data: content,
                        size: OffsetWidget.setSc(173),
                      ),
                      visible: show2Code,
                    ),
                  ),
                  Positioned(
                    child: Visibility(
                      child: LoadAssetsImage(
                        Constant.ASSETS_IMG + "icon/icon_hidden_2code.png",
                        width: OffsetWidget.setSc(173),
                        height: OffsetWidget.setSc(173),
                        fit: BoxFit.contain,
                      ),
                      visible: !show2Code,
                    ),
                  ),
                ],
              )),
        ),
        OffsetWidget.vGap(29),
        CustomRadiusButton(
          width: OffsetWidget.setSc(156),
          height: OffsetWidget.setSc(38),
          textStr: "export_show_qr".local(),
          fontSize: OffsetWidget.setSp(12),
          textColor: Color(0xFFFFFFFF),
          background: Color(0xFF1308FE),
          topLeftBorderRadius: 19,
          topRightBorderRadius: 19,
          bottomLeftBorderRadius: 19,
          bottomRightBorderRadius: 19,
          onTap: () {
            show2Code = !show2Code;
            setState(() {});
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    OffsetWidget.screenInit(context, 360);
    return DefaultTabController(
      length: _myTabs.length,
      child: CustomPageView(
        hiddenScrollView: true,
        hiddenResizeToAvoidBottomInset: false,
        title: Text(
          exportType == 1 ? "export_keystore".local() : "export_prv".local(),
          style: TextStyle(
              fontSize: OffsetWidget.setSp(17), color: Color(0xFF4A4A4A)),
        ),
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(62),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(),
                Material(
                    color: Colors.white,
                    child: Theme(
                      data: ThemeData(
                          splashColor: Color.fromRGBO(0, 0, 0, 0),
                          highlightColor: Color.fromRGBO(0, 0, 0, 0)),
                      child: TabBar(
                        tabs: _myTabs,
                        indicatorColor: Color(0xFF586883),
                        indicatorWeight: 5,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelColor: Color(0xFF586883),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        unselectedLabelColor: Color(0xFFACBBCF),
                        unselectedLabelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        onTap: (page) => {},
                      ),
                    )),
              ],
            )),
        child: TabBarView(
          physics: NeverScrollableScrollPhysics(), //禁止左右滑动
          children: _myTabs.map((Tab tab) {
            return _getPageViewWidget(
              _myTabs.indexOf(tab),
            );
          }).toList(),
        ),
      ),
    );
  }
}
