import 'package:uuid/uuid.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final String categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool pinned;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.pinned = false,
  });

  factory Note.create({
    required String title,
    required String content,
    required String categoryId,
    bool? pinned,
  }) {
    final now = DateTime.now();
    return Note(
      id: const Uuid().v4(),
      title: title,
      content: content,
      categoryId: categoryId,
      createdAt: now,
      updatedAt: now,
      pinned: pinned ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'categoryId': categoryId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'pinned': pinned,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      categoryId: map['categoryId'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      pinned: map['pinned'] as bool? ?? false,
    );
  }

  // Create a copy with updated fields
  Note copyWith({
    String? title,
    String? content,
    String? categoryId,
    bool? pinned,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      pinned: pinned ?? this.pinned,
    );
  }
}
