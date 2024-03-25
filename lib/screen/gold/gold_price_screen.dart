import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/list_tile_data.dart';
import 'package:motivegold/widget/title_tile.dart';


class GoldPriceScreen extends StatefulWidget {
  final bool showBackButton;
  const GoldPriceScreen({super.key, required this.showBackButton});

  @override
  State<GoldPriceScreen> createState() => _GoldPriceScreenState();
}

class _GoldPriceScreenState extends State<GoldPriceScreen> {
  ApiServices api = ApiServices();
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
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
        : Scaffold(
            appBar: widget.showBackButton ? AppBar(
              automaticallyImplyLeading: widget.showBackButton, 
            ) : null,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.all(15.0),
                          decoration: const BoxDecoration(
                              color: Colors.teal,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10))),
                          child: Text(
                            'ราคาทองตามประกาศของสมาคมค้าทองคำ',
                            style: TextStyle(fontSize: size.getWidthPx(8), color: Colors.white),
                          )),
                      TitleTile(
                        title: '${Global.goldDataModel?.date}',
                      ),
                      ListTileData(
                        leftTitle: 'ทองคำแท่ง',
                        leftValue: "96.5%",
                        rightTitle: "ขายออก",
                        rightValue: "${Global.goldDataModel?.theng?.sell}",
                      ),
                      ListTileData(
                        leftTitle: '',
                        leftValue: "",
                        rightTitle: "รับซื้อ",
                        rightValue: "${Global.goldDataModel?.theng?.buy}",
                      ),
                      ListTileData(
                        leftTitle: 'ทองรูปพรรณ',
                        leftValue: "96.5%",
                        rightTitle: "ขายออก",
                        rightValue: "${Global.goldDataModel?.paphun?.sell}",
                      ),
                      ListTileData(
                        leftTitle: '',
                        leftValue: "",
                        rightTitle: "รับซื้อ (ฐานภาษี)",
                        rightValue: "${Global.goldDataModel?.paphun?.buy}",
                      )
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                setState(() {
                  Global.goldDataModel = null;
                });
                init();
              },
              backgroundColor: bgColor3,
              child: const Icon(Icons.refresh),
            ),
          );
  }
}
