import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_coinid/utils/sharedPrefer.dart';

import '../../public.dart';

class ModifiySetPage extends StatefulWidget {
  ModifiySetPage({
    Key key,
    this.setType = 0,
  }) : super(key: key);

  final int setType;

  @override
  _ModifiySetPageState createState() => _ModifiySetPageState();
}

class _ModifiySetPageState extends State<ModifiySetPage> {
  static String kName = "kName";
  static String kState = "kState";

  List datas = [];

  @override
  void initState() {
    super.initState();
    getDatas();
  }

  void getDatas() async {
    int setType = widget.setType;
    List data = [];
    int datastate = 0;
    if (setType == 0) {
      datastate = await getAmountValue();
      data = [
        {
          kName: "CNY",
          kState: false.toString(),
        },
        {
          kName: "USD",
          kState: false.toString(),
        },
      ];
    } else {
      datastate = await getLanguageValue();
      data = [
        {
          kName: "system_zh_hans".local(context: context),
          kState: false.toString(),
        },
        {
          kName: "system_en".local(context: context),
          kState: false.toString(),
        },
      ];
    }
    data.forEach((element) {
      if (data[datastate] == element) {
        data[datastate][kState] = true.toString();
      }
    });
    setState(() {
      datas = data;
    });
  }

  void _cellTap(int index) {
    datas.forEach((element) {
      element[kState] = false.toString();
      if (datas[index] == element) {
        element[kState] = true.toString();
      }
    });
    if (widget.setType == 0) {
      updateAmountValue(index == 0 ? true : false);
      Provider.of<CurrentChooseWalletState>(context, listen: false)
          .updateCurrencyType(
              index == 0 ? MCurrencyType.CNY : MCurrencyType.USD);
    } else {
      updateLanguageValue(index);
      if (index == 0) {
        EasyLocalization.of(context).locale = Locale('zh', 'CN');
      } else {
        EasyLocalization.of(context).locale = Locale('en', 'US');
      }
    }
    getDatas();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
        hiddenScrollView: true,
        title: CustomPageView.getDefaultTitle(
            titleStr: widget.setType == 0
                ? "system_currencychoose".local(context: context)
                : "system_languagechoose".local(context: context)),
        child: ListView.builder(
          itemCount: datas.length,
          itemBuilder: (BuildContext context, int index) {
            Map map = datas[index];
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => {
                _cellTap(index),
              },
              child: Container(
                padding: EdgeInsets.only(
                  bottom: OffsetWidget.setSc(27),
                ),
                margin: EdgeInsets.only(
                    left: OffsetWidget.setSc(19),
                    right: OffsetWidget.setSc(19),
                    top: OffsetWidget.setSc(40)),
                decoration: index == 0
                    ? BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: Color(0xFFEAEFF2), width: 0.5)),
                      )
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      map[kName],
                      style: TextStyle(
                          color: Color(0xFF161D2D),
                          fontSize: OffsetWidget.setSp(15),
                          fontWeight: FontWightHelper.semiBold),
                    ),
                    LoadAssetsImage(
                      map[kState] == true.toString()
                          ? Constant.ASSETS_IMG + "icon/menu_select.png"
                          : Constant.ASSETS_IMG + "icon/menu_normal.png",
                      width: OffsetWidget.setSc(21),
                      height: OffsetWidget.setSc(21),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }
}
