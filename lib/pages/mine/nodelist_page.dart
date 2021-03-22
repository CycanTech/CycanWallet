import 'package:flutter_coinid/channel/channel_wallet.dart';
import 'package:flutter_coinid/models/node/node_model.dart';

import '../../public.dart';

class NodeListPage extends StatefulWidget {
  @override
  _NodeListPageState createState() => _NodeListPageState();
}

class _NodeListPageState extends State<NodeListPage> {
  static const String _kImageName = "_kImageName";
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
        String symbol =
            Constant.getChainSymbol(element.chainType).toLowerCase();
        Map map = {
          _kImageName: "wallet_$symbol.png",
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
      behavior: HitTestBehavior.opaque,
      onTap: () => {
        _cellTap(Constant.getCoinType(map[_kChainType]).index),
      },
      child: Container(
        margin: EdgeInsets.only(
          left: OffsetWidget.setSc(20),
          right: OffsetWidget.setSc(20),
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFEAEFF2),
              width: 0.5,
            ),
          ),
        ),
        height: OffsetWidget.setSc(77),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                LoadAssetsImage(
                  Constant.ASSETS_IMG + "wallet/" + map[_kImageName],
                  width: OffsetWidget.setSc(36),
                  height: OffsetWidget.setSc(36),
                ),
                OffsetWidget.hGap(12),
                Container(
                  width: OffsetWidget.setSc(180),
                  child: Text(
                    map[_kIp],
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Color(0xFFACBBCF),
                        fontSize: OffsetWidget.setSp(14),
                        fontWeight: FontWightHelper.regular),
                  ),
                ),
              ],
            ),
            OffsetWidget.hGap(12),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      map[_kPingValue],
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Color(0xFF161D2D),
                          fontSize: OffsetWidget.setSp(15),
                          fontWeight: FontWightHelper.regular),
                    ),
                  ),
                  OffsetWidget.hGap(7),
                  LoadAssetsImage(
                    Constant.ASSETS_IMG + "icon/arrow_black_right.png",
                    width: OffsetWidget.setSc(8),
                    height: OffsetWidget.setSc(15),
                  ),
                ],
              ),
            ),
          ],
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
      title: CustomPageView.getDefaultTitle(titleStr: "nodelist_title".local()),
      child: Container(
        padding: EdgeInsets.only(top: OffsetWidget.setSc(11)),
        child: ListView.builder(
          itemCount: _datas.length,
          itemBuilder: (BuildContext context, int index) {
            return _getCellWidget(index);
          },
        ),
      ),
    );
  }
}
