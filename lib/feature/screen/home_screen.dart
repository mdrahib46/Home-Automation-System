import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'bedroom_screen.dart';
import 'kitchen_screen.dart';
import 'living_room_screen.dart';
import '../widget/system_alert_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final DatabaseReference _alertsRef = FirebaseDatabase.instance.ref('smart_home/alerts');
  StreamSubscription<DatabaseEvent>? _alertsSubscription;
  bool _isSystemAlertShowing = false;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const _DashboardView(),
      const BedroomScreen(),
      const LivingRoomScreen(),
      const KitchenScreen(),
    ];
    _listenToGlobalAlerts();
  }

  void _listenToGlobalAlerts() {
    _alertsSubscription = _alertsRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return;

      final Map<dynamic, dynamic> alertsData = data;
      final bool isActive = alertsData['active'] as bool? ?? false;
      final String alertType = alertsData['last_alert_type'] as String? ?? 'Sensor Alert';

      if (isActive && !_isSystemAlertShowing) {
        _showSystemAlertDialog(alertType);
      }
    });
  }

  void _showSystemAlertDialog(String type) {
    if (_isSystemAlertShowing) return;
    _isSystemAlertShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SystemAlertDialog(alertType: type),
    ).then((_) {
      _isSystemAlertShowing = false;
    });
  }

  @override
  void dispose() {
    _alertsSubscription?.cancel();
    super.dispose();
  }

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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bed_rounded),
            label: 'Bedroom',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.weekend_rounded),
            label: 'Living',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_rounded),
            label: 'Kitchen',
          ),
        ],
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

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
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person_outline_rounded, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildBannerCard(
                    color: Colors.teal.shade400,
                    title: 'Smart Lighting',
                    subtitle: 'Save up to 30% energy',
                    icon: Icons.lightbulb_outline_rounded,
                  ),
                  _buildBannerCard(
                    color: Colors.orange.shade400,
                    title: 'Home Security',
                    subtitle: '24/7 Monitoring active',
                    icon: Icons.shield_outlined,
                  ),
                  _buildBannerCard(
                    color: Colors.blue.shade400,
                    title: 'Climate Control',
                    subtitle: 'Perfect temp, always',
                    icon: Icons.thermostat_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Key Features',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildFeatureItem(
                  icon: Icons.psychology_rounded,
                  title: 'AI Automation',
                  color: Colors.purple,
                ),
                _buildFeatureItem(
                  icon: Icons.bolt_rounded,
                  title: 'Energy Tracking',
                  color: Colors.green,
                ),
                _buildFeatureItem(
                  icon: Icons.people_rounded,
                  title: 'Multi-User',
                  color: Colors.blue,
                ),
                _buildFeatureItem(
                  icon: Icons.schedule_rounded,
                  title: 'Schedules',
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.gpp_good_rounded,
                      color: Colors.teal,
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'System Secure',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          Text(
                            'Central alert system is monitoring all sensors in real-time.',
                            style: TextStyle(
                              color: Colors.teal.shade800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCard({
    required Color color,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.2),
              size: 100,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
