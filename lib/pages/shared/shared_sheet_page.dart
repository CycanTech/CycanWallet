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

  @override
  Widget build(BuildContext context) {
    OffsetWidget.screenInit(context, 360);
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned(
              bottom: OffsetWidget.setSc(42),
              child: Container(
                color: Color(0xffffffff),
                width: OffsetWidget.setSc(360),
                height: OffsetWidget.setSc(115),
                padding: EdgeInsets.only(bottom: OffsetWidget.setSc(27)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _sharedImage(UMSharePlatform.WechatSession);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          LoadAssetsImage(
                            Constant.ASSETS_IMG + "icon/ic_share_wx.png",
                            width: OffsetWidget.setSc(38),
                            height: OffsetWidget.setSc(38),
                            fit: BoxFit.contain,
                          ),
                          OffsetWidget.vGap(5),
                          Text(
                            "weChat_friends".local(),
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: OffsetWidget.setSp(10),
                              color: Color(0xFF000000),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _sharedImage(UMSharePlatform.WechatTimeLine);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          LoadAssetsImage(
                            Constant.ASSETS_IMG + "icon/ic_share_wx_circle.png",
                            width: OffsetWidget.setSc(38),
                            height: OffsetWidget.setSc(38),
                            fit: BoxFit.contain,
                          ),
                          OffsetWidget.vGap(5),
                          Text(
                            "circle_friends".local(),
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: OffsetWidget.setSp(10),
                              color: Color(0xFF000000),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _sharedImage(UMSharePlatform.Sina);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          LoadAssetsImage(
                            Constant.ASSETS_IMG + "icon/ic_share_sina.png",
                            width: OffsetWidget.setSc(38),
                            height: OffsetWidget.setSc(38),
                            fit: BoxFit.contain,
                          ),
                          OffsetWidget.vGap(5),
                          Text(
                            "sina".local(),
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: OffsetWidget.setSp(10),
                              color: Color(0xFF000000),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        _sharedImage(UMSharePlatform.QQ);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          LoadAssetsImage(
                            Constant.ASSETS_IMG + "icon/ic_share_qq.png",
                            width: OffsetWidget.setSc(38),
                            height: OffsetWidget.setSc(38),
                            fit: BoxFit.contain,
                          ),
                          OffsetWidget.vGap(5),
                          Text(
                            "qq_friends".local(),
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: OffsetWidget.setSp(10),
                              color: Color(0xFF000000),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _sharedImage(UMSharePlatform.Qzone);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          LoadAssetsImage(
                            Constant.ASSETS_IMG + "icon/ic_share_qzone.png",
                            width: OffsetWidget.setSc(38),
                            height: OffsetWidget.setSc(38),
                            fit: BoxFit.contain,
                          ),
                          OffsetWidget.vGap(5),
                          Text(
                            "qq_space".local(),
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: OffsetWidget.setSp(10),
                              color: Color(0xFF000000),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                color: Color(0xffffffff),
                width: OffsetWidget.setSc(360),
                height: OffsetWidget.setSc(41),
                child: FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "dialog_cancel".local(),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: OffsetWidget.setSp(15),
                      color: Color(0xFF000000),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
