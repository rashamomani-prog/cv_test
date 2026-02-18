import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/cv_provider.dart';
import 'screens/personal_info_screen.dart';
import 'constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        FirebaseAuth.instance.signInAnonymously().then((value) {
          print(" تم تسجيل دخول مجهول جديد: ${value.user?.uid}");
        }).catchError((e) {
          print(" خطأ أثناء تسجيل الدخول: $e");
        });
      } else {
        print(" المستخدم متصل بالفعل: ${user.uid}");
      }
    });

  } catch (e) {
    print("❌ Firebase Initialization Error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CVProvider()..loadUserData()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CV Builder',
      theme: ThemeData(
        primaryColor: kNavy,
        scaffoldBackgroundColor: kBeige,
      ),
      home:  PersonalInfoScreen(),
    );
  }
}