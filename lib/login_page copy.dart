import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'home_page.dart'; 

//########################## Login Page ##########################

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
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

  final NetworkInfo _networkInfo = NetworkInfo();
  WebSocket? _socket;  
  
  String? _serverIP;
  int serverPort = 3000;  // Default port, configure as needed
  
  @override
  void initState() {
    super.initState();
    requestLocationPermission(); // Request permission at startup
    _loadUserInfo();
    _nameFocusNode.addListener(() => _scrollToFocusedField(_nameFocusNode));
    _emailFocusNode.addListener(() => _scrollToFocusedField(_emailFocusNode));
    _classSectionFocusNode.addListener(() => _scrollToFocusedField(_classSectionFocusNode));
    _fetchNetworkDetails();
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
          title: Text("Permission Denied"),
          content: Text("This app needs location permission to function correctly."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            )
          ],
        ),
      );
    }
  }

  Future<void> _fetchNetworkDetails() async {
    _serverIP = await _networkInfo.getWifiIP();
    setState(() {});
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
      final widgetPosition = focusNode.context?.findRenderObject()?.paintBounds.top;
      _scrollController.animateTo(
        widgetPosition ?? 0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  Future<void> _takePictureAndLogin() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null && _nameController.text.trim().isNotEmpty && _emailController.text.trim().isNotEmpty && _classSectionController.text.trim().isNotEmpty) {
      await _saveUserInfo();
      if (await _checkConnection()) {
        await _sendDataToServer(photo);
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

  Future<bool> _checkConnection() async {
    try {
      final socket = await Socket.connect(_serverIPController.text, serverPort, timeout: Duration(seconds: 5));
      socket.close();
      return true;
    } catch (e) {
      print('Could not connect to the server at IP ${_serverIPController.text}: $e');
      return false;
    }
  }

  Future<void> _sendDataToServer(XFile photo) async {
    try {
      final socket = await Socket.connect(_serverIPController.text, serverPort);
      Map<String, dynamic> userData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'classSection': _classSectionController.text,
        'photo': base64Encode(await photo.readAsBytes())
      };
      socket.add(utf8.encode(json.encode(userData) + '~')); // Append a delimiter
      await socket.close();
    } catch (e) {
      _showError('Failed to send data to the server.');
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
    _showError('Cannot connect to the server. Please check your network settings.');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login / Attendance'),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/quiz_app_logo.png', width: 100, height: 100),
              const SizedBox(height: 20),
              const Text('Welcome to Quiz App', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: _serverIPController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Server IP',
                  hintText: 'e.g., 192.168.0.100',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: false),
              ),
            const SizedBox(height: 20),
              TextField(
                focusNode: _nameFocusNode,
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter your name',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                focusNode: _emailFocusNode,
                controller: _emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter your email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                focusNode: _classSectionFocusNode,
                controller: _classSectionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter your class section',
                ),
              ),
              const SizedBox(height: 20),
              // if (_serverIP != null) Text('Server IP: $_serverIP'),
              ElevatedButton(
                onPressed: _takePictureAndLogin,
                child: const Text('Take Picture & Login'),
              ),
            ],
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