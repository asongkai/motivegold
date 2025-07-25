import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/list_tile_data.dart';
import 'package:motivegold/widget/title_tile.dart';

class GoldPriceScreen extends StatefulWidget {
  final bool showBackButton;

  const GoldPriceScreen({super.key, required this.showBackButton});

  @override
  State<GoldPriceScreen> createState() => _GoldPriceScreenState();
}

class _GoldPriceScreenState extends State<GoldPriceScreen>
    with TickerProviderStateMixin {
  ApiServices api = ApiServices();
  bool loading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    init();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void init() async {
    setState(() {
      loading = true;
    });
    try {
      Global.goldDataModel =
          Global.goldDataModel ?? await api.getGoldPrice(context);
      if (mounted) {
        _animationController.forward();
      }
    } catch (e) {
      motivePrint(e.toString());
    }
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return loading || Global.goldDataModel == null
        ? Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.amber[50]!,
            Colors.orange[50]!,
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: LoadingIndicator(
                indicatorType: Indicator.ballRotate,
                colors: [Colors.amber, Colors.orange],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'กำลังโหลดราคาทอง...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    )
        : Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: widget.showBackButton,
          title: const Text("ราคาทองตามประกาศของสมาคมค้าทองคำ",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey[50]!,
                  Colors.grey[100]!,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Modern TitleTile with enhanced styling
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[100]!, Colors.indigo[100]!],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TitleTile(
                        title: '${Global.goldDataModel?.date}',
                      ),
                    ),

                    // Modern ListTileData with enhanced styling
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber[50]!, Colors.orange[50]!],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTileData(
                        leftTitle: 'ทองคำแท่ง',
                        leftValue: "96.5%",
                        rightTitle: "ขายออก",
                        rightValue:
                        "${Global.format(Global.toNumber(Global.goldDataModel?.theng?.sell))}",
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber[50]!, Colors.orange[50]!],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTileData(
                        leftTitle: '',
                        leftValue: "",
                        rightTitle: "รับซื้อ",
                        rightValue:
                        "${Global.format(Global.toNumber(Global.goldDataModel?.theng?.buy))}",
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange[50]!, Colors.deepOrange[50]!],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTileData(
                        leftTitle: 'ทองรูปพรรณ',
                        leftValue: "96.5%",
                        rightTitle: "ขายออก",
                        rightValue:
                        "${Global.format(Global.toNumber(Global.goldDataModel?.paphun?.sell))}",
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange[50]!, Colors.deepOrange[50]!],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTileData(
                        leftTitle: '',
                        leftValue: "",
                        rightTitle: "รับซื้อ (ฐานภาษี)",
                        rightValue:
                        "${Global.format(Global.toNumber(Global.goldDataModel?.paphun?.buy))}",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgColor3, Colors.amber[600]!],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: bgColor3.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              Global.goldDataModel = null;
            });
            _animationController.reset();
            init();
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.refresh,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}