import 'package:rxdart/subjects.dart';

class InMemoryStore<T> {
  InMemoryStore(T initials) : _subject = BehaviorSubject<T>.seeded(initials);

  final BehaviorSubject<T> _subject;

  Stream<T> get stream => _subject.stream;

  T get value => _subject.value;

  set value(T value) => _subject.add(value);

  void close() => _subject.close();
}
