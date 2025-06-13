import 'package:flutter/material.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/gold_data.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/gold_price_data.dart';
import 'package:sizer/sizer.dart';

class GoldMiniWidget extends StatefulWidget {

  const GoldMiniWidget({super.key, this.goldDataModel});
  final GoldDataModel? goldDataModel;

  @override
  _GoldMiniWidgetState createState() => _GoldMiniWidgetState();
}

class _GoldMiniWidgetState extends State<GoldMiniWidget> {
  bool _isExpanded = false; // Track the expansion state

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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(color: Colors.pink.shade200, width: 4),
      ),
      margin: const EdgeInsets.all(16),
      child: ExpansionTile(
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (bool expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              // flex: 6,
              child: Text('${Global.goldDataModel?.date}', style: TextStyle(
                  fontSize: 14.sp, //size.getWidthPx(10),
                  color: textColor,
                  fontWeight: FontWeight.w900),),
            ),
            if (Global.goldDataModel!.different! > 0.0)
            getIcon(),
            if (Global.goldDataModel!.different! > 0.0)
            const SizedBox(width: 8),
            if (Global.goldDataModel!.different! > 0.0)
            Text(
              '${getSign()}${formatterInt.format(Global.goldDataModel?.different ?? 0)}',
              textAlign: TextAlign.end,
              style: TextStyle(
                  fontSize: 14.sp, //30,
                  color: getColor(),
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        children: [

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
        ],
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