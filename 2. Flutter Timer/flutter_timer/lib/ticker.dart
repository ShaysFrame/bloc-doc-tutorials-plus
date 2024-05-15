/// The ticker is our data source for the timer application.
/// It will expose a stream of ticks which we can subscribe
/// and react to.
///
/// Starting off by creating `ticker.dart`
class Ticker {
  const Ticker();
  Stream<int> tick({required int ticks}) {
    return Stream.periodic(const Duration(seconds: 1),
        (computationCount) => ticks - computationCount - 1).take(ticks);
  }
}

/**
 * GPT Conversation
 * See README.md
 */

/// All our `Ticker` class does is expose a tick function which takes the number of ticks(seconds) we want and returns a stream which emits the remaining seconds every seconds.

/// Next up we need to create our `TimerBloc` which will consume the `Ticker`
