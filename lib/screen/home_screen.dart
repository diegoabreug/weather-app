import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/screen/forecast_screen.dart';
import 'package:weather_app/services/weather_services.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _currentWeather;
  String city = "Santo Domingo";
  final WeatherServices _weatherServices = WeatherServices();

  @override
  void initState() {
    super.initState();
    _loadWeatherWithLocation();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Los servicios de ubicación están deshabilitados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Los permisos de ubicación fueron denegados');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Los permisos están denegados permanentemente.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _loadWeatherWithLocation() async {
    try {
      Position position = await _determinePosition();
      String locationQuery =
          "${position.latitude},${position.longitude}";

      final forecastData =
      await _weatherServices.fetchCurrentWeather(locationQuery);

      setState(() {
        _currentWeather = forecastData;
        city = forecastData['location']['name'];
      });
    } catch (e) {
      debugPrint("Error obteniendo ubicación o clima: $e");
      _fetchForecastData();
    }
  }

  Future<void> _fetchForecastData() async {
    try {
      final forecastData =
      await _weatherServices.fetchCurrentWeather(city);
      setState(() {
        _currentWeather = forecastData;
      });
    } catch (e) {
      debugPrint("Error fetching forecast: $e");
    }
  }

  void _showCitySelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter a City'),
          content: TypeAheadField(
            builder: (context, controller, focusNode) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'City',
                ),
              );
            },
            itemBuilder: (context, suggestion) {
              final cityData = suggestion as Map<String, dynamic>;
              return ListTile(
                title: Text(cityData['name']),
                subtitle:
                Text("${cityData['region']}, ${cityData['country']}"),
              );
            },
            onSelected: (suggestion) {
              final cityData = suggestion as Map<String, dynamic>;
              setState(() {
                city = cityData['name'];
              });
            },
            suggestionsCallback: (search) async {
              return await _weatherServices
                  .fetchCitySuggestionWeather(search);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _fetchForecastData();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentWeather == null
          ? Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: AlignmentDirectional.bottomCenter,
            colors: [
              Color(0xff1a2344),
              Color.fromARGB(255, 125, 32, 42),
              Colors.purple,
              Color.fromARGB(255, 151, 44, 170),
            ],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      )
          : Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: AlignmentDirectional.bottomCenter,
            colors: [
              Color(0xff1a2344),
              Color.fromARGB(255, 125, 32, 42),
              Colors.purple,
              Color.fromARGB(255, 151, 44, 170),
            ],
          ),
        ),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            InkWell(
              onTap: _showCitySelectionDialog,
              child: Text(
                _currentWeather!['location']['name'],
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 36,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Image.network(
                    'https:${_currentWeather!['current']['condition']['icon']}',
                    width: 100,
                    height: 100,
                  ),
                  Text(
                    '${_currentWeather!['current']['temp_c']} ℃',
                    style: GoogleFonts.lato(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _currentWeather!['current']['condition']['text'],
                    style: GoogleFonts.lato(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Max: ${_currentWeather!['forecast']['forecastday'][0]['day']['maxtemp_c']} ℃',
                        style: GoogleFonts.lato(
                          fontSize: 22,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Min: ${_currentWeather!['forecast']['forecastday'][0]['day']['mintemp_c']} ℃',
                        style: GoogleFonts.lato(
                          fontSize: 22,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 45),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceEvenly,
              children: [
                _buildWeatherDetails(
                  "Sunrise",
                  Icons.wb_sunny,
                  _currentWeather!['forecast']
                  ['forecastday'][0]['astro']
                  ['sunrise'],
                ),
                _buildWeatherDetails(
                  "Sunset",
                  Icons.brightness_3,
                  _currentWeather!['forecast']
                  ['forecastday'][0]['astro']
                  ['sunset'],
                ),
              ],
            ),
            const SizedBox(height: 45),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceEvenly,
              children: [
                _buildWeatherDetails(
                  "Humidity",
                  Icons.water_drop,
                  '${_currentWeather!['current']['humidity']}%',
                ),
                _buildWeatherDetails(
                  "Wind (KPH)",
                  Icons.air,
                  _currentWeather!['current']['wind_kph'],
                ),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ForecastScreen(city: city),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xff1a2344),
                ),
                child: Text(
                  'Next 7 days Forecast',
                  style:
                  GoogleFonts.lato(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildWeatherDetails(
    String label, IconData icon, dynamic value) {
  return ClipRRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [
              const Color(0xff1a2344).withValues(alpha: 0.5),
              const Color(0xff1a2344).withValues(alpha: 0.2),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value is String ? value : value.toString(),
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
