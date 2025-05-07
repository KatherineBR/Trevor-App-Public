import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'home.dart';
import 'feedback.dart';
import 'locationservice.dart';
import 'resources.dart';
import 'theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import "settingsdrawer.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:firebase_analytics/firebase_analytics.dart";
import "messaging.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'switch_icon.dart';
import 'countrycodeservice.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final fcmToken = await FirebaseMessaging.instance.getToken();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  print("fcmToken is $fcmToken");

  // First: request location permission
  String country = await LocationService.getUserCountry(); //CALLS A PERMISSION

  // Then: request notification permission
  Messaging messageHandler = Messaging();
  await messageHandler.mainMessaging(); //CALLS A PERMISSION
  CountryCodeService countryCodeService = CountryCodeService();
  await countryCodeService.initialize();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDefaultTheme = prefs.getBool('isDefaultTheme') ?? true;
  bool isTrevorIcon = prefs.getBool('isTrevorIcon') ?? false;
  runApp(MyApp(initIsDefaultTheme: isDefaultTheme, initIsTrevorIcon: isTrevorIcon,));
}

class MyApp extends StatefulWidget {
  final bool initIsDefaultTheme;
  final bool initIsTrevorIcon;
  const MyApp({super.key, this.initIsDefaultTheme = true, this.initIsTrevorIcon = false});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool isDefaultTheme = widget.initIsDefaultTheme;
  late bool isTrevorIcon = widget.initIsTrevorIcon;
  bool isLoading = true;
  // Initialize the theme state with the value passed from the constructor
  // This makes sure the app starts with the saved theme from SharedPreferences
  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDefaultTheme', isDefaultTheme);
    await prefs.setBool('isTrevorIcon', isTrevorIcon);
  }

  void _toggleTheme() {
      setState(() {
        isDefaultTheme = !isDefaultTheme;
        isTrevorIcon = !isTrevorIcon;
        AppIconSwitcher.switchAppIcon(isTrevorIcon);
        _saveThemePreference();
      });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // if (isLoading) {
    //   return MaterialApp(
    //     home: Scaffold(
    //       body: Center(
    //         child: CircularProgressIndicator(),
    //       ),
    //     ),
    //   );
    // }
    return MaterialApp(
      theme: isDefaultTheme ? AppTheme.getTheme() : AppTheme.getAlternativeTheme(),
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
        isDefaultTheme: isDefaultTheme,
        toggleTheme: _toggleTheme,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool isDefaultTheme;
  final VoidCallback toggleTheme;

  const HomeScreen({
      super.key,
      required this.isDefaultTheme,
      required this.toggleTheme
    });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Track the selected tab

  @override
  void initState() {
    super.initState();
  }
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

    // Get the current theme color and check if it's the default theme
    final defaultThemeColor = AppTheme.getTheme().primaryColor;
    final isUsingDefaultTheme = Theme.of(context).primaryColor == defaultThemeColor;

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
        isDefaultTheme: isUsingDefaultTheme,
        onThemeChanged: (_) => widget.toggleTheme(),
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
