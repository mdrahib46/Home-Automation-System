import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../widget/button_card.dart';
import '../widget/fire_alert_dialog.dart';
import '../widget/temparature_card.dart';

class BedroomScreen extends StatefulWidget {
  const BedroomScreen({super.key});

  @override
  State<BedroomScreen> createState() => _BedroomScreenState();
}

class _BedroomScreenState extends State<BedroomScreen> {
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
          'Bedroom',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        actions: [
          // Dashboard button
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.dashboard_outlined,
              color: Colors.white,
            ),
          ),

          // Fire alert test button
          IconButton(
            onPressed: _showFireAlertDialog,
            icon: const Icon(
              Icons.local_fire_department_outlined,
              color: Colors.white,
            ),
          ),

          // More button
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
            // =========================
            // TEMPERATURE CARD
            // =========================

            const TemperatureCard(
              temperature: 27.5,
            ),

            const SizedBox(height: 20),

            // =========================
            // DEVICE GRID
            // =========================

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
                    isOn: false,
                  ),

                  ButtonCard(
                    icon: HugeIcons.strokeRoundedBulb,
                    onTap: () {},
                    title: 'Light',
                    isOn: true,
                  ),

                  ButtonCard(
                    icon: HugeIcons.strokeRoundedSmartAc,
                    onTap: () {},
                    title: 'AC',
                    isOn: true,
                  ),

                  ButtonCard(
                    icon: HugeIcons.strokeRoundedModernTv,
                    onTap: () {},
                    title: 'TV',
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







