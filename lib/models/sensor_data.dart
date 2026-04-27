class SensorData {
  final double temperature;
  final double humidity;
  final double lux;
  final bool isNight;
  final bool motion;
  final bool soundDetected;
  final int soundLevel;
  final bool gasDetected;
  final int gasLevel;
  final bool flameDetected;
  final int flameLevel;
  final bool alertActive;
  final int alertPriority;
  final String alertMessage;
  final bool servoOuvert;
  final bool buzzerOn;
  final bool ledRougeOn;
  final bool ledVerteOn;
  final int uptime;

  SensorData({
    this.temperature = 0,
    this.humidity = 0,
    this.lux = 0,
    this.isNight = false,
    this.motion = false,
    this.soundDetected = false,
    this.soundLevel = 0,
    this.gasDetected = false,
    this.gasLevel = 0,
    this.flameDetected = false,
    this.flameLevel = 0,
    this.alertActive = false,
    this.alertPriority = 0,
    this.alertMessage = '',
    this.servoOuvert = false,
    this.buzzerOn = false,
    this.ledRougeOn = false,
    this.ledVerteOn = true,
    this.uptime = 0,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      lux: (json['lux'] ?? 0).toDouble(),
      isNight: json['isNight'] ?? false,
      motion: json['motion'] ?? false,
      soundDetected: json['soundDetected'] ?? false,
      soundLevel: json['soundLevel'] ?? 0,
      gasDetected: json['gasDetected'] ?? false,
      gasLevel: json['gasLevel'] ?? 0,
      flameDetected: json['flameDetected'] ?? false,
      flameLevel: json['flameLevel'] ?? 0,
      alertActive: json['alertActive'] ?? false,
      alertPriority: json['alertPriority'] ?? 0,
      alertMessage: json['alertMessage'] ?? '',
      servoOuvert: json['servoOuvert'] ?? false,
      buzzerOn: json['buzzerOn'] ?? false,
      ledRougeOn: json['ledRougeOn'] ?? false,
      ledVerteOn: json['ledVerteOn'] ?? true,
      uptime: json['uptime'] ?? 0,
    );
  }
}
