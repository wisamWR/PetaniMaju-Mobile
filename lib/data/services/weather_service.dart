import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../models/weather_model.dart';
import 'package:intl/intl.dart';
import 'notification_service.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _cacheKeyPrefix = 'cached_weather_';
  static const int _cacheDurationMinutes = 10;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (e) {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return lastKnown;
      }
      throw Exception('Gagal mendapatkan lokasi. Pastikan GPS aktif.');
    }
  }

  Future<WeatherModel> getCurrentWeather({bool forceRefresh = false}) async {
    try {
      Position position = await _determinePosition();
      return _fetchWeatherData(
          lat: position.latitude,
          lon: position.longitude,
          cacheKeySuffix: 'current',
          forceRefresh: forceRefresh);
    } catch (e) {
      // Try load from cache if location fails or internet fails
      final cachedWithLoc = await _loadFromCache('current');
      if (cachedWithLoc != null) return cachedWithLoc;
      rethrow;
    }
  }

  Future<WeatherModel> getWeatherByCity(String cityName,
      {bool forceRefresh = false}) async {
    // Sanitize city name: Remove administrative prefixes
    // OpenWeatherMap works better with just the city name (e.g. "Semarang" vs "KABUPATEN SEMARANG")
    String cleanName = cityName;
    final upperName = cityName.toUpperCase();

    // Administrative Level 2 (City/Regency)
    if (upperName.startsWith("KABUPATEN ")) {
      cleanName = cityName.substring(10).trim();
    } else if (upperName.startsWith("KOTA ")) {
      cleanName = cityName.substring(5).trim();
    }
    // Special Regions (Provinces)
    else if (upperName.startsWith("DI ")) {
      // DI YOGYAKARTA
      cleanName = cityName.substring(3).trim();
    } else if (upperName.startsWith("DKI ")) {
      // DKI JAKARTA
      cleanName = cityName.substring(4).trim();
    } else if (upperName.startsWith("DAERAH ISTIMEWA ")) {
      cleanName = cityName.substring(16).trim();
    }

    return _fetchWeatherData(
        query: cleanName,
        cacheKeySuffix: cleanName.replaceAll(' ', '_'),
        forceRefresh: forceRefresh);
  }

  Future<WeatherModel> _fetchWeatherData(
      {double? lat,
      double? lon,
      String? query,
      required String cacheKeySuffix,
      bool forceRefresh = false}) async {
    final cacheKey = '$_cacheKeyPrefix$cacheKeySuffix';

    // Check Cache
    if (!forceRefresh) {
      final cachedData = await _loadFromCache(cacheKeySuffix);
      if (cachedData != null) {
        return cachedData;
      }
    }

    try {
      // 1. Fetch Current Weather

      Uri currentUri;
      if (query != null) {
        currentUri = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
          'q': query,
          'appid': AppConstants.openWeatherApiKey,
          'units': 'metric',
          'lang': 'id'
        });
      } else {
        currentUri = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
          'lat': lat.toString(),
          'lon': lon.toString(),
          'appid': AppConstants.openWeatherApiKey,
          'units': 'metric',
          'lang': 'id'
        });
      }

      debugPrint("DEBUG: Fetching Weather: $currentUri");

      var currentRes =
          await http.get(currentUri).timeout(const Duration(seconds: 10));

      // RETRY LOGIC: If 404 and using query, try appending ",ID"
      if (currentRes.statusCode == 404 && query != null) {
        debugPrint("DEBUG: 404 Not Found. Retrying with ',ID' suffix...");
        var retryUri =
            Uri.https('api.openweathermap.org', '/data/2.5/weather', {
          'q': '$query,ID',
          'appid': AppConstants.openWeatherApiKey,
          'units': 'metric',
          'lang': 'id'
        });
        debugPrint("DEBUG: Retrying: $retryUri");
        currentRes =
            await http.get(retryUri).timeout(const Duration(seconds: 10));

        // RETRY 2: If still 404, try removing spaces (e.g. "GUNUNG KIDUL" -> "GUNUNGKIDUL,ID")
        if (currentRes.statusCode == 404 && query.contains(' ')) {
          debugPrint("DEBUG: Still 404. Retrying with no spaces...");
          final noSpaceQuery = query.replaceAll(' ', '');
          retryUri = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
            'q': '$noSpaceQuery,ID',
            'appid': AppConstants.openWeatherApiKey,
            'units': 'metric',
            'lang': 'id'
          });
          debugPrint("DEBUG: Retrying: $retryUri");
          currentRes =
              await http.get(retryUri).timeout(const Duration(seconds: 10));
        }
      }

      if (currentRes.statusCode != 200) {
        throw Exception(
            'Gagal memuat cuaca saat ini: ${currentRes.statusCode}');
      }
      final currentJson = jsonDecode(currentRes.body);

      // 2. Fetch Forecast (5 Day / 3 Hour)
      String forecastUrl;
      // Using coordinates from current weather response ensures consistency
      final double targetLat = (currentJson['coord']['lat'] as num).toDouble();
      final double targetLon = (currentJson['coord']['lon'] as num).toDouble();

      forecastUrl =
          '$_baseUrl/forecast?lat=$targetLat&lon=$targetLon&appid=${AppConstants.openWeatherApiKey}&units=metric&lang=id';

      final forecastRes = await http
          .get(Uri.parse(forecastUrl))
          .timeout(const Duration(seconds: 10));
      List<DailyForecast> dailyForecasts = [];

      if (forecastRes.statusCode == 200) {
        final forecastJson = jsonDecode(forecastRes.body);
        dailyForecasts = _processForecastData(forecastJson['list']);
      } else {
        debugPrint(
            "Warning: Failed to load forecast data: ${forecastRes.statusCode}");
      }

      // 3. Construct Model
      var weather = WeatherModel.fromJson(currentJson);

      // 4. Generate Alerts
      List<WeatherAlert> alerts = _generateAlerts(weather, dailyForecasts);

      // --- CHECK & TRIGGER NOTIFICATION ---
      try {
        if (alerts.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          final lastDate = prefs.getString('last_weather_alert_date');
          final todayStr = DateTime.now().toIso8601String().split('T')[0];

          // Check global notification setting
          final globalEnabled = prefs.getBool('notifications_enabled') ?? false;

          if (globalEnabled && lastDate != todayStr) {
            // Pick the most critical alert
            final severeAlert = alerts.firstWhere((a) => a.severity == 'danger',
                orElse: () => alerts.first);

            await NotificationService().showWeatherAlert(
              "⚠️ ${severeAlert.title}",
              "${severeAlert.description} ${severeAlert.recommendation}",
            );

            // Save state to prevent spamming the user all day
            await prefs.setString('last_weather_alert_date', todayStr);
          }
        }
      } catch (e) {
        debugPrint("Error triggering weather alert: $e");
      }
      // ------------------------------------

      // 5. Update Model with Forecast & Alerts
      weather = weather.copyWith(
        dailyForecasts: dailyForecasts,
        alerts: alerts,
      );

      // 6. Save to Cache
      await _saveToCache(cacheKey, weather);

      return weather;
    } catch (e) {
      debugPrint("Error fetching weather data: $e");
      // Fallback: Try load STALE cache if network fails
      final staleCache =
          await _loadFromCache(cacheKeySuffix, ignoreExpiry: true);
      if (staleCache != null) return staleCache;

      rethrow;
    }
  }

  // Aggregate 3-hour forecast into Daily
  List<DailyForecast> _processForecastData(List<dynamic> list) {
    Map<String, List<dynamic>> groupedByDay = {};

    for (var item in list) {
      final String dateStr =
          item['dt_txt'].toString().split(' ')[0]; // YYYY-MM-DD
      if (!groupedByDay.containsKey(dateStr)) {
        groupedByDay[dateStr] = [];
      }
      groupedByDay[dateStr]!.add(item);
    }

    List<DailyForecast> daily = [];
    groupedByDay.forEach((key, items) {
      double minTemp = 1000;
      double maxTemp = -1000;
      double maxPop = 0;
      String description = "";
      String icon = "";

      // Find max/min temp for the day, and max probability of precipitation
      for (var item in items) {
        final tempMin = (item['main']['temp_min'] as num).toDouble();
        final tempMax = (item['main']['temp_max'] as num).toDouble();
        final pop = (item['pop'] as num).toDouble(); // 0 to 1

        debugPrint(
            "DEBUG: Date: $key, Time: ${item['dt_txt']}, Pop: $pop"); // DEBUG LOG

        if (tempMin < minTemp) minTemp = tempMin;
        if (tempMax > maxTemp) maxTemp = tempMax;
        if (pop > maxPop) maxPop = pop;

        // Pick icon/desc from midday (around 12:00) or just the first one if not available
        final time = item['dt_txt'].toString().split(' ')[1];
        if (time.startsWith("12") || description.isEmpty) {
          description = item['weather'][0]['description'];
          icon = item['weather'][0]['icon'];
        }
      }

      daily.add(DailyForecast(
        date: DateTime.parse(key),
        tempMax: maxTemp,
        tempMin: minTemp,
        iconCode: icon,
        description: description,
        rainChance: maxPop * 100, // Convert to %
      ));
    });

    // Take top 7 if available (API gives 5 days usually, sometimes 6 spanning days)
    return daily.take(7).toList();
  }

  List<WeatherAlert> _generateAlerts(
      WeatherModel current, List<DailyForecast> forecasts) {
    List<WeatherAlert> alerts = [];

    // 1. Extreme Heat (> 35°C)
    if (current.temperature > 35) {
      alerts.add(WeatherAlert(
        title: "Panas Ekstrim",
        description:
            "Suhu mencapai ${current.temperature}°C. Tanaman berisiko layu.",
        severity: "danger",
        recommendation: "Tingkatkan penyiraman dan beri naungan jika mungkin.",
      ));
    }

    // 2. Heavy Rain (Rain chance > 70% or current description implies heavy rain)
    bool expectingHeavyRain = forecasts.any((f) => f.rainChance > 70);
    if (current.description.contains('lebat') || expectingHeavyRain) {
      alerts.add(WeatherAlert(
        title: "Potensi Hujan Lebat",
        description:
            "Terdeteksi peluang hujan tinggi (>70%) atau hujan lebat saat ini.",
        severity: "warning",
        recommendation: "Tunda pemupukan dan penyemprotan pestisida.",
      ));
    }

    // 3. Strong Wind (> 40 km/h)
    if (current.windSpeed > 40) {
      // 40 km/h is quite strong
      alerts.add(WeatherAlert(
        title: "Angin Kencang",
        description: "Kecepatan angin mencapai ${current.windSpeed} km/h.",
        severity: "warning",
        recommendation: "Waspada pohon tumbang dan kerusakan tanaman tinggi.",
      ));
    }

    return alerts;
  }

  Future<void> _saveToCache(String key, WeatherModel data) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'data': data.toJson(),
    };
    await prefs.setString(key, jsonEncode(cacheData));
  }

  Future<WeatherModel?> _loadFromCache(String suffix,
      {bool ignoreExpiry = false}) async {
    final key = '$_cacheKeyPrefix$suffix';
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);

      if (jsonString == null) return null;

      final Map<String, dynamic> cacheMap = jsonDecode(jsonString);
      final int timestamp = cacheMap['timestamp'];
      final DateTime cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

      // Check expiry (10 mins) UNLESS ignoreExpiry is true
      if (!ignoreExpiry &&
          DateTime.now().difference(cacheTime).inMinutes >
              _cacheDurationMinutes) {
        // Expired
        return null;
      }

      final weather = WeatherModel.fromJson(cacheMap['data']);

      // Deserialize Forecasts & Alerts manually
      List<DailyForecast> forecasts = [];
      if (cacheMap['data']['dailyForecasts'] != null) {
        forecasts = (cacheMap['data']['dailyForecasts'] as List)
            .map((e) => DailyForecast.fromJson(e))
            .toList();
      }

      List<WeatherAlert> alerts = [];
      if (cacheMap['data']['alerts'] != null) {
        alerts = (cacheMap['data']['alerts'] as List)
            .map((e) => WeatherAlert.fromJson(e))
            .toList();
      }

      return weather.copyWith(
        dailyForecasts: forecasts,
        alerts: alerts,
        lastUpdated: cacheTime,
      );
    } catch (e) {
      print("Cache load error: $e");
      return null;
    }
  }
}
