import 'package:flutter/material.dart';
import 'package:flutter_coinid/channel/channel_wallet.dart';
import 'package:flutter_coinid/models/node/node_model.dart';
import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
import 'package:flutter_coinid/net/chain_services.dart';
import 'package:flutter_coinid/pages/choose/choose_type_page.dart';
import 'package:flutter_coinid/pages/guide/guide_page.dart';
import 'package:flutter_coinid/pages/tabbar/tabbar_page.dart';
import 'package:flutter_coinid/upgrade/app_upgrade.dart';
import 'package:flutter_coinid/upgrade/download_status.dart';
import 'package:flutter_coinid/upgrade/flutter_upgrade.dart';
import 'package:flutter_coinid/widgets/custom_app.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_coinid/public.dart';

class MyApp extends StatefulWidget {
  //launch
  //tabbar
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loadData = true;
  bool skin = false;
  bool walletCreated = false;

  @override
  Future<void> initState() {
    super.initState();
    getSkip();
    getChooseNodes();
    Constant.getAppFile().then((value) => {
          LogUtil.v("app file " + value.absolute.path),
        });
  }

  Future<bool> getSkip() async {
    final prefs = await SharedPreferences.getInstance();
    bool isSkip = prefs.getBool("skip");
    if (isSkip != null && isSkip) {
      List<MHWallet> wallets = await MHWallet.findAllWallets();
      if (wallets != null && wallets.length > 0) {
        setState(() {
          loadData = false;
          walletCreated = true;
        });
      } else {
        setState(() {
          loadData = false;
          skin = isSkip;
        });
      }
    } else {
      setState(() {
        loadData = false;
        skin = isSkip;
      });
    }
    return Future.value(isSkip);
  }

  Widget buildEmptyView() {
    return Container();
  }

  //替换成设置成的节点
  Future<void> getChooseNodes() async {
    List<NodeModel> nodes = await NodeModel.queryNodeByIsChoose(true);
    if (nodes != null && nodes.length > 0) {
      nodes.forEach((element) {
        if (element.chainType == MCoinType.MCoinType_BTC.index) {
          ChainServices.btcMainChain = element.content;
        } else if (element.chainType == MCoinType.MCoinType_ETH.index) {
          ChainServices.ethMainChain = element.content;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: CurrentChooseWalletState()),
          ChangeNotifierProvider.value(value: SystemSettings()),
        ],
        child: CustomApp(
          child: walletCreated == true
              ? TabbarPage()
              : skin == true
                  ? ChooseTypePage()
                  : GuidePage(),
          // child: ApplicationPage(),
        ));
  }
}
