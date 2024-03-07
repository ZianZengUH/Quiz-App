import 'package:flutter/material.dart';

class QuizData extends ChangeNotifier {
  String name;
  int duration;
  String question;
  int fontSize;

  QuizData(
    {this.name = '',
    this.duration = 15,
    this.question = '',
    this.fontSize = 20}
  );

  void changeQuizData(String name, int duration, String question, int fontSize) {
    this.name = name;
    this.duration = duration;
    this.question = question;
    this.fontSize = fontSize;

    notifyListeners();
  }
}