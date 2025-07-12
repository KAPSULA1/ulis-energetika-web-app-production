import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart'; // Needed for Colors in TodoPriorityExtension

// TodoPriority Enum definition
enum TodoPriority {
  low,
  medium,
  high,
}

// Extensions for TodoPriority (text and color)
extension TodoPriorityExtension on TodoPriority {
  String toGeorgianString() {
    switch (this) {
      case TodoPriority.low:
        return 'დაბალი';
      case TodoPriority.medium:
        return 'საშუალო';
      case TodoPriority.high:
        return 'მაღალი';
    }
  }

  Color get toColor {
    switch (this) {
      case TodoPriority.low:
        return Colors.blue;
      case TodoPriority.medium:
        return Colors.yellow.shade700;
      case TodoPriority.high:
        return Colors.red;
    }
  }
}

class TodoItem {
  final String id;
  String title;
  String description;
  String group;
  TodoPriority priority;
  bool isCompleted;
  DateTime? dueDate; // <--- This is the new field for the date

  TodoItem({
    String? id,
    required this.title,
    this.description = '',
    this.group = '',
    this.priority = TodoPriority.medium,
    this.isCompleted = false,
    this.dueDate, // <--- Added to the constructor
  }) : this.id = id ?? const Uuid().v4();

  // Creating an object from JSON (Deserialization)
  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      group: json['group'] ?? '',
      isCompleted: json['isCompleted'],
      priority: TodoPriority.values.firstWhere(
        (e) => e.toString().split('.').last == json['priority'],
        orElse: () => TodoPriority.medium,
      ),
      dueDate: json['dueDate'] != null // <--- Parsing date from JSON
          ? DateTime.parse(json['dueDate'])
          : null,
    );
  }

  // Converting object to JSON (Serialization)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'group': group,
      'isCompleted': isCompleted,
      'priority': priority.toString().split('.').last,
      'dueDate': dueDate?.toIso8601String(), // <--- Converting date for JSON
    };
  }
}