import 'package:flutter/material.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:sizer/sizer.dart';

class ProductListTileData extends StatelessWidget {
  final String? orderId;
  final String? weight;
  final String? totalPrice;
  final String? type;
  bool showTotal;

  ProductListTileData(
      {super.key,
      this.orderId,
      this.weight,
      this.totalPrice,
        this.type,
      this.showTotal = false});

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
                width: 0,
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
                          fontSize: 16.sp,
                          color: const Color(0xFF636564),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Text(
                        orderId!,
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                if (type != null)
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
                          fontSize: 16.sp,
                          color: const Color(0xFF636564),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Text(
                        type!,
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                if (weight != null)
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'น้ำหนัก',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: const Color(0xFF636564),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Text(
                        weight!,
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                if (showTotal)
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
                          fontSize: 16.sp,
                          color: const Color(0xFF636564),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Text(
                        totalPrice!,
                        style: TextStyle(
                            fontSize: 16.sp,
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
