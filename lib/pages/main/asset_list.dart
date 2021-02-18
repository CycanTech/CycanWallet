import 'dart:math';

import 'package:flutter_coinid/models/assets/currency_asset.dart';
import 'package:flutter_coinid/utils/screenutil.dart';
import 'package:flutter_coinid/utils/sharedPrefer.dart';

import '../../public.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class AssetsListPage extends StatefulWidget {
  AssetsListPage({Key key, this.params}) : super(key: key);

  final Map<String, dynamic> params;
  @override
  _AssetsListPageState createState() => _AssetsListPageState();
}

class PieDatas {
  int index;
  double value;
  String coinType;
  charts.Color color;
  double percent;
  PieDatas({this.index, this.value, this.coinType, this.color, this.percent});
}

class _AssetsListPageState extends State<AssetsListPage> {
  List<PieDatas> pieDatas = [];
  String allAssets = "0.00";
  int amountType = 0;
  List<CurrencyAssetModel> cellDatas = [];
  double changeRatio = 0;
  double radioPercent = 0;

  static Map<String, Color> colors = {
    "BTC": Color(0xFFF6A93B),
    "ETH": Color(0XFFF42850),
    "EOS": Color(0XFF410ADF),
    "VNS": Color(0XFF48C0FB),
    "BTM": Color(0XFF434261),
    "LTC": Color(0XFF094A7F),
    "USDT": Color(0XFF00A478),
  };
  @override
  void initState() {
    super.initState();

    initData();
  }

  initData() async {
    String assets = await CurrencyAssetModel.fetchAllChainAssetsValue();
    int amount = await getAmountValue();
    List cells = await CurrencyAssetModel.findAllCurrencyAssets();
    String oldAssets = await getOriginMoney(amount == 0 ? true : false);
    List<PieDatas> pies = [];
    Map<String, Map<String, dynamic>> percentsMap =
        await CurrencyAssetModel.fetchChainAssetsPercents(
            isCny: amount == 0 ? true : false);
    for (var i = 0; i < percentsMap.keys.length; i++) {
      var key = percentsMap.keys.elementAt(i);
      Map<String, dynamic> coinMap = percentsMap[key];
      PieDatas pie = PieDatas();
      pie.index = i;
      pie.coinType = key;
      pie.value = coinMap["assets"];
      pie.percent = coinMap["percent"];
      pie.color = charts.ColorUtil.fromDartColor(colors[key]);
      pies.add(pie);
    }
    setState(() {
      allAssets = assets;
      amountType = amount;
      pieDatas = pies;
      cellDatas = cells;
      String lastupdate = widget.params["originAssets"][0];
      double radio = double.tryParse(allAssets) - double.tryParse(lastupdate);
      if (radio.isNaN) {
        radio = 0;
      }
      radio ??= 0;
      changeRatio = radio;
      radioPercent = changeRatio /
          ((double.tryParse(lastupdate)) == 0
              ? 1
              : double.tryParse(lastupdate));
    });
  }

  Widget _simplePie() {
    var seriesList = [
      charts.Series<PieDatas, int>(
        id: 'assets',
        domainFn: (PieDatas sales, _) => sales.index,
        measureFn: (PieDatas sales, _) => sales.value,
        colorFn: (PieDatas sales, _) => sales.color,
        data: pieDatas,
        insideLabelStyleAccessorFn: (PieDatas row, _) => charts.TextStyleSpec(
          fontSize: OffsetWidget.setSp(11).toInt(),
          color: charts.ColorUtil.fromDartColor(Color(0xFF000000)),
          fontWeight: "Medium",
        ),

        labelAccessorFn: (PieDatas row, _) =>
            '${row.coinType}:${(row.percent * 100).toStringAsFixed(2)}\%', //文本标题
      )
    ];
    return charts.PieChart(
      seriesList,
      animate: true,
      defaultRenderer:
          charts.ArcRendererConfig(arcWidth: 30, arcRendererDecorators: [
        charts.ArcLabelDecorator(labelPosition: charts.ArcLabelPosition.outside)
      ]),
    );
  }

  Widget _detailPieData() {
    int row = 4;
    double spacing = OffsetWidget.setSc(20);
    double leftoffset = OffsetWidget.setSc(40);
    double width =
        (ScreenUtil.screenWidth - leftoffset * 2 - ((row - 1) * spacing)) / row;

    List<Widget> singleAssets = [];
    for (PieDatas item in pieDatas) {
      singleAssets.add(
        Container(
          // color: Colors.red,
          alignment: Alignment.center,
          width: width,
          child: Row(
            children: [
              Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  color: charts.ColorUtil.toDartColor(item.color),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              OffsetWidget.hGap(3),
              Text(
                item.coinType,
                style: TextStyle(
                  color: Color(0xFF000000),
                  fontSize: OffsetWidget.setSp(11),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.only(top: OffsetWidget.setSc(14)),
      alignment: Alignment.topLeft,
      child: Wrap(
        spacing: spacing,
        runSpacing: 7.0,
        alignment: WrapAlignment.start,
        children: singleAssets,
      ),
    );
  }

  Widget buildCell(int index) {
    CurrencyAssetModel item = cellDatas[index];
    Color color = colors[item.coinType] ??= Colors.red;
    String coinType = item.coinType ??= "";
    String token = item.token ??= "";
    String balance = item.balance ??= "0";
    String assets = amountType == 0 ? item.cnyassets : item.usdassets;
    assets ??= "0";
    assets = "≈" + double.tryParse(assets).toStringAsFixed(2);

    Widget cell = Container(
      padding: EdgeInsets.only(
          left: OffsetWidget.setSc(40), right: OffsetWidget.setSc(40)),
      alignment: Alignment.centerLeft,
      height: OffsetWidget.setSc(44),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              OffsetWidget.hGap(5),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    token,
                    style: TextStyle(
                      color: Color(0xFF000000),
                      fontSize: OffsetWidget.setSp(11),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    coinType,
                    style: TextStyle(
                      color: Color(0xFF4A4A4A),
                      fontSize: OffsetWidget.setSp(11),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    balance,
                    style: TextStyle(
                      color: Color(0xFF000000),
                      fontSize: OffsetWidget.setSp(11),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    assets,
                    style: TextStyle(
                      color: Color(0xFF4A4A4A),
                      fontSize: OffsetWidget.setSp(11),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    Widget line = Container(
      color: Color(0xFFD9D9D9),
      alignment: Alignment.center,
      height: 1,
    );

    if (index == 0) {
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: OffsetWidget.setSc(40),
                top: OffsetWidget.setSc(35),
                right: OffsetWidget.setSc(40)),
            child: Column(
              children: [
                RichText(
                    textAlign: TextAlign.center,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      text: "≈",
                      style: TextStyle(
                          color: Color(0xFF000000),
                          fontSize: OffsetWidget.setSp(24),
                          fontWeight: FontWeight.w500),
                      children: [
                        TextSpan(
                          text: amountType == 0 ? "￥" : "\$",
                          style: TextStyle(
                              color: Color(0xFF000000),
                              fontSize: OffsetWidget.setSp(24),
                              fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: allAssets,
                          style: TextStyle(
                              color: Color(0xFF000000),
                              fontSize: OffsetWidget.setSp(32),
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    )),
                Container(
                  height: OffsetWidget.setSc(40),
                  child: Row(
                    children: [
                      Expanded(
                        child: RichText(
                            textAlign: TextAlign.center,
                            softWrap: true,
                            text: TextSpan(
                              text: "assetlist_radio".local() + "：",
                              style: TextStyle(
                                  color: Color(0xFF4A4A4A),
                                  fontSize: OffsetWidget.setSp(10),
                                  fontWeight: FontWeight.w500),
                              children: [
                                TextSpan(
                                  text: ((changeRatio > 0 ? "+" : "") +
                                      changeRatio.toStringAsFixed(2)),
                                  style: TextStyle(
                                      color: Color(0xFFF42850),
                                      fontSize: OffsetWidget.setSp(10),
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            )),
                      ),
                      OffsetWidget.hGap(5),
                      Expanded(
                        child: RichText(
                            textAlign: TextAlign.center,
                            softWrap: true,
                            text: TextSpan(
                              text: "assetlist_precent".local() + "：",
                              style: TextStyle(
                                  color: Color(0xFF4A4A4A),
                                  fontSize: OffsetWidget.setSp(10),
                                  fontWeight: FontWeight.w500),
                              children: [
                                TextSpan(
                                  text: (radioPercent > 0 ? "+" : "") +
                                      (radioPercent * 100).toStringAsFixed(2) +
                                      "%",
                                  style: TextStyle(
                                      color: Color(0XFF7ED321),
                                      fontSize: OffsetWidget.setSp(10),
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            )),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    top: OffsetWidget.setSc(35),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                      "assetlist_percent".local() +
                          (amountType == 0 ? "(CNY)" : "(USD)"),
                      style: TextStyle(
                          color: Color(0xFF000000),
                          fontSize: OffsetWidget.setSp(14),
                          fontWeight: FontWeight.w500)),
                ),
                Container(
                  padding: EdgeInsets.only(
                    top: OffsetWidget.setSc(25),
                  ),
                  height: 300,
                  child: _simplePie(),
                ),
                Container(
                  padding: EdgeInsets.only(
                    top: OffsetWidget.setSc(50),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                      "assetlist_detailpercent".local() +
                          (amountType == 0 ? "(CNY)" : "(USD)"),
                      style: TextStyle(
                          color: Color(0xFF000000),
                          fontSize: OffsetWidget.setSp(14),
                          fontWeight: FontWeight.w500)),
                ),
                _detailPieData(),
                Container(
                  padding: EdgeInsets.only(
                      left: OffsetWidget.setSc(10),
                      right: OffsetWidget.setSc(0),
                      top: OffsetWidget.setSc(60)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("assetlist_currency".local(),
                          style: TextStyle(
                              color: Color(0xFF000000),
                              fontSize: OffsetWidget.setSp(12),
                              fontWeight: FontWeight.w500)),
                      Text("assetlist_num".local(),
                          style: TextStyle(
                              color: Color(0xFF000000),
                              fontSize: OffsetWidget.setSp(12),
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          line,
          cell,
          line,
        ],
      );
    }
    return Column(
      children: [
        cell,
        line,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
      title: Text(
        "my_wallet".local(),
        style: TextStyle(
            color: Color(0xFF000000),
            fontSize: OffsetWidget.setSp(18),
            fontWeight: FontWeight.w400),
      ),
      hiddenScrollView: true,
      child: Container(
        child: double.tryParse(allAssets) != 0
            ? ListView.builder(
                itemCount: cellDatas.length,
                itemBuilder: (BuildContext context, int index) {
                  return buildCell(index);
                },
              )
            : EmptyDataPage(),
      ),
    );
  }
}
