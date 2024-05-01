import 'dart:io';

import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {    
    String currentDirectory = Directory.current.path;
    String savedQuizzesDir = '';
    String studentAnswersDir = '';

    if (Platform.isMacOS | Platform.isLinux) {
      savedQuizzesDir = '$currentDirectory/Saved Quizzes';
      studentAnswersDir = '$currentDirectory/Student Quizzes';
    } else {
      savedQuizzesDir = '$currentDirectory\\Saved Quizzes';
      studentAnswersDir = '$currentDirectory\\Student Quizzes';
    }

    return SizedBox(
      child: SelectionArea(
        child: Column (
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget> [
            Container(
              padding: const EdgeInsets.all(5.0),
              decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        // Color.fromARGB(255, 71, 148, 56), // Light green
                        // Color(0xFF004D40), // Dark green color
                        Color.fromARGB(255, 71, 148, 56), // Light green
                         Color.fromARGB(255, 71, 148, 56),
                      ],
                      stops: [0.2, 0.9],
                    ),
                  ),
              child: const Text(
                'How To Use This Application',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),  
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 20, bottom: 20, left: 100, right: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            '***** IMPORTANT *****',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold
                            ),  
                          ),
                          const Text(
                            'We recommend making shortcuts to the following locations for ease of access.',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const Text(''),
                          const Text(
                            'Saved Quizzes Location:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),  
                          ),
                          Text(
                            savedQuizzesDir,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const Text(''),
                          const Text(
                            'Student Answer Location:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),  
                          ),
                          Text(
                            studentAnswersDir,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(''),
                    Padding(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 5),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                    Text(
                      'Wi-fi Connectivity',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),  
                    ),
                    Text('\u2022 This app uses instructor Wi-fi IP address to prevent students from taking quiz at home.'),
                    Text('\u2022 Student app will not work if they cannot reach your device.'),
                    Text('    \u2022 They must be on the same Wi-fi network --OR--'),
                    Text('    \u2022 Your device is reachable from the internet.'),
                    Text('\u2022 Click the "Start Server" button on left of the app.'),
                    Text('    \u2022 Students can now connect to your device to submit answers.'),
                    Text('\u2022 Click the "Stop Server" button on left of the app.'),
                    Text('    \u2022 This stops the server and disconnects all connected students.'),
                    Text('    \u2022 IF YOU STOP THE SERVER, IT CANNOT BE RESTARTED',
                      style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    Text('        \u2022 APP MUST BE RESTARTED TO START SERVER AGAIN.',
                      style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    Text(''),
                    Text(
                      'Reviewing Student Answers Tips and Tricks',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),  
                    ),
                    Text('\u2022 Starting the server creates a folder named after today\'s date (if it doesn\'t exist).'),
                    Text('\u2022 In this folder, there are folders named after the section numbers your students submit.'),
                    Text('\u2022 In the section number folders are folders named after each student.'),
                    Text('\u2022 In the student\'s folder are the student\'s answers, picture they took, and info.'),
                    Text('    \u2022 Files are named "answer_HH_mm_ss", "photo_HH_mm_ss", and "student_info_HH_mm_ss".'),
                    Text('        \u2022 "HH_mm_ss" is the timestamp each file was submitted.'),
                    Text('        \u2022 "This lets you see if a student connected or answered multiple times.'),
                    Text('    \u2022 "answer_HH_mm_ss" may contain "!!!!! APP MINIMIZED !!!!!"'),
                    Text('        \u2022 This means the student minimized their app and might be cheating.'),
                    Text('        \u2022 "This lets you see if a student connected or answered multiple times.'),
                    Text('    \u2022 "student_info_HH_mm_ss" contains the IP address of the student\'s device.'),
                    Text('        \u2022 Anti-cheating measure if you are administering your quiz over public internet.'),
                    Text('        \u2022 This lets you check if the student is answering from the same Wi-fi network or not.'),
                    Text(''),
                    Text(
                      'Create/Modify Quiz',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),  
                    ),
                    Text('\u2022 Change the quiz name, duration, font size, and question.'),
                    Text('\u2022 You can then save the quiz to either "Memory Only" or "Memory and Disk"'),
                    Text('    \u2022 "Memory Only" - Saves any changes to your quiz non-persistently.'),
                    Text('        \u2022 Quiz data will be lost when app is closed!'),
                    Text('    \u2022 "Memory and Disk" - Saves to Saved Quizzes folder as .quiz files.'),
                    Text('        \u2022 Will overwrite without prompting!'),
                    Text('        \u2022 Please be careful you don\'t overwrite something by accident!'),
                    Text(''),
                    Text(
                      'Load Quiz',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),  
                    ),
                    Text('\u2022 Searches Saved Quizzes folder for your saved quiz files.'),
                    Text('\u2022 Returns a list of .quiz files that you can select from via radial button.'),
                    Text('\u2022 You can then load the quiz and modify it, display it to the class, etc.'),
                    Text(''),
                    Text(
                      'Display Quiz',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),  
                    ),
                    Text('\u2022 This page is intended to be shown to your class via projector.'),
                    Text('\u2022 Has a large timer at the top of the screen and the quiz question below it.'),
                    Text('\u2022 There are two buttons that allow you to start and pause the quiz timer.'),
                    Text(''),
                 ],
                      ),
                    ),
                  ]
                )
              )
            )
          ]
        )
      )
    );
  }
}