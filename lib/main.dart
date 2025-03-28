import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';       // Import home.dart
import 'feedback.dart';   // Import feedback.dart

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
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        // uses the content from the translation that it retrieved from the 
        // the generated class
        title: Text(localizations.appTitle),
      ),
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