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
  int memoLanguageType = 1; //当前中文 还是英文
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
          object.enMemos = memo.split(" ");
          memoType = 1;
        } else {
          object.enStandMemos = memo.split(" ");
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
    List<Widget> singleTexts = [];
    for (String item in values) {
      singleTexts.add(
        Container(
          height: OffsetWidget.setSc(32),
          padding: EdgeInsets.only(
              left: OffsetWidget.setSc(20), right: OffsetWidget.setSc(20)),
          decoration: BoxDecoration(
            color: Color(0xFFF6F8F9),
            borderRadius: BorderRadius.circular(OffsetWidget.setSc(21)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF000000),
                  fontSize: OffsetWidget.setSp(16),
                  fontWeight: FontWightHelper.regular,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.only(
          top: OffsetWidget.setSc(28), bottom: OffsetWidget.setSc(118)),
      alignment: Alignment.topLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 12,
        children: singleTexts,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
      title: CustomPageView.getDefaultTitle(
        titleStr: "create_backupmemo".local(),
        fontSize: 20,
        fontWeight: FontWightHelper.semiBold,
      ),
      child: Container(
        padding: EdgeInsets.only(
            left: OffsetWidget.setSc(20),
            right: OffsetWidget.setSc(20),
            top: OffsetWidget.setSc(27)),
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Text(
              "create_wallettip".local(),
              style: TextStyle(
                color: Color(0xFFF15F4A),
                fontSize: OffsetWidget.setSp(14),
                fontWeight: FontWightHelper.regular,
              ),
            ),
            _getMemoContentWidget(),
            GestureDetector(
              onTap: _nextPage,
              child: Container(
                height: OffsetWidget.setSc(40),
                margin: EdgeInsets.only(
                    left: OffsetWidget.setSc(22),
                    right: OffsetWidget.setSc(22)),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xFFC5D4E9)),
                child: Text(
                  "memo_been_copied".local(),
                  style: TextStyle(
                      fontWeight: FontWightHelper.semiBold,
                      fontSize: OffsetWidget.setSp(20),
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
