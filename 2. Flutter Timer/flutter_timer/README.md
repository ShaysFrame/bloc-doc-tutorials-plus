# flutter_timer

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Ticker FAQ

>  WTP = What is The Purpose?

Explaination of ticker.dart

```dart
class Ticker {
```
This line defines the `Ticker` class.

```dart
  const Ticker();
```
This is the constructor of the `Ticker` class. It's declared as `const`, meaning instances of `Ticker` can be created at compile-time, which can be beneficial for performance.

```dart
  Stream<int> tick({required int ticks}) {
```
This line defines a method named `tick` which returns a `Stream` of integers. The `tick` method takes an integer parameter named `ticks`, which specifies the number of ticks (seconds) we want.

```dart
    return Stream.periodic(const Duration(seconds: 1), (x) => ticks - x - 1)
        .take(ticks);
```
This is the implementation of the `tick` method. It returns a `Stream` that emits values periodically. The `Stream.periodic` constructor creates a stream that emits events at a regular interval specified by the `Duration`. In this case, it emits a value every second (`Duration(seconds: 1)`). The value emitted is calculated based on the formula `(ticks - x - 1)`, where `x` is the index of the tick emitted by the stream. This effectively counts down from `ticks` to `0`. Finally, the `.take(ticks)` method ensures that the stream only emits `ticks` number of values before completing.

Overall, the `Ticker` class provides a convenient way to create a stream of ticks (time intervals) that can be used in a timer application.

Let's break down the `(x) => ticks - x - 1` statement and the `.take()` method:

1. `(x) => ticks - x - 1`:
   - `(x)` is a parameter of an anonymous function.
   - `x` represents the index of each tick emitted by the stream.
   - `ticks - x - 1` is the expression that calculates the value of each tick emitted by the stream. Here's how it works:
     - `ticks` is the total number of ticks (seconds) specified when calling the `tick` method.
     - `x` represents the index of each tick emitted by the stream. For example, `x = 0` for the first tick, `x = 1` for the second tick, and so on.
     - So, `ticks - x - 1` calculates the remaining seconds until the timer completes. For example, if `ticks = 10` and `x = 0`, then `ticks - x - 1 = 10 - 0 - 1 = 9`, indicating there are 9 seconds remaining. As `x` increments, the remaining seconds decrease until it reaches `0`.

2. `.take(ticks)`:
   - `.take()` is a method provided by the `Stream` class in Dart.
   - It creates a new stream that emits the first `n` elements of the original stream, where `n` is the argument passed to `.take()`.
   - In this case, `.take(ticks)` ensures that the stream only emits `ticks` number of values before completing. This is useful because once the timer reaches `ticks` (i.e., `0` seconds remaining), we want the stream to complete and stop emitting values.

So, the `(x) => ticks - x - 1` function calculates the value of each tick emitted by the stream, and `.take(ticks)` ensures that the stream emits only `ticks` number of values before completing. This combination effectively creates a countdown timer that emits the remaining seconds every second until the timer completes.

## EQUITABLE 

### [WTP? . . . (i && ii)]

Let's break down these two syntaxes:

1. `@override List<Object> get props => [duration];`:
   - `@override`: This annotation indicates that the method below it is overriding a method from a superclass or interface.
   - `List<Object> get props`: This is a getter method named `props` that returns a list of `Object`s.
   - `=> [duration];`: This arrow function syntax is shorthand for a single-expression function. It returns a list containing the `duration` property. The `props` getter is commonly used in classes that extend `Equatable`, a package commonly used in Dart/Flutter for value equality comparisons. By overriding `props`, "you're specifying which properties of the object should be considered when comparing two instances for equality. In this case, `props` returns a list containing only the `duration` property, indicating that two `TimerState` instances should be considered equal if their `duration` properties are equal."

2. `@override String toString() => 'TimerInitial {duration: $duration}';`:
   - `@override`: Similar to the previous usage, this indicates that the method is overriding the `toString()` method of the superclass or interface.
   - `String toString()`: This is the `toString()` method, which returns a string representation of the object.
   - `=> 'TimerInitial {duration: $duration}';`: This arrow function syntax returns a string that represents the `TimerInitial` object. It includes the class name (`TimerInitial`) and the value of its `duration` property. The `$duration` is a string interpolation syntax, which inserts the value of the `duration` property into the resulting string.

In summary, `@override` is used to indicate that these methods are overriding methods from a superclass or interface. The `props` getter is used for value equality comparisons in classes that extend `Equatable`, and the `toString()` method is used to provide a string representation of the object, often for debugging purposes.

The purpose `toString()` method override, is to provide a human-readable string representation of the `TimerInitial` object. This is particularly useful for debugging and logging purposes.

By overriding the `toString()` method, you can control what information is included in the string representation of an object when it's converted to a string using methods like `print()` or when it's logged to a console.

In this specific case:
- The `toString()` method returns a string that includes the class name (`TimerInitial`) and the value of its `duration` property.
- For example, if you have an instance of `TimerInitial` with a `duration` of `10`, calling `toString()` on that instance will return `'TimerInitial {duration: 10}'`.

Having a meaningful `toString()` implementation makes it easier to understand the state of objects when debugging or logging, as it provides relevant information about the object's properties.

### WTP (iii)

In the `TimerRunComplete` class, `: super(0)` is used to call the constructor of the superclass `TimerState` with an argument. This syntax is specifically used when you want to call a superclass constructor with arguments.

In contrast, in the previous example (`TimerInitial` class), the superclass constructor `TimerState` is called without arguments because the superclass constructor (`TimerState`) doesn't take any parameters beyond the `duration` parameter already defined in the superclass.

Here's what `: super(0)` means:

- `super(0)`: This syntax calls the constructor of the superclass (`TimerState`) with the value `0` as an argument. This means that when you create an instance of `TimerRunComplete`, it will call the constructor of `TimerState` with `0` as the value of `duration`.

In summary, `: super(0)` is used to call the superclass constructor with arguments when necessary, whereas `super()` without arguments is used when no additional arguments are needed beyond what the superclass constructor already requires.

Additionally

The keyword `super` in Dart is used in two different contexts:

1. Calling Constructors: `super(arguments)`
   - When you want to call a constructor of the superclass, you use `super` followed by the constructor's name and any required arguments in parentheses. This is typically done in the constructor of a subclass to initialize properties or perform additional setup in the superclass.

2. Accessing Superclass Members: `super.member`
   - When you want to access a member (property or method) of the superclass from within a subclass, you use `super` followed by the member's name. This is typically done to access or override superclass properties or methods.

In the code snippet:

```dart
final class TimerInitial extends TimerState {
  const TimerInitial(super.duration);

  @override
  String toString() => 'TimerInitial {duration: $duration}';
}
```

Here, `super.duration` is accessing the `duration` property of the superclass `TimerState`. It's used to reference the `duration` property defined in the superclass from within the `TimerInitial` subclass.

In contrast, in the `TimerRunComplete` class, `super(0)` is calling the constructor of the superclass `TimerState` with `0` as an argument. This is used to initialize the `duration` property of the superclass when creating an instance of `TimerRunComplete`.