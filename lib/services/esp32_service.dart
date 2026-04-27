import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../models/sensor_data.dart';

class Esp32Service extends ChangeNotifier {
  static final Esp32Service _instance = Esp32Service._internal();
  factory Esp32Service() => _instance;
  Esp32Service._internal();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;

  // ═══════════════════════════════════════════════════════
  // IP FIXE — MODE ACCESS POINT
  // L'ESP32 crée son propre réseau WiFi "SmartHouse_IoT"
  // L'IP est TOUJOURS 192.168.4.1 — jamais besoin de la changer
  // ═══════════════════════════════════════════════════════
  static const String ESP32_IP = '192.168.4.1';
  final String _ipAddress = ESP32_IP;

  bool _connected = false;
  SensorData _data = SensorData();

  // Historique pour les graphiques
  final List<double> tempHistory = [];
  final List<double> humidHistory = [];
  final List<double> luxHistory = [];

  // Historique des alertes
  final List<AlertLog> alertHistory = [];

  // Callback pour les notifications in-app
  Function(String title, String message, int priority)? onNewAlert;

  String get ipAddress => _ipAddress;
  bool get connected => _connected;
  SensorData get data => _data;

  // Init — plus besoin de lire depuis SharedPreferences, IP est fixe
  Future<void> init() async {
    // Connexion automatique au démarrage
    connect();
  }

  void connect() {
    disconnect();
    try {
      final uri = Uri.parse('ws://$_ipAddress/ws');
      _channel = WebSocketChannel.connect(uri);

      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );

      _connected = true;
      debugPrint('[ESP32] Connexion à $_ipAddress réussie');
      notifyListeners();
    } catch (e) {
      debugPrint('[ESP32] Erreur connexion: $e');
      _handleError(e);
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close(status.normalClosure);
    _channel = null;
    _connected = false;
  }

  void _handleMessage(dynamic message) {
    try {
      final jsonData = json.decode(message as String);
      final newData = SensorData.fromJson(jsonData);

      // Détecter nouvelle alerte (transition OFF → ON)
      if (!_data.alertActive && newData.alertActive) {
        _logAlert(newData);
        onNewAlert?.call(
          _alertTitle(newData.alertPriority),
          newData.alertMessage,
          newData.alertPriority,
        );
      }

      _data = newData;
      _addHistory(tempHistory, newData.temperature);
      _addHistory(humidHistory, newData.humidity);
      _addHistory(luxHistory, newData.lux);

      notifyListeners();
    } catch (e) {
      debugPrint('[ESP32] Parse error: $e');
    }
  }

  void _addHistory(List<double> list, double value) {
    list.add(value);
    if (list.length > 30) list.removeAt(0);
  }

  void _logAlert(SensorData d) {
    alertHistory.insert(0, AlertLog(
      message: d.alertMessage,
      priority: d.alertPriority,
      timestamp: DateTime.now(),
    ));
    if (alertHistory.length > 50) alertHistory.removeLast();
  }

  String _alertTitle(int priority) {
    if (priority == 3) return 'ALERTE CRITIQUE';
    if (priority == 2) return 'Avertissement';
    return 'Information';
  }

  void _handleError(dynamic error) {
    debugPrint('[ESP32] Déconnecté: $error');
    _connected = false;
    notifyListeners();
    _scheduleReconnect();
  }

  void _handleDisconnect() {
    _connected = false;
    notifyListeners();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    // Réessaie toutes les 5 secondes automatiquement
    _reconnectTimer = Timer(const Duration(seconds: 5), connect);
  }

  // ══ COMMANDES VERS L'ESP32 ═══════════════════════════════════════

  Future<bool> _cmd(String endpoint) async {
    try {
      final response = await http
          .post(Uri.parse('http://$_ipAddress/api/cmd/$endpoint'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[CMD] Erreur: $e');
      return false;
    }
  }

  Future<bool> openDoor()      => _cmd('door/open');
  Future<bool> closeDoor()     => _cmd('door/close');
  Future<bool> silenceBuzzer() => _cmd('buzzer/off');
  Future<bool> resetAlerts()   => _cmd('reset');

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

class AlertLog {
  final String message;
  final int priority;
  final DateTime timestamp;
  AlertLog({required this.message, required this.priority, required this.timestamp});
}