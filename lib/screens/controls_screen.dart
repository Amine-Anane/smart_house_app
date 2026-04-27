import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/esp32_service.dart';

class ControlsScreen extends StatefulWidget {
  const ControlsScreen({super.key});

  @override
  State<ControlsScreen> createState() => _ControlsScreenState();
}

class _ControlsScreenState extends State<ControlsScreen> {
  final Esp32Service _esp = Esp32Service();
  bool _sendingDoor = false;
  bool _sendingBuzzer = false;
  bool _sendingBuzzerLow = false;
  bool _sendingBuzzerHigh = false;
  bool _sendingReset = false;

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

  Future<void> _toggleDoor() async {
    setState(() => _sendingDoor = true);
    final ok = _esp.data.servoOuvert
        ? await _esp.closeDoor()
        : await _esp.openDoor();
    if (!mounted) return;
    setState(() => _sendingDoor = false);
    _showSnack(
      ok
          ? (_esp.data.servoOuvert ? 'Porte fermée' : 'Porte ouverte')
          : 'Échec de la commande',
      ok,
    );
  }

  Future<void> _silenceBuzzer() async {
    setState(() => _sendingBuzzer = true);
    final ok = await _esp.silenceBuzzer();
    if (!mounted) return;
    setState(() => _sendingBuzzer = false);
    _showSnack(ok ? 'Buzzer coupé' : 'Échec de la commande', ok);
  }

  Future<void> _setBuzzerLow() async {
    setState(() => _sendingBuzzerLow = true);
    final ok = await _esp.setBuzzerLow();
    if (!mounted) return;
    setState(() => _sendingBuzzerLow = false);
    _showSnack(ok ? 'Buzzer BAS activé (5s)' : 'Échec de la commande', ok);
  }

  Future<void> _setBuzzerHigh() async {
    setState(() => _sendingBuzzerHigh = true);
    final ok = await _esp.setBuzzerHigh();
    if (!mounted) return;
    setState(() => _sendingBuzzerHigh = false);
    _showSnack(ok ? 'Buzzer HAUT activé (5s)' : 'Échec de la commande', ok);
  }

  Future<void> _resetAlerts() async {
    setState(() => _sendingReset = true);
    final ok = await _esp.resetAlerts();
    if (!mounted) return;
    setState(() => _sendingReset = false);
    _showSnack(ok ? 'Alertes réinitialisées' : 'Échec', ok);
  }

  void _showSnack(String msg, bool ok) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          ok ? Icons.check_circle : Icons.error,
          color: ok ? const Color(0xFF50FA7B) : const Color(0xFFFF5555),
          size: 18,
        ),
        const SizedBox(width: 10),
        Text(msg),
      ]),
      backgroundColor: const Color(0xFF0D1B29),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final d = _esp.data;
    final open = d.servoOuvert;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Text('Contrôles',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                )),
            const SizedBox(height: 4),
            Text('Commandez votre maison',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5), fontSize: 13)),
            const SizedBox(height: 24),

            // ── PORTE / SERVO ────────────────────────────────
            _sectionTitle('PORTE · SERVO SG90'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: open
                      ? [
                          const Color(0xFFFFB86C).withOpacity(0.18),
                          const Color(0xFF0D1B29),
                        ]
                      : [
                          const Color(0xFF4D9FFF).withOpacity(0.15),
                          const Color(0xFF0D1B29),
                        ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: open
                        ? const Color(0xFFFFB86C).withOpacity(0.4)
                        : const Color(0xFF1A3048)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: open
                          ? const Color(0xFFFFB86C).withOpacity(0.1)
                          : const Color(0xFF4D9FFF).withOpacity(0.1),
                      border: Border.all(
                        color: open
                            ? const Color(0xFFFFB86C)
                            : const Color(0xFF4D9FFF),
                        width: 2,
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        open
                            ? Icons.door_front_door_outlined
                            : Icons.door_front_door,
                        key: ValueKey(open),
                        color: open
                            ? const Color(0xFFFFB86C)
                            : const Color(0xFF4D9FFF),
                        size: 50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    open ? 'PORTE OUVERTE' : 'PORTE FERMÉE',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    open ? 'Servo positionné à 90°' : 'Servo positionné à 0°',
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                          (_sendingDoor || !_esp.connected) ? null : _toggleDoor,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: open
                            ? const Color(0xFF4D9FFF)
                            : const Color(0xFFFFB86C),
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _sendingDoor
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.black54),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(open ? Icons.lock : Icons.lock_open,
                                    size: 20),
                                const SizedBox(width: 10),
                                Text(open ? 'FERMER LA PORTE' : 'OUVRIR LA PORTE',
                                    style: GoogleFonts.spaceGrotesk(
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2)),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── BUZZER ────────────────────────────────────────
            _sectionTitle('ALARME SONORE'),
            const SizedBox(height: 10),
            _commandCard(
              icon: Icons.volume_off_rounded,
              iconColor: const Color(0xFFFF5555),
              title: 'Couper le buzzer',
              subtitle: d.buzzerOn
                  ? '● Le buzzer sonne actuellement'
                  : 'Buzzer silencieux',
              activeIndicator: d.buzzerOn,
              loading: _sendingBuzzer,
              enabled: _esp.connected && d.buzzerOn,
              onTap: _silenceBuzzer,
            ),
            const SizedBox(height: 12),

            // ── BUZZER TEST (BAS / HAUT) ──────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1B29),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1A3048)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB74D).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.notifications_active_rounded,
                            color: Color(0xFFFFB74D), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tester le buzzer',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text('Active le buzzer pendant 5 secondes',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: (_sendingBuzzerLow || !_esp.connected)
                                ? null
                                : _setBuzzerLow,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF4D9FFF).withOpacity(0.15),
                              foregroundColor: const Color(0xFF4D9FFF),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                    color: Color(0xFF4D9FFF), width: 1.5),
                              ),
                              disabledBackgroundColor:
                                  const Color(0xFF4D9FFF).withOpacity(0.05),
                              disabledForegroundColor: Colors.white24,
                            ),
                            child: _sendingBuzzerLow
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF4D9FFF)),
                                  )
                                : Text('BAS',
                                    style: GoogleFonts.spaceGrotesk(
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2,
                                        fontSize: 14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: (_sendingBuzzerHigh || !_esp.connected)
                                ? null
                                : _setBuzzerHigh,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFFFB74D).withOpacity(0.15),
                              foregroundColor: const Color(0xFFFFB74D),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                    color: Color(0xFFFFB74D), width: 1.5),
                              ),
                              disabledBackgroundColor:
                                  const Color(0xFFFFB74D).withOpacity(0.05),
                              disabledForegroundColor: Colors.white24,
                            ),
                            child: _sendingBuzzerHigh
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFFFFB74D)),
                                  )
                                : Text('HAUT',
                                    style: GoogleFonts.spaceGrotesk(
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2,
                                        fontSize: 14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── RESET ─────────────────────────────────────────
            _commandCard(
              icon: Icons.refresh_rounded,
              iconColor: const Color(0xFF50FA7B),
              title: 'Réinitialiser les alertes',
              subtitle: 'Efface les alertes et remet le système à zéro',
              loading: _sendingReset,
              enabled: _esp.connected,
              onTap: _resetAlerts,
            ),

            const SizedBox(height: 26),

            // ── STATUTS LED ─────────────────────────────────────
            _sectionTitle('INDICATEURS LED'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1B29),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1A3048)),
              ),
              child: Row(children: [
                Expanded(
                    child: _ledIndicator(
                  'LED ROUGE',
                  'DANGER',
                  d.ledRougeOn,
                  const Color(0xFFFF5555),
                )),
                Container(
                  width: 1,
                  height: 55,
                  color: const Color(0xFF1A3048),
                ),
                Expanded(
                    child: _ledIndicator(
                  'LED VERTE',
                  'NORMAL',
                  d.ledVerteOn,
                  const Color(0xFF50FA7B),
                )),
              ]),
            ),

            if (!_esp.connected) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5555).withOpacity(0.08),
                  border: Border.all(
                      color: const Color(0xFFFF5555).withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  const Icon(Icons.wifi_off, color: Color(0xFFFF5555), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'ESP32 déconnecté — les commandes sont désactivées',
                      style: TextStyle(
                          color: const Color(0xFFFF5555).withOpacity(0.9),
                          fontSize: 13),
                    ),
                  ),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _commandCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool activeIndicator = false,
    required bool loading,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF0D1B29),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled && !loading ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: enabled
                    ? iconColor.withOpacity(0.25)
                    : const Color(0xFF1A3048)),
          ),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(enabled ? 0.15 : 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(icon, color: enabled ? iconColor : Colors.white38, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(title,
                        style: TextStyle(
                            color: enabled ? Colors.white : Colors.white38,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    if (activeIndicator) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFF5555),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0xFFFF5555), blurRadius: 5),
                          ],
                        ),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5), fontSize: 12)),
                ],
              ),
            ),
            if (loading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFF4D9FFF)),
              )
            else
              Icon(Icons.arrow_forward_ios_rounded,
                  color: enabled ? Colors.white54 : Colors.white24, size: 14),
          ]),
        ),
      ),
    );
  }

  Widget _ledIndicator(String label, String state, bool active, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? color : color.withOpacity(0.15),
              boxShadow: active
                  ? [BoxShadow(color: color, blurRadius: 12, spreadRadius: 1)]
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: GoogleFonts.jetBrainsMono(
                  color: Colors.white54, fontSize: 10, letterSpacing: 1.5)),
          const SizedBox(height: 2),
          Text(active ? 'ON' : 'OFF',
              style: TextStyle(
                color: active ? color : Colors.white.withOpacity(0.3),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              )),
          Text(state,
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 10,
                letterSpacing: 1,
              )),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: GoogleFonts.jetBrainsMono(
            color: Colors.white.withOpacity(0.5),
            fontSize: 10,
            letterSpacing: 3,
            fontWeight: FontWeight.w600),
      );
}