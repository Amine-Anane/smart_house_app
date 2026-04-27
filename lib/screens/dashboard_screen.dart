import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/esp32_service.dart';
import '../services/auth_service.dart';
import '../widgets/sensor_card.dart';
import '../widgets/alert_banner.dart';
import '../widgets/in_app_notification.dart';
import 'controls_screen.dart';
import 'alerts_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final Esp32Service _esp = Esp32Service();

  @override
  void initState() {
    super.initState();
    _esp.onNewAlert = _handleAlert;
    // Connexion automatique au démarrage (IP fixe 192.168.4.1)
    if (!_esp.connected) {
      _esp.connect();
    }
  }

  void _handleAlert(String title, String message, int priority) {
    if (!mounted) return;
    InAppNotification.show(context,
        title: title, message: message, priority: priority);
  }

  @override
  void dispose() {
    _esp.onNewAlert = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _HomeTab(),
      const ControlsScreen(),
      const AlertsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0D1B29),
          border: Border(top: BorderSide(color: Color(0xFF1A3048))),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Accueil'),
                _navItem(1, Icons.tune_outlined, Icons.tune, 'Contrôles'),
                _navItem(2, Icons.notifications_outlined,
                    Icons.notifications, 'Alertes'),
                _navItem(3, Icons.settings_outlined, Icons.settings, 'Réglages'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData off, IconData on, String label) {
    final active = _currentIndex == idx;
    return InkWell(
      onTap: () => setState(() => _currentIndex = idx),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Icon(
                active ? on : off,
                key: ValueKey(active),
                color: active ? const Color(0xFF4D9FFF) : Colors.white54,
                size: 24,
              ),
            ),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 0.5,
                  color: active ? const Color(0xFF4D9FFF) : Colors.white54,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
//  HOME TAB
// ═════════════════════════════════════════════════════════════════
class _HomeTab extends StatefulWidget {
  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final Esp32Service _esp = Esp32Service();
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    AuthService.getUsername().then((v) {
      if (mounted) setState(() => _userName = v);
    });
    _esp.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _esp.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() => mounted ? setState(() {}) : null;

  void _retryConnect() {
    _esp.connect();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tentative de reconnexion à 192.168.4.1...',
          style: TextStyle(color: Color(0xFF4D9FFF)),
        ),
        backgroundColor: Color(0xFF0D1B29),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _setBuzzerLow() async {
    await _esp.setBuzzerLow();
  }

  void _setBuzzerHigh() async {
    await _esp.setBuzzerHigh();
  }

  @override
  Widget build(BuildContext context) {
    final d = _esp.data;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_greeting(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13,
                        )),
                    const SizedBox(height: 2),
                    Text(_userName,
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
                _statusBadge(),
              ],
            ),
            const SizedBox(height: 20),

            // Carte de connexion (visible si déconnecté)
            if (!_esp.connected) _connectCard(),
            if (!_esp.connected) const SizedBox(height: 18),

            // Bannière d'alerte
            if (d.alertActive) AlertBanner(data: d),
            if (d.alertActive) const SizedBox(height: 14),

            // Vue d'ensemble
            _overviewCard(d),
            const SizedBox(height: 16),

            // Section Environnement
            _sectionTitle('ENVIRONNEMENT'),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.15,
              children: [
                SensorCard(
                  icon: Icons.thermostat_rounded,
                  label: 'Température',
                  value: d.temperature.toStringAsFixed(1),
                  unit: '°C',
                  color: d.temperature > 35
                      ? const Color(0xFFFF5555)
                      : d.temperature > 30
                          ? const Color(0xFFFFB86C)
                          : const Color(0xFF50FA7B),
                  history: _esp.tempHistory,
                ),
                SensorCard(
                  icon: Icons.water_drop_outlined,
                  label: 'Humidité',
                  value: d.humidity.toStringAsFixed(1),
                  unit: '% RH',
                  color: d.humidity > 80
                      ? const Color(0xFFFFB86C)
                      : const Color(0xFF8BE9FD),
                  history: _esp.humidHistory,
                ),
                SensorCard(
                  icon: d.isNight
                      ? Icons.nightlight_round
                      : Icons.wb_sunny_outlined,
                  label: 'Luminosité',
                  value: d.lux.toStringAsFixed(0),
                  unit: d.isNight ? 'lux · NUIT' : 'lux · JOUR',
                  color: d.isNight
                      ? const Color(0xFFBD93F9)
                      : const Color(0xFFF1FA8C),
                  history: _esp.luxHistory,
                ),
                _doorStatusCard(d),
                _gasDetectionCard(d),
                _fireDetectionCard(d),
              ],
            ),
            const SizedBox(height: 20),

            // Section Sécurité
            _sectionTitle('SÉCURITÉ'),
            const SizedBox(height: 10),
            _securityList(d),
            const SizedBox(height: 20),

            // Section Buzzer
            _sectionTitle('CONTRÔLES'),
            const SizedBox(height: 10),
            _buzzerControlCard(),
          ],
        ),
      ),
    );
  }

  // ═══ Carte de reconnexion ═══
  Widget _connectCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF5555).withOpacity(0.18),
            const Color(0xFF0D1B29),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFF5555).withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF5555).withOpacity(0.2),
                ),
                child: const Icon(Icons.wifi_off,
                    color: Color(0xFFFF5555), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ESP32 NON CONNECTÉ',
                        style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFFFF5555),
                          fontSize: 11,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      'Connecte ton téléphone au WiFi "SmartHouse_IoT"',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _retryConnect,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text('RÉESSAYER',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  )),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4D9FFF),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 6) return 'Bonne nuit';
    if (h < 12) return 'Bonjour';
    if (h < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _esp.connected
            ? const Color(0xFF50FA7B).withOpacity(0.12)
            : const Color(0xFFFF5555).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _esp.connected
              ? const Color(0xFF50FA7B).withOpacity(0.35)
              : const Color(0xFFFF5555).withOpacity(0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _esp.connected
                  ? const Color(0xFF50FA7B)
                  : const Color(0xFFFF5555),
              boxShadow: _esp.connected
                  ? [const BoxShadow(color: Color(0xFF50FA7B), blurRadius: 4)]
                  : null,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            _esp.connected ? 'Connecté' : 'Déconnecté',
            style: TextStyle(
              color: _esp.connected
                  ? const Color(0xFF50FA7B)
                  : const Color(0xFFFF5555),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewCard(d) {
    final bool safe = !d.alertActive;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: safe
              ? [
                  const Color(0xFF50FA7B).withOpacity(0.15),
                  const Color(0xFF0D1B29),
                ]
              : [
                  const Color(0xFFFF5555).withOpacity(0.18),
                  const Color(0xFF0D1B29),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: safe
              ? const Color(0xFF50FA7B).withOpacity(0.3)
              : const Color(0xFFFF5555).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: safe
                  ? const Color(0xFF50FA7B).withOpacity(0.2)
                  : const Color(0xFFFF5555).withOpacity(0.2),
            ),
            child: Icon(
              safe ? Icons.shield_outlined : Icons.warning_amber_rounded,
              color: safe ? const Color(0xFF50FA7B) : const Color(0xFFFF5555),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('État système',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11.5,
                      letterSpacing: 2,
                    )),
                const SizedBox(height: 4),
                Text(
                  safe ? 'Tout est normal' : _alertShort(d.alertPriority),
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  safe
                      ? 'Tous les capteurs sont sous surveillance'
                      : d.alertMessage,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _alertShort(int p) {
    if (p == 3) return 'Danger critique';
    if (p == 2) return 'Avertissement';
    return 'Information';
  }

  Widget _doorStatusCard(d) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B29),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: d.servoOuvert
              ? const Color(0xFFFFB86C).withOpacity(0.4)
              : const Color(0xFF1A3048),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            d.servoOuvert
                ? Icons.door_front_door_outlined
                : Icons.door_front_door,
            color: d.servoOuvert
                ? const Color(0xFFFFB86C)
                : const Color(0xFF4D9FFF),
            size: 26,
          ),
          const Spacer(),
          Text('Porte',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
                letterSpacing: 2,
              )),
          const SizedBox(height: 4),
          Text(d.servoOuvert ? 'OUVERTE' : 'FERMÉE',
              style: GoogleFonts.spaceGrotesk(
                color: d.servoOuvert ? const Color(0xFFFFB86C) : Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 2),
          Text(d.servoOuvert ? 'Servo à 90°' : 'Servo à 0°',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
              )),
        ],
      ),
    );
  }

  Widget _gasDetectionCard(d) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: d.gasDetected
            ? const Color(0xFFFFB74D).withOpacity(0.15)
            : const Color(0xFF0D1B29),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: d.gasDetected
              ? const Color(0xFFFFB74D)
              : const Color(0xFF1A3048),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.local_gas_station,
            color: d.gasDetected ? const Color(0xFFFFB74D) : Colors.white54,
            size: 26,
          ),
          const Spacer(),
          Text('Gaz',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
                letterSpacing: 2,
              )),
          const SizedBox(height: 4),
          Text(d.gasDetected ? 'DÉTECTÉ' : 'NORMAL',
              style: GoogleFonts.spaceGrotesk(
                color: d.gasDetected ? const Color(0xFFFFB74D) : Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 2),
          Text(d.gasDetected ? '⚠️ Fuite détectée' : 'Aucune fuite',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
              )),
        ],
      ),
    );
  }

  Widget _fireDetectionCard(d) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: d.flameDetected
            ? const Color(0xFFFF5555).withOpacity(0.15)
            : const Color(0xFF0D1B29),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: d.flameDetected
              ? const Color(0xFFFF5555)
              : const Color(0xFF1A3048),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.local_fire_department,
            color: d.flameDetected ? const Color(0xFFFF5555) : Colors.white54,
            size: 26,
          ),
          const Spacer(),
          Text('Incendie',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
                letterSpacing: 2,
              )),
          const SizedBox(height: 4),
          Text(d.flameDetected ? 'DÉTECTÉ' : 'NORMAL',
              style: GoogleFonts.spaceGrotesk(
                color: d.flameDetected ? const Color(0xFFFF5555) : Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 2),
          Text(d.flameDetected ? '🔥 Flamme détectée' : 'Aucune flamme',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
              )),
        ],
      ),
    );
  }

  Widget _buzzerControlCard() {
    return Container(
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
              const Icon(Icons.notifications_active,
                  color: Color(0xFFFFB74D), size: 24),
              const SizedBox(width: 12),
              Text('Buzzer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _setBuzzerLow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4D9FFF).withOpacity(0.15),
                    foregroundColor: const Color(0xFF4D9FFF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Color(0xFF4D9FFF)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('BAS',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      )),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _setBuzzerHigh,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB74D).withOpacity(0.15),
                    foregroundColor: const Color(0xFFFFB74D),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Color(0xFFFFB74D)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('HAUT',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _securityList(d) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B29),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1A3048)),
      ),
      child: Column(
        children: [
          _securityRow(
            icon: Icons.directions_run_rounded,
            label: 'Mouvement',
            active: d.motion,
            activeText: 'Détecté',
            inactiveText: 'Aucun',
            color: const Color(0xFFBD93F9),
          ),
          _divider(),
          _securityRow(
            icon: Icons.mic_none_rounded,
            label: 'Son',
            active: d.soundLevel > 50,
            activeText: 'Bruit',
            inactiveText: 'Normal',
            color: const Color(0xFFF1FA8C),
          ),
        ],
      ),
    );
  }

  Widget _securityRow({
    required IconData icon,
    required String label,
    required bool active,
    required String activeText,
    required String inactiveText,
    required Color color,
    bool critical = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: (active ? color : Colors.white).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                color: active ? color : Colors.white54, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                )),
          ),
          if (active && critical)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [BoxShadow(color: color, blurRadius: 6)],
              ),
            ),
          Text(
            active ? activeText : inactiveText,
            style: TextStyle(
              color: active ? color : Colors.white54,
              fontSize: 13,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: const Color(0xFF1A3048),
      );

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.jetBrainsMono(
        color: Colors.white.withOpacity(0.5),
        fontSize: 10,
        letterSpacing: 3,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}