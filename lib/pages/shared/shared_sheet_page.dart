import 'package:umengshare/umengshare.dart';
import 'package:flutter_coinid/utils/permission.dart';
import '../../public.dart';

enum SheetType {
  SheetType_IMG, //连接蓝牙
  SheetType_TXT, //解除配对
}

class SharedSheetPage extends StatefulWidget {
  SharedSheetPage({
    this.title,
    this.content,
    this.imageByte,
    this.isPath,
  });

  final String title;
  final String content;
  final String imageByte;
  final bool isPath;

  @override
  _SharedSheetPageState createState() => _SharedSheetPageState();
}

class _SharedSheetPageState extends State<SharedSheetPage> {
  String title;
  String content;
  String imageByte;
  bool isPath;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    title = widget.title;
    content = widget.content;
    imageByte = widget.imageByte;
    isPath = widget.isPath;
  }

  _sharedImage(UMSharePlatform umSharePlatform) async {
    if (await PermissionUtils.checkStoragePermissions() == false) {
      HWToast.showText(text: "permission_err".local());
    } else {
      if (isPath) {
        UMengShare.shareImage(umSharePlatform, imageByte, imageByte);
      } else {
        UMengShare.shareImageBytes(umSharePlatform, imageByte, imageByte);
      }
      Navigator.pop(context);
    }
  }

  Widget _getItem(VoidCallback tap, String imgName, String content) {
    return Expanded(
        child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: tap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LoadAssetsImage(
            Constant.ASSETS_IMG + imgName,
            width: OffsetWidget.setSc(50),
            height: OffsetWidget.setSc(50),
            fit: BoxFit.contain,
          ),
          OffsetWidget.vGap(7),
          Text(
            content,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: OffsetWidget.setSp(12),
                color: Color(0xFF161D2D),
                fontWeight: FontWightHelper.regular),
          ),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    OffsetWidget.screenInit(context, 360);
    return Container(
      height: OffsetWidget.setSc(150),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        color: Color(0xFFFFFFFF),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: OffsetWidget.setSc(17)),
            child: Text(
              "mine_sharewith".local(),
              style: TextStyle(
                color: Color(0xFFACBBCF),
                fontWeight: FontWightHelper.medium,
                fontSize: OffsetWidget.setSp(15),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(top: OffsetWidget.setSc(16)),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _getItem(() {
                    _sharedImage(UMSharePlatform.WechatSession);
                  }, "icon/ic_share_wx.png", "weChat_friends".local()),
                  _getItem(() {
                    _sharedImage(UMSharePlatform.WechatTimeLine);
                  }, "icon/ic_share_wx_circle.png", "circle_friends".local()),
                  _getItem(() {
                    _sharedImage(UMSharePlatform.Sina);
                  }, "icon/ic_share_sina.png", "sina".local()),
                  _getItem(() {
                    _sharedImage(UMSharePlatform.QQ);
                  }, "icon/ic_share_qq.png", "qq_friends".local()),
                  _getItem(() {
                    _sharedImage(UMSharePlatform.Qzone);
                  }, "icon/ic_share_qzone.png", "qq_space".local()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
