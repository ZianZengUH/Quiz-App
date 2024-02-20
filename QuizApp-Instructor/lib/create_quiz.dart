import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app_instructor/quiz_data.dart';

class CreateQuizPage extends StatelessWidget {
  const CreateQuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    //var appState = context.watch<MyAppState>();

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
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const BeveledRectangleBorder(),
                        ),
                      onPressed: () {
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

                        Provider.of<QuizData>(context, listen: false).changeQuizData(name, duration, question);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text('Save Quiz'),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      )
    );
  }
}