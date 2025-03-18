import 'package:flutter/material.dart';
import 'webview_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'home.dart';        // Import home.dart
import 'feedback.dart';   // Import feedback.dart
import 'resources.dart'; // Import resources.dart

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
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
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Track the selected tab

  // List of pages to display based on the selected index
  final List<Widget> _pages = [
    MyHomePage(),        // Home page from home.dart
    MyResourcesPage(),  // Meditation page from resources.dart
    MyFeedbackPage(),    // Feedback page from feedback.dart
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
      
      body: IndexedStack(
        index: _selectedIndex, // Show the page based on the selected index
        children: _pages, // The list of pages
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped, // Handle selection of nav items
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home), 
            label: localizations.home,
          ),
          NavigationDestination(
            icon: Icon(Icons.self_improvement), // Meditation icon
            label: localizations.meditation,
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