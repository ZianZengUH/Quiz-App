import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

import 'home_page.dart';
import 'websocket_manager.dart';

//########################## Login Page ##########################

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _classSectionController = TextEditingController();
  final TextEditingController _serverIPController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _classSectionFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    requestLocationPermission(); // Request permission at startup
    _loadUserInfo();
    _nameFocusNode.addListener(() => _scrollToFocusedField(_nameFocusNode));
    _emailFocusNode.addListener(() => _scrollToFocusedField(_emailFocusNode));
    _classSectionFocusNode
        .addListener(() => _scrollToFocusedField(_classSectionFocusNode));
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }

    // After requesting, check again
    if (await Permission.location.isGranted) {
      // Permission is granted; you can fetch network info here or set a flag
    } else {
      // Handle the scenario where permission is denied
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("Permission Denied"),
          content:
              const Text("This app needs location permission to function correctly."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            )
          ],
        ),
      );
    }
  }

  Future<void> _loadUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('userName') ?? '';
    String email = prefs.getString('userEmail') ?? '';
    String classSection = prefs.getString('userClassSection') ?? '';
    _nameController.text = name;
    _emailController.text = email;
    _classSectionController.text = classSection;
  }

  Future<void> _saveUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text);
    await prefs.setString('userEmail', _emailController.text);
    await prefs.setString('userClassSection', _classSectionController.text);
  }

  void _scrollToFocusedField(FocusNode focusNode) {
    if (focusNode.hasFocus) {
      final widgetPosition =
          focusNode.context?.findRenderObject()?.paintBounds.top;
      _scrollController.animateTo(
        widgetPosition ?? 0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  Future<void> _takePictureAndLogin() async {
    final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera, 
        preferredCameraDevice: CameraDevice.front
    );

    if (photo != null &&
        _nameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _classSectionController.text.trim().isNotEmpty) {
      await _saveUserInfo();

      // Retrieve student's current location
      Map<String, double> currentLocation = await getCurrentLocation(context);
      Map<String, double>? classroomLocation = await WebSocketManager().getClassroomLocation();

      if (classroomLocation == null) {
        _showAlertDialog(context, "Classroom location not set.");
        return;
      }

      if (!isWithinRange(currentLocation, classroomLocation, 50)) {
        _showAlertDialog(context, "You are not within the required 50m radius.");
        return;
      }

      if (await _connectWebSocket()) {
        await _sendDataToServer(photo, context);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const MyHomePage(title: 'Quiz App'),
        ));
      } else {
        _showConnectionError();
      }
    } else {
      // Optionally show an error message if needed
      _showError('Please ensure all fields are filled and a photo is taken.');
    }
  }

  Future<bool> _connectWebSocket() async {
    String serverUri = 'ws://${_serverIPController.text}:3000';
    try {
      return await WebSocketManager().connect(serverUri);
    } catch (e) {
      _showError('Invalid IP address. Please enter a valid IP address.');
      return false;
    }
  }

  Future<String?> _getPhoneIPAddress() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            print('Phone IP Address: ${addr.address}');
            return addr.address;
          }
        }
      }
    } catch (e) {
      print('Failed to get IP address: $e');
    }
    return null;
  }

  Future<Map<String, double>> getCurrentLocation(BuildContext context) async {
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

    return {'latitude': position.latitude, 'longitude': position.longitude};
  }

  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  bool isWithinRange(Map<String, double> current, Map<String, double> classroom, double radius) {
    return calculateDistance(current['latitude']!, current['longitude']!, classroom['latitude']!, classroom['longitude']!) <= radius;
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p)/2 +
            cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a)); // Returns distance in meters
  }


  Future<void> _sendDataToServer(XFile? photo, BuildContext context) async {
    if (photo != null && WebSocketManager().isConnected) {
      try {
        Map<String, double> location = await getCurrentLocation(context);
        String? phoneIPAddress = await _getPhoneIPAddress();

        final Map<String, dynamic> userData = {
          'name': _nameController.text,
          'email': _emailController.text,
          'classSection': _classSectionController.text,
          'photo': base64Encode(await photo.readAsBytes()),
          'phoneIPAddress': phoneIPAddress,
          'latitude': location['latitude'],
          'longitude': location['longitude'],
        };

        WebSocketManager().sendMessage(json.encode(userData));
      } catch (e) {
        print("Error sending data: $e");
      }
    } else if (photo == null) {
      _showAlertDialog(context, "No photo was taken.");
    } else {
      _showAlertDialog(context, "Not connected to the server.");
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showConnectionError() {
    _showError(
        'Cannot connect to the server. Please check your Wi-Fi connection and IP address are correct.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login / Attendance',
          style: TextStyle(color: Colors.white),
        ),
              bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Colors.white,
          height: 1.0,
        ),
      ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/UH_Manoa_ICS_logo.png"),
              opacity: 0.060,
              fit: BoxFit.contain),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image.asset('assets/images/quiz_app_logo.png',
                      height: 100, width: 100, fit: BoxFit.cover),
                ),
                const SizedBox(height: 20),
                const Text('Welcome to Quiz App',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
                const SizedBox(height: 20),
                TextField(
                  controller: _serverIPController,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter Server IP',
                    hintText: 'e.g., 192.168.0.100',
                    labelStyle: TextStyle(color: Colors.white),
                    hintStyle: TextStyle(
                        color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.white),
                    ),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 20),
                TextField(
                  focusNode: _nameFocusNode,
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter your name',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(children: <Widget>[
                  Expanded(
                    child: TextField(
                      focusNode: _emailFocusNode,
                      controller: _emailController,
                      style:
                          const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter your email',
                        labelStyle:
                            TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Text(
                    '@hawaii.edu',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ]),
                const SizedBox(height: 20),
                TextField(
                  focusNode: _classSectionFocusNode,
                  controller: _classSectionController,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter your class section',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _takePictureAndLogin,
                  child: const Text('Take Picture & Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _serverIPController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _classSectionController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _classSectionFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
