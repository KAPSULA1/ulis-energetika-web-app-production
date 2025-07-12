import 'package:flutter/material.dart';

// Todo-ს პრიორიტეტის ენამი
enum TodoPriority {
  low,     // დაბალი
  medium,  // საშუალო
  high,    // მაღალი
}

// გაფართოება TodoPriority-სთვის, რათა დააბრუნოს ქართული ტექსტი და ფერი
extension TodoPriorityExtension on TodoPriority {
  String get toGeorgianString {
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
        return Colors.greenAccent;
      case TodoPriority.medium:
        return Colors.orangeAccent;
      case TodoPriority.high:
        return Colors.redAccent;
    }
  }
}

class TodoItem {
  final String id;
  String title;
  String description;
  String group;
  bool isCompleted;
  TodoPriority priority; // <--- ახალი ველი პრიორიტეტისთვის

  TodoItem({
    required this.id,
    required this.title,
    this.description = '',
    this.group = 'General',
    this.isCompleted = false,
    this.priority = TodoPriority.medium, // <--- ნაგულისხმევი მნიშვნელობა (ინგლისურად)
  });

  // JSON-დან ობიექტის შექმნა
  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      group: json['group'] ?? 'General',
      isCompleted: json['isCompleted'] ?? false,
      priority: TodoPriority.values.firstWhere(
        (e) => e.toString() == 'TodoPriority.${json['priority']}',
        orElse: () => TodoPriority.medium, // უსაფრთხოებისათვის (ინგლისურად)
      ),
    );
  }

  // ობიექტის JSON-ად გადაქცევა
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'group': group,
      'isCompleted': isCompleted,
      'priority': priority.toString().split('.').last, // <--- პრიორიტეტის შენახვა
    };
  }
}
