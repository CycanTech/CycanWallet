import 'package:flutter_coinid/net/wallet_services.dart';
import 'package:flutter_coinid/widgets/custom_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../public.dart';

class AddAssetsPage extends StatefulWidget {
  AddAssetsPage({
    Key key,
    this.params,
  }) : super(key: key);
  Map params = Map();
  @override
  _AddAssetsPageState createState() => _AddAssetsPageState();
}

class _AddAssetsPageState extends State<AddAssetsPage> {
  List allDatas = List();
  String symbol = "";
  String account = "";
  TextEditingController searchEC = TextEditingController();
  RefreshController refreshController = RefreshController(
    initialRefresh: false,
  );

  _getAssets() {
    Future.delayed(Duration(seconds: 2)).then((value) => {
          refreshController.refreshCompleted(),
          refreshController.loadComplete(),
        });

    WalletServices.requestFindTokensData(account, searchEC.text, symbol,
        (result, code) {
      if (code == 200 && mounted) {
        setState(() {
          allDatas = result;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.params != null) {
      symbol = widget.params["symbol"][0];
      account = widget.params["account"][0];
      _getAssets();
    }
  }

  Widget _buildCell(int index) {
    Map<String, dynamic> map = allDatas[index];
    return Container(
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage(
            Constant.ASSETS_IMG + "background/bg_item.png",
          ),
          fit: BoxFit.fill,
        ),
      ),
      margin: EdgeInsets.only(
          left: OffsetWidget.setSc(19),
          right: OffsetWidget.setSc(19),
          bottom: OffsetWidget.setSc(10)),
      height: OffsetWidget.setSp(48),
      child: Row(
        children: [
          OffsetWidget.hGap(10),
          StringUtil.isNotEmpty(map["iconPath"])
              ? LoadNetworkImage(
                  map["iconPath"],
                  width: OffsetWidget.setSc(30),
                  height: OffsetWidget.setSc(30),
                  fit: BoxFit.contain,
                  scale: 1,
                )
              : LoadAssetsImage(
                  Constant.ASSETS_IMG +
                      "wallet/icon_" +
                      symbol.toLowerCase() +
                      "_token_default.png",
                  width: OffsetWidget.setSc(30),
                  height: OffsetWidget.setSc(30),
                  fit: BoxFit.contain,
                  scale: 1,
                ),
          OffsetWidget.hGap(9),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: OffsetWidget.setSc(220),
                child: Text(
                  map["token"],
                  style: TextStyle(
                      fontSize: OffsetWidget.setSp(15),
                      color: Color(0xFF586883)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: OffsetWidget.setSc(220),
                child: Text(
                  map["contract"],
                  style: TextStyle(
                      fontSize: OffsetWidget.setSp(10),
                      color: Color(0xFFACBBCF)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          OffsetWidget.hGap(9),
          GestureDetector(
            onTap: () {
              _collectToken(index);
            },
            child: Container(
              height: OffsetWidget.setSp(48),
              child: LoadAssetsImage(
                map["state"] == 1
                    ? Constant.ASSETS_IMG + "icon/icon_switch_close.png"
                    : Constant.ASSETS_IMG + "icon/icon_switch_open.png",
                width: OffsetWidget.setSc(29),
                height: OffsetWidget.setSc(13),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _collectToken(int index) {
    Map<String, dynamic> map = allDatas[index];
    WalletServices.requestCollectionToken(account, map["id"], symbol,
        (result, code) {
      if (code == 200) {
        setState(() {
          if (map["state"] == 1) {
            map["state"] = 0;
          } else {
            map["state"] = 1;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    OffsetWidget.screenInit(context, 360);
    return CustomPageView(
      hiddenAppBar: true,
      hiddenScrollView: true,
      hiddenResizeToAvoidBottomInset: false,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(
                OffsetWidget.setSc(0),
                OffsetWidget.setSc(7),
                OffsetWidget.setSc(19),
                OffsetWidget.setSc(7)),
            height: OffsetWidget.setSc(42),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Routers.goBackWithParams(context, null);
                  },
                  child: LoadAssetsImage(
                    Constant.ASSETS_IMG + "icon/icon_goback.png",
                    width: OffsetWidget.setSc(45),
                    height: OffsetWidget.setSc(45),
                    fit: BoxFit.contain,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: OffsetWidget.setSp(54),
                    color: Color(Constant.TextFileld_FillColor),
                    child: Row(
                      children: [
                        OffsetWidget.hGap(10),
                        LoadAssetsImage(
                          Constant.ASSETS_IMG + "icon/icon_search.png",
                          width: OffsetWidget.setSc(13),
                          height: OffsetWidget.setSc(13),
                          fit: BoxFit.contain,
                        ),
                        Container(
                          width: OffsetWidget.setSc(270),
                          height: OffsetWidget.setSp(54),
                          child: CustomTextField(
                            controller: searchEC,
                            maxLines: 1,
                            hiddenBorderSide: false,
                            onSubmitted: (value) {
                              _getAssets();
                            },
                            fillColor: Color(Constant.TextFileld_FillColor),
                            hintText: "search_token_hit".local(),
                            hintStyle: TextStyle(
                                fontSize: OffsetWidget.setSp(10),
                                color: Color(0xFFACBBCF)),
                            contentPadding:
                                EdgeInsets.all(OffsetWidget.setSp(4)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: OffsetWidget.setSc(360),
            margin: EdgeInsets.only(
                left: OffsetWidget.setSc(33),
                top: OffsetWidget.setSc(8),
                bottom: OffsetWidget.setSc(10)),
            child: Text(
              "search_token_title".local(),
              style: TextStyle(
                  fontSize: OffsetWidget.setSp(12), color: Color(0xFF586883)),
            ),
          ),
          Expanded(
            child: CustomRefresher(
              refreshController: refreshController,
              onRefresh: () {
                _getAssets();
              },
              enableHeader: false,
              child: ListView.builder(
                itemCount: allDatas.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildCell(index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
