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

  // Stores the user's input.
  TextEditingController nameController = TextEditingController(text: name,);
  TextEditingController durationController = TextEditingController(text: duration.toString());
  TextEditingController questionController = TextEditingController(text: question);


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
                      updateQuiz(context, name, duration, question, nameController, durationController, questionController);
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
                    updateQuiz(context, name, duration, question, nameController, durationController, questionController);
                    _write(context, name, duration, question, nameController, durationController, questionController);
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
      )
    );
  }

  void updateQuiz(context, name, duration, question, nameController, durationController, questionController) {
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

    // Updates QuizData values.
    Provider.of<QuizData>(context, listen: false).changeQuizData(name, duration, question);
  }

  _write(context, name, duration, question, nameController, durationController, questionController) async {
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

    final Directory directory = await getApplicationDocumentsDirectory();

    // Windows - C:\Users\<user>\Documents\<quiz name>.txt
    // Mac - unknown
    print('${directory.path}/$name');
    final File file = File('${directory.path}/$name.txt');
    await file.writeAsString('$name, $duration, $question');
  }
}