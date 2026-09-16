import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weatherapidemo/weather_model.dart';
import 'package:weatherapidemo/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService('b50bde26f4a74528a702fb7e3c57bc69');
  Weather? _weather;
  bool _isLoading = true;

  /// Fetch weather using GPS coordinates (Web & Mobile safe)
  _fetchWeather() async {
    try {
      Position position = await _weatherService.getCurrentPosition();
      final weather = await _weatherService.getWeatherByCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching weather: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Weather animations mapping
  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/partly cloudy.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
      case 'thunderstorm':
        return 'assets/storm.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _weather?.cityName ?? "Unknown City",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 200,
              width: 200,
              child: Lottie.asset(
                getWeatherAnimation(_weather?.mainCondition),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              _weather != null
                  ? '${_weather!.temperature.round()}°C'
                  : '--°C',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              _weather?.mainCondition ?? "",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}