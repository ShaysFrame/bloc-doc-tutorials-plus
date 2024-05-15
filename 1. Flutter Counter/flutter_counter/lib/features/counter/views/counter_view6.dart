/// Let’s create lib/counter/view/counter_view.dart:

/// The `CounterView` is responsible for rendering the
/// current count and rendering two FloatingActionButtons
/// to increment/decrement the counter.
///
/// The `BlocBuilder` here will rebuild the widgets based
/// on state of the application.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_counter/features/counter/counter8.dart';
import 'package:flutter_counter/features/counter/cubit/counter_cubit5.dart';

/// {@template counter_view}
/// A [StatelessWidget] which reacts to the provided
/// [CounterCubit] state and notifies it in response to user input.
/// {@endtemplate}
class CounterView extends StatelessWidget {
  /// {@macro counter_view}
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocBuilder<CounterCubit, int>(
          builder: (context, state) {
            return Text('$state', style: TextStyle(fontSize: 16));
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              return context.read<CounterCubit>().increment();
            },
            key: const Key('counterView_increment_floatingActionButton'),
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () {
              return context.read<CounterCubit>().decrement();
            },
            key: const Key('counterView_decrement_floatingActionButton'),
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

/// Now exporting the views in view.dart
