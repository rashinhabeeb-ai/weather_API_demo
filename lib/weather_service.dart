import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapidemo/weather_model.dart';

class WeatherService {
  static const baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  final String apiKey;

  WeatherService(this.apiKey);

  // Fetch weather using City Name
  Future<Weather> getWeather(String cityName) async {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        'q': cityName,
        'appid': apiKey,
        'units': 'metric',
      },
    );
    return _fetchWeather(uri);
  }

  // Fetch weather using Coordinates (Works on Chrome/Web + Mobile!)
  Future<Weather> getWeatherByCoordinates(double lat, double lon) async {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'appid': apiKey,
        'units': 'metric',
      },
    );
    return _fetchWeather(uri);
  }

  Future<Weather> _fetchWeather(Uri uri) async {
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Could not fetch weather: ${response.statusCode}');
    }

    return Weather.fromJson(jsonDecode(response.body));
  }

  // Get GPS Position safely across Web and Mobile
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission was denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
}