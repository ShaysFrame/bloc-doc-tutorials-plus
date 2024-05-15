import 'package:bloc/bloc.dart';

/// {@template counter_cubit}
/// A [Cubit] which manages on [int] as its state.
/// {@endtemplate}
class CounterCubit extends Cubit<int> {
  /// {@macro counter_cubit}
  CounterCubit() : super(0);

  /// Add 1 to the current state.
  void increment() => emit(state + 1);

  // Subtract 1 from the current state.
  void decrement() => emit(state - 1);
}

/// Next let's take a look at the `CounterView`
/// which will be responsible for consuming the
/// state and interacting with the `CounterCubit`.
