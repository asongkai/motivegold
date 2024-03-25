import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/widget/empty.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:motivegold/widget/product_list_tile.dart';


class HoldListModal extends StatefulWidget {
  const HoldListModal({super.key});

  @override
  State<HoldListModal> createState() => _HoldListModalState();
}

class _HoldListModalState extends State<HoldListModal> {
  List<OrderModel>? holds;
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
    var list = await Global.getHoldList();
    setState(() {
      holds = list;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        title: Text('รายการคำสั่งระงับ'.tr()),
      ),
      body: SafeArea(
        child: loading
            ? const LoadingProgress()
            : holds!.isEmpty
                ? const EmptyContent()
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: getProportionateScreenWidth(8.0),
                                  vertical: getProportionateScreenWidth(8.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SingleChildScrollView(
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                9 /
                                                10,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          color: bgColor2,
                                        ),
                                        child: ListView.builder(
                                            itemCount: holds?.length,
                                            itemBuilder: (context, index) {
                                              return _itemOrderList(
                                                  order: holds![index],
                                                  index: index);
                                            }),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
      persistentFooterButtons: [
        SizedBox(
            height: 70,
            width: 150,
            child: ElevatedButton(
              style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.red[700]!),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          side: BorderSide(color: Colors.red[700]!)))),
              onPressed: () async {
                await Global.clearHold();
                Future.delayed(const Duration(milliseconds: 500), () {
                  holds?.clear();
                  init();
                  setState(() {});
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "เคลียร์".tr(),
                    style: TextStyle(
                        color: Colors.white, fontSize: size.getWidthPx(8)),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  const Icon(
                    Icons.delete_outline_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                ],
              ),
            )),
      ],
    );
  }

  void checkout() async {
    setState(() {});
  }

  Widget _itemOrderList({required OrderModel order, required index}) {
    return Row(
      children: [
        Expanded(
          flex: 8,
          child: ListTile(
            title: ProductListTileData(
              leftTitle: order.orderId,
              leftValue: order.type,
              rightTitle: 'วันที่',
              rightValue: order.orderDate,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  removeProduct(index);
                },
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () async {
                  await Global.removeHold(index);
                  Global.posOrder = order;

                  if (order.type == 'sell') {
                    Global.posIndex = 0;
                    Global.sellOrderDetail = order.detail;
                  } else if (order.type == 'buy') {
                    Global.posIndex = 1;
                    Global.buyOrderDetail = order.detail;
                  }
                  Future.delayed(const Duration(milliseconds: 500), () async {
                    setState(() {
                    });
                    Navigator.of(context).pop();
                  });

                },
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  void removeProduct(int i) async {
    await Global.removeHold(i);
    Future.delayed(const Duration(milliseconds: 200), () async {
      holds!.removeAt(i);
      init();
      setState(() {});
    });
  }
}

class PaymentCard extends StatelessWidget {
  const PaymentCard(
      {Key? key, this.isSelected = false, this.title, this.image, this.action})
      : super(key: key);

  final bool? isSelected;
  final String? title;
  final String? image;
  final Function()? action;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action,
      child: Stack(
        children: [
          Container(
            height: getProportionateScreenWidth(30),
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(8.0),
                vertical: getProportionateScreenHeight(8.0)),
            margin: EdgeInsets.only(
              bottom: getProportionateScreenHeight(8.0),
            ),
            decoration: BoxDecoration(
              color: isSelected! ? Colors.white : Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(
                getProportionateScreenWidth(
                  4,
                ),
              ),
              boxShadow: [
                isSelected!
                    ? BoxShadow(
                        color: kShadowColor,
                        offset: Offset(
                          getProportionateScreenWidth(2),
                          getProportionateScreenWidth(4),
                        ),
                        blurRadius: 80,
                      )
                    : const BoxShadow(color: Colors.transparent),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: getProportionateScreenWidth(30),
                  height: getProportionateScreenWidth(30),
                  decoration: ShapeDecoration(
                    color: kGreyShade5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        getProportionateScreenWidth(8.0),
                      ),
                    ),
                  ),
                  child: image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(image!,
                              fit: BoxFit.cover, width: 1000.0),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            "assets/images/no_image.png",
                            fit: BoxFit.cover,
                            width: 1000.0,
                          )),
                ),
                SizedBox(
                  width: getProportionateScreenWidth(8),
                ),
                Expanded(
                  child: Text(
                    title!,
                    style: TextStyle(
                      fontSize: getProportionateScreenWidth(8),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              ],
            ),
          ),
          if (isSelected!)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                child: const IconButton(
                  icon: Icon(
                    Icons.check,
                    color: Colors.teal,
                  ),
                  onPressed: null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
