import '../../public.dart';

class ChooseCreateTypePage extends StatefulWidget {
  ChooseCreateTypePage({
    Key key,
    this.isMSW,
  }) : super(key: key);

  bool isMSW = true;

  @override
  _ChooseCreateTypePageState createState() => _ChooseCreateTypePageState();
}

class _ChooseCreateTypePageState extends State<ChooseCreateTypePage> {
  bool isMSW = true;

  @override
  void initState() {
    super.initState();
    bool isMSW = widget.isMSW;
  }

  @override
  Widget build(BuildContext context) {
    OffsetWidget.screenInit(context, 360);
    return CustomPageView(
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: OffsetWidget.setSc(120)),
            child: Image.asset(
              Constant.ASSETS_IMG + "icon/icon_app.png",
              fit: BoxFit.cover,
              scale: 2,
              width: OffsetWidget.setSc(91),
              height: OffsetWidget.setSc(91),
            ),
          ),
          OffsetWidget.vGap(228),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => {
                  Routers.push(context, Routers.createPage),
                },
                child: Container(
                  height: OffsetWidget.setSc(38),
                  width: OffsetWidget.setSc(92),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF1308FE)),
                      borderRadius:
                          BorderRadius.circular(OffsetWidget.setSc(38)),
                      color: Color(0xFF1308FE)),
                  child: Text(
                    "create_wallet".local(),
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: OffsetWidget.setSp(13),
                        color: Colors.white),
                  ),
                ),
              ),
              OffsetWidget.hGap(36),
              GestureDetector(
                onTap: () => {
                  Routers.push(context, Routers.restorePage),
                },
                child: Container(
                  height: OffsetWidget.setSc(38),
                  width: OffsetWidget.setSc(92),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF1308FE)),
                      borderRadius:
                          BorderRadius.circular(OffsetWidget.setSc(38)),
                      color: Color(0xffffffff)),
                  child: Text(
                    "restore_wallet".local(),
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: OffsetWidget.setSp(13),
                        color: Color(0xFF1308FE)),
                  ),
                ),
              ),
            ],
          ),
          OffsetWidget.vGap(10),
          Offstage(
            offstage: isMSW,
            child: GestureDetector(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  width: OffsetWidget.setSc(162),
                  height: OffsetWidget.setSc(40),
                  color: Color.fromARGB(255, 0, 245, 255),
                  child: Center(
                    child: Text(
                      "restore_mswwallet",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
