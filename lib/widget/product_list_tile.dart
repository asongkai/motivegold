import 'package:flutter/material.dart';
import 'package:motivegold/utils/responsive_screen.dart';

class ProductListTileData extends StatelessWidget {
  final String? orderId;
  final String? orderDate;
  final String? totalPrice;
  final String? type;
  final bool? showTotal;

  const ProductListTileData(
      {Key? key,
      this.orderId,
      this.orderDate,
      this.totalPrice,
        this.type,
      this.showTotal})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFE9E9E9),
                width: 1,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "เลขที่",
                        style: TextStyle(
                          fontSize: size.getWidthPx(8),
                          color: const Color(0xFF636564),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Text(
                        orderId!,
                        style: TextStyle(
                            fontSize: size.getWidthPx(10),
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "ประเภท",
                        style: TextStyle(
                          fontSize: size.getWidthPx(8),
                          color: const Color(0xFF636564),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Text(
                        type!,
                        style: TextStyle(
                            fontSize: size.getWidthPx(10),
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                if (showTotal!)
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "ยอดรวม",
                        style: TextStyle(
                          fontSize: size.getWidthPx(8),
                          color: const Color(0xFF636564),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Text(
                        totalPrice!,
                        style: TextStyle(
                            fontSize: size.getWidthPx(10),
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'วันที่',
                        style: TextStyle(
                          fontSize: size.getWidthPx(8),
                          color: const Color(0xFF636564),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Text(
                        orderDate!,
                        style: TextStyle(
                            fontSize: size.getWidthPx(10),
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
