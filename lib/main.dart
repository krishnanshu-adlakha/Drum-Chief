import 'package:drum_chief/pages/about.dart';
import 'package:drum_chief/auth/auth_services.dart';
import 'package:drum_chief/auth/change_password.dart';
import 'package:drum_chief/auth/change_username.dart';
import 'package:drum_chief/auth/delete_account.dart';
import 'package:drum_chief/auth/edit_account.dart';
import 'package:drum_chief/auth/forgot_password.dart';
import 'package:drum_chief/auth/login_screen.dart';
import 'package:drum_chief/auth/signup_screen.dart';
import 'package:drum_chief/pages/click_only.dart';
import 'package:drum_chief/pages/create.dart';
import 'package:drum_chief/pages/dashboard.dart';
import 'package:drum_chief/widgets/loading_page.dart';
import 'package:drum_chief/pages/welcome.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

//Add speeding up click

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      routes: {
        "/dashboard": (context) => Dashboard(),
        "/create": (context) => CreationScreen(routine: {}, id: ""),
        "/login": (context) => LoginScreen(),
        "/signup": (context) => SignupScreen(),
        "/forgot-password": (context) => ForgotPasswordScreen(),
        "/edit-account": (context) => EditAccountScreen(),
        "/change-username": (context) => UsernameScreen(),
        "/change-password": (context) => ChangePasswordScreen(),
        "/delete-account": (context) => DeleteAccountScreen(),
        "/about": (context) => AboutPage(),
        "/metronome": (context) => MetronomeScreen()
      },
      theme: ThemeData(
        textTheme: GoogleFonts.josefinSansTextTheme(),
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
        primaryColor: Colors.orange,
        scaffoldBackgroundColor: Color.fromARGB(255, 8, 14, 22),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authService,
      builder: (context, authService, child) {
        return StreamBuilder(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            Widget widget;
            if (snapshot.connectionState == ConnectionState.waiting) {
              widget = LoadingPage();
            } else if (snapshot.hasData) {
              widget = WelcomePage();
            } else {
              widget = LoginScreen();
            }
            return widget;
          },
        );
      },
    );
  }
}
