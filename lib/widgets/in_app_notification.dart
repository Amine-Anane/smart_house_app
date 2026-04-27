import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InAppNotification {
  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required int priority,
  }) {
    hide();

    final Color color = priority == 3
        ? const Color(0xFFFF5555)
        : priority == 2
            ? const Color(0xFFFFB86C)
            : const Color(0xFF4D9FFF);
    final IconData icon = priority == 3
        ? Icons.warning_rounded
        : priority == 2
            ? Icons.info_outline_rounded
            : Icons.notifications_none_rounded;

    _entry = OverlayEntry(
      builder: (_) => _NotifOverlay(
        title: title,
        message: message,
        color: color,
        icon: icon,
        onDismiss: hide,
      ),
    );

    Overlay.of(context).insert(_entry!);

    _timer = Timer(Duration(seconds: priority == 3 ? 6 : 4), hide);
  }

  static void hide() {
    _timer?.cancel();
    _entry?.remove();
    _entry = null;
  }
}

class _NotifOverlay extends StatefulWidget {
  final String title;
  final String message;
  final Color color;
  final IconData icon;
  final VoidCallback onDismiss;

  const _NotifOverlay({
    required this.title,
    required this.message,
    required this.color,
    required this.icon,
    required this.onDismiss,
  });

  @override
  State<_NotifOverlay> createState() => _NotifOverlayState();
}

class _NotifOverlayState extends State<_NotifOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 12,
      right: 12,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _fade,
            child: GestureDetector(
              onTap: widget.onDismiss,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1B29),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.color.withOpacity(0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(widget.icon, color: widget.color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: GoogleFonts.jetBrainsMono(
                              color: widget.color,
                              fontSize: 10,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white54, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: widget.onDismiss,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
