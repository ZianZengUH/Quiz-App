import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app_instructor/server.dart';

class ConnectedStudentsPage extends StatefulWidget {
  final String ipAddress;
  final VoidCallback onNextPage;

  const ConnectedStudentsPage(
      {super.key, required this.ipAddress, required this.onNextPage});

  @override
  _ConnectedStudentsPageState createState() => _ConnectedStudentsPageState();
}

class _ConnectedStudentsPageState extends State<ConnectedStudentsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 71, 148, 56),
              Color(0xFF004D40),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Connect to",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                widget.ipAddress,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(
                      255, 25, 148, 0), // Button text color (green)
                  backgroundColor: Colors.white,
                ),
                onPressed: () {
                  widget.onNextPage();
                },
                child: const Text('Display Quizzes'),
              ),
              const SizedBox(height: 20),
              const Divider(
                color: Colors.white,
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
              const SizedBox(height: 20),
              const Text(
                "Connected Students",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Consumer<Server>(
              builder: (context, server, child) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: server.connectedStudentsData.map((studentData) {
                        return Chip(
                          label: Text(
                            studentData['name'],
                            style: const TextStyle(color: Color.fromARGB(
                      255, 25, 148, 0)),
                          ),
                          backgroundColor: Colors.white70,
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
}
