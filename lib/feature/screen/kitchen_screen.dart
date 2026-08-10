import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../widget/button_card.dart';
import '../widget/gas_alert_dialog.dart';
import '../widget/temparature_card.dart';

class KitchenScreen extends StatefulWidget {
  const KitchenScreen({super.key});

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  bool isHumanDetected = false;
  
  // These will be controlled by human detection
  bool isFanOn = false;
  bool isLightOn = false;

  void _toggleHumanDetection(bool value) {
    setState(() {
      isHumanDetected = value;
      // Auto-control based on human detection
      isFanOn = value;
      isLightOn = value;
    });
  }

  void _showGasAlertDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return GasAlertDialog(
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
          'Kitchen',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showGasAlertDialog,
            icon: const Icon(
              Icons.warning_amber_rounded,
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
              temperature: 29.0,
            ),
            const SizedBox(height: 20),
            
            // Human Detection Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isHumanDetected 
                    ? Colors.orange.withValues(alpha: 0.1) 
                    : Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isHumanDetected ? Colors.orange : Colors.blue,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isHumanDetected ? Icons.person : Icons.person_off,
                    color: isHumanDetected ? Colors.orange : Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHumanDetected ? 'Human Detected' : 'No Human',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isHumanDetected ? Colors.orange.shade900 : Colors.blue.shade900,
                          ),
                        ),
                        Text(
                          isHumanDetected 
                              ? 'Fan and Light are ON' 
                              : 'Devices are OFF',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isHumanDetected,
                    onChanged: _toggleHumanDetection,
                    activeColor: Colors.orange,
                  ),
                ],
              ),
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
                    onTap: () {
                      setState(() {
                        isFanOn = !isFanOn;
                      });
                    },
                    title: 'Fan',
                    isOn: isFanOn,
                  ),
                  ButtonCard(
                    icon: HugeIcons.strokeRoundedBulb,
                    onTap: () {
                      setState(() {
                        isLightOn = !isLightOn;
                      });
                    },
                    title: 'Light',
                    isOn: isLightOn,
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
