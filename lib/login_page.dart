import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    _classSectionFocusNode.addListener(() => _scrollToFocusedField(_classSectionFocusNode));
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
      if (await _connectWebSocket()) {
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

  Future<bool> _connectWebSocket() async {
    String serverUri = 'ws://${_serverIPController.text}:3000';
    return await WebSocketManager().connect(serverUri);
  }

  Future<void> _sendDataToServer(XFile? photo) async {
    if (photo != null && WebSocketManager().isConnected) {
      final Map<String, dynamic> userData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'classSection': _classSectionController.text,
        'photo': base64Encode(await photo.readAsBytes())
      };
      WebSocketManager().sendMessage(json.encode(userData));
      print('Data sent to the server');
    } else if (photo == null) {
      _showError('No photo was taken.');
    } else {
      _showError('Not connected to the server.');
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
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
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