import 'package:flutter/services.dart';
import 'package:flutter_coinid/pages/application/application_page.dart';
import 'package:flutter_coinid/pages/main/main_page.dart';
import 'package:flutter_coinid/pages/mine/mine_page.dart';
import '../../public.dart';

class TabbarPage extends StatefulWidget {
  @override
  _TabbarPageState createState() => _TabbarPageState();
}

class _TabbarPageState extends State<TabbarPage> {
  final items = [
    BottomNavigationBarItem(
        icon: LoadAssetsImage(
            Constant.ASSETS_IMG + "tabbar/tabbar_wallet_unselect.png",
            width: 20,
            height: 20),
        activeIcon: LoadAssetsImage(
            Constant.ASSETS_IMG + "tabbar/tabbar_wallet_select.png",
            width: 20,
            height: 20),
        label: "wallet".local()),
    // BottomNavigationBarItem(
    //     icon: LoadAssetsImage(
    //         Constant.ASSETS_IMG + "tabbar/tabbar_market_unselect.png",
    //         width: 30,
    //         height: 30),
    //     activeIcon: LoadAssetsImage(
    //         Constant.ASSETS_IMG + "tabbar/tabbar_market_select.png",
    //         width: 30,
    //         height: 30),
    //     label: "market".local()),
    BottomNavigationBarItem(
        icon: LoadAssetsImage(
            Constant.ASSETS_IMG + "tabbar/tabbar_app_unselect.png",
            width: 20,
            height: 20),
        activeIcon: LoadAssetsImage(
            Constant.ASSETS_IMG + "tabbar/tabbar_app_select.png",
            width: 20,
            height: 20),
        label: "application".local()),
    BottomNavigationBarItem(
        icon: LoadAssetsImage(
            Constant.ASSETS_IMG + "tabbar/tabbar_mine_unselect.png",
            width: 20,
            height: 20),
        activeIcon: LoadAssetsImage(
            Constant.ASSETS_IMG + "tabbar/tabbar_mine_select.png",
            width: 20,
            height: 20),
        label: "my".local()),
  ];
  final bodyList = [
    MainPage(),
    // CurrencyMarket(),
    ApplicationPage(),
    MinePage()
  ];
  int currentIndex = 0;
  int exitTime = 0;

  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        //0x1AFFFFFF
        if (DateUtil.getNowDateMs() - exitTime > 2000) {
          HWToast.showText(text: 'exit_hint'.local());
          exitTime = DateUtil.getNowDateMs();
        } else {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
      },
      child: CustomPageView(
          hiddenScrollView: true,
          hiddenAppBar: true,
          hiddenLeading: true,
          bottomNavigationBar: Theme(
              data: ThemeData(
                  // brightness: Brightness.dark,
                  splashColor: Color.fromRGBO(0, 0, 0, 0),
                  highlightColor: Color.fromRGBO(0, 0, 0, 0)),
              child: BottomNavigationBar(
                items: items,
                currentIndex: currentIndex,
                onTap: onTap,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Color(Constant.main_color),
                selectedItemColor: Color(Constant.tabbar_select_color),
                unselectedItemColor: Color(Constant.tabbar_unselect_color),
                selectedFontSize: 10,
                unselectedFontSize: 10,
              )),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              IndexedStack(
                index: currentIndex,
                children: bodyList,
              ),
            ],
          )),
    );
  }
}
