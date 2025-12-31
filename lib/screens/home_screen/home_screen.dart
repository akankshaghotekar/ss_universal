import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ss_universal/utils/app_colors.dart';
import 'package:ss_universal/utils/common_drawer.dart';
import 'package:ss_universal/utils/media_query.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  final List<String> banners = [
    "assets/images/carousel_img.png",
    "assets/images/carousel_img.png",
    "assets/images/carousel_img.png",
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentIndex < banners.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }

      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MQ.width(context);
    final h = MQ.height(context);

    return Scaffold(
      backgroundColor: AppColor.background,

      /// DRAWER
      drawer: CommonDrawer(onClose: () => Navigator.pop(context)),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TOP BAR
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.04,
                vertical: h * 0.015,
              ),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => InkWell(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: const Icon(Icons.menu, size: 28),
                    ),
                  ),

                  const Spacer(),

                  Image.asset(
                    "assets/images/ss-universal-logo.png",
                    height: 40.h,
                  ),

                  const Spacer(),
                ],
              ),
            ),

            SizedBox(height: h * 0.015),

            /// IMAGE CAROUSEL
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.04),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: SizedBox(
                  height: h * 0.25,
                  width: double.infinity,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: banners.length,
                    onPageChanged: (index) {
                      _currentIndex = index;
                    },
                    itemBuilder: (context, index) {
                      return Image.asset(banners[index], fit: BoxFit.cover);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
