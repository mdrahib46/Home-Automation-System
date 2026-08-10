


import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class FireAlertDialog extends StatelessWidget {
  const FireAlertDialog({
    super.key,
    required this.onDismiss,
  });

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      contentPadding: const EdgeInsets.fromLTRB(
        24,
        28,
        24,
        20,
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ==========================================
          // FIRE ICON
          // ==========================================

          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const HugeIcon(
              icon: HugeIcons.strokeRoundedFire,
              size: 48,
              color: Colors.red,
            ),
          ),

          const SizedBox(height: 20),

          // ==========================================
          // TITLE
          // ==========================================

          const Text(
            'Fire / Smoke Detected!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),

          const SizedBox(height: 12),

          // ==========================================
          // DESCRIPTION
          // ==========================================

          Text(
            'Danger has been detected inside your home. '
                'Please check immediately and take necessary action.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 20),

          // ==========================================
          // SENSOR STATUS
          // ==========================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 10,
                  width: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    'Smoke sensor is active',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Text(
                  'ALERT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onDismiss,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Dismiss Alert',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}