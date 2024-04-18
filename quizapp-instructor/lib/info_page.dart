import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {    
    return SizedBox(
      child: Column (
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget> [
          Container(
            padding: const EdgeInsets.all(5.0),
            color: const Color.fromARGB(50, 6, 86, 6),
            child: const Text(
              'HOW TO USE THIS APPLICATION',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold
              ),  
            ),
          ),
          const Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  Text('        \u2022 ***WARNING*** Quiz data will be lost when app is closed!'),
                  Text('    \u2022 "Memory and Disk" - Saves to "<\$Installation Dir>/Saves Quizzes/<Quiz Name>.quiz".'),
                  Text('        \u2022 ***WARNING*** - Will overwrite without prompting!'),
                  Text('        \u2022 Please be careful you don\'t overwrite something by accident!'),
                  Text(''),
                  Text(
                    'Load Quiz',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),  
                  ),
                  Text('\u2022 Searches in "<\$Installation Dir>/Saved Quizzes" folder for your saved quiz files.'),
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
                  Text('\u2022 There are two buttons that allow you to start and pause the quiz timer'),
                  Text(''),
                  Text(
                    'Bluetooth Connectivity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),  
                  ),
                  Text('\u2022 This app supports hop connect functionality using Bluetooth.'),
                  Text('\u2022 To connect to devices:'),
                  Text('    1. Navigate to the Bluetooth page.'),
                  Text('    2. Scan for available devices.'),
                  Text('    3. Select the devices you want to connect to.'),
                  Text('    4. Once connected, you can send quiz data to the connected devices.'),
                  Text('    5. To disconnect from a device, tap the "Disconnect" button next to the device.'),
                  Text(''),
                  Text(
                    'Sending Quiz Data',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),  
                  ),
                  Text('\u2022 When you have devices connected via Bluetooth:'),
                  Text('    1. Load or create a quiz.'),
                  Text('    2. Navigate to the "Display Quiz" page.'),
                  Text('    3. Tap the "Send Quiz" button to send the quiz data to all connected devices.'),
                  Text('    4. The quiz data will be sent to the devices, and they can start answering the quiz.'),
                  Text(''),
                  Text(
                    'Export Quiz',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),  
                  ),
                  Text('\u2022 Exports the student\'s answers and pictures to disk.'),
                  Text('\u2022 Saves to "<\$Installation Dir>/Quiz Responses".'),
                  Text('\u2022 There will be several subfolders beneath this directory.'),
                  Text('    \u2022 Each folder is named after each section you have.'),
                  Text('    \u2022 For example, if you have 3 sections, there will be folders named "1", "2", and "3".'),
                  Text('\u2022 There will also be one large file that contains the all students answers.'),
                  Text('    \u2022 This is in case the data is not parsed correctly to each section folder.'),
                ]
              )
            )
          )
        ]
      )
    );
  }
}