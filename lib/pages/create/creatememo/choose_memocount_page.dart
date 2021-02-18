import 'package:flutter_coinid/public.dart';
import 'package:flutter_coinid/utils/screenutil.dart';

class ChooseCountPage extends StatefulWidget {
  ChooseCountPage({
    Key key,
    this.params,
  }) : super(key: key);
  Map params = Map();

  @override
  _ChooseCountPageState createState() => _ChooseCountPageState();
}

class _ChooseCountPageState extends State<ChooseCountPage> {
  MemoCount memoCount = MemoCount.MemoCount_24;
  Map params = Map();

  @override
  void initState() {
    super.initState();
    Map widgetparams = widget.params;
    memoCount = memoCount;
    params = widgetparams;
  }

  void _updateMemoCount(MemoCount count) {
    setState(() {
      memoCount = count;
    });
  }

  void _generateMemoValue() {
    Map<String, dynamic> urlparams = Map.from(params);
    urlparams["memoCount"] = memoCount;
    Routers.push(context, Routers.backupMemosPage, params: urlparams);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
      child: Column(
        children: <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: OffsetWidget.setSc(65)),
              child: Image.asset(
                Constant.ASSETS_IMG + "icon/create_memo.png",
                width: OffsetWidget.setSc(50),
                height: OffsetWidget.setSc(50),
                fit: BoxFit.contain,
              ),
            ),
          ),
          OffsetWidget.vGap(15),
          Text(
            "create_choosecount".local(),
            style: TextStyle(
                color: Color(0xFF000000),
                fontSize: OffsetWidget.setSp(18),
                fontWeight: FontWeight.w400),
          ),
          OffsetWidget.vGap(90),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              OffsetWidget.hGap(20),
              Expanded(
                child: GestureDetector(
                  onTap: () => {
                    _updateMemoCount(MemoCount.MemoCount_12),
                  },
                  child: Container(
                    height: OffsetWidget.setSc(40),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF1308FE)),
                        borderRadius:
                            BorderRadius.circular(OffsetWidget.setSc(40)),
                        color: memoCount == MemoCount.MemoCount_12
                            ? Color(0xFF1308FE)
                            : Color(0xffffffff)),
                    child: Text(
                      "create_12count".local(),
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: OffsetWidget.setSp(16),
                          color: memoCount == MemoCount.MemoCount_12
                              ? Colors.white
                              : Color(0xFF1308FE)),
                    ),
                  ),
                ),
              ),
              OffsetWidget.hGap(10),
              Expanded(
                child: GestureDetector(
                  onTap: () => {
                    _updateMemoCount(MemoCount.MemoCount_18),
                  },
                  child: Container(
                    height: OffsetWidget.setSc(40),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF1308FE)),
                        borderRadius:
                            BorderRadius.circular(OffsetWidget.setSc(40)),
                        color: memoCount == MemoCount.MemoCount_18
                            ? Color(0xFF1308FE)
                            : Color(0xffffffff)),
                    child: Text(
                      "create_18count".local(),
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: OffsetWidget.setSp(16),
                          color: memoCount == MemoCount.MemoCount_18
                              ? Colors.white
                              : Color(0xFF1308FE)),
                    ),
                  ),
                ),
              ),
              OffsetWidget.hGap(10),
              Expanded(
                child: GestureDetector(
                  onTap: () => {
                    _updateMemoCount(MemoCount.MemoCount_24),
                  },
                  child: Container(
                    height: OffsetWidget.setSc(40),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF1308FE)),
                        borderRadius:
                            BorderRadius.circular(OffsetWidget.setSc(40)),
                        color: memoCount == MemoCount.MemoCount_24
                            ? Color(0xFF1308FE)
                            : Color(0xffffffff)),
                    child: Text(
                      "create_24count".local(),
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: OffsetWidget.setSp(16),
                          color: memoCount == MemoCount.MemoCount_24
                              ? Colors.white
                              : Color(0xFF1308FE)),
                    ),
                  ),
                ),
              ),
              OffsetWidget.hGap(20),
            ],
          ),
          OffsetWidget.vGap(52),
          GestureDetector(
            onTap: _generateMemoValue,
            child: Container(
              height: OffsetWidget.setSc(40),
              width: OffsetWidget.setSc(162),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(OffsetWidget.setSc(50)),
                  color: Color(0xFF1308FE)),
              child: Text(
                "create_memo".local(),
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: OffsetWidget.setSp(16),
                    color: Colors.white),
              ),
            ),
          ),
          OffsetWidget.vGap(20),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: <Widget>[
          //     Image.asset(
          //       Constant.ASSETS_IMG + "icon/mnemonic@2x.png",
          //       width: 30,
          //       height: 30,
          //     ),
          //     Text("助记词是什么？"),
          //   ],
          // ),
        ],
      ),
    );
  }
}
