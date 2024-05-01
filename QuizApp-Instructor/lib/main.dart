import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app_instructor/connected_student_page.dart';
import 'package:quiz_app_instructor/create_modify_quiz.dart';
import 'package:quiz_app_instructor/info_page.dart';
import 'package:quiz_app_instructor/load_quiz.dart';
import 'package:quiz_app_instructor/quiz_data.dart';
import 'package:quiz_app_instructor/server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';



class ClassroomLocationManager {

  static Future<void> setClassroomLocation(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('classroomLatitude', latitude);
    await prefs.setDouble('classroomLongitude', longitude);
  }

  static Future<Map<String, double>?> getClassroomLocation() async {
    final prefs = await SharedPreferences.getInstance();
    double? latitude = prefs.getDouble('classroomLatitude');
    double? longitude = prefs.getDouble('classroomLongitude');
    if (latitude != null && longitude != null) {
      return {'latitude': latitude, 'longitude': longitude};
    }
    return null;
  }

  static Future<void> retrieveAndStoreLocation(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showAlertDialog(context, "Location services are disabled.");
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      _showAlertDialog(context, "Location permissions are permanently denied. Enable them from the app's settings.");
      throw Exception("Location permissions are permanently denied.");
    }

    if (permission == LocationPermission.denied) {
      _showAlertDialog(context, "Location permissions are denied.");
      throw Exception("Location permissions are denied.");
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    await setClassroomLocation(position.latitude, position.longitude);
  }

  static void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog( 
          title: Text(
            "Error",
            style: TextStyle(color: Colors.red), // Set the title text color to red),
          ),  
          content: Text(message),
          backgroundColor: Colors.white, // Set the background color to white
          actions: [
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white),
                backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 37, 130, 18)), 
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1550, 835),
    minimumSize: Size(1000, 600),
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
          // colorScheme: ColorScheme.dark().copyWith(
          //   primary: Color(0xFF0A3D62), // Dark green color
          //   secondary: Color(0xFF52c234), // Neon green-yellow color
          // ),
          // colorScheme: ColorScheme.dark()
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ClassroomLocationManager.retrieveAndStoreLocation(context); // Retrieve and store location
      } catch (e) {
        print("Location error: $e");
      }
    });
  
  } 

  @override
  Widget build(BuildContext context) {
    _checkQuizDirExists();

    List<Widget> pages = [
      const InfoPage(),
      const CreateQuizPage(),
      const LoadQuizPage(),
      ConnectedStudentsPage(ipAddress: ipAddress),
    ];

    List<NavigationRailDestination> destinations = [
      _buildDestination(0, Icons.question_mark, 'Introduction'),
      _buildDestination(1, Icons.new_label, 'Create/Modify Quiz'),
      _buildDestination(2, Icons.file_open, 'Load Quiz'),
      _buildDestination(3, Icons.screen_share, 'Display Quiz'),
      // Add other destinations here
    ];
    
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      foregroundColor: const Color.fromARGB(255, 25, 148, 0), // Button text color (green)
      backgroundColor: Colors.white, 
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromARGB(255, 71, 148, 56), // Light green
                        Color(0xFF004D40), // Dark green color
                      ],
                      stops: [0.2, 0.9],
                    ),
                  ),
                  child: NavigationRail(
                    backgroundColor: Colors.transparent,
                    unselectedLabelTextStyle: const TextStyle(
                      color: Colors.white),
                    unselectedIconTheme: const IconThemeData(
                      color: Colors.white),
                    selectedLabelTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                    selectedIconTheme: const IconThemeData(
                      color: Color.fromARGB(255, 255, 255, 255)),
                    extended: constraints.maxWidth >= 600,

                    leading: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // const Text(
                        //   "Connect to",
                        //   style: TextStyle(
                        //     fontSize: 30,
                        //     fontWeight: FontWeight.bold,
                        //     color: Colors.white
                        //   ),
                        // ),
                        // Text(
                        //   ipAddress,
                        //   style: const TextStyle(
                        //     fontSize: 30,
                        //     fontWeight: FontWeight.bold,
                        //     color: Colors.white
                        //   ),
                        // ),

                        const Text(""),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30.0),
                          child: Image.asset(
                            'images/quiz_app_logo.png',
                            height: 150,
                            width: 150
                          ),
                        ),
                        const Text(""),

                        ElevatedButton(
                          style: buttonStyle,
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
                    destinations: destinations,
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (index) {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                  ),
                ),
              ),

              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("images/UH_Manoa_ICS_Logo.png"),
                      opacity: 0.060,
                      fit: BoxFit.contain,
                      ),
                    // gradient: LinearGradient(
                    //   begin: Alignment.topCenter,
                    //   end: Alignment.bottomCenter,
                    //   colors: [
                    //     // Color.fromARGB(240, 217, 43, 8),                    
                    //     // Color.fromARGB(255, 0, 0, 0), 
                    //     Color.fromARGB(255, 71, 148, 56), // Light green
                    //     Color(0xFF004D40), // Dark green color
                    //   ],
                    //   stops: [0.2, 0.9],
                    // ),
                  //   gradient: RadialGradient(
                  //     center: Alignment(0, -0.5), // top center
                  //     radius: 0.5, // radius of the gradient, as a fraction of the shortest side of the widget
                  //     colors: [
                  //       Color.fromARGB(255, 20, 90, 0), // Neon green-yellow color
                  //       Color.fromARGB(255, 0, 0, 0), // Dark green color
                  //     ],
                  //     stops: [0.3, 1.0], // Adjust the stops to fine-tune the gradient effect
                  //   ),
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
      padding: const EdgeInsets.all(0), // No additional padding around the icon
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.9) : Colors.transparent, // Make it more white
          borderRadius: BorderRadius.circular(8), // Adjust for shape
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0), // Add horizontal padding inside the box
          child: SizedBox(
            height: 40, // Adjust the height to match the icon's selection shape
            child: Align(
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color.fromARGB(255, 0, 0, 0) : Colors.white,
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
