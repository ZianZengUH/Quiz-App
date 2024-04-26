import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
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
    size: Size(900, 600),
    minimumSize: Size(900, 600),
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
  String ipAddress = "N/A"; 
  bool isServerRunning = false;
  
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
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.asset(
                          'images/quiz_app_logo.png',
                          height: 150,
                          width: 150
                        ),
                      ),
                      const Text(""),

                      ElevatedButton(
                        onPressed: () {
                          if (!isServerRunning) {
                            // Start server.
                            Provider.of<Server>(context, listen: false); 
                            setState(() {
                              isServerRunning = true;
                            });
                          } else {
                            // Stop server
                            Provider.of<Server>(context, listen: false).stopServer();
                            setState(() {
                              isServerRunning = false;
                            });
                          }
                        },
                        child: 
                        Text(isServerRunning? 'Stop Server':'Start Server'),
                      ),
                    ],
                  ),

                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.question_mark),
                      label: Text('How To Use This Program'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.new_label),
                      label: Text('Create/Modify Quiz'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.file_open),
                      label: Text('Load Quiz'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.screen_share),
                      label: Text('Display Quiz'),
                    ),
                  ],
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
