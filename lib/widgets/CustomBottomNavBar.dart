
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:azpire_new/View/profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../View/Dashboard_screen.dart';
import '../View/Notifications.dart';


class CustomBottomNavBar extends StatelessWidget {
  final NotchBottomBarController controller;

  const CustomBottomNavBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    String? _registeredDevice;
    return Stack(
      children: [
        Positioned(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedNotchBottomBar(
                notchBottomBarController: controller,
                color: Colors.white,
                showLabel: true,
                maxLine: 2,
                shadowElevation: 2,
                kBottomRadius: 28.0,
                notchColor: Colors.grey,
                removeMargins: false,
                showShadow: true,
                durationInMilliSeconds: 300,
                itemLabelStyle: const TextStyle(fontSize: 9),
                elevation: 0.5,
                bottomBarItems: const [
                  BottomBarItem(
                    inActiveItem: Icon(Icons.home_filled, color: Color(0xff386BF6)),
                    activeItem: Icon(Icons.home_filled, color: Colors.white),
                    itemLabel: 'Home',
                  ),
                  BottomBarItem(
                    inActiveItem: Icon(Icons.notifications, color: Color(0xff386BF6)),
                    activeItem: Icon(Icons.notifications, color: Colors.white),
                    itemLabel: 'Notifications',
                  ),
                  BottomBarItem(
                    inActiveItem: Icon(Icons.person, color: Color(0xff386BF6)),
                    activeItem: Icon(Icons.person, color: Colors.white),
                    itemLabel: 'Profile',
                  ),
                ],
                onTap: (index) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (index == 0) {
                      Get.to(() => DashboardScreen(deviceID:_registeredDevice ?? ''));
                    } else if (index == 1) {
                      Get.to(() => Notifications_Screen());
                    } else if (index == 2) {
                      Get.to(() => Profile());
                    }
                  });
                },
                kIconSize: 24.0,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

