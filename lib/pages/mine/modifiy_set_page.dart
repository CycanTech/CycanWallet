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
          kName: "简体中文",
          kState: false.toString(),
        },
        {
          kName: "英文",
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
    setState(() {});
    if (widget.setType == 0) {
      updateAmountValue(index == 0 ? true : false);
      Provider.of<SystemSettings>(context, listen: false).changeCurrencyType(
          index == 0 ? MCurrencyType.CNY : MCurrencyType.USD);
    } else {
      updateLanguageValue(index);
      if (index == 0) {
        EasyLocalization.of(context).locale = Locale('zh', 'CN');
      } else {
        EasyLocalization.of(context).locale = Locale('en', 'US');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
        hiddenScrollView: true,
        child: ListView.builder(
          itemCount: datas.length,
          itemBuilder: (BuildContext context, int index) {
            Map map = datas[index];

            return GestureDetector(
              onTap: () => {
                _cellTap(index),
              },
              child: Container(
                margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Color(Constant.TextFileld_FillColor),
                ),
                height: 50,
                child: Container(
                  margin: EdgeInsets.only(
                    left: 18,
                    right: 18,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        map[kName],
                        style: TextStyle(
                          color: Color(0XFF586883),
                          fontSize: 12,
                        ),
                      ),
                      Image.asset(
                        map[kState] == true.toString()
                            ? Constant.ASSETS_IMG + "icon/menu_select.png"
                            : Constant.ASSETS_IMG + "icon/menu_normal.png",
                        fit: BoxFit.cover,
                        scale: 2.0,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}
