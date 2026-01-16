import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherServices {
  final String apikey = "84593a6c28254b6abb1191413261201";
  final String forecastBaseUrl = "http://api.weatherapi.com/v1/forecast.json";
  final String searchBaseUrl = "http://api.weatherapi.com/v1/search.json";

  Future<Map<String, dynamic>> fetchCurrentWeather(String city) async {
    final url = '$forecastBaseUrl?key=$apikey&q=$city&days=1&aqi=no&alerts=no';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load weather data");
    }
  }

  //metodo para traer el forecast de 7 dias
  Future<Map<String, dynamic>> fetch7DaysWeather(String city) async {
    final url = '$forecastBaseUrl?key=$apikey&q=$city&days=7&aqi=no&alerts=no';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load weather data");
    }
  }

  //metodo para traer las sugerencias de ciudades
  Future<List<dynamic>> fetchCitySuggestionWeather(String query) async {
    final url = '$searchBaseUrl?key=$apikey&q=$query';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }
}