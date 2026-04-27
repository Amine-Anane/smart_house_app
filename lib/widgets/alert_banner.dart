import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/sensor_data.dart';

class AlertBanner extends StatefulWidget {
  final SensorData data;
  const AlertBanner({super.key, required this.data});

  @override
  State<AlertBanner> createState() => _AlertBannerState();
}

class _AlertBannerState extends State<AlertBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final Color color = d.alertPriority == 3
        ? const Color(0xFFFF5555)
        : d.alertPriority == 2
            ? const Color(0xFFFFB86C)
            : const Color(0xFF4D9FFF);
    final IconData icon = d.alertPriority == 3
        ? Icons.warning_rounded
        : d.alertPriority == 2
            ? Icons.info_outline_rounded
            : Icons.notifications_none_rounded;
    final String title = d.alertPriority == 3
        ? 'ALERTE CRITIQUE'
        : d.alertPriority == 2
            ? 'AVERTISSEMENT'
            : 'INFORMATION';

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final glow = d.alertPriority == 3 ? _ctrl.value : 0.0;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12 + glow * 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.4 + glow * 0.4),
              width: 1.5,
            ),
            boxShadow: d.alertPriority == 3
                ? [
                    BoxShadow(
                      color: color.withOpacity(glow * 0.4),
                      blurRadius: 20,
                    ),
                  ]
                : null,
          ),
          child: Row(children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.jetBrainsMono(
                        color: color,
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 2),
                  Text(d.alertMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      )),
                ],
              ),
            ),
          ]),
        );
      },
    );
  }
}
