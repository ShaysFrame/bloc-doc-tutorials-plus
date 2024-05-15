import 'package:flutter/material.dart';
import 'package:flutter_timer/features/timer/timer.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Timer",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color.fromRGBO(72, 74, 126, 1),
        ),
      ),
      home: const TimerPage(),
    );
  }
}

// Next, we need to implement our Timer widget.
