import 'package:flutter_coinid/models/node/node_model.dart';
import 'package:flutter_coinid/services/EventBus.dart';
import 'package:flutter_coinid/utils/sharedPrefer.dart';

import '../../public.dart';

class SystemSetPage extends StatefulWidget {
  SystemSetPage({Key key}) : super(key: key);

  @override
  _SystemSetPageState createState() => _SystemSetPageState();
}

class _SystemSetPageState extends State<SystemSetPage> {
  int amount = 0;
  int language = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSetType();
    _configNodeList();
  }

  Future<void> _configNodeList() async {
    List<NodeModel> nodes = await NodeModel.queryNodeByIsChoose(true);
    if (nodes == null || nodes.length == 0) {
      nodes = [];
      NodeModel node = NodeModel(
          "https://btc-api.coinid.pro",
          MCoinType.MCoinType_BTC.index,
          true,
          true,
          MNodeNetType.MNodeNetType_Main.index);
      nodes.add(node);
      // node = NodeModel(
      //     "https://mainnet-eos.coinid.pro",
      //     MCoinType.MCoinType_EOS.index,
      //     true,
      //     true,
      //     MNodeNetType.MNodeNetType_Main.index);
      // nodes.add(node);
      node = NodeModel(
          "https://mainnet-eth.coinid.pro",
          MCoinType.MCoinType_ETH.index,
          true,
          true,
          MNodeNetType.MNodeNetType_Main.index);
      nodes.add(node);
      // node = NodeModel(
      //     "https://mainnet-gvns.coinid.pro",
      //     MCoinType.MCoinType_VNS.index,
      //     true,
      //     true,
      //     MNodeNetType.MNodeNetType_Main.index);
      // nodes.add(node);
      // node = NodeModel(
      //     "https://mainnet-bytom.coinid.pro",
      //     MCoinType.MCoinType_BTM.index,
      //     true,
      //     true,
      //     MNodeNetType.MNodeNetType_Main.index);
      // nodes.add(node);
      // node = NodeModel(
      //     "https://ltc-explorer.coinid.pro",
      //     MCoinType.MCoinType_LTC.index,
      //     true,
      //     true,
      //     MNodeNetType.MNodeNetType_Main.index);
      // nodes.add(node);
      // node = NodeModel(
      //     "https://btc-api.coinid.pro",
      //     MCoinType.MCoinType_USDT.index,
      //     true,
      //     true,
      //     MNodeNetType.MNodeNetType_Main.index);
      // nodes.add(node);
      NodeModel.insertNodeDatas(nodes);
    }
  }

  void getSetType() async {
    int newamount = await getAmountValue();
    int newlanguage = await getLanguageValue();
    print("getSetType $newamount $newlanguage");
    setState(() {
      amount = newamount;
      language = newlanguage;
    });
  }

  Future<void> _cellTap(int index) async {
    if (index == 0 || index == 1) {
      Routers.push(context, Routers.modifiySetPage, params: {"settype": index})
          .then((value) => {
                getSetType(),
                if (index == 0)
                  {
                    getAmountValue().then((value) => {
                          eventBus.fire(ConvertEvent(value)),
                        }),
                  }
              });
    } else {
      Routers.push(context, Routers.nodeListPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
        child: Column(
      children: <Widget>[
        GestureDetector(
          onTap: () => {
            _cellTap(0),
          },
          child: Container(
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 20, right: 20, top: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color(Constant.TextFileld_FillColor),
            ),
            height: 50,
            child: Container(
              margin: EdgeInsets.only(
                left: 18,
                right: 18,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "货币",
                    style: TextStyle(
                      color: Color(0xffACBBCF),
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        amount == 0 ? "CNY" : "USDT",
                        style: TextStyle(
                          color: Color(0xff586883),
                          fontSize: 12,
                        ),
                      ),
                      OffsetWidget.hGap(16),
                      Image.asset(
                        Constant.ASSETS_IMG + "icon/arrow_black_right.png",
                        fit: BoxFit.cover,
                        scale: 2.0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => {
            _cellTap(1),
          },
          child: Container(
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 20, right: 20, top: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color(Constant.TextFileld_FillColor),
            ),
            height: 50,
            child: Container(
              margin: EdgeInsets.only(
                left: 18,
                right: 18,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "语言",
                    style: TextStyle(
                      color: Color(0xffACBBCF),
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        language == 0 ? "简体中文" : "英文",
                        style: TextStyle(
                          color: Color(0xff586883),
                          fontSize: 12,
                        ),
                      ),
                      OffsetWidget.hGap(16),
                      Image.asset(
                        Constant.ASSETS_IMG + "icon/arrow_black_right.png",
                        fit: BoxFit.cover,
                        scale: 2.0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => {
            _cellTap(2),
          },
          child: Container(
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 20, right: 20, top: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color(Constant.TextFileld_FillColor),
            ),
            height: 50,
            child: Container(
              margin: EdgeInsets.only(
                left: 18,
                right: 18,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "节点设置",
                    style: TextStyle(
                      color: Color(0xffACBBCF),
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Image.asset(
                        Constant.ASSETS_IMG + "icon/arrow_black_right.png",
                        fit: BoxFit.cover,
                        scale: 2.0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ));
  }
}
