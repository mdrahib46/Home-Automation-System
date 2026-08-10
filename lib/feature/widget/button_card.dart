import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class ButtonCard extends StatelessWidget {
  const ButtonCard({
    super.key,
    required this.icon,
    required this.onTap,
    required this.title,
    required this.isOn,
  });

  final dynamic icon;
  final VoidCallback onTap;
  final String title;
  final bool isOn;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 180,
        width: 160,
        child: Card(
          color: isOn ? Colors.green.shade50 : Colors.white,
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HugeIcon(
                  icon: icon,
                  size: 42,
                  color: isOn ? Colors.green : Colors.grey,
                ),

                const Spacer(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 26,
                          color: isOn ? Colors.green : Colors.grey
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,

                    ),

                    CircleAvatar(
                      radius: 8,
                      backgroundColor: isOn
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}