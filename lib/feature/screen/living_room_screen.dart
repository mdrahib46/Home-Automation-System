import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../widget/button_card.dart';
import '../widget/fire_alert_dialog.dart';
import '../widget/temparature_card.dart';

class LivingRoomScreen extends StatefulWidget {
  const LivingRoomScreen({super.key});

  @override
  State<LivingRoomScreen> createState() => _LivingRoomScreenState();
}

class _LivingRoomScreenState extends State<LivingRoomScreen> {
  void _showFireAlertDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return FireAlertDialog(
          onDismiss: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'Living Room',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.dashboard_outlined,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: _showFireAlertDialog,
            icon: const Icon(
              Icons.local_fire_department_outlined,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const TemperatureCard(
              temperature: 24.0,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 160 / 180,
                children: [
                  ButtonCard(
                    icon: HugeIcons.strokeRoundedFan01,
                    onTap: () {},
                    title: 'Fan',
                    isOn: true,
                  ),
                  ButtonCard(
                    icon: HugeIcons.strokeRoundedBulb,
                    onTap: () {},
                    title: 'Light',
                    isOn: false,
                  ),
                  ButtonCard(
                    icon: HugeIcons.strokeRoundedSmartAc,
                    onTap: () {},
                    title: 'AC',
                    isOn: false,
                  ),
                  ButtonCard(
                    icon: HugeIcons.strokeRoundedModernTv,
                    onTap: () {},
                    title: 'Smart TV',
                    isOn: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
