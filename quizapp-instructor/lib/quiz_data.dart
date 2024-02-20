import 'package:flutter/material.dart';

class QuizData extends ChangeNotifier {
  String name;
  int duration;
  String question;

  QuizData(
    {this.name = '',
    this.duration = 15,
    this.question = ''}
  );

  void changeQuizData(String name, int duration, String question) {
    this.name = name;
    this.duration = duration;
    this.question = question;

    notifyListeners();
  }
}