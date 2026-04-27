import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/esp32_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final Esp32Service _esp = Esp32Service();

  @override
  void initState() {
    super.initState();
    _esp.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _esp.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() => mounted ? setState(() {}) : null;

  @override
  Widget build(BuildContext context) {
    final history = _esp.alertHistory;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Historique',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        )),
                    Text('${history.length} alerte${history.length > 1 ? "s" : ""} enregistrée${history.length > 1 ? "s" : ""}',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 13)),
                  ],
                ),
                if (history.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Color(0xFFFF5555)),
                    tooltip: 'Effacer l\'historique',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF0D1B29),
                          title: const Text('Effacer l\'historique ?',
                              style: TextStyle(color: Colors.white)),
                          content: Text(
                              'Toutes les alertes enregistrées seront supprimées.',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7))),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () {
                                _esp.alertHistory.clear();
                                Navigator.pop(ctx);
                                setState(() {});
                              },
                              child: const Text('Effacer',
                                  style: TextStyle(color: Color(0xFFFF5555))),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: history.isEmpty
                ? _emptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) => _alertTile(history[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF50FA7B).withOpacity(0.1),
            ),
            child: const Icon(Icons.check_circle_outline,
                color: Color(0xFF50FA7B), size: 42),
          ),
          const SizedBox(height: 20),
          Text('Aucune alerte',
              style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Tout va bien dans votre maison',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _alertTile(AlertLog alert) {
    final Color color = alert.priority == 3
        ? const Color(0xFFFF5555)
        : alert.priority == 2
            ? const Color(0xFFFFB86C)
            : const Color(0xFF4D9FFF);

    final IconData icon = alert.priority == 3
        ? Icons.warning_rounded
        : alert.priority == 2
            ? Icons.info_outline_rounded
            : Icons.notifications_none_rounded;

    final String prio = alert.priority == 3
        ? 'CRITIQUE'
        : alert.priority == 2
            ? 'AVERTISSEMENT'
            : 'INFO';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B29),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: color, width: 3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(prio,
                        style: GoogleFonts.jetBrainsMono(
                          color: color,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        )),
                  ),
                  const Spacer(),
                  Text(_timeAgo(alert.timestamp),
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 11)),
                ]),
                const SizedBox(height: 6),
                Text(alert.message,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 60) return 'à l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    return '${t.day}/${t.month} ${t.hour}:${t.minute.toString().padLeft(2, '0')}';
  }
}
