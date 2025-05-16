import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';

class Category {
  final String id;
  final String name;
  final Color color;

  static final List<Color> availableColors = [
    Color(0xFFC2D2FD),
    Color(0xFFFFD8F4),
    Color(0xFFFBF6AA),
    Color(0xFFB0E9CA),
    Color(0xFFFCFAD9),
    Color(0xFFF1DBF5),
    Color(0xFFD9E8FC),
    Color(0xFFFFDBE3),
  ];

  const Category._({required this.id, required this.name, required this.color});

  static Category create(String name, int index) {
    final color = availableColors[index % availableColors.length];
    return Category._(id: const Uuid().v4(), name: name, color: color);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorIndex': availableColors.indexOf(color),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    final colorIndex = map['colorIndex'] as int;
    return Category._(
      id: map['id'] as String,
      name: map['name'] as String,
      color: availableColors[colorIndex % availableColors.length],
    );
  }

  Category copyWith({String? name, Color? color}) {
    return Category._(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }
}
