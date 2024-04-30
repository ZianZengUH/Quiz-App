import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app_instructor/quiz_data.dart';

class CreateQuizPage extends StatelessWidget {
  const CreateQuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    Directory currentDirectory = Directory.current;
    String currentDirectoryString = currentDirectory.path;
    String name = Provider.of<QuizData>(context).name;
    int duration = Provider.of<QuizData>(context).duration;
    String question = Provider.of<QuizData>(context).question;
    int fontSize = Provider.of<QuizData>(context).fontSize.toInt();

    // Stores the user's input.
    TextEditingController nameController = TextEditingController(text: name,);
    TextEditingController durationController = TextEditingController(text: duration.toString());
    TextEditingController questionController = TextEditingController(text: question);
    TextEditingController fontSizeController = TextEditingController(text: fontSize.toString());

    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget> [
          Container(
            padding: const EdgeInsets.all(5.0),
            color: const Color.fromARGB(255, 71, 148, 56),
            //  decoration: const BoxDecoration(
            //         gradient: LinearGradient(
            //           colors: [
            //             // Color.fromARGB(255, 71, 148, 56), // Light green
            //             // Color(0xFF004D40), // Dark green color
            //             Color.fromARGB(255, 71, 148, 56), // Light green
            //              Color.fromARGB(255, 71, 148, 56),
            //           ],
            //           stops: [0.2, 0.9],
            //         ),
            //       ),
            child: Text(
              'Quizzes will be saved in:\n$currentDirectoryString\\Saved Quizzes',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold
              ),  
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Quiz Name',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:5, bottom: 20),
                    child: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const Text(
                    'Duration in Minutes (if left blank, set to 15 min)',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:5, bottom: 20),
                    child: TextFormField(
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: durationController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const Text(
                    'Font Size (if left blank, set to 20)',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:5, bottom: 20),
                    child: TextFormField(
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: fontSizeController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),    
                  const Text('Question',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:5, bottom: 20),
                    child: TextField(
                      maxLines: null,
                      controller: questionController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const BeveledRectangleBorder(),
                        ),
                        onPressed: () {
                          updateQuiz(context, name, duration, question, fontSize, nameController, durationController, questionController, fontSizeController);
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text('Save Quiz to Memory Only'),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const BeveledRectangleBorder(),
                        ),
                        onPressed: () {
                          updateQuiz(context, name, duration, question, fontSize, nameController, durationController, questionController, fontSizeController);
                          _write(context, name, duration, question, fontSize, nameController, durationController, questionController, fontSizeController);
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                        child: Text('Save Quiz to Memory and Disk'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ]
      )
    );
  }

  void updateQuiz(context, name, duration, question, fontSize, nameController, durationController, questionController, fontSizeController) {
    // Check to see if user changed quiz name.
    if (name != nameController.text) {
      name = nameController.text;
    }

    // Check if user submitted empty duration field or changed duration.
    if (durationController.text.isEmpty) {
      duration = 15;
    } else if (duration != int.parse(durationController.text)){
      duration = int.parse(durationController.text);
    }
                        
    // Check to see if user changed quiz question.
    if (question != questionController.text) {
      question = questionController.text;
    }

    // Check if user submitted empty font size field or changed font size.
    if (fontSizeController.text.isEmpty) {
      fontSize = 20;
    } else if (fontSize != int.parse(fontSizeController.text)){
      fontSize = int.parse(fontSizeController.text);
    }

    // Updates QuizData values.
    Provider.of<QuizData>(context, listen: false).changeQuizData(name, duration, fontSize, question);
  }

  _write(context, name, duration, question, fontSize, nameController, durationController, questionController, fontSizeController) async {
    // Check to see if user changed quiz name.
    if (name != nameController.text) {
      name = nameController.text;
    }

    // Check if user submitted empty duration field or changed duration.
    if (durationController.text.isEmpty) {
      duration = 15;
    } else if (duration != int.parse(durationController.text)){
      duration = int.parse(durationController.text);
    }
                        
    // Check to see if user changed quiz question.
    if (question != questionController.text) {
      question = questionController.text;
    }

    // Check if user submitted empty font size field or changed font size.
    if (fontSizeController.text.isEmpty) {
      fontSize = 20;
    } else if (fontSize != int.parse(fontSizeController.text)){
      fontSize = int.parse(fontSizeController.text);
    }

    Directory quizDirectory = Directory('Saved Quizzes');
    
    // Windows - C:\Users\<user>\Documents\<quiz name>.txt
    // Mac - unknown
    // print('${quizDirectory.path}/$name');

    // Write quizzes to .quiz file (can view in any text editor)
    File file = File('${quizDirectory.path}/$name.quiz');
    file.writeAsString('$name,,$duration,,$fontSize,,$question');
  }
}