import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherService {
  final String apiKey = '611e1d9c581dba63c147a944f732d3ee';
  final String openWeatherMapURL = 'https://api.openweathermap.org/data/2.5/weather';

  // 1. Hàm lấy vị trí hiện tại
  Future<Position?> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          return null; // Người dùng từ chối cấp quyền
        }
      }
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    } catch (e) {
      print("Lỗi lấy vị trí: $e");
      return null;
    }
  }

  // 2. Hàm lấy thời tiết từ tọa độ
  Future<dynamic> getLocationWeather() async {
    try {
      Position? position = await getCurrentLocation();

      // Nếu không lấy được vị trí, thoát luôn
      if (position == null) return null;

      String url = '$openWeatherMapURL?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric';
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
      return null;
    }
  }

  // 3. Hàm lấy icon thời tiết
  String getWeatherIcon(int condition) {
    if (condition < 300) return '🌩';
    if (condition < 400) return '🌧';
    if (condition < 600) return '☔️';
    if (condition < 700) return '☃️';
    if (condition < 800) return '🌫';
    if (condition == 800) return '☀️';
    if (condition <= 804) return '☁️';
    return '🤷‍';
  }

  // 4. Hàm đưa ra lời khuyên
  String getMessage(int temp) {
    if (temp > 25) return 'Nên ăn kem 🍦';
    if (temp > 20) return 'Mặc áo thun là ổn 👕';
    if (temp < 10) return 'Cần khăn quàng cổ 🧣';
    return 'Nhớ mang áo khoác 🧥';
  }
}