# Flutter Infinite List
**level** `intermediate`

In this tutorial, we’re going to be implementing an app which fetches data over the network and loads it as a user scrolls using Flutter and the bloc library.

demo
![Demo](https://bloclibrary.dev/_astro/flutter-infinite-list.CE1vzh4s_ZR5PIR.webp)

# Key Topics

* Observe state changes with [BlocObserver](https://bloclibrary.dev/bloc-concepts#blocobserver).
* [BlocProvider](https://bloclibrary.dev/flutter-bloc-concepts#blocprovider), Flutter widget which provides a bloc to its children.
* [BlocBuilder](https://bloclibrary.dev/flutter-bloc-concepts#blocbuilder), Flutter widget that handles building the widget in response to new states.
* Adding events with [context.read](https://bloclibrary.dev/flutter-bloc-concepts#contextread).
* Prevent unnecessary rebuilds with [Equatable](https://bloclibrary.dev/faqs#when-to-use-equatable).
* Use the `transformEvents` method with Rx.

<br>

# Setup
We’ll start off by creating a brand new Flutter project

```yaml
flutter create flutter_infinite_list

We can then go ahead and replace the contents of pubspec.yaml with

pubspec.yaml
name: flutter_infinite_list
description: A new Flutter project.
version: 1.0.0+1
publish_to: none

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  bloc: ^8.1.0
  bloc_concurrency: ^0.2.0
  equatable: ^2.0.3
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.1
  http: ^0.13.0
  stream_transform: ^2.0.0

dev_dependencies:
  bloc_test: ^9.0.0
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0

flutter:
  uses-material-design: true
```

and then install all of our dependencies

```bash
flutter pub get

```

# Project Structure

```
├── lib
|   ├── posts
│   │   ├── bloc
│   │   │   └── post_bloc.dart
|   |   |   └── post_event.dart
|   |   |   └── post_state.dart
|   |   └── models
|   |   |   └── models.dart*
|   |   |   └── post.dart
│   │   └── view
│   │   |   ├── posts_page.dart
│   │   |   └── posts_list.dart
|   |   |   └── view.dart*
|   |   └── widgets
|   |   |   └── bottom_loader.dart
|   |   |   └── post_list_item.dart
|   |   |   └── widgets.dart*
│   │   ├── posts.dart*
│   ├── app.dart
│   ├── simple_bloc_observer.dart
│   └── main.dart
├── pubspec.lock
├── pubspec.yaml
```
The application uses a feature-driven directory structure. This project structure enables us to scale the project by having self-contained features. In this example we will only have a single feature (the post feature) and it’s split up into respective folders with barrel files, indicated by the asterisk (*).

# REST API

For this demo application, we’ll be using jsonplaceholder as our data source.

    NOTE

    jsonplaceholder is an online REST API which serves fake data; it’s very useful for building prototypes.

Open a new tab in your browser and visit https://jsonplaceholder.typicode.com/posts?_start=0&_limit=2 to see what the API returns.

```json
[
  {
    "userId": 1,
    "id": 1,
    "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
    "body": "quia et suscipit
suscipit recusandae consequuntur expedita et cum
reprehenderit molestiae ut ut quas totam
nostrum rerum est autem sunt rem eveniet architecto"
  },
  {
    "userId": 1,
    "id": 2,
    "title": "qui est esse",
    "body": "est rerum tempore vitae
sequi sint nihil reprehenderit dolor beatae ea dolores neque
fugiat blanditiis voluptate porro vel nihil molestiae ut reiciendis
qui aperiam non debitis possimus qui neque nisi nulla"
  }
]
```

    Note

    In our url we specified the start and limit as query parameters to the GET request.

Great, now that we know what our data is going to look like, let’s create the model.

# Data Model
Create `post.dart` and let’s get to work creating the model of our Post object.

path: `lib/posts/models/post.dart`

```dart 
import 'package:equatable/equatable.dart';

final class Post extends Equatable {
  const Post({required this.id, required this.title, required this.body});

  final int id;
  final String title;
  final String body;

  @override
  List<Object> get props => [id, title, body];
}
```
`Post` is just a class with an `id`, `title`, and `body`.

    Note

    We extend Equatable so that we can compare Posts. Without this, we would need to manually change our class to override equality and hashCode so that we could tell the difference between two Posts objects. See the package for more details.

Now that we have our `Post` object model, let’s start working on the Business Logic Component (bloc).

# Post Events
Before we dive into the implementation, we need to define what our `PostBloc` is going to be doing.

At a high level, it will be responding to user input (scrolling) and fetching more posts in order for the presentation layer to display them. Let’s start by creating our `Event`.

Our `PostBloc` will only be responding to a single event; `PostFetched` which will be added by the presentation layer whenever it needs more Posts to present. Since our `PostFetched` event is a type of `PostEvent` we can create `bloc/post_event.dart` and implement the event like so.

dir: `lib/posts/bloc/post_event.dart`
```dart
part of 'post_bloc.dart';

sealed class PostEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class PostFetched extends PostEvent {}
```
To recap, our `PostBloc` will be receiving `PostEvents` and converting them to `PostStates`. We have defined all of our `PostEvents` (PostFetched) so next let’s define our `PostState`.

# Post States

Our presentation layer will need to have several pieces of information in order to properly lay itself out:

* `PostInitial`- will tell the presentation layer it needs to render a loading indicator while the initial batch of posts are loaded
* `PostSuccess`- will tell the presentation layer it has content to render
  * `posts`- will be the List<Post> which will be displayed
  * `hasReachedMax`- will tell the presentation layer whether or not it has reached the maximum number of posts
* `PostFailure`- will tell the presentation layer that an error has occurred while fetching posts
  
We can now create `bloc/post_state.dart` and implement it like so.

path: `lib/posts/bloc/post_state.dart`
```dart
part of 'post_bloc.dart';

enum PostStatus { initial, success, failure }

final class PostState extends Equatable {
  const PostState({
    this.status = PostStatus.initial,
    this.posts = const <Post>[],
    this.hasReachedMax = false,
  });

  final PostStatus status;
  final List<Post> posts;
  final bool hasReachedMax;

  PostState copyWith({
    PostStatus? status,
    List<Post>? posts,
    bool? hasReachedMax,
  }) {
    return PostState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() {
    return '''PostState { status: $status, hasReachedMax: $hasReachedMax, posts: ${posts.length} }''';
  }

  @override
  List<Object> get props => [status, posts, hasReachedMax];
}
```
    NOTE

    We implemented `copyWith` so that we can copy an instance of `PostSuccess` and update zero or more properties conveniently (this will come in handy later).

Now that we have our `Events` and `States` implemented, we can create our `PostBloc`.

# Post Bloc

For simplicity, our `PostBloc` will have a direct dependency on an `http client`; however, in a production application we suggest instead you inject an api client and use the repository pattern [docs](https://bloclibrary.dev/architecture).

Let’s create `post_bloc.dart` and create our empty `PostBloc`.

`lib/posts/bloc/post_bloc.dart`
```dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_infinite_list/bloc/bloc.dart';
import 'package:flutter_infinite_list/post.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({required this.httpClient}) : super(const PostState()) {
   /// TODO: register on<PostFetched> event
  }

  final http.Client httpClient;
}
```
    Note

    Just from the class declaration we can tell that our PostBloc will be taking PostEvents as input and outputting PostStates.

Next, we need to register an event handler to handle incoming `PostFetched` events. In response to a `PostFetched` event, we will call `_fetchPosts` to fetch posts from the API.

`lib/posts/bloc/post_bloc.dart`
```dart
PostBloc({required this.httpClient}) : super(const PostState()) {
  on<PostFetched>(_onPostFetched);
}

Future<void> _onPostFetched(PostFetched event, Emitter<PostState> emit) async {
  if (state.hasReachedMax) return;
  try {
    if (state.status == PostStatus.initial) {
      final posts = await _fetchPosts();
      return emit(state.copyWith(
        status: PostStatus.success,
        posts: posts,
        hasReachedMax: false,
      ));
    }
    final posts = await _fetchPosts(state.posts.length);
    emit(posts.isEmpty
        ? state.copyWith(hasReachedMax: true)
        : state.copyWith(
            status: PostStatus.success,
            posts: List.of(state.posts)..addAll(posts),
            hasReachedMax: false,
          ));
  } catch (_) {
    emit(state.copyWith(status: PostStatus.failure));
  }
}
```
Our `PostBloc` will `emit` new states via the `Emitter<PostState>` provided in the event handler. Check out [core concepts](https://bloclibrary.dev/bloc-concepts#streams) for more information.

Now every time a `PostEvent` is added, if it is a `PostFetched` event and there are more posts to fetch, our `PostBloc` will fetch the next 20 posts.

The API will return an empty array if we try to fetch beyond the maximum number of posts (100), so if we get back an empty array, our bloc will `emit` the currentState except we will set `hasReachedMax` to true.

If we cannot retrieve the posts, we throw an exception and `emit` `PostFailure()`.

If we can retrieve the posts, we return `PostSuccess()` which takes the entire list of posts.

One optimization we can make is to `debounce` the `Events` in order to prevent spamming our API unnecessarily. We can do this by overriding the transform method in our `PostBloc`.

    Note

    Passing a transformer to on<PostFetched> allows us to customize how events are processed.

    Note

    Make sure to import package:stream_transform to use the throttle api.

`lib/posts/bloc/post_bloc.dart`
```dart
import 'package:stream_transform/stream_transform.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({required this.httpClient}) : super(const PostState()) {
    on<PostFetched>(
      _onPostFetched,
      transformer: throttleDroppable(throttleDuration),
    );
  }
}
```
Our finished PostBloc should now look like this:
```dart
lib/posts/bloc/post_bloc.dart
import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_infinite_list/posts/posts.dart';
import 'package:http/http.dart' as http;
import 'package:stream_transform/stream_transform.dart';

part 'post_event.dart';
part 'post_state.dart';

const _postLimit = 20;
const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({required this.httpClient}) : super(const PostState()) {
    on<PostFetched>(
      _onPostFetched,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  final http.Client httpClient;

  Future<void> _onPostFetched(
    PostFetched event,
    Emitter<PostState> emit,
  ) async {
    if (state.hasReachedMax) return;
    try {
      if (state.status == PostStatus.initial) {
        final posts = await _fetchPosts();
        return emit(
          state.copyWith(
            status: PostStatus.success,
            posts: posts,
            hasReachedMax: false,
          ),
        );
      }
      final posts = await _fetchPosts(state.posts.length);
      posts.isEmpty
          ? emit(state.copyWith(hasReachedMax: true))
          : emit(
              state.copyWith(
                status: PostStatus.success,
                posts: List.of(state.posts)..addAll(posts),
                hasReachedMax: false,
              ),
            );
    } catch (_) {
      emit(state.copyWith(status: PostStatus.failure));
    }
  }

  Future<List<Post>> _fetchPosts([int startIndex = 0]) async {
    final response = await httpClient.get(
      Uri.https(
        'jsonplaceholder.typicode.com',
        '/posts',
        <String, String>{'_start': '$startIndex', '_limit': '$_postLimit'},
      ),
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as List;
      return body.map((dynamic json) {
        final map = json as Map<String, dynamic>;
        return Post(
          id: map['id'] as int,
          title: map['title'] as String,
          body: map['body'] as String,
        );
      }).toList();
    }
    throw Exception('error fetching posts');
  }
}
```
Great! Now that we’ve finished implementing the business logic all that’s left to do is implement the presentation layer.

# Presentation Layer

In our `main.dart` we can start by implementing our main function and calling `runApp` to render our root widget. Here, we can also include our bloc observer to log transitions and any errors.

`lib/main.dart`
```dart
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_infinite_list/app.dart';
import 'package:flutter_infinite_list/simple_bloc_observer.dart';

void main() {
  Bloc.observer = const SimpleBlocObserver();
  runApp(const App());
}
```
Note

EquatableConfig.stringify = kDebugMode; is a constant that affects the output of toString. When in debug mode, equatable’s toString method will behave differently than profile and release mode and can use constants like kDebugMode or kReleaseMode to understand if you are running on debug or release.

In our App widget, the root of our project, we can then set the home to PostsPage

lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_infinite_list/posts/posts.dart';

class App extends MaterialApp {
  const App({super.key}) : super(home: const PostsPage());
}

In our PostsPage widget, we use BlocProvider to create and provide an instance of PostBloc to the subtree. Also, we add a PostFetched event so that when the app loads, it requests the initial batch of Posts.

lib/posts/view/posts_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_infinite_list/posts/posts.dart';
import 'package:http/http.dart' as http;

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => PostBloc(httpClient: http.Client())..add(PostFetched()),
        child: const PostsList(),
      ),
    );
  }
}

Next, we need to implement our PostsList view which will present our posts and hook up to our PostBloc.

lib/posts/view/posts_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_infinite_list/posts/posts.dart';

class PostsList extends StatefulWidget {
  const PostsList({super.key});

  @override
  State<PostsList> createState() => _PostsListState();
}

class _PostsListState extends State<PostsList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        switch (state.status) {
          case PostStatus.failure:
            return const Center(child: Text('failed to fetch posts'));
          case PostStatus.success:
            if (state.posts.isEmpty) {
              return const Center(child: Text('no posts'));
            }
            return ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return index >= state.posts.length
                    ? const BottomLoader()
                    : PostListItem(post: state.posts[index]);
              },
              itemCount: state.hasReachedMax
                  ? state.posts.length
                  : state.posts.length + 1,
              controller: _scrollController,
            );
          case PostStatus.initial:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) context.read<PostBloc>().add(PostFetched());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}

Note

PostsList is a StatefulWidget because it will need to maintain a ScrollController. In initState, we add a listener to our ScrollController so that we can respond to scroll events. We also access our PostBloc instance via context.read<PostBloc>().

Moving along, our build method returns a BlocBuilder. BlocBuilder is a Flutter widget from the flutter_bloc package which handles building a widget in response to new bloc states. Any time our PostBloc state changes, our builder function will be called with the new PostState.

Caution

We need to remember to clean up after ourselves and dispose of our ScrollController when the StatefulWidget is disposed.

Whenever the user scrolls, we calculate how far you have scrolled down the page and if our distance is ≥ 90% of our maxScrollextent we add a PostFetched event in order to load more posts.

Next, we need to implement our BottomLoader widget which will indicate to the user that we are loading more posts.

lib/posts/widgets/bottom_loader.dart
import 'package:flutter/material.dart';

class BottomLoader extends StatelessWidget {
  const BottomLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(strokeWidth: 1.5),
      ),
    );
  }
}

Lastly, we need to implement our PostListItem which will render an individual Post.

lib/posts/widgets/post_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_infinite_list/posts/posts.dart';

class PostListItem extends StatelessWidget {
  const PostListItem({required this.post, super.key});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      child: ListTile(
        leading: Text('${post.id}', style: textTheme.bodySmall),
        title: Text(post.title),
        isThreeLine: true,
        subtitle: Text(post.body),
        dense: true,
      ),
    );
  }
}

At this point, we should be able to run our app and everything should work; however, there’s one more thing we can do.

One added bonus of using the bloc library is that we can have access to all Transitions in one place.

The change from one state to another is called a Transition.

Note

A Transition consists of the current state, the event, and the next state.

Even though in this application we only have one bloc, it’s fairly common in larger applications to have many blocs managing different parts of the application’s state.

If we want to be able to do something in response to all Transitions we can simply create our own BlocObserver.

lib/simple_bloc_observer.dart
// ignore_for_file: avoid_print

import 'package:bloc/bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  const SimpleBlocObserver();

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    print(error);
    super.onError(bloc, error, stackTrace);
  }
}

Note

All we need to do is extend BlocObserver and override the onTransition method.

Now every time a Bloc Transition occurs we can see the transition printed to the console.

Note

In practice, you can create different BlocObservers and because every state change is recorded, we are able to very easily instrument our applications and track all user interactions and state changes in one place!

That’s all there is to it! We’ve now successfully implemented an infinite list in flutter using the bloc and flutter_bloc packages and we’ve successfully separated our presentation layer from our business logic.

Our PostsPage has no idea where the Posts are coming from or how they are being retrieved. Conversely, our PostBloc has no idea how the State is being rendered, it simply converts events into states.

The full source for this example can be found here.

Edit page
Previous
Flutter Timer
Next
Flutter Login