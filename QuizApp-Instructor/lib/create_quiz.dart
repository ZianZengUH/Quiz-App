import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app_instructor/quiz_data.dart';

class CreateQuizPage extends StatelessWidget {
  const CreateQuizPage({super.key});

  @override
  Widget build(BuildContext context) {
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
      height: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget> [
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
    Provider.of<QuizData>(context, listen: false).changeQuizData(name, duration, question, fontSize);
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

    Directory quizDirectory = await getApplicationDocumentsDirectory();

    // Windows - C:\Users\<user>\Documents\<quiz name>.txt
    // Mac - unknown
    print('${quizDirectory.path}/$name');
    File file = File('${quizDirectory.path}/$name.txt');
    file.writeAsString('$name, $duration, $question, $fontSize');
  }
}