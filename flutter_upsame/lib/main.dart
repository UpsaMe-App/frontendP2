import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/landing_page.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/main_layout.dart';
import 'screens/create_post_page.dart';
import 'screens/public_profile_page.dart';
import 'screens/edit_profile_page.dart';
import 'screens/post_detail_page.dart';
import 'screens/edit_post_page.dart';
import 'screens/favorites_page.dart';
import 'models/models.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // verde oscuro UPSA vibes
        ),
        useMaterial3: true,
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
            return MaterialPageRoute(
              builder: (_) => MainLayout(userId: userId),
            );
          case '/create-post':
            // Usar PostType.student como valor por defecto si no se especifica
            final initialType =
                settings.arguments as PostType? ?? PostType.student;
            return MaterialPageRoute(
              builder: (_) => CreatePostPage(initialPostType: initialType),
            );
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
          case '/post-detail':
            final post = settings.arguments as Post;
            return MaterialPageRoute(
              builder: (_) => PostDetailPage(post: post),
            );
          case '/edit-post':
            final post = settings.arguments as Post;
            return MaterialPageRoute(builder: (_) => EditPostPage(post: post));
          case '/favorites':
            return MaterialPageRoute(builder: (_) => const FavoritesPage());
          default:
            return MaterialPageRoute(builder: (_) => const LandingPage());
        }
      },
    );
  }
}
