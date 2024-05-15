/// The `CounterPage` widget is responsible for creating a
/// `CounterCubit` and providing it to the `CounterView`.
/// in another word page(provides bloc) makes it available
/// under its widget tree.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_counter/features/counter/counter8.dart';

/// {@template counter_page}
/// A [StatelessWidget] which is responsible for providing a
/// [CounterCubit] instance to the [CounterView].
/// {@endtemplate}

class CounterPage extends StatelessWidget {
  /// {@macro counter_page}
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterCubit(), // here _ is type of BuildContext.
      child: const CounterView(),
    );
  }
}

/// Note:
/// It's important to separate or decouple the creation of
/// a `Cubit` from the consumption of a `Cubit` in order to
/// have code that is much more testable and reusable.
///
/// Next
/// we go to counter_cubit.dart to create the CounterCubit().
/// so that the BlocProvider can provide it for the CounterView().
