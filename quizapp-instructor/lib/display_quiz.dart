import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app_instructor/quiz_data.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:slide_countdown/slide_countdown.dart';

class ShowQuiz extends StatelessWidget {
  const ShowQuiz({super.key});

  @override
  Widget build(BuildContext context) {    
    int duration = Provider.of<QuizData>(context).duration;
    String question = Provider.of<QuizData>(context).question;
    StreamDuration astreamDuration = StreamDuration(
      config: StreamDurationConfig(
        autoPlay: false,
        countDownConfig: CountDownConfig(
          // There is a bug with Duration(), where it sets the time to duration minutes - 2 seconds.
          // Ex. If duration is set to 15 minutes, Duration() is set to 14 minutes, 58 seconds.
          duration: Duration(minutes: duration, seconds: 2),
        ),
      ),
    );


    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  SlideCountdown(
                    streamDuration: astreamDuration,
                    
                    style: const TextStyle(
                      fontSize: 100,
                      color: Colors.white
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: ElevatedButton(
                            onPressed: () => astreamDuration.play(),
                            child: const Text('Play'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: ElevatedButton(
                            onPressed: () => astreamDuration.pause(),
                            child: const Text('Pause'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text(question),
          ],
        )
      )
    );
  }

  void handleTimeout() {

  }
}