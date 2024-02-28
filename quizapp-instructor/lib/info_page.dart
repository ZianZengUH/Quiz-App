import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {    
    return const SizedBox(
      child: Column(
        children: <Widget>  [
          Text('HOW TO USE THIS APPLICATION\n'),
          Text('Create/Modify Quiz'),
          Text('Set the quiz name, duration, and question.'),
          Text('You can then save the quiz to either "memory only" or "memory and disk"'),
          Text('If you choose "memory only", quiz data will be lost if you close the app'),
          Text('Saving to disk will save your quiz as <quiz name>.txt in a specific directory.'),
          Text('WARNING - Saving to disk will overwrite whatever file is named <quiz name>.txt!  Please be careful you don\'t overwrite something by accident!'),
          Text('Windows - C:\\Users\\<your username>\\Documents\\<quiz name>.txt'),
          Text('Mac - TODO\n'),
          Text('Load Quiz'),
          Text('Searches in a specific directory for the quiz files.'),
          Text('Windows - C:\\Users\\<your username>\\Documents\\<quiz name>.txt'),
          Text('Mac - TODO'),
          Text('Returns a list of .txt files that you can select from via radial button.'),
          Text('You can then load the quiz and modify it, display it to the class, etc.\n'),
          Text('Display Quiz'),
          Text('This page is intended to be shown to your class via projector.'),
          Text('Has a large timer at the top of the screen and the quiz question below it.'),
          Text('There are two buttons that allow you to start and pause the quiz timer'),
          Text('There are another two buttons that allow you to adjust the font size (increase or decrease)\n'),
          Text('Export Quiz'),
          Text('Exports the student\'s answers and pictures to disk.'),
          Text('By default, creates a folder named after the quiz name in a specific directory.'),
          Text('Windows - C:\\Users\\<your username>\\Documents\\<quiz name>.txt'),
          Text('Mac - TODO'),

        ]
      )
    );
  }
}