/// TimerEvent
/// Our `TimerBloc` will need to know how to process the following events:

/// `TimerStarted`: informs the TimerBloc that the timer should be started.
/// `TimerPaused`: informs the TimerBloc that the timer should be paused.
/// `TimerResumed`: informs the TimerBloc that the timer should be resumed.
/// `TimerReset`: informs the TimerBloc that the timer should be reset to the original state.
/// `_TimerTicked`: informs the TimerBloc that a tick has occurred and that it needs to update its state accordingly.

part of 'timer_bloc.dart';

sealed class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object> get props => [];
}

final class TimerStarted extends TimerEvent {
  const TimerStarted({required this.duration});
  final int duration;
}

final class TimerPaused extends TimerEvent {
  const TimerPaused();
}

final class TimerResumed extends TimerEvent {
  const TimerResumed();
}

final class TimerReset extends TimerEvent {
  const TimerReset();
}

class _TimerTicked extends TimerEvent {
  const _TimerTicked({required this.duration});
  final int duration;
}

/// Next up, let’s implement the TimerBloc!
