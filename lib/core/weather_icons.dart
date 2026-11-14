import 'package:flutter/material.dart';

/// Ikon & warna Material untuk kode ikon OpenWeather (mis. "10d", "01n").
/// https://openweathermap.org/weather-conditions
class WeatherIcons {
  static IconData iconFor(String iconCode) {
    final night = iconCode.endsWith('n');
    switch (iconCode.length >= 2 ? iconCode.substring(0, 2) : '') {
      case '01':
        return night ? Icons.nightlight_round : Icons.wb_sunny;
      case '02':
        return night ? Icons.nights_stay : Icons.wb_cloudy_outlined;
      case '03':
      case '04':
        return Icons.cloud;
      case '09':
      case '10':
        return Icons.water_drop;
      case '11':
        return Icons.thunderstorm;
      case '13':
        return Icons.ac_unit;
      case '50':
        return Icons.blur_on;
      default:
        return Icons.wb_cloudy_outlined;
    }
  }

  static Color colorFor(String iconCode) {
    if (iconCode.endsWith('n')) return Colors.white;
    switch (iconCode.length >= 2 ? iconCode.substring(0, 2) : '') {
      case '01':
      case '02':
        return Colors.yellow;
      case '09':
      case '10':
      case '11':
        return Colors.lightBlue.shade100;
      default:
        return Colors.white;
    }
  }
}
