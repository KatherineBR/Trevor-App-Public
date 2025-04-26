import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'home.dart';
import 'feedback.dart';
import 'resources.dart';
import 'theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import "settingsdrawer.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:firebase_analytics/firebase_analytics.dart";
import "messaging.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  
  final fcmToken = await FirebaseMessaging.instance.getToken();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  print("fcmToken is $fcmToken");

  Messaging message_handler = Messaging();
  message_handler.main_messaging();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _useAlternativeTheme = false;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _useAlternativeTheme ? AppTheme.getAlternativeTheme() : AppTheme.getTheme()  ,
      // loads localized resources
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // lists the languages that the app supports
      supportedLocales: [
        Locale('en', 'US'), // English
        Locale('es', 'MX'), // Spanish
      ],
      home: HomeScreen(
        onThemeChanged: (bool useDefault) {
          setState(() {
            _useAlternativeTheme = useDefault;
          });
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Function(bool)? onThemeChanged;

  const HomeScreen({super.key, this.onThemeChanged});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Track the selected tab

  // List of pages to display based on the selected index
  final List<Widget> _pages = [
    MyHomePage(),        // Home page from home.dart
    ResourcesPage(),  // Meditation page from resources.dart
    FeedbackApp(),    // Feedback page from feedback.dart
  ];

  // This function is called when a bottom nav item is selected
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Set the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: SettingsDrawer(
        onThemeChanged: (bool value) {
          if (widget.onThemeChanged != null) {
            widget.onThemeChanged!(value);
          }
        },
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      // styles
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped, // Handle selection of nav items
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: localizations.home,
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books), // Resources icon
            label: localizations.resources,
          ),
          NavigationDestination(
            icon: Icon(Icons.feedback), // Feedback icon
            label: localizations.feedback,
          ),
        ],
      ),
    );
  }
}