import 'package:flutter_coinid/channel/channel_dapp.dart';
import 'package:flutter_coinid/net/wallet_services.dart';
import 'package:flutter_coinid/widgets/custom_network_image.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import '../../public.dart';

class ApplicationPage extends StatefulWidget {
  @override
  _ApplicationPageState createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  List<Map> _imageUrls = [
    {
      "linkImage":
          "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fyouimg1.c-ctrip.com%2Ftarget%2Ftg%2F035%2F063%2F726%2F3ea4031f045945e1843ae5156749d64c.jpg&refer=http%3A%2F%2Fyouimg1.c-ctrip.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1622339396&t=4a4f88f41d046c201f60d0f38bfdcb88"
    }
  ];
  List<Map> _items = [{}, {}];
  TextEditingController _searchEC = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // ChannelDapp.addMethodListener();
    _getBannerDatas();
  }

  void _getBannerDatas() {
    // WalletServices.getOtherLinkImageDatas("eos", (result, code) {
    //   if (code == 200 && mounted) {
    //     _imageUrls = result;
    //     setState(() {});
    //   }
    // });
  }

  void _tapItem(int index) {
    LogUtil.v("_tapItem " + index.toString());
  }

  Widget _buildHistoryItem(int index) {
    // Map map = _items[index];
    String url =
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fyouimg1.c-ctrip.com%2Ftarget%2Ftg%2F035%2F063%2F726%2F3ea4031f045945e1843ae5156749d64c.jpg&refer=http%3A%2F%2Fyouimg1.c-ctrip.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1622339396&t=4a4f88f41d046c201f60d0f38bfdcb88";
    return Container(
      alignment: Alignment.center,
      width: OffsetWidget.setSc(40),
      margin: EdgeInsets.only(right: 10),
      child: LoadNetworkImage(
        url,
        placeholder: "",
        fit: BoxFit.cover,
        scale: 1,
      ),
    );
  }

  Widget _buildItem(int index) {
    // Map map = _items[index];
    String url =
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fyouimg1.c-ctrip.com%2Ftarget%2Ftg%2F035%2F063%2F726%2F3ea4031f045945e1843ae5156749d64c.jpg&refer=http%3A%2F%2Fyouimg1.c-ctrip.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1622339396&t=4a4f88f41d046c201f60d0f38bfdcb88";

    String name = "ELP-DPT LP";
    String desc = "Cycan Defi项目";
    String owners = "由 pancakeswap.finance 开发";

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _tapItem(index),
      child: Container(
        alignment: Alignment.center,
        height: OffsetWidget.setSc(62),
        margin: EdgeInsets.only(bottom: OffsetWidget.setSc(18)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LoadNetworkImage(
                url,
                placeholder: "",
                fit: BoxFit.cover,
                scale: 1,
              ),
            ),
            OffsetWidget.hGap(9),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Color(0xFF000000),
                    fontWeight: FontWightHelper.semiBold,
                    fontSize: OffsetWidget.setSp(15),
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    color: Color(0xFFFFA703),
                    fontWeight: FontWightHelper.regular,
                    fontSize: OffsetWidget.setSp(12),
                  ),
                ),
                Text(
                  owners,
                  style: TextStyle(
                    color: Color(0xFFACBBCF),
                    fontWeight: FontWightHelper.regular,
                    fontSize: OffsetWidget.setSp(12),
                  ),
                )
              ],
            ),
          ],
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
      hiddenAppBar: true,
      child: Container(
        padding: EdgeInsets.only(
            left: OffsetWidget.setSc(20),
            top: OffsetWidget.setSc(10),
            right: OffsetWidget.setSc(20)),
        child: Column(
          children: [
            Container(
              height: OffsetWidget.setSc(36),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFFEAEFF2),
                ),
                borderRadius: BorderRadius.circular(
                  OffsetWidget.setSc(18),
                ),
              ),
              child: Row(
                children: [
                  OffsetWidget.hGap(10),
                  Icon(
                    Icons.search,
                    color: Color(0xFFC5C7D8),
                  ),
                  Expanded(
                    child: CustomTextField(
                      controller: _searchEC,
                      maxLines: 1,
                      onSubmitted: (value) {},
                      onChange: (value) async {
                        print("onChange" + value);
                      },
                      decoration: CustomTextField.getBorderLineDecoration(
                        hintText: "applic_search".local(),
                        borderColor: Colors.transparent,
                        hintStyle: TextStyle(
                            fontSize: OffsetWidget.setSp(12),
                            fontWeight: FontWightHelper.medium,
                            color: Color(0xFF929695)),
                      ),
                    ),
                  ),
                  OffsetWidget.hGap(10),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: OffsetWidget.setSc(13)),
              height: OffsetWidget.setSc(156),
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
                      child: Image.network(
                        _imageUrls[index]["linkImage"],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
                pagination: _imageUrls.length > 1 ? SwiperPagination() : null,
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: OffsetWidget.setSc(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        top: OffsetWidget.setSc(17),
                        bottom: OffsetWidget.setSc(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "applic_recentused".local(),
                          style: TextStyle(
                              color: Color(0xFF000000),
                              fontSize: OffsetWidget.setSp(15),
                              fontWeight: FontWightHelper.semiBold),
                        ),
                        Text(
                          "wallets_all".local() + " >",
                          style: TextStyle(
                              color: Color(0xFFACBBCF),
                              fontSize: OffsetWidget.setSp(15),
                              fontWeight: FontWightHelper.semiBold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: OffsetWidget.setSc(40),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 10,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildHistoryItem(index);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: OffsetWidget.setSc(21)),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(right: OffsetWidget.setSc(30)),
                    child: Text(
                      "wallets_all".local(),
                      style: TextStyle(
                          color: Color(0xFF000000),
                          fontSize: OffsetWidget.setSp(15),
                          fontWeight: FontWightHelper.semiBold),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: OffsetWidget.setSc(30)),
                    child: Text(
                      "applic_newproduct".local(),
                      style: TextStyle(
                          color: Color(0xFFACBBCF),
                          fontSize: OffsetWidget.setSp(15),
                          fontWeight: FontWightHelper.semiBold),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: OffsetWidget.setSc(30)),
                    child: Text(
                      "applic_popular".local(),
                      style: TextStyle(
                          color: Color(0xFFACBBCF),
                          fontSize: OffsetWidget.setSp(15),
                          fontWeight: FontWightHelper.semiBold),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (BuildContext context, int index) {
                  return _buildItem(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
