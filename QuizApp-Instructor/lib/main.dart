import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

//import 'package:quiz_app_instructor/connected_devices_page.dart';
import 'package:quiz_app_instructor/create_modify_quiz.dart';
import 'package:quiz_app_instructor/display_quiz.dart';
import 'package:quiz_app_instructor/info_page.dart';
import 'package:quiz_app_instructor/load_quiz.dart';
import 'package:quiz_app_instructor/quiz_data.dart';
import 'package:quiz_app_instructor/server.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1550, 835),
    minimumSize: Size(1550, 835),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    windowButtonVisibility: false,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Server()),
        ChangeNotifierProvider(create: (context) => QuizData()),
      ],
      child: MaterialApp(
        title: 'Quiz App - Instructor Version',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: const AppLayout(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// ---------------------AppLayout--------------------
class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int selectedIndex = 0;
  String ipAddress = "WiFi IP address not found"; 
  
  @override 
  void initState() { 
    super.initState(); 
    _getWiFiAddress(); 
  } 

  @override
  Widget build(BuildContext context) {
    _checkQuizDirExists();

    List<Widget> pages = [
      const InfoPage(),
      const CreateQuizPage(),
      const LoadQuizPage(),
      const ShowQuiz(),
      //Placeholder for Export Quiz Answers - you'll need to implement this widget
      const Placeholder(),
      //const ConnectedDevicesPage(),
    ];

    List<NavigationRailDestination> destinations = [
      _buildDestination(0, Icons.question_mark, 'How To Use This Program'),
      _buildDestination(1, Icons.new_label, 'Create/Modify Quiz'),
      _buildDestination(2, Icons.file_open, 'Load Quiz'),
      _buildDestination(3, Icons.screen_share, 'Display Quiz'),
      _buildDestination(4, Icons.save_as, 'Export Quiz Answers'),
      // Add other destinations here
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  //backgroundColor: Colors.green,
                  backgroundColor: const Color.fromARGB(255, 6, 86, 6),
                  unselectedLabelTextStyle: const TextStyle(
                    color: Colors.white70),
                  unselectedIconTheme: const IconThemeData(
                    color: Colors.white70),
                  selectedLabelTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                  selectedIconTheme: const IconThemeData(
                    color: Colors.black),
                  extended: constraints.maxWidth >= 600,

                  leading: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Connect to",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
                      Text(
                        ipAddress,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
                      const Text(""),
                      Image.asset("images/quiz_app_logo.png", height: 150, width: 150),
                      const Text("")
                    ],
                  ),
                  destinations: destinations,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("images/UH_Manoa_ICS_Logo.png"),
                      opacity: 0.060,
                      fit: BoxFit.contain,
                      )
                  ),
                  child: pages[selectedIndex],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  NavigationRailDestination _buildDestination(int index, IconData icon, String label) {
    bool isSelected = selectedIndex == index;

    // A custom widget for the destination to have better control over the layout.
    Widget destinationWidget = Padding(
      padding: EdgeInsets.all(0), // No additional padding around the icon
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.5) : Colors.transparent, // Make it more white
          borderRadius: BorderRadius.circular(8), // Adjust for shape
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0), // Add horizontal padding inside the box
          child: SizedBox(
            height: 40, // Adjust the height to match the icon's selection shape
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return NavigationRailDestination(
      icon: Icon(icon, color: isSelected ? Colors.transparent : Colors.white70), // Hide icon when selected
      selectedIcon: Icon(icon, color: Colors.black), // Show icon when selected
      label: destinationWidget,
    );
  }


  Future<void> _getWiFiAddress() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4 && interface.name == 'Wi-Fi') {
          ipAddress = addr.address.toString();
        } else if (addr.type == InternetAddressType.IPv4 && interface.name == 'en0') {
          ipAddress = addr.address.toString();
        }
      }
    }
  }

  // Checks if the "Saved Quizzes" directory exists. If not, create it.
  void _checkQuizDirExists() async {
    final quizDir = Directory('Saved Quizzes');
    if (!await quizDir.exists()) {
      await quizDir.create();
    }
  }
}
