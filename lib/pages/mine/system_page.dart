import 'package:flutter_coinid/channel/channel_wallet.dart';
import 'package:flutter_coinid/net/wallet_services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../public.dart';

class SystemPage extends StatefulWidget {
  @override
  _SystemPageState createState() => _SystemPageState();
}

class _SystemPageState extends State<SystemPage> {
  List allDatas = List();
  int page = 1;
  int pageSize = 10;
  String _imei = "";

  @override
  void initState() {
    super.initState();
    _getAppInfo();
  }

  void _getAppInfo() async {
    _imei = await ChannelWallet.deviceImei();
    _getDatas();
  }

  _getDatas() {
    WalletServices.requestGetSystemMessage(_imei, page, pageSize,
        (result, code) {
      refreshController.loadComplete();
      refreshController.refreshCompleted(resetFooterState: true);
      if (code == 200 && mounted) {
        allDatas.addAll(result);
        setState(() {});
      }
    });
  }

  _readMsg(Map map) {
    WalletServices.requestClickSystemMessage(_imei, map["id"], (result, code) {
      if (mounted) {
        setState(() {
          map["state"] = 0;
        });
        Map<String, dynamic> params = {};
        params["title"] = map["title"];
        params["content"] = map["message"];
        params["team"] = map["author"];
        params["date"] = map["dataTime"];
        Routers.push(context, Routers.msgSystemDetailPage, params: params);
      }
    });
  }

  Widget _buildCell(int index) {
    Map map = allDatas[index];
    return Center(
      child: GestureDetector(
        onTap: () {
          _readMsg(map);
        },
        child: Container(
          width: OffsetWidget.setSc(322),
          height: OffsetWidget.setSc(48),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color(0xFFF6F9FC),
          ),
          padding: EdgeInsets.fromLTRB(
              OffsetWidget.setSc(13),
              OffsetWidget.setSc(7),
              OffsetWidget.setSc(13),
              OffsetWidget.setSc(10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(map["title"],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: OffsetWidget.setSp(12),
                      color: map["state"] == 1 ? Color(0xFF586883) : Color(0xFFACBBCF))),
              OffsetWidget.vGap(5),
              Text(map["message"],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: OffsetWidget.setSp(10),
                      color: map["state"] == 1 ? Color(0xFF586883) : Color(0xFFACBBCF))),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> getBarAction() {
    return <Widget>[
      Container(
        margin: EdgeInsets.only(right: OffsetWidget.setSc(10)),
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

  _readAll() {
    WalletServices.requestClickSystemMessageAllRead(_imei, (result, code) {
      if (mounted) {
        page = 1;
        allDatas.clear();
        _getDatas();
      }
    });
  }

  TextEditingController searchEC = TextEditingController();
  RefreshController refreshController = RefreshController(
    initialRefresh: false,
  );
  @override
  Widget build(BuildContext context) {
    OffsetWidget.screenInit(context, 360);
    return CustomPageView(
      title: Text("msg_system".local(),
          style: TextStyle(
              fontSize: OffsetWidget.setSp(17), color: Color(0xFF4A4A4A))),
      hiddenScrollView: true,
      actions: getBarAction(),
      child: CustomRefresher(
        refreshController: refreshController,
        onRefresh: () {
          page = 1;
          allDatas.clear();
          _getDatas();
        },
        onLoading: () {
          page++;
          _getDatas();
        },
        child: ListView.builder(
          itemCount: allDatas.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildCell(index);
          },
        ),
      ),
    );
  }
}
