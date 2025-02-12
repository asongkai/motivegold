// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:motivegold/constants/colors.dart';
// import 'package:motivegold/model/customer.dart';
// import 'package:motivegold/model/location/amphure.dart';
// import 'package:motivegold/model/location/province.dart';
// import 'package:motivegold/model/location/tambon.dart';
// import 'package:motivegold/screen/customer/customer_screen.dart';
// import 'package:motivegold/utils/alert.dart';
// import 'package:motivegold/utils/helps/common_function.dart';
// import 'package:motivegold/utils/motive.dart';
// import 'package:motivegold/utils/responsive_screen.dart';
// import 'package:motivegold/utils/screen_utils.dart';
// import 'package:motivegold/utils/util.dart';
// import 'package:motivegold/widget/customer/location.dart';
// import 'package:motivegold/widget/empty_data.dart';
// import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
// import 'package:thai_idcard_reader_flutter/thai_idcard_reader_flutter.dart';
//
// import 'package:motivegold/api/api_services.dart';
// import 'package:motivegold/utils/global.dart';
// import 'package:motivegold/widget/empty.dart';
//
// class CustomerEntryScreen extends StatefulWidget {
//   const CustomerEntryScreen({super.key});
//
//   @override
//   State<CustomerEntryScreen> createState() => _CustomerEntryScreenState();
// }
//
// class _CustomerEntryScreenState extends State<CustomerEntryScreen> {
//   final TextEditingController idCardCtrl = TextEditingController();
//   final TextEditingController firstNameCtrl = TextEditingController();
//   final TextEditingController lastNameCtrl = TextEditingController();
//   final TextEditingController emailAddressCtrl = TextEditingController();
//   final TextEditingController phoneCtrl = TextEditingController();
//   final TextEditingController birthDateCtrl = TextEditingController();
//
//   final ImagePicker imagePicker = ImagePicker();
//   List<File>? imageFiles = [];
//
//   bool isSeller = false;
//   bool isCustomer = false;
//   bool isBuyer = false;
//
//   ThaiIDCard? _data;
//   String? _error;
//   UsbDevice? _device;
//   dynamic _card;
//   StreamSubscription? subscription;
//   final List _idCardType = [
//     ThaiIDType.cid,
//     ThaiIDType.photo,
//     ThaiIDType.nameTH,
//     ThaiIDType.nameEN,
//     ThaiIDType.gender,
//     ThaiIDType.birthdate,
//     ThaiIDType.address,
//     ThaiIDType.issueDate,
//     ThaiIDType.expireDate,
//   ];
//   List<String> selectedTypes = [];
//   List<CustomerModel> customers = [];
//   bool loading = false;
//   CustomerModel? selectedCustomer;
//
//   @override
//   void initState() {
//     // implement initState
//     super.initState();
//     birthDateCtrl.text = Global.formatDateDD(DateTime.now().toString());
//     ThaiIdcardReaderFlutter.deviceHandlerStream.listen(_onUSB);
//     init();
//   }
//
//   init() async {
//     setState(() {
//       loading = true;
//     });
//     try {
//       var result = await ApiServices.post(
//           '/customer/all/customer', Global.requestObj(null));
//       // motivePrint(result!.toJson());
//       if (result?.status == "success") {
//         var data = jsonEncode(result?.data);
//         List<CustomerModel> products = customerListModelFromJson(data);
//         setState(() {
//           customers = products;
//         });
//       } else {
//         customers = [];
//       }
//
//       var province =
//           await ApiServices.post('/customer/province', Global.requestObj(null));
//       // motivePrint(province!.toJson());
//       if (province?.status == "success") {
//         var data = jsonEncode(province?.data);
//         List<ProvinceModel> products = provinceModelFromJson(data);
//         setState(() {
//           Global.provinceList = products;
//         });
//       } else {
//         Global.provinceList = [];
//       }
//     } catch (e) {
//       motivePrint(e.toString());
//     }
//     setState(() {
//       loading = false;
//     });
//   }
//
//   void _onUSB(usbEvent) {
//     try {
//       if (usbEvent.hasPermission) {
//         subscription =
//             ThaiIdcardReaderFlutter.cardHandlerStream.listen(_onData);
//       } else {
//         if (subscription == null) {
//           subscription?.cancel();
//           subscription = null;
//         }
//         _clear();
//       }
//       setState(() {
//         _device = usbEvent;
//       });
//     } catch (e) {
//       setState(() {
//         _error = "_onUSB $e";
//       });
//       Alert.error(context, 'OnUsb', "$e", 'OK', action: () {});
//     }
//   }
//
//   void _onData(readerEvent) {
//     try {
//       setState(() {
//         _card = readerEvent;
//       });
//       if (readerEvent.isReady) {
//         readCard(only: selectedTypes);
//       } else {
//         _clear();
//       }
//     } catch (e) {
//       setState(() {
//         _error = "_onData $e";
//       });
//       Alert.error(context, 'OnData', "$e", 'OK', action: () {});
//     }
//   }
//
//   readCard({List<String> only = const []}) async {
//     try {
//       var response = await ThaiIdcardReaderFlutter.read(only: only);
//       setState(() {
//         _data = response;
//       });
//
//       if (_data != null) {
//         idCardCtrl.text = _data!.cid!;
//         if (_data!.firstnameTH != null) {
//           firstNameCtrl.text = '${_data!.titleTH} ${_data!.firstnameTH}';
//           lastNameCtrl.text = '${_data?.lastnameTH!}';
//         } else {
//           firstNameCtrl.text = '${_data!.titleEN} ${_data!.firstnameEN}';
//           lastNameCtrl.text = '${_data?.lastnameEN!}';
//         }
//         emailAddressCtrl.text = "";
//         phoneCtrl.text = "";
//         var address0 = _data!.address ?? "";
//
//         if (address0.isNotEmpty) {
//           var sp1 = address0.split("ตำบล");
//           var sp2 = sp1[1].split("อำเภอ");
//           var sp3 = sp2[1].split("จังหวัด");
//
//           var address = sp1[0].trimLeft().trimRight();
//           var tambon = sp2[0].trimLeft().trimRight();
//           var ampher = sp3[0].trimLeft().trimRight();
//           var chunvat = sp3[1].trimLeft().trimRight();
//
//           Global.addressCtrl.text = address0;
//
//           int? chungVatId = filterChungVatByName(chunvat);
//           await loadAmphureByProvince(chungVatId);
//           int? ampherId = filterAmpheryName(ampher);
//           await loadTambonByAmphure(ampherId);
//           int? tambonId = filterTambonByName(tambon);
//           Alert.success(context, 'Success', 'ID Synced', 'OK', action: () {
//             setState(() {});
//           });
//         }
//
//         birthDateCtrl.text = Global.formatDateDD(_data!.birthdate!);
//       }
//       setState(() {});
//     } catch (e) {
//       setState(() {
//         _error = 'ERR readCard $e';
//       });
//       if (mounted) {
//         Alert.warning(context, 'ERR readCard'.tr(), '$e', 'OK'.tr());
//       }
//     }
//   }
//
//   formattedDate(dt) {
//     try {
//       DateTime dateTime = DateTime.parse(dt);
//       String formattedDate = DateFormat.yMMMMd('th_TH').format(dateTime);
//       return formattedDate;
//     } catch (e) {
//       return dt.split('').toString() + e.toString();
//     }
//   }
//
//   _clear() {
//     setState(() {
//       _data = null;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Screen? size = Screen(MediaQuery.of(context).size);
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("ลูกค้า"),
//         actions: [
//           IconButton(icon: const Icon(Icons.search),
//               onPressed: () {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const CustomerScreen(selected: true,),
//                         fullscreenDialog: true))
//                     .whenComplete(() {
//                   setState(() {});
//                 });
//               })
//         ],
//       ),
//       body: SafeArea(
//         child: GestureDetector(
//           onTap: () {
//             FocusScope.of(context).requestFocus(FocusNode());
//           },
//           child: SingleChildScrollView(
//             child: SizedBox(
//               // height: MediaQuery.of(context).size.height,
//               width: MediaQuery.of(context).size.width,
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     // Padding(
//                     //   padding: const EdgeInsets.all(8.0),
//                     //   child: SearchAnchor(builder:
//                     //       (BuildContext context, SearchController controller) {
//                     //     return SearchBar(
//                     //       controller: controller,
//                     //       padding: const WidgetStatePropertyAll<EdgeInsets>(
//                     //           EdgeInsets.symmetric(horizontal: 16.0)),
//                     //       onTap: () {
//                     //         controller.openView();
//                     //         setState(() {
//                     //           selectedCustomer = null;
//                     //         });
//                     //       },
//                     //       onChanged: (_) {
//                     //         controller.openView();
//                     //         setState(() {
//                     //           selectedCustomer = null;
//                     //         });
//                     //       },
//                     //       leading: const Icon(Icons.search),
//                     //     );
//                     //   }, suggestionsBuilder:
//                     //       (BuildContext context, SearchController controller) {
//                     //     return customers.isEmpty
//                     //         ? [
//                     //             Container(
//                     //               margin: const EdgeInsets.only(top: 50.0),
//                     //               child:
//                     //                   const Center(child: NoDataFoundWidget()),
//                     //             )
//                     //           ]
//                     //         : customers.map((e) {
//                     //             return ListTile(
//                     //               title: Text(
//                     //                 '${e.firstName} ${e.lastName}',
//                     //                 style: const TextStyle(fontSize: 20),
//                     //               ),
//                     //               onTap: () {
//                     //                 setState(() {
//                     //                   controller.closeView(
//                     //                       '${e.firstName} ${e.lastName}');
//                     //                   selectedCustomer = e;
//                     //                   Global.customer = e;
//                     //                   // idCardCtrl.text = '${e.idCard}';
//                     //                   // firstNameCtrl.text = '${e.firstName}';
//                     //                   // lastNameCtrl.text = '${e.lastName}';
//                     //                   // emailAddressCtrl.text = '${e.email}';
//                     //                   // phoneCtrl.text = '${e.phoneNumber}';
//                     //                   // birthDateCtrl.text = Global.formatDateDD(e.doB.toString());
//                     //                   // Global.addressCtrl.text = '${e.address}';
//                     //                   // if (e.provinceId != null) {
//                     //                   //
//                     //                   // }
//                     //                   Future.delayed(
//                     //                       const Duration(milliseconds: 500),
//                     //                       () {
//                     //                     Navigator.of(context).pop();
//                     //                     setState(() {
//                     //                       // Here you can write your code for open new view
//                     //                     });
//                     //                   });
//                     //                 });
//                     //               },
//                     //               trailing: Text(getCustomerType(e),
//                     //                   style: const TextStyle(fontSize: 20)),
//                     //             );
//                     //           });
//                     //   }),
//                     // ),
//                     // const SizedBox(
//                     //   height: 20,
//                     // ),
//                     if (_device != null)
//                       UsbDeviceCard(
//                         device: _device,
//                       ),
//                     if (_card != null) Text(_card.toString()),
//                     if (_device == null || !_device!.isAttached) ...[
//                       const EmptyHeader(
//                         text: 'เสียบเครื่องอ่านบัตรก่อน',
//                       ),
//                     ],
//                     if (_error != null) Text(_error.toString()),
//                     if (_data == null &&
//                         (_device != null && _device!.hasPermission)) ...[
//                       const EmptyHeader(
//                         icon: Icons.credit_card,
//                         text: 'เสียบบัตรประชาชนได้เลย',
//                       ),
//                       SizedBox(
//                         height: 200,
//                         child: Wrap(children: [
//                           Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Checkbox(
//                                   value: selectedTypes.isEmpty,
//                                   onChanged: (val) {
//                                     setState(() {
//                                       if (selectedTypes.isNotEmpty) {
//                                         selectedTypes = [];
//                                       }
//                                     });
//                                   }),
//                               const Text('readAll'),
//                             ],
//                           ),
//                           for (var ea in _idCardType)
//                             Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Checkbox(
//                                     value: selectedTypes.contains(ea),
//                                     onChanged: (val) {
//                                       motivePrint(ea);
//                                       setState(() {
//                                         if (selectedTypes.contains(ea)) {
//                                           selectedTypes.remove(ea);
//                                         } else {
//                                           selectedTypes.add(ea);
//                                         }
//                                       });
//                                     }),
//                                 Text('$ea'),
//                               ],
//                             ),
//                         ]),
//                       ),
//                     ],
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     if (_data != null)
//                       if (_data!.photo.isNotEmpty)
//                         Center(
//                           child: Image.memory(
//                             Uint8List.fromList(_data!.photo),
//                           ),
//                         ),
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Padding(
//                             padding:
//                                 const EdgeInsets.only(left: 8.0, right: 8.0),
//                             child: Column(
//                               children: [
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 buildTextFieldBig(
//                                   labelText: 'เลขบัตรประจำตัวประชาชน'.tr(),
//                                   validator: null,
//                                   inputType: TextInputType.text,
//                                   controller: idCardCtrl,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Padding(
//                             padding:
//                                 const EdgeInsets.only(left: 8.0, right: 8.0),
//                             child: Column(
//                               children: [
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 buildTextFieldBig(
//                                   labelText: 'ชื่อ'.tr(),
//                                   validator: null,
//                                   inputType: TextInputType.text,
//                                   controller: firstNameCtrl,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: Padding(
//                             padding:
//                                 const EdgeInsets.only(left: 8.0, right: 8.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               children: [
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 buildTextFieldBig(
//                                   labelText: 'นามสกุล'.tr(),
//                                   validator: null,
//                                   inputType: TextInputType.text,
//                                   controller: lastNameCtrl,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Padding(
//                             padding:
//                                 const EdgeInsets.only(left: 8.0, right: 8.0),
//                             child: Column(
//                               children: [
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 buildTextFieldBig(
//                                   labelText: 'อีเมล'.tr(),
//                                   validator: null,
//                                   inputType: TextInputType.emailAddress,
//                                   controller: emailAddressCtrl,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: Padding(
//                             padding:
//                                 const EdgeInsets.only(left: 8.0, right: 8.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               children: [
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 buildTextFieldBig(
//                                   labelText: 'โทรศัพท์'.tr(),
//                                   validator: null,
//                                   inputType: TextInputType.phone,
//                                   controller: phoneCtrl,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(
//                       height: 15,
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Expanded(
//                           child: Padding(
//                             padding:
//                                 const EdgeInsets.only(left: 8.0, right: 8.0),
//                             child: TextField(
//                               controller: birthDateCtrl,
//                               //editing controller of this TextField
//                               style: const TextStyle(fontSize: 38),
//                               decoration: InputDecoration(
//                                 prefixIcon: const Icon(Icons.calendar_today),
//                                 //icon of text field
//                                 floatingLabelBehavior:
//                                     FloatingLabelBehavior.always,
//                                 contentPadding: const EdgeInsets.symmetric(
//                                     vertical: 10.0, horizontal: 10.0),
//                                 labelText: "วันเกิด".tr(),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(
//                                     getProportionateScreenWidth(8),
//                                   ),
//                                   borderSide: const BorderSide(
//                                     color: kGreyShade3,
//                                   ),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(
//                                     getProportionateScreenWidth(2),
//                                   ),
//                                   borderSide: const BorderSide(
//                                     color: kGreyShade3,
//                                   ),
//                                 ),
//                               ),
//                               readOnly: true,
//                               //set it true, so that user will not able to edit text
//                               onTap: () async {
//                                 DateTime? pickedDate = await showDatePicker(
//                                     context: context,
//                                     initialDate: DateTime.now(),
//                                     firstDate: DateTime.now(),
//                                     //DateTime.now() - not to allow to choose before today.
//                                     lastDate: DateTime(2101));
//                                 if (pickedDate != null) {
//                                   motivePrint(
//                                       pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
//                                   String formattedDate =
//                                       DateFormat('yyyy-MM-dd')
//                                           .format(pickedDate);
//                                   motivePrint(
//                                       formattedDate); //formatted date output using intl package =>  2021-03-16
//                                   //you can implement different kind of Date Format here according to your requirement
//                                   setState(() {
//                                     birthDateCtrl.text =
//                                         formattedDate; //set output date to TextField value.
//                                   });
//                                 } else {
//                                   motivePrint("Date is not selected");
//                                 }
//                               },
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(
//                       height: 15,
//                     ),
//                     const LocationEntryWidget()
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//       persistentFooterButtons: [
//         SizedBox(
//             height: 70,
//             width: 150,
//             child: ElevatedButton(
//               style: ButtonStyle(
//                   foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
//                   backgroundColor:
//                       WidgetStateProperty.all<Color>(Colors.teal[700]!),
//                   shape: WidgetStateProperty.all<RoundedRectangleBorder>(
//                       RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25.0),
//                           side: BorderSide(color: Colors.teal[700]!)))),
//               onPressed: () async {
//                 if (idCardCtrl.text.isEmpty) {
//                   Alert.warning(
//                       context, 'คำเตือน', 'กรุณากรอกหมายเลขบัตรประชาชน', 'OK',
//                       action: () {});
//                   return;
//                 }
//
//                 if (selectedCustomer == null) {
//                   var customerObject = Global.requestObj({
//                     "companyName": '',
//                     "fistName": firstNameCtrl.text,
//                     "lastName": lastNameCtrl.text,
//                     "email": emailAddressCtrl.text,
//                     "doB": birthDateCtrl.text.isEmpty
//                         ? ""
//                         : Global.convertDate(birthDateCtrl.text),
//                     "phoneNumber": phoneCtrl.text,
//                     "username": generateRandomString(8),
//                     "password": generateRandomString(10),
//                     "address": Global.addressCtrl.text,
//                     "tambonId": Global.tambonModel?.id,
//                     "amphureId": Global.amphureModel?.id,
//                     "provinceId": Global.provinceModel?.id,
//                     "nationality": '',
//                     "postalCode": '',
//                     "photoUrl": '',
//                     "idCard": idCardCtrl.text,
//                     "taxNumber": '',
//                     "isCustomer": 1,
//                     "isBuyer": 0,
//                     "isSeller": 0
//                   });
//
//                   Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
//                       action: () async {
//                     final ProgressDialog pr = ProgressDialog(context,
//                         type: ProgressDialogType.normal,
//                         isDismissible: true,
//                         showLogs: true);
//                     await pr.show();
//                     pr.update(message: 'processing'.tr());
//                     try {
//                       var result = await ApiServices.post(
//                           '/customer/create', customerObject);
//                       await pr.hide();
//                       if (result?.status == "success") {
//                         if (mounted) {
//                           CustomerModel customer =
//                               customerModelFromJson(jsonEncode(result!.data!));
//                           // print(customer.toJson());
//                           setState(() {
//                             Global.customer = customer;
//                           });
//
//                           Navigator.of(context).pop();
//                         }
//                       } else {
//                         if (mounted) {
//                           Alert.warning(context, 'Warning'.tr(),
//                               result!.message!, 'OK'.tr(),
//                               action: () {});
//                         }
//                       }
//                     } catch (e) {
//                       await pr.hide();
//                       if (mounted) {
//                         Alert.warning(
//                             context, 'Warning'.tr(), e.toString(), 'OK'.tr(),
//                             action: () {});
//                       }
//                     }
//                   });
//                 } else {
//                   setState(() {
//                     Global.customer = selectedCustomer;
//                   });
//                   Navigator.of(context).pop();
//                 }
//               },
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "บันทึก".tr(),
//                     style: const TextStyle(color: Colors.white, fontSize: 32),
//                   ),
//                   const SizedBox(
//                     width: 2,
//                   ),
//                   const Icon(
//                     Icons.save,
//                     color: Colors.white,
//                     size: 30,
//                   ),
//                 ],
//               ),
//             )),
//       ],
//     );
//   }
//
//   saveRow() {
//     if (birthDateCtrl.text.isEmpty) {
//       Alert.warning(
//           context, 'คำเตือน'.tr(), 'กรุณาเลือกวันเกิด'.tr(), 'OK'.tr(),
//           action: () {});
//       return;
//     }
//
//     if (Motive.imagesFileList!.isEmpty) {
//       Alert.warning(context, 'คำเตือน'.tr(), 'กรุณาเลือกรูปภาพ'.tr(), 'OK'.tr(),
//           action: () {});
//       return;
//     }
//
//     setState(() {});
//   }
//
//   openImages() async {
//     try {
//       var pickedFiles = await imagePicker.pickMultiImage();
//       //you can use ImageCourse.camera for Camera capture
//       imageFiles = pickedFiles.map((e) => File(e.path)).toList();
//       Motive.imagesFileList = imageFiles;
//       setState(() {});
//     } catch (e) {
//       print("error while picking file.");
//     }
//   }
//
//   String getCustomerType(CustomerModel e) {
//     // print(e.toJson());
//     if (e.isSeller == 1) {
//       return 'ผู้ขาย';
//     }
//     if (e.isBuyer == 1) {
//       return 'ผู้ซื้อ';
//     }
//     if (e.isCustomer == 1) {
//       return 'ลูกค้า';
//     }
//     return 'ลูกค้า';
//   }
// }
//
// class EmptyHeader extends StatelessWidget {
//   final IconData? icon;
//   final String? text;
//
//   const EmptyHeader({
//     this.icon,
//     this.text,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//         child: SizedBox(
//             height: 140,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   icon ?? Icons.usb,
//                   size: 60,
//                 ),
//                 Center(
//                     child: Text(
//                   text ?? 'Empty',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 )),
//               ],
//             )));
//   }
// }
//
// class UsbDeviceCard extends StatelessWidget {
//   final dynamic device;
//
//   const UsbDeviceCard({
//     Key? key,
//     this.device,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Opacity(
//       opacity: device.isAttached ? 1.0 : 0.5,
//       child: Card(
//         child: ListTile(
//           leading: const Icon(
//             Icons.usb,
//             size: 32,
//           ),
//           title: Text('${device!.manufacturerName} ${device!.productName}'),
//           subtitle: Text(device!.identifier ?? ''),
//           trailing: Container(
//             padding: const EdgeInsets.all(8),
//             color: device!.hasPermission ? Colors.green : Colors.grey,
//             child: Text(
//                 device!.hasPermission
//                     ? 'Listening'
//                     : (device!.isAttached ? 'Connected' : 'Disconnected'),
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                 )),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class DisplayInfo extends StatelessWidget {
//   const DisplayInfo({
//     Key? key,
//     required this.title,
//     required this.value,
//   }) : super(key: key);
//
//   final String title;
//   final String value;
//
//   @override
//   Widget build(BuildContext context) {
//     TextStyle sTitle =
//         const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
//     TextStyle sVal = const TextStyle(fontSize: 28);
//
//     _copyFn(value) {
//       Clipboard.setData(ClipboardData(text: value)).then((_) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(const SnackBar(content: Text("Copy it already")));
//       });
//     }
//
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Text(
//                 '$title : ',
//                 style: sTitle,
//               ),
//             ],
//           ),
//           Stack(
//             alignment: Alignment.centerRight,
//             children: [
//               Row(
//                 children: [
//                   Flexible(
//                     child: Text(
//                       value,
//                       style: sVal,
//                     ),
//                   ),
//                 ],
//               ),
//               GestureDetector(
//                 onTap: () => _copyFn(value),
//                 child: const Icon(Icons.copy),
//               )
//             ],
//           ),
//           const Divider(
//             color: Colors.black,
//           ),
//         ],
//       ),
//     );
//   }
// }
