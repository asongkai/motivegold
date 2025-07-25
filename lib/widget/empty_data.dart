import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NoDataFoundWidget extends StatelessWidget {
  const NoDataFoundWidget({super.key, this.message = "โปรดลองเพิ่มข้อมูลก่อน"});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
        // width: MediaQuery.of(context).size.width,
        // height: MediaQuery.of(context).size.height,
        // color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Lottie.asset('assets/no_data_found.json', width: 200, fit: BoxFit.cover),
              const SizedBox(height: 20, width: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18.0, color: Colors.black54, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ));
  }
}

class NoInternetWidget extends StatelessWidget {
  const NoInternetWidget({super.key, this.message = "ไม่มีอินเทอร์เน็ต"});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Lottie.asset('assets/no_internet_connection.json', width: 450, fit: BoxFit.cover),
              const SizedBox(height: 20, width: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18.0, color: Colors.black54, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ));
  }
}