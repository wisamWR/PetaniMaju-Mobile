import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/weather_model.dart';
import '../../data/services/weather_service.dart';
import '../../data/services/supabase_service.dart';

class WeatherDetailScreen extends StatefulWidget {
  final WeatherModel? weather;

  const WeatherDetailScreen({super.key, this.weather});

  @override
  State<WeatherDetailScreen> createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> {
  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _weather = widget.weather;
    // Auto-fetch if weather is missing OR if forecast data is incomplete
    // This solves the issue where dashboard might pass partial data
    if (_weather == null || _weather!.dailyForecasts.isEmpty) {
      _fetchWeather();
    }
  }

  Future<void> _fetchWeather({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final weatherService = WeatherService();
      final supabaseService = SupabaseService();

      String? cityName;
      String? provinceName;

      try {
        final profile = await supabaseService.getUserProfile();
        if (profile != null) {
          cityName = profile.kota;
          provinceName = profile.provinsi;
        }
      } catch (e) {
        debugPrint("Error fetching profile for location: $e");
      }

      final locationQuery =
          cityName != null && cityName.isNotEmpty ? cityName : 'Semarang';

      WeatherModel data;
      try {
        data = await weatherService.getWeatherByCity(locationQuery,
            forceRefresh: forceRefresh);
      } catch (e) {
        debugPrint(
            "DEBUG: Failed to fetch by City '$locationQuery'. Trying Province...");

        // Fallback to Province
        if (provinceName != null && provinceName.isNotEmpty) {
          try {
            data = await weatherService.getWeatherByCity(provinceName,
                forceRefresh: forceRefresh);
          } catch (e2) {
            debugPrint("DEBUG: Failed to fetch by Province '$provinceName'.");
            rethrow;
          }
        } else {
          rethrow;
        }
      }

      if (mounted) setState(() => _weather = data);
    } catch (e) {
      debugPrint("Error fetching weather: $e");
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _weather == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: const Color(0xFF166534)),
        ),
      );
    }

    if (_weather == null && _errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Info Cuaca")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  "Gagal memuat cuaca",
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _fetchWeather(forceRefresh: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF166534),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Coba Lagi"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Default empty state protection
    if (_weather == null) return const Scaffold();

    final weather = _weather!;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        title: Text(
          "Info Cuaca Detail",
          style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: RefreshIndicator(
        onRefresh: () async => await _fetchWeather(forceRefresh: true),
        color: const Color(0xFF166534),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Alert Section
              if (weather.alerts.isNotEmpty) ...[
                _buildAlertSection(weather.alerts),
                const SizedBox(height: 20),
              ],

              // 2. Hero Current Weather
              _buildCurrentWeatherCard(weather),
              const SizedBox(height: 24),

              // 3. 7-Day Forecast Header
              Text(
                "Ramalan 5 Hari Ke Depan",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF166534),
                ),
              ),
              const SizedBox(height: 12),

              // 4. Forecast List
              _buildForecastList(weather.dailyForecasts),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertSection(List<WeatherAlert> alerts) {
    return Column(
      children: alerts.map((alert) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                alert.severity == 'danger' ? Colors.red[50] : Colors.orange[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: alert.severity == 'danger'
                  ? Colors.red[200]!
                  : Colors.orange[200]!,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: alert.severity == 'danger'
                    ? Colors.red[700]
                    : Colors.orange[700],
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: alert.severity == 'danger'
                            ? Colors.red[800]
                            : Colors.orange[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.description,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Rekomendasi: ${alert.recommendation}",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCurrentWeatherCard(WeatherModel weather) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF166534), Color(0xFF15803d)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF166534).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Basic Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            weather.cityName,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                          .format(DateTime.now()),
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Update: ${DateFormat('HH:mm').format(weather.lastUpdated ?? DateTime.now())}",
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 10),
                ),
              )
            ],
          ),
          const SizedBox(height: 24),

          // Main Temp & Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl:
                    'https://openweathermap.org/img/wn/${weather.iconCode}@2x.png',
                width: 80,
                height: 80,
                placeholder: (context, url) => const SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(color: Colors.white)),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.cloud, color: Colors.white, size: 60),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "${weather.temperature.toStringAsFixed(0)}°",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ),
                    Text(
                      weather.description.replaceFirstMapped(RegExp(r'^\w'),
                          (match) => match.group(0)!.toUpperCase()),
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Grid Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                  child: _buildStatItem(
                      Icons.water_drop, "${weather.humidity}%", "Kelembaban")),
              Container(width: 1, height: 30, color: Colors.white24),
              Expanded(
                  child: _buildStatItem(
                      Icons.air, "${weather.windSpeed} km/h", "Angin")),
              if (weather.dailyForecasts.isNotEmpty) ...[
                Container(width: 1, height: 30, color: Colors.white24),
                Expanded(
                    child: _buildStatItem(
                        Icons.umbrella,
                        "${weather.dailyForecasts.first.rainChance.toInt()}%",
                        "Hujan")),
              ]
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(color: Colors.white60, fontSize: 10),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildForecastList(List<DailyForecast> forecasts) {
    if (forecasts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text("Data ramalan tidak tersedia.",
              style: GoogleFonts.inter(color: Colors.grey)),
        ),
      );
    }

    return Column(
      children: forecasts.map((day) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[100]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Day & Date (Expanded flex 3)
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE', 'id_ID').format(day.date),
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      DateFormat('d MMM', 'id_ID').format(day.date),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Icon & Rain (Expanded flex 3)
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CachedNetworkImage(
                      imageUrl:
                          'https://openweathermap.org/img/wn/${day.iconCode}.png',
                      width: 40,
                      height: 40,
                      placeholder: (_, __) => const SizedBox(width: 40),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.cloud, size: 24, color: Colors.grey),
                    ),
                    if (day.rainChance > 20)
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 4),
                            Icon(Icons.water_drop,
                                size: 12, color: Colors.blue[300]),
                            Flexible(
                              child: Text(
                                "${day.rainChance.toInt()}%",
                                style: GoogleFonts.inter(
                                    fontSize: 10, color: Colors.blue[300]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      )
                  ],
                ),
              ),

              // Min/Max Temp (Expanded flex 2 to allow right align without fixed width)
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "${day.tempMax.toInt()}°",
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${day.tempMin.toInt()}°",
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
