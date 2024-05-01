import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app_instructor/display_quiz.dart';
import 'package:quiz_app_instructor/server.dart';


class ConnectedStudentsPage extends StatefulWidget {
  final String ipAddress;

  const ConnectedStudentsPage({Key? key, required this.ipAddress})
      : super(key: key);

  @override
  _ConnectedStudentsPageState createState() => _ConnectedStudentsPageState();
}

class _ConnectedStudentsPageState extends State<ConnectedStudentsPage> {
 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Connect to",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.ipAddress,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShowQuiz()),
              );
            },
            child: const Text('Display Quiz'),
          ),
          const SizedBox(height: 20),
          const Text(
            "Connected Students",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Consumer<Server>(
            builder: (context, server, child) {
              return Expanded(
                child: ListView.builder(
                  itemCount: server.connectedStudentsData.length,
                  itemBuilder: (context, index) {
                    final studentData = server.connectedStudentsData[index];
                    return ListTile(
                      title: Text(studentData['name']),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
}
