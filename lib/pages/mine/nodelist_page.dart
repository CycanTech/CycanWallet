import 'package:flutter_coinid/channel/channel_wallet.dart';
import 'package:flutter_coinid/models/node/node_model.dart';

import '../../public.dart';

class NodeListPage extends StatefulWidget {
  @override
  _NodeListPageState createState() => _NodeListPageState();
}

class _NodeListPageState extends State<NodeListPage> {
  static const String _kImageName = "_kImageName";
  static const String _kContent = "_kContent";
  static const String _kIp = "_kIp";
  static const String _kChainType = "_kChainType";
  static const String _kPingValue = "_kPingValue";

  List<Map> _datas = [];

  @override
  void initState() {
    super.initState();
    _getAllNodes();
  }

  _getAllNodes() async {
    List<NodeModel> nodes = await NodeModel.queryNodeByIsChoose(true);
    if (nodes != null && nodes.length > 0) {
      _datas.clear();
      nodes.forEach((element) {
        String symbol = Constant.getChainSymbol(element.chainType);
        Map map = {
          _kImageName: "logo_$symbol.png",
          _kContent: "",
          _kIp: element.content,
          _kChainType: symbol,
          _kPingValue: "-1",
        };
        _datas.add(map);
      });
      setState(() {});
      _getIpPingValue();
    }
  }

 _getIpPingValue() async {
    await Future.wait<dynamic>([
      ChannelWallet.getAvgRTT(_datas[0][_kIp]),
      ChannelWallet.getAvgRTT(_datas[1][_kIp]),
      // ChannelWallet.getAvgRTT(_datas[2][_kIp]),
      // ChannelWallet.getAvgRTT(_datas[3][_kIp]),
      // ChannelWallet.getAvgRTT(_datas[4][_kIp]),
      // ChannelWallet.getAvgRTT(_datas[5][_kIp]),
      // ChannelWallet.getAvgRTT(_datas[6][_kIp]),
    ]).then((e) {
      print(e); //[true,true,false]
      int i = 0;
      for (i = 0; i < e.length; i++) {
        _datas[i][_kPingValue] = e[i] + "ms";
      }
      setState(() {});
    }).catchError((e) {});
  }


  Widget _getCellWidget(int index) {
    Map map = _datas[index];
    return GestureDetector(
      onTap: () => {
        _cellTap(Constant.getCoinType(map[_kChainType]).index),
      },
      child: Container(
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
              Row(
                children: <Widget>[
                  Image.asset(
                    Constant.ASSETS_IMG + "wallet/" + map[_kImageName],
                    fit: BoxFit.cover,
                    scale: 2,
                  ),
                  OffsetWidget.hGap(9),
                  Text(
                    map[_kContent],
                    style: TextStyle(
                      color: Color(0xff586883),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              OffsetWidget.hGap(9),
              Expanded(
                child: Text(
                  map[_kIp],
                  textWidthBasis: TextWidthBasis.parent,
                  maxLines: 1,
                  style: TextStyle(
                    color: Color(0XFFACBBCF),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              OffsetWidget.hGap(9),
              Row(
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    width: 60,
                    color: Colors.white,
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Text(
                      map[_kPingValue],
                      style: TextStyle(
                          color: Color(0xff586883),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  OffsetWidget.hGap(15),
                  Image.asset(
                    Constant.ASSETS_IMG + "icon/arrow_black_right.png",
                    fit: BoxFit.cover,
                    scale: 3.0,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _cellTap(int chainType) {
    Map<String, dynamic> params = {};
    params["chainType"] = chainType;
    Routers.push(context, Routers.nodeAddPage, params: params).then((value) => {
      _getAllNodes(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
      hiddenScrollView: true,
      title: Text("nodelist_title".local(),
          style: TextStyle(
              fontSize: OffsetWidget.setSp(17), color: Color(0xFF4A4A4A))),
      child: ListView.builder(
        itemCount: _datas.length,
        itemBuilder: (BuildContext context, int index) {
          return _getCellWidget(index);
        },
      ),
    );
  }
}
