import '../public.dart';

class EmptyDataPage extends StatefulWidget {
  EmptyDataPage({Key key}) : super(key: key);

  @override
  _EmptyDataPageState createState() => _EmptyDataPageState();
}

class _EmptyDataPageState extends State<EmptyDataPage> {
  @override
  Widget build(BuildContext context) {
    OffsetWidget.screenInit(context, 360);
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadAssetsImage(
            Constant.ASSETS_IMG + "icon/icon_empty.png",
            width: OffsetWidget.setSc(44),
            height: OffsetWidget.setSc(44),
            fit: BoxFit.cover,
          ),
          OffsetWidget.vGap(16),
          Text("empay_data".local(),
              style: TextStyle(
                color: Color(0xFF9B9B9B),
                fontSize: OffsetWidget.setSp(12),
                fontWeight: FontWeight.w400,
              )),
        ],
      ),
    );
  }
}
