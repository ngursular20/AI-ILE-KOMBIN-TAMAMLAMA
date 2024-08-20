import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:kombin/components/my_button.dart';

class RegisterPage extends StatelessWidget {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> registerUser(BuildContext context) async {
    final name = nameController.text;
    final email = emailController.text;
    final password = passwordController.text;

    final url = Uri.parse('http://89.252.140.157:2600/register');

    try {
      final client = http.Client();

      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        print('Kayıt başarıyla tamamlandı.');
        print(jsonDecode(response.body)['message']);
        GoRouter.of(context).go('/home');
      } else {
        print('Kayıt işlemi başarısız oldu. Hata kodu: ${response.statusCode}');
        print(jsonDecode(response.body)['message']);
      }

      client.close();
    } catch (error) {
      print('Bağlantı hatası: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 100),
                  Text(
                    'HESAP OLUŞTUR',
                    style: TextStyle(
                      color: Color.fromARGB(255, 155, 115, 130),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 25),
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Ad-Soyad',
                        prefixIcon: Icon(Icons.person), // İnsan logosu
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              50), // Tamamen yuvarlanmış köşeler
                        ),
                        fillColor: Colors.white, // Arka plan rengi
                        filled: true, // Arkaplanı doldurmayı etkinleştir
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'E-Posta',
                        prefixIcon: Icon(Icons.email), // İnsan logosu
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              50), // Tamamen yuvarlanmış köşeler
                        ),
                        fillColor: Colors.white, // Arka plan rengi
                        filled: true, // Arkaplanı doldurmayı etkinleştir
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        hintText: 'Şifre',
                        prefixIcon: Icon(Icons.lock), // Şifre logosu
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              50), // Fully rounded corners
                        ),
                        fillColor: Colors.white, // Arka plan rengi
                        filled: true, // Arkaplanı doldurmayı etkinleştir
                      ),
                    ),
                  ),
                  SizedBox(height: 55),
                  MyButton(
                    onTap: () => registerUser(context),
                    buttonText: 'Kayıt Ol',
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      GoRouter.of(context).go('/');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Zaten hesabınız var mı?',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'buradan giriş yapın',
                          style: TextStyle(
                            color: Color.fromARGB(255, 161, 112, 131),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
