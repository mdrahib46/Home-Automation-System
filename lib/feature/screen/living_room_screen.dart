import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
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
  final DatabaseReference _livingRoomRef = FirebaseDatabase.instance.ref(
    'smart_home/current_state/rooms/living_room',
  );

  StreamSubscription<DatabaseEvent>? _livingRoomSubscription;

  double _temperature = 0.0;
  bool _fireDetected = false;
  bool _isFireAlertShowing = false;

  bool _fanStatus = false;
  bool _lightStatus = false;
  bool _acStatus = false;
  bool _tvStatus = false;

  @override
  void initState() {
    super.initState();
    _listenToLivingRoomData();
  }

  void _listenToLivingRoomData() {
    _livingRoomSubscription = _livingRoomRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return;

      final Map<dynamic, dynamic> livingRoomData = data;
      final sensors = livingRoomData['sensors'];

      if (sensors is Map) {
        _temperature = (sensors['temperature'] as num?)?.toDouble() ?? 0.0;
        _fireDetected = sensors['fire_detected'] as bool? ?? false;
      }

      final devices = livingRoomData['devices'];
      if (devices is Map) {
        _fanStatus = (devices['fan'] as Map?)?['status'] as bool? ?? false;
        _lightStatus = (devices['light'] as Map?)?['status'] as bool? ?? false;
        _acStatus = (devices['ac'] as Map?)?['status'] as bool? ?? false;
        _tvStatus = (devices['tv'] as Map?)?['status'] as bool? ?? false;
      }

      if (mounted) setState(() {});

      if (_fireDetected && !_isFireAlertShowing) {
        _showFireAlertDialog();
      }
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
          roomRef: _livingRoomRef,
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
      await _livingRoomRef
          .child('devices')
          .child(device)
          .update({'status': status});
    } catch (e) {
      debugPrint('Firebase update error: $e');
    }
  }

  @override
  void dispose() {
    _livingRoomSubscription?.cancel();
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
            onPressed: () {},
            icon: const Icon(Icons.dashboard_outlined, color: Colors.white),
          ),
          IconButton(
            onPressed: _showFireAlertDialog,
            icon: const Icon(Icons.local_fire_department_outlined, color: Colors.white),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TemperatureCard(temperature: _temperature),
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
                    onTap: () => _setDeviceStatus(device: 'fan', status: !_fanStatus),
                    title: 'Fan',
                    isOn: _fanStatus,
                  ),
                  ButtonCard(
                    icon: HugeIcons.strokeRoundedBulb,
                    onTap: () => _setDeviceStatus(device: 'light', status: !_lightStatus),
                    title: 'Light',
                    isOn: _lightStatus,
                  ),
                  ButtonCard(
                    icon: HugeIcons.strokeRoundedSmartAc,
                    onTap: () => _setDeviceStatus(device: 'ac', status: !_acStatus),
                    title: 'AC',
                    isOn: _acStatus,
                  ),
                  ButtonCard(
                    icon: HugeIcons.strokeRoundedModernTv,
                    onTap: () => _setDeviceStatus(device: 'tv', status: !_tvStatus),
                    title: 'Smart TV',
                    isOn: _tvStatus,
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
