class WeatherModel {
  final double temperature;
  final String description;
  final String iconCode;
  final String cityName;
  final int humidity;
  final double windSpeed;
  final List<DailyForecast> dailyForecasts;
  final List<WeatherAlert> alerts;
  final DateTime? lastUpdated;

  WeatherModel({
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.cityName,
    this.humidity = 0,
    this.windSpeed = 0.0,
    this.dailyForecasts = const [],
    this.alerts = const [],
    this.lastUpdated,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'],
      iconCode: json['weather'][0]['icon'],
      cityName: json['name'],
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num?)?.toDouble() ?? 0.0,
      dailyForecasts: [], // To be populated separately
      alerts: [], // To be populated separately
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
    );
  }

  WeatherModel copyWith({
    double? temperature,
    String? description,
    String? iconCode,
    String? cityName,
    int? humidity,
    double? windSpeed,
    List<DailyForecast>? dailyForecasts,
    List<WeatherAlert>? alerts,
    DateTime? lastUpdated,
  }) {
    return WeatherModel(
      temperature: temperature ?? this.temperature,
      description: description ?? this.description,
      iconCode: iconCode ?? this.iconCode,
      cityName: cityName ?? this.cityName,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      dailyForecasts: dailyForecasts ?? this.dailyForecasts,
      alerts: alerts ?? this.alerts,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'main': {
        'temp': temperature,
        'humidity': humidity,
      },
      'weather': [
        {'description': description, 'icon': iconCode}
      ],
      'name': cityName,
      'wind': {'speed': windSpeed},
      // Note: forecasts and alerts are not strictly part of OpenWeather 'current' response structure
      // but we can serialize them if we cache the whole model.
      'dailyForecasts': dailyForecasts.map((e) => e.toJson()).toList(),
      'alerts': alerts.map((e) => e.toJson()).toList(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }
}

class DailyForecast {
  final DateTime date;
  final double tempMax;
  final double tempMin;
  final String iconCode;
  final String description;
  final double rainChance;

  DailyForecast({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.iconCode,
    required this.description,
    required this.rainChance,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'tempMax': tempMax,
        'tempMin': tempMin,
        'iconCode': iconCode,
        'description': description,
        'rainChance': rainChance,
      };

  factory DailyForecast.fromJson(Map<String, dynamic> json) => DailyForecast(
        date: DateTime.parse(json['date']),
        tempMax: (json['tempMax'] as num).toDouble(),
        tempMin: (json['tempMin'] as num).toDouble(),
        iconCode: json['iconCode'],
        description: json['description'],
        rainChance: (json['rainChance'] as num).toDouble(),
      );
}

class WeatherAlert {
  final String title;
  final String description;
  final String severity; // 'warning' or 'danger'
  final String recommendation;

  WeatherAlert({
    required this.title,
    required this.description,
    required this.severity,
    required this.recommendation,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'severity': severity,
        'recommendation': recommendation,
      };

  factory WeatherAlert.fromJson(Map<String, dynamic> json) => WeatherAlert(
        title: json['title'],
        description: json['description'],
        severity: json['severity'],
        recommendation: json['recommendation'],
      );
}
