import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app_instructor/main.dart';

class CreateQuizPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var timeAllowed = 0;

    return Container(
      height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget> [
              const Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Enter quiz name"
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: "Duration in minutes (Numbers only)"
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: TextField(
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: "Enter quiz question"
                  ),
                ),
              ),
          
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: BeveledRectangleBorder(),
                        ),
                      onPressed: () {
                        print('You have saved the quiz.');
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text('Save Quiz'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}