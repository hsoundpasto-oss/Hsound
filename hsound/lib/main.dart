import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hsound/screens/songs/add_song_screen.dart';
import 'package:hsound/screens/profile/edit_profile_screen.dart';
import 'package:hsound/screens/songs/song_player_screen.dart';
import 'package:hsound/screens/home/home_screen.dart';
import 'package:hsound/screens/profile/artist_profile_screen.dart';
import 'package:hsound/screens/events/add_event_screen.dart';
import 'package:hsound/screens/events/event_detail_screen.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hsound',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      // CORREGIDO: Nuevo sistema de rutas
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),

        // HomeScreen como ruta principal
        // Las pantallas de Search, Favorites y Profile ahora están DENTRO del HomeScreen
        '/home': (context) => const HomeScreen(),

        '/edit_profile': (context) => const EditProfileScreen(),
        '/add_song': (context) => const AddSongScreen(),
        '/add_event': (context) => const AddEventScreen(),
        '/event_detail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return EventDetailScreen(eventId: args['eventId']);
        },

        '/artist_profile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return ArtistProfileScreen(artistId: args['artistId']);
        },

        // Rutas que SÍ necesitan navegación separada:
        '/song_player': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return SongPlayerScreen(
            songUrl: args['url'],
            songTitle: args['title'],
            artistName: args['artist'],
            platform: args['platform'],
            artistId: args['artistId'] ?? '',
          );
        },

        // ELIMINADAS (opcional
        // '/search': (context) => const SearchScreen(), // Ahora está dentro de HomeScreen
        // '/favorites': (context) => const FavoritesScreen(), // Ahora está dentro de HomeScreen
        // '/profile': (context) => const ProfileScreen(), // Ahora está dentro de HomeScreen
      },
    );
  }
}
