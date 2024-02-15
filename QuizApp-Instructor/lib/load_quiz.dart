import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app_instructor/main.dart';

class LoadQuizPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Container(
      height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget> [
              // Logic for loading quiz here.
          
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
                        print('You have loaded the quiz.');
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text('Load Quiz'),
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