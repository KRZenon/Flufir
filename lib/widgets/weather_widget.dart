import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:diacritic/diacritic.dart';

class WeatherWidget extends StatefulWidget {
  @override
  _WeatherWidgetState createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  final TextEditingController _controller = TextEditingController();
  String _city = 'Ho Chi Minh';
  String _temperature = '';
  String _humidity = '';
  String _weatherDescription = '';
  String _date = '';
  String _backgroundImage = 'assets/clear.jpg';

  String apiKey = '8f2721516b7e9bd4ab89fb4a65619cf2';

  @override
  void initState() {
    super.initState();
    _getWeather(_city); // Fetch weather for the default city
  }

  Future<void> _getWeather(String city) async {
    final sanitizedCity = removeDiacritics(city).toLowerCase();
    final weatherUrl = 'https://api.openweathermap.org/data/2.5/weather?q=$sanitizedCity&appid=$apiKey&units=metric';
    final weatherResponse = await http.get(Uri.parse(weatherUrl));

    if (weatherResponse.statusCode == 200) {
      final weatherData = json.decode(weatherResponse.body);
      final main = weatherData['main'];
      final weather = weatherData['weather'][0];
      final temp = main['temp'];
      final humidity = main['humidity'];
      final description = weather['description'].toLowerCase(); // Make description lowercase
      final now = DateTime.now();

      setState(() {
        _temperature = '$temp°C';
        _humidity = '$humidity%';
        _weatherDescription = description;
        _date = DateFormat('dd/MM/yyyy').format(now); // Format current date
        _city = removeDiacritics(city).toUpperCase();
        _updateBackgroundImage(description);
      });
    } else {
      setState(() {
        _temperature = '';
        _humidity = '';
        _weatherDescription = 'Error retrieving data';
        _date = '';
        _backgroundImage = 'assets/clear.jpg';
      });
    }
  }

  void _updateBackgroundImage(String description) {
    if (description.contains('cloud')) {
      _backgroundImage = 'assets/cloudy.jpg';
    } else if (description.contains('rain')) {
      _backgroundImage = 'assets/rainy.jpg';
    } else if (description.contains('sun') || description.contains('clear')) {
      _backgroundImage = 'assets/sunny.jpg';
    } else {
      _backgroundImage = 'assets/clear.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildBackgroundImage(),
        Container(
          color: Colors.black.withOpacity(0.3), // Dark overlay for better text readability
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Enter city name',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.5),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _city = _controller.text.isEmpty ? 'Ho Chi Minh' : _controller.text;
                      _getWeather(_city);
                    },
                  ),
                ),
              ),
            ),
            Text('Date: $_date', style: const TextStyle(color: Colors.black)),
            Text('City: $_city', style: const TextStyle(color: Colors.black)),
            const SizedBox(height: 10),
            _buildWeatherInfo(),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherInfo() {
    if (_temperature.isEmpty && _humidity.isEmpty && _weatherDescription.isEmpty && _date.isEmpty) {
      return Container();
    } else {
      return Column(
        children: [
          Text('Temperature: $_temperature', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
          Text('Humidity: $_humidity', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      );
    }
  }

  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: Image.asset(
        _backgroundImage,
        fit: BoxFit.cover,
      ),
    );
  }
}
