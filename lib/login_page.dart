import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _classSectionFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _nameFocusNode.addListener(() => _scrollToFocusedField(_nameFocusNode));
    _emailFocusNode.addListener(() => _scrollToFocusedField(_emailFocusNode));
    _classSectionFocusNode.addListener(() => _scrollToFocusedField(_classSectionFocusNode));
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
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  Future<void> _takePictureAndLogin() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null && _nameController.text.trim().isNotEmpty && _emailController.text.trim().isNotEmpty && _classSectionController.text.trim().isNotEmpty) {
      await _saveUserInfo();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => MyHomePage(title: 'Quiz App'),
      ));
    } else {
      // Optionally show an error message if needed
    }
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