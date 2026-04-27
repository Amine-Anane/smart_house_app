import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _showPass = false;
  String? _error;

  Future<void> _doLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    await Future.delayed(const Duration(milliseconds: 600));
    final ok = await AuthService.login(_userCtrl.text, _passCtrl.text);

    if (!mounted) return;
    setState(() => _loading = false);

    if (!ok) {
      setState(() => _error = 'Identifiants incorrects');
      return;
    }

    // Go DIRECTLY to dashboard (no setup screen)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4D9FFF), Color(0xFF50FA7B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4D9FFF).withOpacity(0.3),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.home_rounded,
                        color: Colors.white, size: 38),
                  ),
                  const SizedBox(height: 24),
                  Text('SMART HOUSE',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 4,
                      )),
                  const SizedBox(height: 6),
                  Text('Authentification requise',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                      )),
                  const SizedBox(height: 42),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1B29),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF1A3048)),
                    ),
                    child: Column(
                      children: [
                        _input(
                          controller: _userCtrl,
                          label: "Nom d'utilisateur",
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 14),
                        _input(
                          controller: _passCtrl,
                          label: 'Mot de passe',
                          icon: Icons.lock_outline,
                          obscure: !_showPass,
                          suffix: IconButton(
                            icon: Icon(
                              _showPass
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.white54,
                            ),
                            onPressed: () =>
                                setState(() => _showPass = !_showPass),
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF5555).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0xFFFF5555)
                                      .withOpacity(0.3)),
                            ),
                            child: Row(children: [
                              const Icon(Icons.error_outline,
                                  color: Color(0xFFFF5555), size: 18),
                              const SizedBox(width: 8),
                              Text(_error!,
                                  style: const TextStyle(
                                      color: Color(0xFFFF5555), fontSize: 13)),
                            ]),
                          ),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _doLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4D9FFF),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text('SE CONNECTER',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 2,
                                    )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4D9FFF).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFF4D9FFF).withOpacity(0.2)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.info_outline,
                          color: Color(0xFF4D9FFF), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Identifiants par défaut :\nadmin / smart123',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: const Color(0xFF4D9FFF),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: const Color(0xFF4D9FFF)),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFF060B12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A3048)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A3048)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4D9FFF), width: 1.5),
        ),
      ),
    );
  }
}
