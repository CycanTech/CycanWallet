import 'package:flutter/cupertino.dart';
import 'package:flutter_coinid/channel/channel_wallet.dart';
import 'package:flutter_coinid/models/node/node_model.dart';
import 'package:flutter_coinid/net/chain_services.dart';

import '../../public.dart';

class NodeAddPage extends StatefulWidget {
  NodeAddPage({
    Key key,
    this.params,
  }) : super(key: key);
  Map params = Map();

  @override
  _NodeAddPageState createState() => _NodeAddPageState();
}

class _NodeAddPageState extends State<NodeAddPage> {
  int chainType = 0;
  List<NodeModel> datas = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.params != null) {
      chainType = int.parse(widget.params["chainType"][0]);
    }
  }

  Future<List<NodeModel>> _getNodes(int chainType) async {
    datas = await NodeModel.queryNodeByChainType(chainType);
    return datas;
  }

  Future<String> _getIpPingValue(String url) async {
    return ChannelWallet.getAvgRTT(url);
  }

  Widget _buildCell(NodeModel nodeModel) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _clickAt(nodeModel);
      },
      child: Container(
        height: OffsetWidget.setSc(56),
        margin: EdgeInsets.only(
            left: OffsetWidget.setSc(19), right: OffsetWidget.setSc(19)),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFEAEFF2),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: OffsetWidget.setSc(220),
              child: Text(nodeModel.content,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontWeight: FontWightHelper.regular,
                      fontSize: OffsetWidget.setSp(15),
                      color: Color(0xFFACBBCF))),
            ),
            Row(
              children: [
                FutureBuilder(
                  future: _getIpPingValue(nodeModel.content),
                  initialData: "0",
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    String ping = snapshot.data;
                    return Text(ping + "ms",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: OffsetWidget.setSp(15),
                            fontWeight: FontWightHelper.regular,
                            color: Color(0xFF161D2D)));
                  },
                ),
                OffsetWidget.hGap(15),
                Container(
                  width: OffsetWidget.setSc(22),
                  child: Visibility(
                    visible: nodeModel.isChoose,
                    child: LoadAssetsImage(
                      Constant.ASSETS_IMG + "icon/icon_node_choose.png",
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _addNode() {
    TextEditingController nodeEC = TextEditingController(text: "https://");
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text("node_add_custom".local()),
            content: CupertinoTextField(
              maxLines: 1,
              controller: nodeEC,
              autofocus: true,
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(
                  "dialog_cancel".local(),
                  style: TextStyle(
                    color: Color(0xFFACBBCF),
                    fontSize: OffsetWidget.setSp(14),
                    fontWeight: FontWightHelper.regular,
                  ),
                ),
                onPressed: () {
                  nodeEC.text = "";
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                  child: Text(
                    "dialog_confirm".local(),
                    style: TextStyle(
                      color: Color(0xFF586883),
                      fontSize: OffsetWidget.setSp(14),
                      fontWeight: FontWightHelper.medium,
                    ),
                  ),
                  onPressed: () async {
                    String str = nodeEC.text;
                    Navigator.pop(context);
                    if (!StringUtil.isValidIp(str.replaceAll("https://", "")) &&
                        !StringUtil.isValidIpAndPort(
                            str.replaceAll("https://", "")) &&
                        !StringUtil.isValidUrl(str)) {
                      HWToast.showText(text: "node_error".local());
                      return;
                    }
                    if (StringUtil.isNotEmpty(str) && str != "https://") {
                      List<NodeModel> nodes =
                          await NodeModel.queryNodeByContentAndChainType(
                              str, chainType);
                      if (nodes != null && nodes.length > 0) {
                        HWToast.showText(text: "node_exists".local());
                      } else {
                        NodeModel node = NodeModel(str, chainType, false, false,
                            MNodeNetType.MNodeNetType_Main.index);
                        bool flag = await NodeModel.insertNodeData(node);
                        if (flag) {
                          Navigator.pop(context);
                          setState(() {});
                        }
                      }
                    } else {
                      HWToast.showText(text: "node_add_input".local());
                    }
                  }),
            ],
          );
        });
  }

  _clickAt(NodeModel nodeModel) async {
    List<NodeModel> nodes = [];
    datas.forEach((element) {
      NodeModel node = element;
      if (node.content == nodeModel.content &&
          node.chainType == nodeModel.chainType) {
        node.isChoose = true;
      } else {
        node.isChoose = false;
      }
      nodes.add(node);
    });
    if (nodes.length > 0) {
      bool flag = await NodeModel.updateNodes(nodes);
      if (flag) {
        setState(() {});
      }
    }
    //替换成设置成的节点
    if (nodeModel.chainType == MCoinType.MCoinType_BTC.index) {
      ChainServices.btcMainChain = nodeModel.content;
    } else if (nodeModel.chainType == MCoinType.MCoinType_ETH.index) {
      ChainServices.ethMainChain = nodeModel.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
      hiddenScrollView: true,
      hiddenResizeToAvoidBottomInset: false,
      title: CustomPageView.getDefaultTitle(
          titleStr: Constant.getChainSymbol(chainType)),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(top: OffsetWidget.setSc(40)),
            margin: EdgeInsets.only(
                left: OffsetWidget.setSc(19),
                right: OffsetWidget.setSc(19),
                bottom: OffsetWidget.setSc(15)),
            child: Text(
              "node_default".local(),
              style: TextStyle(
                  fontSize: OffsetWidget.setSp(15),
                  fontWeight: FontWightHelper.medium,
                  color: Color(0xFF161D2D)),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getNodes(chainType),
              initialData: [],
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                List nodes = snapshot.data;
                return ListView.builder(
                  itemCount: nodes.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildCell(nodes[index]);
                  },
                );
              },
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _addNode();
            },
            child: Container(
              margin: EdgeInsets.only(
                  left: OffsetWidget.setSc(54),
                  bottom: OffsetWidget.setSc(90),
                  right: OffsetWidget.setSc(54)),
              height: OffsetWidget.setSc(40),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(OffsetWidget.setSc(10)),
                  border: Border.all(color: Color(0xFF586883)),
                  color: Colors.white),
              child: Text(
                "+ " + "node_add_custom".local(),
                style: TextStyle(
                    fontWeight: FontWightHelper.medium,
                    fontSize: OffsetWidget.setSp(15),
                    color: Color(0xFF586883)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
