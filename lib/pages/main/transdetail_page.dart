import 'package:flutter/services.dart';
import 'package:flutter_coinid/models/transrecord/trans_record.dart';
import 'package:flutter_coinid/utils/sharedPrefer.dart';

import '../../public.dart';

class TransDetailPage extends StatefulWidget {
  TransDetailPage({Key key, this.params}) : super(key: key);

  final Map params;

  @override
  _TransDetailPageState createState() => _TransDetailPageState();
}

class _TransDetailPageState extends State<TransDetailPage> {
  static const String leftKey = "leftKey";
  static const String rightKey = "rightKey";
  MHTransRecordModel transMdel;
  List cellDatas = [];
  String transState = "";
  String value = "";
  String assets = "";
  String price = "";

  @override
  void initState() {
    super.initState();

    if (widget.params != null) {
      String transStr = widget.params["transModel"][0];
      transMdel = MHTransRecordModel.fromString(transStr);
      price = widget.params["price"][0] ??= "0";
      initData();
    }
  }

  void initData() async {
    if (transMdel == null) {
      return;
    }
    int amountType = await getAmountValue();
    setState(() {
      value = transMdel.isOut == true
          ? ("-" + transMdel.amount)
          : ("+" + transMdel.amount);
      value += transMdel.token ??= transMdel.coinType ??= "";
      assets = "≈" + (amountType == 0 ? "￥" : "\$");
      assets += (double.tryParse(transMdel.amount) * double.tryParse(price))
          .toStringAsFixed(2);
      if (transMdel.transStatus == MTransState.MTransState_Success.index) {
        transState = "payment_transsuccess".local();
      } else {
        transState = "payment_transfailere".local();
      }
      cellDatas = [
        {
          leftKey: "paymentdetail_fromaddress".local(),
          rightKey: transMdel.from ??= "",
        },
        {
          leftKey: "paymentdetail_toaddress".local(),
          rightKey: transMdel.to ??= "",
        },
        {
          leftKey: "paymentdetail_chaintxid".local(),
          rightKey: transMdel.txid ??= "",
          "color": 0xFF1308FE
        },
        {
          leftKey: "payment_remark".local(),
          rightKey: transMdel.remarks ??= "",
        },
        {
          leftKey: "paymentdetail_time".local(),
          rightKey: transMdel.date ??= "",
        },
        {
          leftKey: "paymentdetail_blockh".local(),
          rightKey: transMdel.blocknumber ??= "",
        }
      ];
    });
  }

  void _clickCopy(String value) {
    LogUtil.v("_clickCopy " + value);
    if (value.isValid() == false) return;
    Clipboard.setData(ClipboardData(text: value));
    HWToast.showText(text: "copy_success".local());
  }

  Widget buildCell(int index) {
    Map params = cellDatas[index];

    return Container(
      height: OffsetWidget.setSc(60),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: OffsetWidget.setSc(60),
                    child: Text(params[leftKey],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF4A4A4A),
                          fontSize: OffsetWidget.setSp(14),
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                  OffsetWidget.hGap(22),
                  Container(
                    width: OffsetWidget.setSc(180),
                    child: Text(params[rightKey],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: params.containsKey("color")
                              ? Color(params["color"])
                              : Color(0xFF4A4A4A),
                          fontSize: OffsetWidget.setSp(14),
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ],
              ),
              Visibility(
                  visible: index < 2 ? true : false,
                  child: GestureDetector(
                    onTap: () => _clickCopy(params[rightKey]),
                    child: LoadAssetsImage(
                      Constant.ASSETS_IMG + "icon/icon_copy.png",
                      color: Colors.black,
                      width: 11,
                      height: 11,
                    ),
                  )),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            color: Color(Constant.TextFileld_FocuseCOlor),
            height: 1,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
      hiddenScrollView: true,
      title: Text(
        "trans_detail".local(),
        style: TextStyle(
            color: Color(0xFF000000),
            fontWeight: FontWeight.w400,
            fontSize: OffsetWidget.setSc(18)),
      ),
      child: Container(
        margin: EdgeInsets.only(
            left: OffsetWidget.setSc(28),
            right: OffsetWidget.setSc(28),
            top: OffsetWidget.setSc(30)),
        child: cellDatas.length == 0
            ? EmptyDataPage()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: OffsetWidget.setSc(30),
                    constraints: BoxConstraints(
                      minWidth: OffsetWidget.setSc(100),
                    ),
                    padding: EdgeInsets.only(
                        left: OffsetWidget.setSc(20),
                        top: OffsetWidget.setSc(5),
                        right: OffsetWidget.setSc(20)),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        border: Border.all(color: Color(0xFF1308FE), width: 1)),
                    child: Text(
                      transState,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1308FE),
                          fontSize: OffsetWidget.setSp(14)),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                        top: OffsetWidget.setSc(16),
                        bottom: OffsetWidget.setSc(60)),
                    alignment: Alignment.center,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding:
                              EdgeInsets.only(right: OffsetWidget.setSc(20)),
                          constraints:
                              BoxConstraints(maxWidth: OffsetWidget.setSc(250)),
                          child: Text(
                            value,
                            style: TextStyle(
                              fontSize: OffsetWidget.setSp(30),
                              color: Color(0xFF000000),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: Text(assets,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: OffsetWidget.setSp(12),
                                color: Color(0xFF1308FE),
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cellDatas.length,
                      itemBuilder: (BuildContext context, int index) {
                        return buildCell(index);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
