import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/gold_data.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/title_tile.dart';

import 'package:motivegold/widget/gold_price_data.dart';

class GoldPriceMiniScreen extends StatefulWidget {

  const GoldPriceMiniScreen({super.key, this.goldDataModel});

  final GoldDataModel? goldDataModel;

  @override
  State<GoldPriceMiniScreen> createState() => _GoldPriceMiniScreenState();
}

class _GoldPriceMiniScreenState extends State<GoldPriceMiniScreen> {
  ApiServices api = ApiServices();
  bool loading = false;

  @override
  void initState() {
    // implement initState
    super.initState();
    init();
  }

  void init() async {
    setState(() {
      loading = true;
    });
    Global.goldDataModel = widget.goldDataModel ?? await api.getGoldPrice(context);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return loading || Global.goldDataModel == null
        ? const Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: LoadingIndicator(
                indicatorType: Indicator.ballRotate,

                /// Required, The loading type of the widget
                // colors: [Colors.white],

                /// Optional, The color collections
                // strokeWidth: 2,

                /// Optional, The stroke of the line, only applicable to widget which contains line
                // backgroundColor: Colors.white,

                /// Optional, Background of the widget
                // pathBackgroundColor: Colors.white

                /// Optional, the stroke backgroundColor
              ),
            ),
          )
        : SizedBox(
      width: 800,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: snBgColor, width: 5.0)
            ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 14, top: 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child:  Text('${Global.goldDataModel?.date}', style: TextStyle(
                              fontSize: size.getWidthPx(10),
                              color: textColor,
                              fontWeight: FontWeight.w900),),
                        ),
                        if (Global.goldDataModel!.different! > 0.0)
                        Expanded(
                          flex: 4,
                          child: Row(
                            children: [
                              Expanded(
                                child: getIcon(),
                              ),
                              Expanded(
                                  child: Text(
                                '${getSign()}${formatterInt.format(Global.goldDataModel?.different ?? 0)}',
                                    textAlign: TextAlign.end,
                                style: TextStyle(
                                    fontSize: 30,
                                    color: getColor(),
                                    fontWeight: FontWeight.bold),
                              )),
                              const SizedBox(width: 10,),
                            ],
                          ),
                        ),
                      ],
                    ),
                    GoldPriceListTileData(
                      title: 'ทองคำแท่ง 96.5%',
                      subTitle: "ขายออก",
                      value: "${Global.format(Global.toNumber(Global.goldDataModel?.theng?.sell))} บาท",
                    ),
                    GoldPriceListTileData(
                      title: 'ทองรูปพรรณ 96.5%',
                      subTitle: "รับซื้อบาทละ",
                      value: "${Global.format(Global.toNumber(Global.goldDataModel?.paphun?.buy))} บาท",
                    ),
                    GoldPriceListTileData(
                      title: '',
                      subTitle: "รับซื้อกรัมละ",
                      value:
                          "${Global.format(Global.toNumber(Global.goldDataModel?.paphun?.buy ?? "0") / getUnitWeightValue())} บาท",
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
  }

  getIcon() {
    double diff = Global.goldDataModel!.different ?? 0;
    return diff > 0
        ? Image.asset('assets/icons/up-arrow.png', height: 42, color: Colors.green,)
        : Image.asset('assets/icons/down-arrow.png', height: 42, color: Colors.red,);
  }

  getColor() {
    double diff = Global.goldDataModel!.different ?? 0;
    return diff > 0 ? Colors.green : Colors.redAccent;
  }

  getSign() {
    double diff = Global.goldDataModel!.different ?? 0;
    return diff > 0 ? "+" : "";
  }
}
