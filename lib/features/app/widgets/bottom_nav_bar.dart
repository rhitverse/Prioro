import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prioro/colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: appbarColor,
      unselectedItemColor: Colors.grey.shade400,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/svg/home.svg',
            colorFilter: ColorFilter.mode(
              currentIndex == 0 ? appbarColor : Colors.grey.shade400,
              BlendMode.srcIn,
            ),
            width: 24,
            height: 24,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/svg/task.svg',
            colorFilter: ColorFilter.mode(
              currentIndex == 1 ? appbarColor : Colors.grey.shade400,
              BlendMode.srcIn,
            ),
            width: 28,
            height: 28,
          ),
          label: 'Tasks',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/svg/user.svg',
            colorFilter: ColorFilter.mode(
              currentIndex == 2 ? appbarColor : Colors.grey.shade400,
              BlendMode.srcIn,
            ),
            width: 24,
            height: 24,
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
