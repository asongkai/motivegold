import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

class EmptyHeader extends StatelessWidget {
  final IconData? icon;
  final String? text;

  const EmptyHeader({
    this.icon,
    this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
        child: SizedBox(
            height: 140,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon ?? Icons.usb,
                  size: 60,
                ),
                Center(
                    child: Text(
                      text ?? 'Empty',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ],
            )));
  }
}

class UsbDeviceCard extends StatelessWidget {
  final dynamic device;

  const UsbDeviceCard({
    Key? key,
    this.device,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: device.isAttached ? 1.0 : 0.5,
      child: Card(
        child: ListTile(
          leading: const Icon(
            Icons.usb,
            size: 32,
          ),
          title: Text('${device!.manufacturerName} ${device!.productName}'),
          subtitle: Text(device!.identifier ?? ''),
          trailing: Container(
            padding: const EdgeInsets.all(8),
            color: device!.hasPermission ? Colors.green : Colors.grey,
            child: Text(
                device!.hasPermission
                    ? 'Listening'
                    : (device!.isAttached ? 'Connected' : 'Disconnected'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                )),
          ),
        ),
      ),
    );
  }
}

class DisplayInfo extends StatelessWidget {
  const DisplayInfo({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    TextStyle sTitle =
    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
    TextStyle sVal = const TextStyle(fontSize: 28);

    copyFn(value) {
      Clipboard.setData(ClipboardData(text: value)).then((_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Copy it already")));
      });
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '$title : ',
                style: sTitle,
              ),
            ],
          ),
          Stack(
            alignment: Alignment.centerRight,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: sVal,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => copyFn(value),
                child: const Icon(Icons.copy),
              )
            ],
          ),
          const Divider(
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}