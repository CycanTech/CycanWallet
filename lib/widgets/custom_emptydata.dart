import '../public.dart';

class EmptyDataPage extends StatefulWidget {
  EmptyDataPage({Key key, this.refreshAction}) : super(key: key);

  final Function() refreshAction;

  @override
  _EmptyDataPageState createState() => _EmptyDataPageState();
}

class _EmptyDataPageState extends State<EmptyDataPage> {
  @override
  Widget build(BuildContext context) {
    OffsetWidget.screenInit(context, 360);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => {
        if (widget.refreshAction != null)
          {
            widget.refreshAction(),
          }
      },
      child: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadAssetsImage(
              Constant.ASSETS_IMG + "icon/icon_empty.png",
              width: OffsetWidget.setSc(142),
              height: OffsetWidget.setSc(97),
              fit: BoxFit.contain,
            ),
            OffsetWidget.vGap(7),
            Text("empay_data".local(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFACBBCF),
                  fontSize: OffsetWidget.setSp(14),
                  fontWeight: FontWeight.w400,
                )),
          ],
        ),
      ),
    );
  }
}
