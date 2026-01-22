import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/services/weather_services.dart';

class ForecastScreen extends StatefulWidget {
  final String city;
  const ForecastScreen({super.key, required this.city});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  final WeatherServices _weatherServices = WeatherServices();
  List<dynamic>? _forecast;

  @override
  void initState() {
    super.initState();
    _fetchForecastData();
  }

  Future<void> _fetchForecastData() async {
    try {
      final forecastData =
      await _weatherServices.fetch7DaysWeather(widget.city);
      setState(() {
        _forecast = forecastData['forecast']['forecastday'];
      });
    } catch (e) {
      debugPrint("Error fetching forecast: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "7-Day Forecast: ${widget.city}",
          style: GoogleFonts.lato(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // 🌈 FULL SCREEN BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xff1a2344),
                  Color.fromARGB(255, 125, 32, 42),
                  Colors.purple,
                  Color.fromARGB(255, 151, 44, 170),
                ],
              ),
            ),
          ),

          // 📱 CONTENT
          SafeArea(
            child: _forecast == null
                ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
                : ListView.builder(
              padding: const EdgeInsets.only(top: 16),
              itemCount: _forecast!.length,
              itemBuilder: (context, index) {
                final day = _forecast![index];

                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Image.network(
                      "https:${day['day']['condition']['icon']}",
                      width: 50,
                      height: 50,
                    ),
                    title: Text(
                      day['date'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      day['day']['condition']['text'],
                      style:
                      const TextStyle(color: Colors.white70),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Max: ${day['day']['maxtemp_c'].toStringAsFixed(1)}°",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Min: ${day['day']['mintemp_c'].toStringAsFixed(1)}°",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
