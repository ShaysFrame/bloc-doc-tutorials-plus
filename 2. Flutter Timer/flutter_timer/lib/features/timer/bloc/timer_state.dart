///   TimerState
///   We’ll start off by defining the `TimerStates` which our `TimerBloc` can be in.

///   Our `TimerBloc` state can be one of the following:

///   `TimerInitial`: ready to start counting down from the specified duration.
///   `TimerRunInProgress`: actively counting down from the specified duration.
///   `TimerRunPause`: paused at some remaining duration.
///   `TimerRunComplete`: completed with a remaining duration of 0.
///   Each of these states will have an implication on the user interface and actions that the user can perform. For ex/ample:

///   if the state is `TimerInitial` the user will be able to start the timer.
///   if the state is `TimerRunInProgress` the user will be able to pause and reset the timer as well as see the re/maining duration.
///   if the state is `TimerRunPause` the user will be able to resume the timer and reset the timer.
///   if the state is `TimerRunComplete` the user will be able to reset the timer.
///   In order to keep all of our bloc files together, let’s create a bloc directory with `bloc/timer_state.dart`.

part of 'timer_bloc.dart';

sealed class TimerState extends Equatable {
  const TimerState(this.duration);

  final int duration;

  /// WTP? . . . (i)
  @override
  List<Object> get props => [duration];
}

final class TimerInitial extends TimerState {
  const TimerInitial(super.duration);

  /// WTP? . . . (ii)
  @override
  String toString() => 'TimerInitial {duration: $duration}';
}

final class TimerRunPause extends TimerState {
  const TimerRunPause(super.duration);

  @override
  String toString() => "TimerRunPause {duration: $duration}";
}

final class TimerRunInProgress extends TimerState {
  const TimerRunInProgress(super.duration);

  @override
  String toString() => 'TimerRunInProgress {duration: $duration}';
}

final class TimerRunComplete extends TimerState {
  const TimerRunComplete() : super(0); // WTP? . . . (iii)
}

/// Note that all of the `TimerStates` extend the abstract base class `TimerState` which has a duration property. This is because no matter what state our `TimerBloc` is in, we want to know how much time is remaining. Additionally, `TimerState` extends `Equatable` to optimize our code by ensuring that our app does not trigger rebuilds if the same state occurs.

/// Next up, let’s define and implement the TimerEvents which our TimerBloc will be processing.
