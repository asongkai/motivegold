import 'package:flutter/material.dart';

class CustomAppBarRadius extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final double height;
  const CustomAppBarRadius({
    super.key,
    required this.title,
    this.height = 120,
  });
  @override
  Size get preferredSize => Size.fromHeight(height);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      )),
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.teal,
      toolbarHeight: height,
    );
  }
}
