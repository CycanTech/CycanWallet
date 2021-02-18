import 'package:flutter_coinid/channel/channel_wallet.dart';
import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
import 'package:flutter_coinid/net/wallet_services.dart';
import 'package:flutter_coinid/pages/mine/msg_trans_page.dart';

import '../../public.dart';
import 'msg_system_page.dart';

class MineMsgPage extends StatefulWidget {
  @override
  _MineMsgPageState createState() => _MineMsgPageState();
}

class _MineMsgPageState extends State<MineMsgPage> {
  int mPage = 0;
  String _imei = "";
  List<String> _accounts = [];
  final List<Tab> _myTabs = <Tab>[
    Tab(text: 'msg_trans'.local()),
    Tab(text: 'msg_system'.local()),
  ];

  List<Widget> getBarAction() {
    return <Widget>[
      Container(
        margin: EdgeInsets.only(right:OffsetWidget.setSc(10)),
        alignment: Alignment.centerRight,
        width: OffsetWidget.setSc(80),
        height: OffsetWidget.setSc(48),
        child: GestureDetector(
          onTap: () => {_readAll()},
          child: Text("msg_all_read".local(),
          textAlign: TextAlign.end,
              style: TextStyle(
                  fontSize: OffsetWidget.setSp(12), color: Color(0xFF4A4A4A))),
        ),
      ),
    ];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getAppInfo();
    _getAccounts();
  }

  void _getAppInfo() async {
    _imei = await ChannelWallet.deviceImei();
    setState(() {});
  }

  Future<void> _getAccounts() async {
    List<MHWallet> wallets = await MHWallet.findAllWallets();
    if (wallets != null) {
      wallets.forEach((element) {
        _accounts.add(element.walletAaddress);
      });
      setState(() {});
    }
  }

  _readAll() {
    if (mPage == 0) {
      WalletServices.requestClickTransferNoticeAllRead(_accounts,
          (result, code) {
        if (mounted) {}
      });
    } else {
      WalletServices.requestClickSystemMessageAllRead(_imei, (result, code) {
        if (mounted) {}
      });
    }
  }

  Widget _getPageViewWidget(int page) {
    mPage = page;
    if (page == 0) {
      return MsgTransPage();
    } else {
      return MsgSystemPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _myTabs.length,
      child: CustomPageView(
        hiddenScrollView: true,
        actions: getBarAction(),
        title: Text("about_title".local(),
            style: TextStyle(
                fontSize: OffsetWidget.setSp(17), color: Color(0xFF4A4A4A))),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Container(),
        ),
                child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(

                ),
                Material(
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
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        unselectedLabelColor: Color(0xFF9B9B9B),
                        unselectedLabelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        onTap: (page) => {
                          _getPageViewWidget(page)
                        },
                      ),
                    )),
              ],
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(), //禁止左右滑动
                children: _myTabs.map((Tab tab) {
                  return _getPageViewWidget(
                    _myTabs.indexOf(tab),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
