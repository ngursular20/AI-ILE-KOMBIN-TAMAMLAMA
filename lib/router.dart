import 'package:go_router/go_router.dart';
import 'package:kombin/pages/home_page.dart';
import 'package:kombin/pages/login_page.dart';
import 'package:kombin/pages/register_page.dart';
import 'package:kombin/pages/chatbot_page.dart';
import 'package:kombin/pages/camera.dart';
import 'package:kombin/pages/images.dart';

Map<String, dynamic> appState = {
  'responseData': [], // Initial data
};

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => RegisterPage(),
    ),
    GoRoute(
      path: '/home',
      name: 'homePage',
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) => ChatBotPage(),
    ),
    GoRoute(
      path: '/camera',
      name: 'camera',
      builder: (context, state) => CameraPage(),
    ),
    GoRoute(
      path: '/images',
      name: 'images',
      builder: (context, state) {
        final responseData = appState['responseData'] as List<dynamic>;
        return ImagesPage(responseData: responseData);
      },
    ),
  ],
);
