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
  TextEditingController nodeEC = TextEditingController();

  List customizeNodes = [];
  List defaultNodes = [];

  Future<List<NodeModel>> _getNodes(bool isOrigin, int chainType) async {
    return await NodeModel.queryNodeByIsOriginAndChainType(isOrigin, chainType);
  }

  Future<String> _getIpPingValue(String url) async {
    return await ChannelWallet.getAvgRTT(url) + "ms";
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.params != null) {
      chainType = int.parse(widget.params["chainType"][0]);
    }
    setState(() {
      nodeEC.text = "https://";
    });
  }

  Widget _buildCell(int index, bool isOrigin) {
    NodeModel nodeModel;
    if (isOrigin) {
      nodeModel = defaultNodes[index];
    } else {
      nodeModel = customizeNodes[index];
    }
    return GestureDetector(
      onTap: () {
        _clickAt(nodeModel);
      },
      child: Container(
        height: OffsetWidget.setSc(43),
        margin: EdgeInsets.only(
            left: OffsetWidget.setSc(28), right: OffsetWidget.setSc(28)),
        child: Column(
          children: [
            OffsetWidget.vGap(16),
            Row(
              children: [
                Container(
                  width: OffsetWidget.setSc(220),
                  child: Text(nodeModel.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: OffsetWidget.setSp(12),
                          color: Color(0xFF9B9B9B))),
                ),
                FutureBuilder(
                  future: _getIpPingValue(nodeModel.content),
                  initialData: "",
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    String ping = snapshot.data;
                    return Container(
                      width: OffsetWidget.setSc(60),
                      child: Text(ping,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: OffsetWidget.setSp(12),
                              color: Color(0xFF4A4A4A))),
                    );
                  },
                ),
                Visibility(
                  visible: nodeModel.isChoose,
                  child: LoadAssetsImage(
                    Constant.ASSETS_IMG + "icon/icon_node_choose.png",
                    width: OffsetWidget.setSc(15),
                    height: OffsetWidget.setSc(15),
                    scale: 1,
                  ),
                ),
              ],
            ),
            OffsetWidget.vGap(11),
            OffsetWidget.vLineWhitColor(1, Color(0xFFCFCFCF)),
          ],
        ),
      ),
    );
  }

  _addNode(BuildContext cxt) {
    _showDialog(cxt, () async {
      String str = nodeEC.text;
      if(!StringUtil.isValidIp(str.replaceAll("https://", ""))&& !StringUtil.isValidIpAndPort(str.replaceAll("https://", "")) && !StringUtil.isValidUrl(str)){
        HWToast.showText(text: "node_error".local());
        return;
      }
      if (StringUtil.isNotEmpty(str) &&str != "https://") {
        List<NodeModel> nodes = await NodeModel.queryNodeByContentAndChainType(
            str, chainType);
        if (nodes != null && nodes.length > 0) {
          HWToast.showText(text: "node_exists".local());
        } else {
          NodeModel node = NodeModel(str, chainType, false, false,
              MNodeNetType.MNodeNetType_Main.index);
          bool flag = await NodeModel.insertNodeData(node);
          if (flag) {
            customizeNodes.add(node);
            Navigator.pop(context);
            setState(() {
              
            });
          }
        }
      } else {
        HWToast.showText(text: "node_add_input".local());
      }
    }, () {});
  }

  _clickAt(NodeModel nodeModel) async {
    List<NodeModel> nodes = [];
    defaultNodes.forEach((element) {
      NodeModel node = element;
      if (node.content == nodeModel.content &&
          node.chainType == nodeModel.chainType) {
        node.isChoose = true;
      } else {
        node.isChoose = false;
      }
      nodes.add(node);
    });

    customizeNodes.forEach((element) {
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

  _showDialog(BuildContext cxt, ok(), cancel()) {
    showCupertinoDialog<int>(
        context: cxt,
        builder: (cxt) {
          return CupertinoAlertDialog(
            title: Text("node_add_custom".local(),
                style: TextStyle(
                    fontSize: OffsetWidget.setSp(13),
                    color: Color(0xFF4A4A4A))),
            content: Card(
              elevation: 0.0,
              child: Container(
                width: OffsetWidget.setSc(200),
                child: CustomTextField(
                  controller: nodeEC,
                  maxLines: 1,
                  fillColor: Colors.white,
                  obscureText: false,
                  contentPadding: EdgeInsets.all(OffsetWidget.setSc(8)),
                ),
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("dialog_cancel".local(),
                    style: TextStyle(
                        fontSize: OffsetWidget.setSp(13),
                        color: Color(0xFF9B9B9B))),
                onPressed: () {
                  setState(() {
                    nodeEC.text = "https://";
                  });
                  Navigator.pop(context);
                  cancel();
                },
              ),
              CupertinoDialogAction(
                child: Text("dialog_confirm".local(),
                    style: TextStyle(
                        fontSize: OffsetWidget.setSp(13),
                        color: Color(0xFF4A4A4A))),
                onPressed: () {
                  ok();
                  setState(() {
                    nodeEC.text = "https://";
                  });
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    OffsetWidget.screenInit(context, 360);
    return CustomPageView(
      hiddenScrollView: true,
      hiddenResizeToAvoidBottomInset: false,
      title: Text(Constant.getChainSymbol(chainType),
          style: TextStyle(
              fontSize: OffsetWidget.setSp(17), color: Color(0xFF4A4A4A))),
      child: Column(
        children: [
          Container(
            height: OffsetWidget.setSc(430),
            child: Column(
              children: [
                OffsetWidget.vGap(OffsetWidget.setSc(32)),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(
                      left: OffsetWidget.setSc(28),
                      right: OffsetWidget.setSc(28),
                      bottom: OffsetWidget.setSc(10)),
                  child: Text(
                    "node_default".local(),
                    style: TextStyle(
                        fontSize: OffsetWidget.setSp(13),
                        color: Color(0xFF4A4A4A)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      left: OffsetWidget.setSc(28),
                      right: OffsetWidget.setSc(28)),
                  child: OffsetWidget.vLineWhitColor(1, Color(0xFFCFCFCF)),
                ),
                FutureBuilder(
                  future: _getNodes(true, chainType),
                  initialData: [],
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    List nodes = snapshot.data;
                    if (nodes != null && nodes.length > 0) {
                      defaultNodes.clear();
                      defaultNodes.addAll(nodes);
                    }
                    return Container(
                        height: OffsetWidget.setSc(50),
                        child: ListView.builder(
                          itemCount: defaultNodes.length,
                          itemBuilder: (BuildContext context, int index) {
                            return _buildCell(index, true);
                          },
                        ));
                  },
                ),
                OffsetWidget.vGap(OffsetWidget.setSc(14)),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(
                      left: OffsetWidget.setSc(28),
                      right: OffsetWidget.setSc(28),
                      bottom: OffsetWidget.setSc(10)),
                  child: Text(
                    "node_custom".local(),
                    style: TextStyle(
                        fontSize: OffsetWidget.setSp(13),
                        color: Color(0xFF4A4A4A)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      left: OffsetWidget.setSc(28),
                      right: OffsetWidget.setSc(28)),
                  child: OffsetWidget.vLineWhitColor(1, Color(0xFFCFCFCF)),
                ),
                FutureBuilder(
                  future: _getNodes(false, chainType),
                  initialData: [],
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    List nodes = snapshot.data;
                    if (nodes != null && nodes.length > 0) {
                      customizeNodes.clear();
                      customizeNodes.addAll(nodes);
                    }
                    return Container(
                        height: OffsetWidget.setSc(260),
                        child: ListView.builder(
                          itemCount: customizeNodes.length,
                          itemBuilder: (BuildContext context, int index) {
                            return _buildCell(index, false);
                          },
                        ));
                  },
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              _addNode(context);
            },
            child: Container(
              margin: EdgeInsets.only(
                  left: OffsetWidget.setSc(30),
                  top: OffsetWidget.setSc(30),
                  right: OffsetWidget.setSc(30)),
              height: OffsetWidget.setSc(38),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(OffsetWidget.setSc(50)),
                  color: Color(0xFF1308FE)),
              child: Text(
                "node_add_custom".local(),
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: OffsetWidget.setSp(13),
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
