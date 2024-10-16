
import 'package:empty_widget_fork/empty_widget_fork.dart';

import 'package:flutter/material.dart';

class EmptyContent extends StatefulWidget {
  const EmptyContent({Key? key}) : super(key: key);

  @override
  EmptyContentState createState() => EmptyContentState();
}

class EmptyContentState extends State<EmptyContent> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 300,
        alignment: Alignment.center,
        child: EmptyWidget(
          image: null,
          packageImage: PackageImage.Image_1,
          title: 'ว่างเปล่า',
          subTitle: 'โปรดลองเพิ่มข้อมูลก่อน',
          titleTextStyle: const TextStyle(
            fontSize: 22,
            color: Color(0xff9da9c7),
            fontWeight: FontWeight.w500,
          ),
          subtitleTextStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xffabb8d6),
          ),
        ),
      ),
    );
  }
}
