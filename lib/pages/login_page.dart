import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:kombin/components/my_button.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> signUserIn(BuildContext context) async {
    final String email = usernameController.text;
    final String password = passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('http://89.252.140.157:2600/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Login successful, navigate to home page
        GoRouter.of(context).go('/home');
      } else {
        // Login failed, show error message
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('GİRİŞ BAŞARISIZ'),
            content: Text(
                'Girilen e-posta ile kayıtlı bir hesap bulunamadı! Lütfen tekrar deneyin.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 55),
                    FractionallySizedBox(
                      widthFactor: 0.8,
                      child: TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          hintText: 'e-posta',
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
                          hintText: 'şifre',
                          prefixIcon: Icon(Icons.lock), // Şifre logosu
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                50), // Fully rounded corners
                          ),
                          fillColor: Colors.white, // Arka plan rengi
                          filled: true, // Arkaplanı doldurmayı etkinleştir
                        ),
                        obscureText: true,
                      ),
                    ),
                    SizedBox(height: 45),
                    MyButton(
                      onTap: () => signUserIn(context),
                      buttonText: 'Giriş Yap',
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        GoRouter.of(context).go('/register');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Hala üye değil misin?',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'hemen üye ol',
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
      ),
    );
  }
}
