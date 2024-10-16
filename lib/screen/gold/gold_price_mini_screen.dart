import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/title_tile.dart';

import 'package:motivegold/widget/gold_price_data.dart';


class GoldPriceMiniScreen extends StatefulWidget {
  const GoldPriceMiniScreen({super.key});

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
    Global.goldDataModel =
        Global.goldDataModel ?? await api.getGoldPrice(context);
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
        : SingleChildScrollView(
          child: Column(
            children: [
              // TitleTile(
              //   title: '${Global.goldDataModel?.date}',
              // ),
              GoldPriceListTileData(
                title: 'ทองคำแท่ง 96.5%',
                buy: "รับซื้อ",
                sell: "${Global.goldDataModel?.theng?.buy}",
              ),
              GoldPriceListTileData(
                title: '',
                buy: "ขายออก",
                sell: "${Global.goldDataModel?.theng?.buy}",
              ),
              GoldPriceListTileData(
                title: 'ทองรูปพรรณ',
                buy: "รับซื้อ",
                sell: "${Global.goldDataModel?.paphun?.buy}",
              ),
              GoldPriceListTileData(
                title: '',
                buy: "ขายออก",
                sell: "${Global.goldDataModel?.paphun?.sell}",
              ),
            ],
          ),
        );
  }
}
