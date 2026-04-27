import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0C1520), Color(0xFF060B12)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text('Configuration WiFi',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 3,
                    )),
                const SizedBox(height: 8),
                Text('Connectez votre téléphone au réseau ESP32',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6), fontSize: 13)),
                const SizedBox(height: 32),

                // STEP 1
                _stepCard(
                  number: 1,
                  title: 'Ouvrir les paramètres WiFi',
                  description:
                      'Allez dans les paramètres WiFi de votre téléphone',
                  icon: Icons.settings_outlined,
                ),
                const SizedBox(height: 16),

                // STEP 2
                _stepCard(
                  number: 2,
                  title: 'Chercher le réseau SmartHouse_IoT',
                  description:
                      'Recherchez un réseau WiFi nommé "SmartHouse_IoT"',
                  icon: Icons.router_rounded,
                ),
                const SizedBox(height: 16),

                // STEP 3
                _stepCard(
                  number: 3,
                  title: 'Se connecter au réseau',
                  description:
                      'Connectez-vous (pas de mot de passe requis en mode AP)',
                  icon: Icons.wifi_rounded,
                ),
                const SizedBox(height: 16),

                // STEP 4
                _stepCard(
                  number: 4,
                  title: 'L\'app se connecte automatiquement',
                  description: 'Une fois connecté, l\'app trouvera l\'ESP32 à l\'adresse 192.168.4.1',
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF50FA7B),
                ),

                const SizedBox(height: 32),

                // INFO BOX
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4D9FFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF4D9FFF).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.info_outline,
                            color: Color(0xFF4D9FFF), size: 20),
                        const SizedBox(width: 10),
                        Text('Mode Access Point (AP)',
                            style: GoogleFonts.spaceGrotesk(
                              color: const Color(0xFF4D9FFF),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            )),
                      ]),
                      const SizedBox(height: 8),
                      Text(
                        'L\'ESP32 crée son propre réseau WiFi. Votre téléphone doit d\'abord se connecter à ce réseau pour communiquer avec l\'ESP32.',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                            height: 1.5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4D9FFF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('J\'ai compris',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepCard({
    required int number,
    required String title,
    required String description,
    required IconData icon,
    Color color = const Color(0xFF4D9FFF),
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B29),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
            ),
            child: Center(
              child: Text(
                '$number',
                style: GoogleFonts.spaceGrotesk(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 4),
                Text(description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    )),
              ],
            ),
          ),
          Icon(icon, color: color, size: 28),
        ],
      ),
    );
  }
}