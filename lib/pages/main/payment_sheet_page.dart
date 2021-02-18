import '../../public.dart';

class PaymentSheetText {
  String title;
  TextStyle titleStyle;
  String content;
  TextStyle contentStyle;

  PaymentSheetText({
    this.title,
    this.content,
    this.contentStyle,
    this.titleStyle,
  });
}

class PaymentSheet extends StatefulWidget {
  PaymentSheet({Key key, @required this.datas, @required this.nextAction})
      : super(key: key);

  final List<PaymentSheetText> datas;
  final VoidCallback nextAction;

  @override
  _PaymentSheetState createState() => _PaymentSheetState();

  static List<PaymentSheetText> getTransStyleList(
      {String from = "",
      String to = "",
      String amount = "",
      String remark = "",
      String fee = ""}) {
    TextStyle title = TextStyle(
      color: Color(0xFF4A4A4A),
      fontSize: OffsetWidget.setSp(14),
      fontWeight: FontWeight.w400,
    );
    TextStyle value = TextStyle(
      color: Color(0xFF1308FE),
      fontSize: OffsetWidget.setSp(14),
      fontWeight: FontWeight.w400,
    );
    TextStyle content = TextStyle(
      color: Color(0xFF000000),
      fontSize: OffsetWidget.setSp(14),
      fontWeight: FontWeight.w400,
    );
    TextStyle valuecon = TextStyle(
      color: Color(0xFF1308FE),
      fontSize: OffsetWidget.setSp(14),
      fontWeight: FontWeight.w400,
    );

    List<PaymentSheetText> datas = [
      PaymentSheetText(
          title: "payment_transtype".local(),
          content: "payment_transtout".local(),
          titleStyle: title,
          contentStyle: content),
      PaymentSheetText(
          title: "payment_fromaddress".local(),
          content: from,
          titleStyle: title,
          contentStyle: content),
      PaymentSheetText(
          title: "payment_toaddress".local(),
          content: to,
          titleStyle: title,
          contentStyle: content),
      PaymentSheetText(
          title: "payment_value".local(),
          content: amount,
          titleStyle: value,
          contentStyle: valuecon),
      PaymentSheetText(
          title: "payment_remark".local(),
          content: remark,
          titleStyle: title,
          contentStyle: content),
      PaymentSheetText(
          title: "payment_fee".local(),
          content: fee,
          titleStyle: title,
          contentStyle: content),
    ];

    return datas;
  }
}

class _PaymentSheetState extends State<PaymentSheet> {
  void _next() {
    Navigator.pop(context);
    widget.nextAction();
  }

  @override
  Widget build(BuildContext context) {
    OffsetWidget.screenInit(context, 360);
    return Container(
      height: OffsetWidget.setSc(350),
      padding: EdgeInsets.only(top: 18, left: 14, right: 16, bottom: 16),
      child: Column(
        children: [
          Text(
            "paymentsheep_info".local(),
            style: TextStyle(
                color: Color(0xFF4A4A4A),
                fontSize: OffsetWidget.setSp(18),
                fontWeight: FontWeight.w500),
          ),
          OffsetWidget.vGap(25),
          Expanded(
            child: ListView.builder(
              itemCount: widget.datas.length,
              itemBuilder: (BuildContext context, int index) {
                PaymentSheetText sheet = widget.datas[index];
                return Container(
                  constraints: BoxConstraints(minHeight: 45),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: OffsetWidget.setSc(80),
                            child: Text(sheet.title, style: sheet.titleStyle),
                          ),
                          OffsetWidget.hGap(9),
                          Expanded(
                            child:
                                Text(sheet.content, style: sheet.contentStyle),
                          ),
                        ],
                      ),
                      OffsetWidget.vGap(5),
                      Container(
                        alignment: Alignment.center,
                        height: 1,
                        color: Color(Constant.TextFileld_FocuseCOlor),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          GestureDetector(
              onTap: _next,
              child: Container(
                height: OffsetWidget.setSc(40),
                width: OffsetWidget.setSc(96),
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
              )),
        ],
      ),
    );
  }
}
