import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:smart_home/feature/screen/bedroom_screen.dart';
import 'package:smart_home/feature/screen/kitchen_screen.dart';
import 'package:smart_home/feature/screen/living_room_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const BedroomScreen(),
    const LivingRoomScreen(),
    const KitchenScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedBedDouble,
              color: Colors.grey,
              size: 24,
            ),
            activeIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedBedDouble,
              color: Colors.teal,
              size: 24,
            ),
            label: 'Bedroom',
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedSofa01,
              color: Colors.grey,
              size: 24,
            ),
            activeIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedSofa01,
              color: Colors.teal,
              size: 24,
            ),
            label: 'Living',
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedChefHat,
              color: Colors.grey,
              size: 24,
            ),
            activeIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedChefHat,
              color: Colors.teal,
              size: 24,
            ),
            label: 'Kitchen',
          ),
        ],
      ),
    );
  }
}
