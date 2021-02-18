import 'package:flutter_coinid/channel/channel_memo.dart';
import 'package:flutter_coinid/public.dart';
import 'package:flutter_coinid/utils/screenutil.dart';

class BackupMemoPage extends StatefulWidget {
  BackupMemoPage({
    Key key,
    this.params,
  }) : super(key: key);
  Map params = Map();
  @override
  _BackupMemoPageState createState() => _BackupMemoPageState();
}

// column
//img
//text
//text
//memos
//row 中文助记词 英文助记词
//row 通用助记词 Coinid专用助记词
class _BackupMemoPageState extends State<BackupMemoPage> {
  int memoLanguageType = 0; //当前中文 还是英文
  int memoType = 0; //当前通用 还是专用
  bool isBackUp = false; //是否是备份
  ChannelMemosObjects memoObjects;
  @override
  void initState() {
    super.initState();
    _getMemosValue();
  }

  Future<void> _getMemosValue() async {
    try {
      if (widget.params.containsKey("memoCount") == true) {
        String memoCount = "";
        memoCount = widget.params["memoCount"][0];
        MemoCount count =
            MemoCount.values.firstWhere((e) => e.toString() == memoCount);
        ChannelMemosObjects objects =
            await ChannelMemos.createWalletMemo(count);

        setState(() {
          isBackUp = false;
          memoObjects = objects;
        });
      } else {
        String memo = "";
        int leadType = 0;
        memo = widget.params["memo"][0];
        leadType = int.tryParse((widget.params["leadType"][0]));
        ChannelMemosObjects object = ChannelMemosObjects();
        if (leadType == MLeadType.MLeadType_Memo.index) {
          object.cnMemos = memo.split(" ");
          memoType = 1;
        } else {
          object.cnStandMemos = memo.split(" ");
          memoType = 0;
        }
        setState(() {
          isBackUp = true;
          memoObjects = object;
        });
      }
    } catch (e) {
      print("_getMemosValue " + e.toString());
    }
  }

  void _updateMemoWidgetValue(int language, int type) {
    setState(() {
      memoLanguageType = language;
      memoType = type;
    });
  }

  List<dynamic> _getMemoContents(int language, int type) {
    LogUtil.v("_getMemoContents language $language type $type");
    LogUtil.v("memoObjects  " + memoObjects.toJson().toString());
    List values = [];
    if (memoLanguageType == 0 && memoType == 0) {
      values = memoObjects.cnStandMemos;
    }
    if (memoLanguageType == 0 && memoType == 1) {
      values = memoObjects.cnMemos;
    }
    if (memoLanguageType == 1 && memoType == 0) {
      values = memoObjects.enStandMemos;
    }
    if (memoLanguageType == 1 && memoType == 1) {
      values = memoObjects.enMemos;
    }
    return values ??= [];
  }

  void _nextPage() {
    Map<String, dynamic> object = Map.from(widget.params);
    List<dynamic> paramsLists = _getMemoContents(memoLanguageType, memoType);
    object["paramsLists"] = paramsLists;
    object["memoLanguageType"] = memoLanguageType;
    object["memoType"] = memoType;
    object["isBackUp"] = isBackUp;
    Routers.push(context, Routers.verifyMemoPage, params: object);
  }

  Widget _getMemoContentWidget() {
    if (memoObjects == null) {
      return Text("data");
    }
    List values = [];
    values = _getMemoContents(memoLanguageType, memoType);
    int row = values.length == 12 ? 3 : 6;
    double spacing = 10;
    double leftoffset = 20;
    double width =
        (ScreenUtil.screenWidth - leftoffset * 4 - ((row - 1) * spacing)) / row;

    List<Widget> singleTexts = [];
    for (String item in values) {
      singleTexts.add(
        Container(
          constraints: BoxConstraints(
            minWidth: width,
          ),
          child: Text(
            item,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF000000),
            ),
          ),
        ),
      );
    }
    return Container(
      margin: EdgeInsets.only(top: 15, left: leftoffset, right: leftoffset),
      padding: EdgeInsets.only(
          top: 15, left: leftoffset, bottom: 15, right: leftoffset),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Color(0xffD3D3D3),
                offset: Offset(3, 3),
                blurRadius: 3.0,
                spreadRadius: 1.0)
          ]),
      child: Wrap(
        spacing: spacing,
        runSpacing: 11.0,
        alignment: WrapAlignment.start,
        children: singleTexts,
      ),
    );
  }

  Widget _getMemoTypeWidget() {
    if (memoObjects == null) {
      return Text("data");
    }
    List<Widget> widgets = [];
    if (isBackUp == false) {
      widgets.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () => {
                LogUtil.v("点击中文"),
                _updateMemoWidgetValue(0, memoType),
              },
              child: Container(
                alignment: Alignment.center,
                height: OffsetWidget.setSc(30),
                child: Text(
                  "create_cnmemo".local(),
                  style: TextStyle(
                    color: memoLanguageType == 0
                        ? Color(0xFF1308FE)
                        : Color(0xFFACBBCF),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => {
                LogUtil.v("点击英文"),
                _updateMemoWidgetValue(1, memoType),
              },
              child: Container(
                alignment: Alignment.center,
                height: OffsetWidget.setSc(30),
                child: Text(
                  "create_enmemo".local(),
                  style: TextStyle(
                    color: memoLanguageType == 1
                        ? Color(0xFF1308FE)
                        : Color(0xFFACBBCF),
                  ),
                ),
              ),
            ),
          )
        ],
      ));
    }
    return Column(
      children: widgets,
    );
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
            "create_backupmemo".local(),
            style: TextStyle(
                color: Color(0xFF000000),
                fontSize: OffsetWidget.setSp(18),
                fontWeight: FontWeight.w400),
          ),
          OffsetWidget.vGap(40),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Text(
              isBackUp == false ? "create_backupmemodesc".local() : "",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xff9B9B9B),
                  fontSize: OffsetWidget.setSp(12),
                  fontWeight: FontWeight.w400),
            ),
          ),
          _getMemoContentWidget(),
          OffsetWidget.vGap(20),
          _getMemoTypeWidget(),
          OffsetWidget.vGap(60),
          GestureDetector(
            onTap: _nextPage,
            child: Container(
              height: OffsetWidget.setSc(40),
              width: OffsetWidget.setSc(162),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(OffsetWidget.setSc(50)),
                  color: Color(0xFF1308FE)),
              child: Text(
                "comfirm_trans".local(),
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: OffsetWidget.setSp(16),
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
