import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/esp32_service.dart';
import 'login_screen.dart';
import 'setup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Esp32Service _esp = Esp32Service();
  String _username = '';

  @override
  void initState() {
    super.initState();
    AuthService.getUsername().then((v) {
      if (mounted) setState(() => _username = v);
    });
    _esp.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _esp.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() => mounted ? setState(() {}) : null;

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1B29),
        title: const Text('Se déconnecter ?',
            style: TextStyle(color: Colors.white)),
        content: Text('Vous devrez vous reconnecter pour accéder à l\'app.',
            style: TextStyle(color: Colors.white.withOpacity(0.7))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Déconnecter',
                style: TextStyle(color: Color(0xFFFF5555))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _esp.disconnect();
      await AuthService.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (r) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Text('Réglages',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                )),
            const SizedBox(height: 20),

            // PROFIL
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4D9FFF), Color(0xFF50FA7B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.25),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Connecté en tant que',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(_username,
                          style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // CONNEXION ESP32
            _sectionTitle('CONNEXION ESP32'),
            const SizedBox(height: 10),
            _tile(
              icon: Icons.router_outlined,
              title: 'Adresse IP',
              subtitle: _esp.ipAddress.isEmpty ? 'Non configurée' : _esp.ipAddress,
              color: const Color(0xFF4D9FFF),
              trailing: _esp.connected
                  ? _dot(const Color(0xFF50FA7B))
                  : _dot(const Color(0xFFFF5555)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SetupScreen()),
                );
              },
            ),
            const SizedBox(height: 8),
            _tile(
              icon: _esp.connected ? Icons.wifi : Icons.wifi_off,
              title: _esp.connected ? 'Déconnecter' : 'Reconnecter',
              subtitle: _esp.connected
                  ? 'Couper la liaison WebSocket'
                  : 'Rétablir la liaison WebSocket',
              color: _esp.connected
                  ? const Color(0xFFFF5555)
                  : const Color(0xFF50FA7B),
              onTap: () {
                if (_esp.connected) {
                  _esp.disconnect();
                } else {
                  _esp.connect();
                }
              },
            ),
            const SizedBox(height: 20),

            // INFOS SYSTÈME
            _sectionTitle('SYSTÈME'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1B29),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1A3048)),
              ),
              child: Column(
                children: [
                  _infoRow('Uptime ESP32', _formatUptime(_esp.data.uptime)),
                  _divider(),
                  _infoRow('Température', '${_esp.data.temperature.toStringAsFixed(1)}°C'),
                  _divider(),
                  _infoRow('Version app', '1.0.0'),
                  _divider(),
                  _infoRow('Framework', 'Flutter 3.x'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // LOGOUT
            _sectionTitle('COMPTE'),
            const SizedBox(height: 10),
            _tile(
              icon: Icons.logout_rounded,
              title: 'Se déconnecter',
              subtitle: 'Retourner à l\'écran de login',
              color: const Color(0xFFFF5555),
              onTap: _logout,
            ),

            const SizedBox(height: 24),
            Center(
              child: Text('SMART HOUSE · IoT',
                  style: GoogleFonts.jetBrainsMono(
                    color: Colors.white.withOpacity(0.25),
                    fontSize: 10,
                    letterSpacing: 3,
                  )),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text('ENSTAB · 2025–2026',
                  style: GoogleFonts.jetBrainsMono(
                    color: Colors.white.withOpacity(0.15),
                    fontSize: 9,
                    letterSpacing: 2,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: const Color(0xFF0D1B29),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1A3048)),
          ),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5), fontSize: 12)),
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (trailing == null && onTap != null)
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white38, size: 14),
          ]),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.6), fontSize: 13)),
          ),
          Text(value,
              style: GoogleFonts.jetBrainsMono(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }

  Widget _dot(Color c) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c,
          boxShadow: [BoxShadow(color: c, blurRadius: 4)],
        ),
      );

  Widget _divider() => Container(
        height: 1,
        color: const Color(0xFF1A3048),
      );

  Widget _sectionTitle(String t) => Text(t,
      style: GoogleFonts.jetBrainsMono(
        color: Colors.white.withOpacity(0.5),
        fontSize: 10,
        letterSpacing: 3,
        fontWeight: FontWeight.w600,
      ));

  String _formatUptime(int sec) {
    final h = sec ~/ 3600;
    final m = (sec % 3600) ~/ 60;
    final s = sec % 60;
    return '${h}h ${m}m ${s}s';
  }
}
