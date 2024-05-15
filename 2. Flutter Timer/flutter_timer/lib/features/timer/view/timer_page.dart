// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_timer/features/timer/bloc/timer_bloc.dart';
// import 'package:flutter_timer/ticker.dart';

// /// Timer
// /// Our Timer widget (lib/timer/view/timer_page.dart) will be responsible for displaying the remaining time along with the proper buttons which will enable users to start, pause, and reset the timer.

// class TimerPage extends StatelessWidget {
//   const TimerPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => TimerBloc(ticker: Ticker()),
//       child: const TimerView(),
//     );
//   }
// }

// class TimerView extends StatelessWidget {
//   const TimerView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Flutter Timer"),
//       ),
//       body: Stack(
//         children: [
//           const Background(),
//           Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Padding(
//                 padding: EdgeInsets.symmetric(vertical: 100.0),
//                 child: Center(
//                   child: TimerText(),
//                 ),
//               )
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }

// class TimerText extends StatelessWidget {
//   const TimerText({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final duration = context.select((TimerBloc bloc) => bloc.state.duration);
//     final minutesStr =
//         ((duration / 60) % 60).floor().toString().padLeft(2, '0');
//     final secondsStr = (duration % 60).floor().toString().padLeft(2, '0');
//     return Text(
//       "$minutesStr:$secondsStr",
//       style: Theme.of(context).textTheme.displayLarge,
//     );
//   }
// }

/// So far, we’re just using BlocProvider to access the instance of our TimerBloc.
///
/// Next, we’re going to implement our Actions widget which will have the proper actions (start, pause, and reset).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_timer/features/timer/bloc/timer_bloc.dart';
import 'package:flutter_timer/ticker.dart';

/// Timer
/// Our Timer widget (lib/timer/view/timer_page.dart) will be responsible for displaying the remaining time along with the proper buttons which will enable users to start, pause, and reset the timer.

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TimerBloc(ticker: Ticker()),
      child: const TimerView(),
    );
  }
}

class TimerView extends StatelessWidget {
  const TimerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Timer"),
      ),
      body: Stack(
        children: [
          const Background(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 100.0),
                child: Center(
                  child: TimerText(),
                ),
              ),
              Actions(),
            ],
          )
        ],
      ),
    );
  }
}

class TimerText extends StatelessWidget {
  const TimerText({super.key});

  @override
  Widget build(BuildContext context) {
    final duration = context.select((TimerBloc bloc) => bloc.state.duration);
    final minutesStr =
        ((duration / 60) % 60).floor().toString().padLeft(2, '0');
    final secondsStr = (duration % 60).floor().toString().padLeft(2, '0');
    return Text(
      "$minutesStr:$secondsStr",
      style: Theme.of(context).textTheme.displayLarge,
    );
  }
}

class Background extends StatelessWidget {
  const Background({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            Colors.blue.shade50,
            Colors.blue.shade500,
          ])),
    );
  }
}

class Actions extends StatelessWidget {
  const Actions({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      buildWhen: (prev, state) => prev.runtimeType != state.runtimeType,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ...switch (state) {
              TimerInitial() => [
                  FloatingActionButton(
                    onPressed: () => context
                        .read<TimerBloc>()
                        .add(TimerStarted(duration: state.duration)),
                    child: const Icon(Icons.play_arrow),
                  )
                ],
              TimerRunInProgress() => [
                  FloatingActionButton(
                    onPressed: () =>
                        context.read<TimerBloc>().add(const TimerPaused()),
                    child: const Icon(Icons.pause),
                  ),
                  FloatingActionButton(
                    onPressed: () =>
                        context.read<TimerBloc>().add(const TimerReset()),
                    child: const Icon(Icons.replay),
                  )
                ],
              TimerRunPause() => [
                  FloatingActionButton(
                    onPressed: () =>
                        context.read<TimerBloc>().add(const TimerResumed()),
                    child: const Icon(Icons.play_arrow),
                  ),
                  FloatingActionButton(
                    onPressed: () =>
                        context.read<TimerBloc>().add(const TimerReset()),
                    child: const Icon(Icons.replay),
                  )
                ],
              TimerRunComplete() => [
                  FloatingActionButton(
                    onPressed: () =>
                        context.read<TimerBloc>().add(const TimerReset()),
                    child: const Icon(Icons.replay),
                  )
                ],
            }
          ],
        );
      },
    );
  }
}

/// The Actions widget is just another StatelessWidget which uses a BlocBuilder to rebuild the UI every time we get a new TimerState. Actions uses context.read<TimerBloc>() to access the TimerBloc instance and returns different FloatingActionButtons based on the current state of the TimerBloc. Each of the FloatingActionButtons adds an event in its onPressed callback to notify the TimerBloc.
/// 
/// If you want fine-grained control over when the builder function is called you can provide an optional buildWhen to BlocBuilder. The buildWhen takes the previous bloc state and current bloc state and returns a boolean. If buildWhen returns true, builder will be called with state and the widget will rebuild. If buildWhen returns false, builder will not be called with state and no rebuild will occur.
/// 
/// In this case, we don’t want the Actions widget to be rebuilt on every tick because that would be inefficient. Instead, we only want Actions to rebuild if the runtimeType of the TimerState changes (TimerInitial => TimerRunInProgress, TimerRunInProgress => TimerRunPause, etc…).
/// 
/// As a result, if we randomly colored the widgets on every rebuild, it would look like:
