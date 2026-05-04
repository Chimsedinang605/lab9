import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'weather_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Thiết lập Theme sáng (Light Mode) làm chủ đạo
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.pink[300],
        scaffoldBackgroundColor: const Color(0xFFFFFAFA), // Màu trắng tuyết nhạt
      ),
      home: const LoadingScreen(),
    );
  }
}

// ==========================================
// MÀN HÌNH 1: LOADING (Phông nền Hồng Pastel)
// ==========================================
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    getLocationData();
  }

  void getLocationData() async {
    var weatherData = await WeatherService().getLocationWeather();

    if (!mounted) return;

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return LocationScreen(locationWeather: weatherData);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50], // Nền hồng cực nhạt
      body: Center(
        child: SpinKitPulse( // Đổi hiệu ứng loading nhẹ nhàng hơn
          color: Colors.pink[300],
          size: 100.0,
        ),
      ),
    );
  }
}

// ==========================================
// MÀN HÌNH 2: HIỂN THỊ THỜI TIẾT (Pastel)
// ==========================================
class LocationScreen extends StatefulWidget {
  final dynamic locationWeather;

  const LocationScreen({super.key, this.locationWeather});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final WeatherService weatherService = WeatherService();
  int temperature = 0;
  String weatherIcon = '';
  String cityName = '';
  String weatherMessage = '';

  // Thêm biến để đổi màu chữ tùy theo tông nền
  final Color darkTextColor = Colors.blue.shade900;

  @override
  void initState() {
    super.initState();
    updateUI(widget.locationWeather);
  }

  void updateUI(dynamic weatherData) {
    setState(() {
      if (weatherData == null) {
        temperature = 0;
        weatherIcon = '🤷‍';
        weatherMessage = 'Lỗi dữ liệu';
        cityName = '';
        return;
      }
      double temp = weatherData['main']['temp'];
      temperature = temp.toInt();
      var condition = weatherData['weather'][0]['id'];
      cityName = weatherData['name'];

      weatherIcon = weatherService.getWeatherIcon(condition);
      weatherMessage = weatherService.getMessage(temperature);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 1. Tạo nền Gradient nữ tính (Hồng sang Xanh da trời)
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.pink[50]!, // Hồng nhạt
              Colors.blue[50]!, // Xanh da trời nhạt
            ],
          ),
        ),
        constraints: const BoxConstraints.expand(),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Hàng nút bấm màu Hồng
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TextButton(
                    onPressed: () async {
                      var weatherData = await weatherService.getLocationWeather();
                      updateUI(weatherData);
                    },
                    child: Icon(Icons.near_me, size: 50.0, color: Colors.pink[400]),
                  ),
                  TextButton(
                    onPressed: () {
                      // Mở rộng sau
                    },
                    child: Icon(Icons.location_city, size: 50.0, color: Colors.pink[400]),
                  ),
                ],
              ),

              // 2. Khu vực hiển thị Nhiệt độ nổi bật
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Căn giữa
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Text(
                      '$temperature°',
                      style: TextStyle(
                        fontSize: 120.0,
                        fontWeight: FontWeight.w900,
                        color: darkTextColor, // Chữ màu tối
                      ),
                    ),
                    Text(
                      weatherIcon,
                      style: const TextStyle(fontSize: 90.0),
                    ),
                  ],
                ),
              ),

              // 3. Thẻ Card chứa lời khuyên (Hiện đại và gọn gàng)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9), // Trắng trong suốt nhẹ
                      borderRadius: BorderRadius.circular(20), // Bo góc
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.1), // Đổ bóng hồng mờ
                          blurRadius: 20,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        )
                      ]
                  ),
                  child: Text(
                    '$weatherMessage tại $cityName',
                    textAlign: TextAlign.center, // Căn giữa lời khuyên
                    style: TextStyle(
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                      height: 1.3, // Khoảng cách dòng rộng rãi
                      color: darkTextColor.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}