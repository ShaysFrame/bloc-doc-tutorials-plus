/// bloc/timer_bloc.dart
///
/// the first thing we need to do is define the initial state of our `TimerBloc`. In this case, we want the `TimerBloc` to start off in the `TimerInitial` state with a preset duration of 1 minute (60 seconds).

// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';

// part 'timer_event.dart';
// part 'timer_state.dart';

// class TimerBloc extends Bloc<TimerEvent, TimerState> {
//   static const int _duration = 60;

//   TimerBloc() : super(TimerInitial(_duration)) {
//     on<TimerEvent>((event, emit) {
//       // TODO: implement event handler
//     });
//   }
// }

/// Next, we need to define the dependency on our `Ticker`.
// import 'dart:async';

// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter_timer/ticker.dart';

// part 'timer_event.dart';
// part 'timer_state.dart';

// class TimerBloc extends Bloc<TimerEvent, TimerState> {
//   final Ticker _ticker;
//   static const int _duration = 60;

//   StreamSubscription<int>? _tickerSubscription;

//   TimerBloc({required Ticker ticker})
//       : _ticker = ticker,
//         super(TimerInitial(_duration)) {
//     on<TimerEvent>((event, emit) {
//       // TODO: implement event handler
//     });
//   }
// }

/// We are also defining a `StreamSubscription` for our Ticker which we'll get to in a bit.
///
/// At this point, all that's left to do is implement the event handlers. For improved readability, I like to break out each event handler into its own helper function. we'll start with the `TimerStarted` event.
///
/// and after that If the TimerBloc receives a TimerStarted event, it pushes a TimerRunInProgress state with the start duration. In addition, if there was already an open _tickerSubscription we need to cancel it to deallocate the memory. We also need to override the close method on our TimerBloc so that we can cancel the _tickerSubscription when the TimerBloc is closed. Lastly, we listen to the _ticker.tick stream and on every tick we add a _TimerTicked event with the remaining duration.
///
/// Next, let’s implement the _TimerTicked event handler.
// import 'dart:async';

// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter_timer/ticker.dart';

// part 'timer_event.dart';
// part 'timer_state.dart';

// class TimerBloc extends Bloc<TimerEvent, TimerState> {
//   final Ticker _ticker;
//   static const int _duration = 60;

//   StreamSubscription<int>? _tickerSubscription;

//   TimerBloc({required Ticker ticker})
//       : _ticker = ticker,
//         super(TimerInitial(_duration)) {
//     // Event handlers
//     on<TimerStarted>(_onStarted); // _onStarted `helper` function.
//     // implementing _TimerTicked event handler
//     on<_TimerTicked>(_onTicked);
//   }

//   @override
//   Future<void> close() {
//     _tickerSubscription?.cancel();
//     return super.close(); // WTP  (iv)
//   }

//   void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
//     emit(TimerRunInProgress(event.duration));
//     _tickerSubscription?.cancel();
//     _tickerSubscription = _ticker
//         .tick(ticks: event.duration)
//         .listen((duration) => add(_TimerTicked(duration: duration)));
//   }

//   void _onTicked(_TimerTicked event, Emitter<TimerState> emit) {
//     emit(
//       event.duration > 0
//           ? TimerRunInProgress(event.duration)
//           : TimerRunComplete(),
//     );
//   }
// }

/// Every time a _TimerTicked event is received, if the tick’s duration is greater than 0, we need to push an updated TimerRunInProgress state with the new duration. Otherwise, if the tick’s duration is 0, our timer has ended and we need to push a TimerRunComplete state.
///
/// Now let’s implement the TimerPaused event handler.
// import 'dart:async';

// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter_timer/ticker.dart';

// part 'timer_event.dart';
// part 'timer_state.dart';

// class TimerBloc extends Bloc<TimerEvent, TimerState> {
//   final Ticker _ticker;
//   static const int _duration = 60;

//   StreamSubscription<int>? _tickerSubscription;

//   TimerBloc({required Ticker ticker})
//       : _ticker = ticker,
//         super(TimerInitial(_duration)) {
//     // Event handlers
//     on<TimerStarted>(_onStarted); // _onStarted `helper` function.
//     // implementing _TimerTicked event handler
//     on<_TimerTicked>(_onTicked);
//     // Implementing on paused event handler
//     on<TimerPaused>(_onPaused);
//   }

//   @override
//   Future<void> close() {
//     _tickerSubscription?.cancel();
//     return super.close(); // WTP  (iv)
//   }

//   void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
//     emit(TimerRunInProgress(event.duration));
//     _tickerSubscription?.cancel();
//     _tickerSubscription = _ticker
//         .tick(ticks: event.duration)
//         .listen((duration) => add(_TimerTicked(duration: duration)));
//   }

//   void _onTicked(_TimerTicked event, Emitter<TimerState> emit) {
//     emit(
//       event.duration > 0
//           ? TimerRunInProgress(event.duration)
//           : TimerRunComplete(),
//     );
//   }

//   void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
//     if (state is TimerRunInProgress) {
//       _tickerSubscription.pause();
//       emit(TimerRunPause(state.duration));
//     }
//   }
// }

/// In _onPaused if the state of our TimerBloc is TimerRunInProgress, then we can pause the _tickerSubscription and push a TimerRunPause state with the current timer duration.
///
/// Next, let’s implement the TimerResumed event handler so that we can unpause the timer.
// import 'dart:async';

// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter_timer/ticker.dart';

// part 'timer_event.dart';
// part 'timer_state.dart';

// class TimerBloc extends Bloc<TimerEvent, TimerState> {
//   final Ticker _ticker;
//   static const int _duration = 60;

//   StreamSubscription<int>? _tickerSubscription;

//   TimerBloc({required Ticker ticker})
//       : _ticker = ticker,
//         super(TimerInitial(_duration)) {
//     // Event handlers
//     on<TimerStarted>(_onStarted); // _onStarted `helper` function.
//     // implementing _TimerTicked event handler
//     on<_TimerTicked>(_onTicked);
//     // Implementing on paused event handler
//     on<TimerPaused>(_onPaused);
//     // Implementing timer resumed event handeler
//     on<TimerResumed>(_onResumed);
//   }

//   @override
//   Future<void> close() {
//     _tickerSubscription?.cancel();
//     return super.close(); // WTP  (iv)
//   }

//   void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
//     emit(TimerRunInProgress(event.duration));
//     _tickerSubscription?.cancel();
//     _tickerSubscription = _ticker
//         .tick(ticks: event.duration)
//         .listen((duration) => add(_TimerTicked(duration: duration)));
//   }

//   void _onTicked(_TimerTicked event, Emitter<TimerState> emit) {
//     emit(
//       event.duration > 0
//           ? TimerRunInProgress(event.duration)
//           : TimerRunComplete(),
//     );
//   }

//   void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
//     if (state is TimerRunInProgress) {
//       _tickerSubscription?.pause();
//       emit(TimerRunPause(state.duration));
//     }
//   }

//   void _onResumed(TimerResumed resume, Emitter<TimerState> emit) {
//     if (state is TimerRunPause) {
//       _tickerSubscription?.resume();
//       emit(TimerRunInProgress(state.duration));
//     }
//   }
// }

/// The TimerResumed event handler is very similar to the TimerPaused event handler. If the TimerBloc has a state of TimerRunPause and it receives a TimerResumed event, then it resumes the _tickerSubscription and pushes a TimerRunInProgress state with the current duration.
///
/// Lastly, we need to implement the TimerReset event handler.
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_timer/ticker.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  static const int _duration = 60;

  StreamSubscription<int>? _tickerSubscription;

  TimerBloc({required Ticker ticker})
      : _ticker = ticker,
        super(TimerInitial(_duration)) {
    // Event handlers
    on<TimerStarted>(_onStarted); // _onStarted `helper` function.
    // implementing _TimerTicked event handler
    on<_TimerTicked>(_onTicked);
    // Implementing on paused event handler
    on<TimerPaused>(_onPaused);
    // Implementing timer resumed event handeler
    on<TimerResumed>(_onResumed);
    // Implementing timer reset event handeler
    on<TimerReset>(_onReset);
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close(); // WTP  (iv)
  }

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    emit(TimerRunInProgress(event.duration));
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: event.duration)
        .listen((duration) => add(_TimerTicked(duration: duration)));
  }

  void _onTicked(_TimerTicked event, Emitter<TimerState> emit) {
    emit(
      event.duration > 0
          ? TimerRunInProgress(event.duration)
          : TimerRunComplete(),
    );
  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state is TimerRunInProgress) {
      _tickerSubscription?.pause();
      emit(TimerRunPause(state.duration));
    }
  }

  void _onResumed(TimerResumed resume, Emitter<TimerState> emit) {
    if (state is TimerRunPause) {
      _tickerSubscription?.resume();
      emit(TimerRunInProgress(state.duration));
    }
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    emit(const TimerInitial(_duration));
  }
}
/// If the TimerBloc receives a TimerReset event, it needs to cancel the current _tickerSubscription so that it isn’t notified of any additional ticks and pushes a TimerInitial state with the original duration.
/// 
/// That’s all there is to the TimerBloc. Now all that’s left is implement the UI for our Timer Application.
