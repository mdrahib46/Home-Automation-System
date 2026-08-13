import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
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
  final DatabaseReference _bedroomRef = FirebaseDatabase.instance.ref(
    'smart_home/current_state/rooms/bedroom',
  );
  final DatabaseReference _globalRef = FirebaseDatabase.instance.ref(
    'smart_home/current_state/global/sensors',
  );

  StreamSubscription<DatabaseEvent>? _bedroomSubscription;
  StreamSubscription<DatabaseEvent>? _globalSubscription;

  double _temperature = 0.0;
  double _humidity = 0.0;
  bool _motionDetected = false;
  bool _fireDetected = false;
  bool _isFireAlertShowing = false;

  bool _fanStatus = false;
  int _fanSpeed = 0;
  bool _lightStatus = false;
  bool _acStatus = false;
  int _acTemperature = 24;
  bool _tvStatus = false;

  @override
  void initState() {
    super.initState();
    _listenToBedroomData();
    _listenToGlobalData();
  }

  void _listenToGlobalData() {
    _globalSubscription = _globalRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return;

      final Map<dynamic, dynamic> globalData = data;
      _temperature = (globalData['temperature'] as num?)?.toDouble() ?? 0.0;
      _humidity = (globalData['humidity'] as num?)?.toDouble() ?? 0.0;

      if (mounted) setState(() {});
    });
  }

  void _listenToBedroomData() {
    _bedroomSubscription = _bedroomRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return;

      final Map<dynamic, dynamic> bedroomData = data;
      final sensors = bedroomData['sensors'];

      if (sensors is Map) {
        // Temperature and Humidity now come from Global path
        _motionDetected = sensors['motion'] as bool? ?? false;
        _fireDetected = sensors['fire_detected'] as bool? ?? false;
      }

      final devices = bedroomData['devices'];
      if (devices is Map) {
        final fan = devices['fan'];
        if (fan is Map) {
          _fanStatus = fan['status'] as bool? ?? false;
          _fanSpeed = (fan['speed'] as num?)?.toInt() ?? 0;
        }

        final light = devices['light'];
        if (light is Map) {
          _lightStatus = light['status'] as bool? ?? false;
        }

        final ac = devices['ac'];
        if (ac is Map) {
          _acStatus = ac['status'] as bool? ?? false;
          _acTemperature = (ac['set_temp'] as num?)?.toInt() ?? 24;
        }

        final tv = devices['tv'];
        if (tv is Map) {
          _tvStatus = tv['status'] as bool? ?? false;
        }
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
          roomRef: _bedroomRef,
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
      await _bedroomRef
          .child('devices')
          .child(device)
          .update({'status': status});
    } catch (e) {
      debugPrint('Firebase update error: $e');
    }
  }

  @override
  void dispose() {
    _bedroomSubscription?.cancel();
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
                    title: 'TV',
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
