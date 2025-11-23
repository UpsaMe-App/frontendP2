import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/landing_page.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/main_layout.dart';
import 'screens/create_post_page.dart';
import 'screens/public_profile_page.dart';
import 'screens/edit_profile_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UpsaMe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const LandingPage());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterPage());
          case '/main':
            final userId = settings.arguments as String? ?? 'user-id';
            return MaterialPageRoute(builder: (_) => MainLayout(userId: userId));
          case '/create-post':
            return MaterialPageRoute(builder: (_) => const CreatePostPage());
          case '/public-profile':
            final userId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => PublicProfilePage(userId: userId),
            );
          case '/edit-profile':
            final userData = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => EditProfilePage(userData: userData),
            );
          default:
            return MaterialPageRoute(builder: (_) => const LandingPage());
        }
      },
    );
  }
}
