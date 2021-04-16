import 'package:flutter_coinid/channel/channel_dapp.dart';
import 'package:flutter_coinid/net/wallet_services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import '../../public.dart';

class ApplicationPage extends StatefulWidget {
  @override
  _ApplicationPageState createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  List<Map> _imageUrls = [];
  List<Map> _items = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ChannelDapp.addMethodListener();
    //屏蔽VNS的功能
    // Map map = {
    //   "title": "帮客",
    //   "type": MURLType.Bancor.index,
    //   "des": "基于VNS公链打造的智能积分兑换系统",
    //   "img": Constant.ASSETS_IMG + "icon/web_bancor.png",
    // };
    // _items.add(map);
    // map = {
    //   "title": "VDNS",
    //   "type": MURLType.VDns.index,
    //   "des": "基于VNS公链打造的域名系统",
    //   "img": Constant.ASSETS_IMG + "icon/web_vdns.png",
    // };
    // _items.add(map);
    // map = {
    //   "title": "VDAI",
    //   "type": MURLType.VDai.index,
    //   "des": "基于VNS公链打造的稳定币兑换系统",
    //   "img": Constant.ASSETS_IMG + "icon/web_vdai.png",
    // };
    // _items.add(map);
    Map map = {
      "title": "BTC浏览器",
      "type": MURLType.Links.index,
      "des": "BTC链上交易详情数据",
      "img": Constant.ASSETS_IMG + "wallet/logo_btc.png",
      "url": "https://btc-explorer.coinid.pro/#/BTC/mainnet/home",
    };
    _items.add(map);
    map = {
      "title": "ETH浏览器",
      "type": MURLType.Links.index,
      "des": "ETH链上交易详情数据",
      "img": Constant.ASSETS_IMG + "wallet/logo_eth.png",
      "url": "https://cn.etherscan.com",
    };
    _items.add(map);
    setState(() {});
    _getBannerDatas();
  }

  void _getBannerDatas() {
    WalletServices.getOtherLinkImageDatas("eos", (result, code) {
      if (code == 200 && mounted) {
        _imageUrls = result;
        setState(() {});
      }
    });
  }

  void _tapItem(Map map) {
    if (map["type"] == MURLType.VDai.index) {
      ChannelDapp.pushVdai();
    } else if (map["type"] == MURLType.VDns.index) {
      ChannelDapp.pushVdns();
    } else if (map["type"] == MURLType.Bancor.index) {
      ChannelDapp.pushBancor();
    } else if (map["type"] == MURLType.Links.index) {
      ChannelDapp.pushUrl(map["url"]);
    }
  }

  Widget _buildItem(int index) {
    Map map = _items[index];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _tapItem(map);
      },
      child: Container(
        height: OffsetWidget.setSc(100),
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage(
              Constant.ASSETS_IMG + "background/bg_web_item.png",
            ),
            fit: BoxFit.fill,
          ),
        ),
        child: Container(
          margin: EdgeInsets.only(
              left: OffsetWidget.setSc(30), right: OffsetWidget.setSc(30)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    map["title"],
                    style: TextStyle(
                        fontSize: OffsetWidget.setSp(12),
                        color: Color(0xFF171F24)),
                  ),
                  OffsetWidget.vGap(9),
                  Text(
                    map["des"],
                    style: TextStyle(
                        fontSize: OffsetWidget.setSp(10),
                        color: Color(0xFFFFFFFF)),
                  ),
                ],
              ),
              LoadAssetsImage(
                map["img"],
                width: OffsetWidget.setSc(48),
                height: OffsetWidget.setSc(48),
                fit: BoxFit.contain,
                scale: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    OffsetWidget.screenInit(context, 360);
    return CustomPageView(
      hiddenScrollView: true,
      hiddenLeading: true,
      title: Text("application_title".local(),
          style: TextStyle(
              fontSize: OffsetWidget.setSp(17), color: Color(0xFF4A4A4A))),
      child: Column(
        children: [
          Container(
            height: OffsetWidget.setSc(180),
            child: Swiper(
              itemCount: _imageUrls.length,
              autoplay: _imageUrls.length > 1 ? true : false,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    ChannelDapp.pushUrl(_imageUrls[index]["linkUrl"]);
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                        left: OffsetWidget.setSc(14),
                        right: OffsetWidget.setSc(14),
                        top: OffsetWidget.setSc(10),
                        bottom: OffsetWidget.setSc(10)),
                    child: Image.network(
                      _imageUrls[index]["linkImage"],
                      fit: BoxFit.fill,
                    ),
                  ),
                );
              },
              pagination: _imageUrls.length > 1 ? SwiperPagination() : null,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildItem(index);
              },
            ),
          )
        ],
      ),
    );
  }
}
