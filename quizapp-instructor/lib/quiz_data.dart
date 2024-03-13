import 'package:flutter/material.dart';

class QuizData extends ChangeNotifier {
  String name;
  int duration;
  String question;
  int fontSize;

  QuizData(
    {this.name = '',
    this.duration = 15,
    this.fontSize = 20,
    this.question = ''}
  );

  void changeQuizData(String name, int duration, int fontSize, String question) {
    this.name = name;
    this.duration = duration;
    this.fontSize = fontSize;
    this.question = question;

    notifyListeners();
  }
}