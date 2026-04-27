import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/esp32_service.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _boot();
  }

  Future<void> _boot() async {
    await Esp32Service().init();
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final loggedIn = await AuthService.isLoggedIn();
    if (!loggedIn) {
      _go(const LoginScreen());
      return;
    }
    // Skip setup screen — go directly to dashboard
    _go(const DashboardScreen());
  }

  void _go(Widget page) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: page),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFF0C1520), Color(0xFF060B12)],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4D9FFF), Color(0xFF50FA7B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4D9FFF).withOpacity(0.4),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.home_rounded,
                      color: Colors.white, size: 60),
                ),
                const SizedBox(height: 32),
                Text('SMART HOUSE',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 6,
                    )),
                const SizedBox(height: 8),
                Text('IoT CONTROL CENTER',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: const Color(0xFF4D9FFF),
                      letterSpacing: 4,
                    )),
                const SizedBox(height: 60),
                const SizedBox(
                  width: 140,
                  child: LinearProgressIndicator(
                    backgroundColor: Color(0xFF1A3048),
                    valueColor: AlwaysStoppedAnimation(Color(0xFF4D9FFF)),
                    minHeight: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
