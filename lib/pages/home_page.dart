import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as geoLocation;
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

void _launchURL(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
}

class Clothing {
  final String image;
  final String price;
  final String productUrl;

  Clothing({
    required this.image,
    required this.price,
    required this.productUrl,
  });
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _weatherMessage = '';
  int? _temperature;
  int? _condition;
  String _city = '';
  List<Clothing> _clothingList = [];

  @override
  void initState() {
    super.initState();
    _getWeather();
    _getCity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 150.0, // AppBar'ın yüksekliğini artırır
        flexibleSpace: Container(
          width: double.infinity, // AppBar'ın genişliği kadar
          height: 180.0, // Konteynırın yüksekliği
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image/logo.png'),
              fit: BoxFit.fill, // Konteynırı tamamen doldurur
              alignment: Alignment.topLeft,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_temperature != null && _condition != null)
              Container(
                color: Colors
                    .blue[50], // Hava durumu bölümüne arka plan rengi ekler
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    WeatherIcon(condition: _condition!),
                    SizedBox(width: 20), // İkon ve metin arasına boşluk ekler
                    Expanded(
                      // Expanded widget ekleyerek yazının taşmasını önler
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_temperature°C',
                            style: TextStyle(
                              fontSize: 34, // Derecenin fontunu büyütmek için
                            ),
                          ),
                          Text(_city),
                          SizedBox(height: 10),
                          Text(
                            _weatherMessage,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily:
                                  'Arial', // Font ailesini değiştirir (örneğin 'Arial')
                              fontWeight:
                                  FontWeight.bold, // Kalın yapar (isteğe bağlı)
                              color: Color.fromARGB(255, 110, 118,
                                  146), // Rengi siyah yapar (isteğe bağlı)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'İlgini çekebilecek ürünler',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _clothingList.length,
                itemBuilder: (context, index) {
                  return _buildClothingItem(_clothingList[index]);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, // Arka plan rengini beyaz yapar
        selectedItemColor: Colors.black, // Seçili öğe metin rengini ayarlar
        unselectedItemColor:
            Colors.black, // Seçili olmayan öğe metin rengini ayarlar
        selectedFontSize: 12, // Seçili öğe metin boyutunu ayarlar
        unselectedFontSize: 12, // Seçili olmayan öğe metin boyutunu ayarlar
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/image/chatbot.png',
              width: 50,
              height: 60,
            ),
            label: 'Sohbet',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/image/camera.png',
              width: 50,
              height: 60,
            ),
            label: 'Kamera',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/image/logout.png',
              width: 50,
              height: 60,
            ),
            label: 'Çıkış',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            GoRouter.of(context).go('/chat');
          } else if (index == 1) {
            GoRouter.of(context).go('/camera');
          } else if (index == 2) {
            GoRouter.of(context).go('/');
          }
        },
      ),
    );
  }

  Widget _buildClothingItem(Clothing clothing) {
    return GestureDetector(
      onTap: () {
        _launchURL(clothing.productUrl);
      },
      child: Container(
        // margin: EdgeInsets.symmetric(horizontal: 8.0), // Değişiklik burada
        width: 150, // Container'ın genişliğini belirler
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Image.network(
                clothing.image,
                width: 150, // Resmin genişliğini sabit bir değere eşitle
                height: 150, // Resmin yüksekliğini sabit bir değere eşitle
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 8), // Resim ile fiyat arasına boşluk ekler
            Text(
              '${clothing.price}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center, // Fiyatın metni ortalamak için
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getWeather() async {
    final apiKey = '70f950bbaf90a2c9390d5ff3a2a0540f';
    geoLocation.Location location = geoLocation.Location();
    bool _serviceEnabled;
    var _permissionGranted;
    geoLocation.LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await Permission.location.status;
    if (_permissionGranted != PermissionStatus.granted) {
      _permissionGranted = await Permission.location.request();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    final latitude = _locationData.latitude;
    final longitude = _locationData.longitude;

    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('main') &&
            data['main'] != null &&
            data['main']['temp'] != null &&
            data.containsKey('weather') &&
            data['weather'] != null &&
            data['weather'].isNotEmpty) {
          setState(() {
            _temperature = (data['main']['temp'] - 273.15).round();
            _condition = data['weather'][0]['id'];
            _weatherMessage = _getWeatherMessage(_condition!);
          });
          print("here!");
          // Send temperature to the server
        } else {
          print('Invalid data format');
        }
      } else {
        print('Failed to load weather data: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _sendTemperature(int temperature) async {
    print("here2!");
    print(temperature);

    const url = 'http://89.252.140.157:2600/suggest';
    try {
      print(temperature);
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'temperature': temperature}),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _fetchClothingSuggestions(
            data); // Giyim önerileri verisini kullanarak giyim önerilerini güncelle
      } else {
        print('Failed to load clothing suggestions: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _getCity() async {
    geoLocation.Location location = geoLocation.Location();
    bool _serviceEnabled;
    var _permissionGranted;
    geoLocation.LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await Permission.location.status;
    if (_permissionGranted != PermissionStatus.granted) {
      _permissionGranted = await Permission.location.request();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    final latitude = _locationData.latitude;
    final longitude = _locationData.longitude;

    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=70f950bbaf90a2c9390d5ff3a2a0540f';
    try {
      final response = await http.get(Uri.parse(url));
      print('City response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Weather data received: $data');
        if (data.containsKey('main') &&
            data['main'] != null &&
            data['main']['temp'] != null &&
            data.containsKey('weather') &&
            data['weather'] != null &&
            data['weather'].isNotEmpty) {
          setState(() {
            _temperature = (data['main']['temp'] - 273.15).round();
            _condition = data['weather'][0]['id'];
            _weatherMessage = _getWeatherMessage(_condition!);
            _city = data['name']; // Şehir adını güncelle
          });
          print(_temperature);
          _sendTemperature(_temperature!);
        } else {
          print('Invalid data format');
        }
      } else {
        print('Failed to load city data: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String _getWeatherMessage(int condition) {
    String message = '';
    if (condition < 300) {
      message = 'Gök gürültülü fırtına var zayıfsan dışarı çıkma!';
    } else if (condition < 400) {
      message =
          'Hafif yağmur var şemsiyeye gerek yok ama yağmurluğunu alsan iyi olur!';
    } else if (condition < 600) {
      message = 'Hava bugün yağmurlu şemsiyeni unutma sakın!';
    } else if (condition < 700) {
      message = 'Hava bugün karlı kardan adam yapmak için mükemmel bir gün!';
    } else if (condition < 800) {
      message = 'Hava bugün sisli göz gözü görmeyebilir! ';
    } else if (condition == 800) {
      message = 'Hava bugün açık ince giyinebilirsin...';
    } else if (condition <= 804) {
      message = 'Hava bugün bulutlu üstüne bir şey almak isteyebilirsin...';
    } else {
      message = 'Hava bugün bulutlu üstüne bir şey almak isteyebilirsin...';
    }
    return message;
  }

  Future<void> _fetchClothingSuggestions(List<dynamic> data) async {
    List<Clothing> clothingList = [];
    for (var item in data) {
      clothingList.add(Clothing(
        image: item['image_url'],
        price: item['price'], // Fiyat string olarak güncellendi
        productUrl: item['product_url'],
      ));
    }
    setState(() {
      _clothingList = clothingList;
    });
  }
}

class WeatherIcon extends StatelessWidget {
  final int? condition;

  const WeatherIcon({required this.condition});

  @override
  Widget build(BuildContext context) {
    return condition != null
        ? Image.asset(
            _getWeatherIcon(condition!),
            width: 100,
            height: 100,
          )
        : CircularProgressIndicator();
  }

  String _getWeatherIcon(int condition) {
    if (condition < 300) {
      return 'assets/image/thunderstorm.png';
    } else if (condition < 400) {
      return 'assets/image/drizzle.png';
    } else if (condition < 600) {
      return 'assets/image/rainy.png';
    } else if (condition < 700) {
      return 'assets/image/snow.png';
    } else if (condition < 800) {
      return 'assets/image/atmosphore.png';
    } else if (condition == 800) {
      return 'assets/image/sun.png';
    } else if (condition <= 804) {
      return 'assets/image/cloudy.png';
    } else {
      return 'assets/image/cloudy.png';
    }
  }
}
