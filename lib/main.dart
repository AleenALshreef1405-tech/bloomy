import 'package:bloomy/views/splash_view.dart';
import 'package:bloomy/widgets/MainNavigation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://qzdnnypydnaueawbvogy.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF6ZG5ueXB5ZG5hdWVhd2J2b2d5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzNzk3NDUsImV4cCI6MjA3OTk1NTc0NX0.mdK9GOFlm5Am_IA8xlISygeFSz5_OC0cj-fyFpZ9cqA');
  
  runApp(const MyApp());}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLOOMY',
      // home: const MainNavigation(),
       home: const SplashView(),

    );
  }
}
