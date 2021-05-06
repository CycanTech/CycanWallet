import '../../public.dart';

class ApplicationSearch extends StatefulWidget {
  ApplicationSearch({Key key}) : super(key: key);

  @override
  _ApplicationSearchState createState() => _ApplicationSearchState();
}

class _ApplicationSearchState extends State<ApplicationSearch> {
  TextEditingController _searchEC = TextEditingController();
  bool isSearch = true;

  List<String> popularList = [
    "大转盘",
    "Pancakeswap",
    "AAVV",
    "Staking",
    "Pancakeswap"
  ];

  List<String> historyList = [];

  Widget getCustomAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => {
            Routers.goBack(context),
          },
          child: Container(
            height: OffsetWidget.setSc(30),
            padding: EdgeInsets.only(right: 5),
            alignment: Alignment.centerLeft,
            child: LoadAssetsImage(
              Constant.ASSETS_IMG + "icon/icon_goback.png",
              scale: 2,
              fit: null,
            ),
          ),
        ),
        Expanded(
          child: Container(
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
                Icon(
                  Icons.cancel,
                  color: Color(0xFFC5C7D8),
                ),
                OffsetWidget.hGap(10),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget getPopularWidget(List<String> datas, String imgName, String title) {
    return Padding(
      padding: EdgeInsets.only(
        top: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LoadAssetsImage(
                Constant.ASSETS_IMG + imgName,
                width: 14,
                height: 15,
              ),
              OffsetWidget.hGap(8),
              Text(
                title,
                style: TextStyle(
                  color: Color(0xFF000000),
                  fontSize: OffsetWidget.setSp(15),
                  fontWeight: FontWightHelper.semiBold,
                ),
              ),
            ],
          ),
          OffsetWidget.vGap(20),
          Wrap(
            spacing: 10,
            runSpacing: 13,
            alignment: WrapAlignment.start,
            children: datas
                .map((e) => Container(
                      height: OffsetWidget.setSc(25),
                      padding: EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Color(0xFFF6F8F9),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            e,
                            style: TextStyle(
                              color: Color(0xFF586883),
                              fontSize: OffsetWidget.setSp(14),
                              fontWeight: FontWightHelper.regular,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
      hiddenAppBar: true,
      hiddenLeading: true,
      hiddenScrollView: true,
      child: Container(
        padding: EdgeInsets.only(
            right: OffsetWidget.setSc(21),
            top: 5,
            left: OffsetWidget.setSc(21)),
        child: isSearch == true
            ? Column(
                children: [
                  getCustomAppBar(),
                  getPopularWidget(
                    popularList,
                    "icon/icon_goback.png",
                    "applic_popularsearch".local(),
                  ),
                  getPopularWidget(
                    historyList,
                    "icon/icon_goback.png",
                    "applic_historysearch".local(),
                  ),
                ],
              )
            : Column(
                children: [
                  getCustomAppBar(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 5,
                      itemBuilder: (BuildContext context, int index) {
                        return getCustomAppBar();
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
