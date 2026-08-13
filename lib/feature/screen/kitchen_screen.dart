import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../widget/button_card.dart';
import '../widget/fire_alert_dialog.dart';
import '../widget/gas_alert_dialog.dart';
import '../widget/temparature_card.dart';

class KitchenScreen extends StatefulWidget {
  const KitchenScreen({super.key});

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  final DatabaseReference _kitchenRef = FirebaseDatabase.instance.ref(
    'smart_home/current_state/rooms/kitchen',
  );
  final DatabaseReference _globalRef = FirebaseDatabase.instance.ref(
    'smart_home/current_state/global/sensors',
  );

  StreamSubscription<DatabaseEvent>? _kitchenSubscription;
  StreamSubscription<DatabaseEvent>? _globalSubscription;

  double _temperature = 0.0;
  bool _isHumanDetected = false;
  bool _gasAlert = false;
  bool _fireDetected = false;
  bool _isGasAlertShowing = false;
  bool _isFireAlertShowing = false;

  Timer? _humanLeavingTimer;
  bool? _lastHumanDetected;

  bool _isFanOn = false;
  bool _isLightOn = false;

  @override
  void initState() {
    super.initState();
    _listenToKitchenData();
    _listenToGlobalData();
  }

  void _listenToGlobalData() {
    _globalSubscription = _globalRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return;

      final Map<dynamic, dynamic> globalData = data;
      _temperature = (globalData['temperature'] as num?)?.toDouble() ?? 0.0;

      if (mounted) setState(() {});
    });
  }

  void _listenToKitchenData() {
    _kitchenSubscription = _kitchenRef.onValue.listen((event) {
      final data = event.snapshot.value;

      if (data == null || data is! Map) {
        return;
      }

      final Map<dynamic, dynamic> kitchenData = data;

      final sensors = kitchenData['sensors'];
      if (sensors is Map) {
        // Temperature now comes from Global path
        final bool newHumanDetected = sensors['human_detected'] as bool? ?? false;
        _gasAlert = sensors['gas_alert'] as bool? ?? false;
        _fireDetected = sensors['fire_detected'] as bool? ?? false;

        if (_lastHumanDetected != newHumanDetected) {
          _handleHumanDetectionAutomation(newHumanDetected);
          _lastHumanDetected = newHumanDetected;
        }
        _isHumanDetected = newHumanDetected;
      }

      final devices = kitchenData['devices'];
      if (devices is Map) {
        _isFanOn = (devices['fan'] as Map?)?['status'] as bool? ?? false;
        _isLightOn = (devices['light'] as Map?)?['status'] as bool? ?? false;
      }

      if (mounted) {
        setState(() {});
      }

      if (_gasAlert && !_isGasAlertShowing) {
        _showGasAlertDialog();
      }

      if (_fireDetected && !_isFireAlertShowing) {
        _showFireAlertDialog();
      }
    });
  }

  void _handleHumanDetectionAutomation(bool detected) {
    if (detected) {
      _humanLeavingTimer?.cancel();
      _humanLeavingTimer = null;
      _autoUpdateDevices(true);
    } else {
      _humanLeavingTimer?.cancel();
      _humanLeavingTimer = Timer(const Duration(seconds: 10), () {
        _autoUpdateDevices(false);
      });
    }
  }

  Future<void> _autoUpdateDevices(bool status) async {
    try {
      await _kitchenRef.update({
        'devices/fan/status': status,
        'devices/light/status': status,
      });
    } catch (e) {
      debugPrint('Firebase automation error: $e');
    }
  }

  void _showGasAlertDialog() {
    if (_isGasAlertShowing) return;
    _isGasAlertShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return GasAlertDialog(
          roomRef: _kitchenRef,
        );
      },
    ).then((_) {
      _isGasAlertShowing = false;
    });
  }

  void _showFireAlertDialog() {
    if (_isFireAlertShowing) return;
    _isFireAlertShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return FireAlertDialog(
          roomRef: _kitchenRef,
        );
      },
    ).then((_) {
      _isFireAlertShowing = false;
    });
  }

  Future<void> _setDeviceStatus({
    required String device,
    required bool status,
  }) async {
    try {
      await _kitchenRef
          .child('devices')
          .child(device)
          .update({
        'status': status,
      });
    } catch (e) {
      debugPrint('Firebase update error: $e');
    }
  }

  Future<void> _toggleHumanDetectionSimulator(bool value) async {
    try {
      await _kitchenRef.update({
        'sensors/human_detected': value,
      });
    } catch (e) {
      debugPrint('Firebase update error: $e');
    }
  }

  @override
  void dispose() {
    _humanLeavingTimer?.cancel();
    _kitchenSubscription?.cancel();
    _globalSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'Smart Home',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showFireAlertDialog,
            icon: const Icon(
              Icons.local_fire_department_outlined,
              color: Colors.white,
            ),
          ),
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
            TemperatureCard(
              temperature: _temperature,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isHumanDetected 
                    ? Colors.orange.withValues(alpha: 0.1) 
                    : Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isHumanDetected ? Colors.orange : Colors.blue,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isHumanDetected ? Icons.person : Icons.person_off,
                    color: _isHumanDetected ? Colors.orange : Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isHumanDetected ? 'Human Detected' : 'No Human',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _isHumanDetected ? Colors.orange.shade900 : Colors.blue.shade900,
                          ),
                        ),
                        Text(
                          _isHumanDetected 
                              ? 'Fan and Light are ON' 
                              : 'Devices are OFF',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isHumanDetected,
                    onChanged: _toggleHumanDetectionSimulator,
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
                      _setDeviceStatus(device: 'fan', status: !_isFanOn);
                    },
                    title: 'Kit. Fan',
                    isOn: _isFanOn,
                  ),
                  ButtonCard(
                    icon: HugeIcons.strokeRoundedBulb,
                    onTap: () {
                      _setDeviceStatus(device: 'light', status: !_isLightOn);
                    },
                    title: 'Kit. Light',
                    isOn: _isLightOn,
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
