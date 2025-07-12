// lib/screens/todo_screen.dart
import 'package:flutter/material.dart';
import '../models/todo_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:sulisenergetika/widgets/animated_background.dart';
import 'package:sulisenergetika/widgets/future_flow_background.dart';
// import 'package:bitsdojo_window/bitsdojo_window.dart'; // ეს ხაზი წაიშალა
import 'package:flutter/foundation.dart'; // ეს იმპორტი დატოვე თუ გჭირდება defaultTargetPlatform-ის სხვაგან

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> with TickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();
  List<TodoItem> _todos = [];
  TodoItem? _editingTodo;
  String _filterGroup = 'All';
  TodoPriority _selectedPriority = TodoPriority.medium;
  DateTime? _selectedDate;
  
  // bool _isAlwaysOnTop = false; // ეს ხაზი წაიშალა

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadTodos();
    // _loadAlwaysOnTopPreference(); // ეს ხაზი წაიშალა
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _groupController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosString = prefs.getString('todos');
    if (todosString != null) {
      final List<dynamic> jsonList = jsonDecode(todosString);
      setState(() {
        _todos = jsonList.map((json) => TodoItem.fromJson(json)).toList();
      });
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String todosString =
        jsonEncode(_todos.map((todo) => todo.toJson()).toList());
    await prefs.setString('todos', todosString);
  }

  // ეს მთელი ფუნქცია წაიშალა
  // Future<void> _loadAlwaysOnTopPreference() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     _isAlwaysOnTop = prefs.getBool('alwaysOnTop') ?? false;
  //   });
  //   if (defaultTargetPlatform == TargetPlatform.linux ||
  //       defaultTargetPlatform == TargetPlatform.macOS ||
  //       defaultTargetPlatform == TargetPlatform.windows) {
  //     appWindow.setAlwaysOnTop(_isAlwaysOnTop);
  //   }
  // }

  // ეს მთელი ფუნქცია წაიშალა
  // void _toggleAlwaysOnTop(bool newValue) async {
  //   setState(() {
  //     _isAlwaysOnTop = newValue;
  //   });
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool('alwaysOnTop', newValue);
  //   
  //   if (defaultTargetPlatform == TargetPlatform.linux ||
  //       defaultTargetPlatform == TargetPlatform.macOS ||
  //       defaultTargetPlatform == TargetPlatform.windows) {
  //     appWindow.setAlwaysOnTop(_isAlwaysOnTop);
  //   }
  // }

  void _addOrUpdateTodo() {
    if (_titleController.text.isEmpty) {
      return;
    }

    setState(() {
      if (_editingTodo == null) {
        _todos.add(TodoItem(
          title: _titleController.text,
          description: _descController.text,
          group: _groupController.text,
          priority: _selectedPriority,
          dueDate: _selectedDate,
        ));
      } else {
        _editingTodo!.title = _titleController.text;
        _editingTodo!.description = _descController.text;
        _editingTodo!.group = _groupController.text;
        _editingTodo!.priority = _selectedPriority;
        _editingTodo!.dueDate = _selectedDate;
      }
      _saveTodos();
    });
    _clearFields();
    Navigator.of(context).pop();
  }

  void _clearFields() {
    _titleController.clear();
    _descController.clear();
    _groupController.clear();
    _selectedPriority = TodoPriority.medium;
    _selectedDate = null;
    _editingTodo = null;
  }

  void _editTodo(TodoItem todo) {
    _editingTodo = todo;
    _titleController.text = todo.title;
    _descController.text = todo.description;
    _groupController.text = todo.group;
    _selectedPriority = todo.priority;
    _selectedDate = todo.dueDate;
    _showTodoDialog();
  }

  void _toggleTodoCompletion(TodoItem todo) {
    setState(() {
      todo.isCompleted = !todo.isCompleted;
      _saveTodos();
    });
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((todo) => todo.id == id);
      _saveTodos();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              surface: Colors.grey.shade900,
              onSurface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueAccent,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showTodoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            _editingTodo == null ? 'ახალი დავალება' : 'დავალების რედაქტირება',
            style: const TextStyle(fontFamily: 'Orbitron', color: Colors.white, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'სათაური',
                    labelStyle: TextStyle(fontFamily: 'Orbitron', color: Colors.grey[400]),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade700),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: const TextStyle(fontFamily: 'Orbitron', color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descController,
                  decoration: InputDecoration(
                    labelText: 'აღწერა',
                    labelStyle: TextStyle(fontFamily: 'Orbitron', color: Colors.grey[400]),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade700),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: const TextStyle(fontFamily: 'Orbitron', color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _groupController,
                  decoration: InputDecoration(
                    labelText: 'ჯგუფი',
                    labelStyle: TextStyle(fontFamily: 'Orbitron', color: Colors.grey[400]),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade700),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: const TextStyle(fontFamily: 'Orbitron', color: Colors.white),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<TodoPriority>(
                  value: _selectedPriority,
                  decoration: InputDecoration(
                    labelText: 'პრიორიტეტი',
                    labelStyle: TextStyle(fontFamily: 'Orbitron', color: Colors.grey[400]),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade700),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  dropdownColor: Colors.grey[850],
                  style: const TextStyle(fontFamily: 'Orbitron', color: Colors.white),
                  onChanged: (TodoPriority? newValue) {
                    setState(() {
                      _selectedPriority = newValue!;
                    });
                  },
                  items: TodoPriority.values.map((priority) {
                    return DropdownMenuItem<TodoPriority>(
                      value: priority,
                      child: Text(
                        priority.toGeorgianString(),
                        style: TextStyle(fontFamily: 'Orbitron', color: priority.toColor),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                ListTile(
                  title: Text(
                    _selectedDate == null
                        ? 'აირჩიეთ ვადა'
                        : 'ვადა: ${_formatDate(_selectedDate!)}',
                    style: const TextStyle(fontFamily: 'Orbitron', color: Colors.white),
                  ),
                  trailing: const Icon(Icons.calendar_today, color: Colors.blueAccent),
                  onTap: () => _selectDate(context),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('გაუქმება', style: TextStyle(fontFamily: 'Orbitron', color: Colors.white)),
              onPressed: () {
                _clearFields();
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: _addOrUpdateTodo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                _editingTodo == null ? 'დამატება' : 'განახლება',
                style: const TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  List<TodoItem> get _filteredTodos {
    if (_filterGroup == 'All') {
      return _todos;
    }
    return _todos.where((t) => t.group == _filterGroup).toList();
  }

  Set<String> get _uniqueGroups {
    final uniqueGroups = {'All', ..._todos.map((e) => e.group).where((e) => e.isNotEmpty).toSet()};
    return uniqueGroups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'SulisEnergetika',
          style: const TextStyle(
            fontFamily: 'Orbitron',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            fontSize: 24.0,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[
          // Always On Top Toggle for desktop - ეს მთელი ბლოკი წაიშალა
          // if (defaultTargetPlatform == TargetPlatform.linux ||
          //     defaultTargetPlatform == TargetPlatform.macOS ||
          //     defaultTargetPlatform == TargetPlatform.windows)
          //   Tooltip(
          //     message: _isAlwaysOnTop ? 'გამორთეთ Always On Top' : 'ჩართეთ Always On Top',
          //     child: Switch(
          //       value: _isAlwaysOnTop,
          //       onChanged: _toggleAlwaysOnTop,
          //       activeColor: Colors.blueAccent,
          //       inactiveThumbColor: Colors.grey,
          //       inactiveTrackColor: Colors.grey.shade700,
          //     ),
          //   ),
          DropdownButton<String>(
            value: _filterGroup,
            dropdownColor: Colors.grey[850],
            style: const TextStyle(fontFamily: 'Orbitron', color: Colors.white),
            underline: Container(),
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onChanged: (String? newValue) {
              setState(() {
                _filterGroup = newValue!;
              });
            },
            items: _uniqueGroups.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedBackground(animation: _fadeAnimation),
          const FutureFlowBackground(),
          FadeTransition(
            opacity: _fadeAnimation,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: kToolbarHeight + 20),
              itemCount: _filteredTodos.length,
              itemBuilder: (context, index) {
                final todo = _filteredTodos[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: todo.isCompleted ? Colors.green.shade900.withOpacity(0.8) : Colors.grey.shade800.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(4, 4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.05),
                          offset: const Offset(-4, -4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                      border: Border.all(
                        color: todo.priority.toColor.withOpacity(0.6),
                        width: 1.5,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: todo.priority.toColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            leading: Checkbox(
                              value: todo.isCompleted,
                              onChanged: (bool? newValue) {
                                _toggleTodoCompletion(todo);
                              },
                              activeColor: Colors.greenAccent,
                              checkColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            title: Text(
                              todo.title,
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                color: todo.isCompleted ? Colors.grey[500] : Colors.white,
                                decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (todo.description.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      todo.description,
                                      style: TextStyle(fontFamily: 'Orbitron', color: Colors.grey[400], fontSize: 14),
                                    ),
                                  ),
                                if (todo.group.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      'ჯგუფი: ${todo.group}',
                                      style: TextStyle(fontFamily: 'Orbitron', color: Colors.grey[400], fontSize: 12),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'პრიორიტეტი: ${todo.priority.toGeorgianString()}',
                                    style: TextStyle(
                                      fontFamily: 'Orbitron',
                                      color: todo.priority.toColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                if (todo.dueDate != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      'ვადა: ${_formatDate(todo.dueDate!)}',
                                      style: const TextStyle(fontFamily: 'Orbitron', color: Color(0xFF87CEEB), fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                  onPressed: () => _editTodo(todo),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => _deleteTodo(todo.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _clearFields();
          _showTodoDialog();
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
