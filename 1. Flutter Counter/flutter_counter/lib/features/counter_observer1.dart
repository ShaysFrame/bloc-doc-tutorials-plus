import 'package:bloc/bloc.dart';

/// {@template counter_observeer}
/// [BlocObserver] for the counter application which
/// observes all state change
/// {@endtemplate}
class CounterObserver extends BlocObserver {
  /// {@macro counter_observer}
  const CounterObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    //ignore: avoid_print
    print('${bloc.runtimeType} $change');
  }
}
