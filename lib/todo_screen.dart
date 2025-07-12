import 'package:flutter/material.dart';
import '../models/todo_item.dart'; // Make sure this path is correct
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:sulisenergetika/widgets/animated_background.dart'; // If you're using this widget

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
  TodoItem? _editingTodo; // If we are editing a task
  String _filterGroup = 'All'; // For filtering
  TodoPriority _selectedPriority = TodoPriority.medium; // <--- Modified
  DateTime? _selectedDate; // <--- New field for the date

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadTodos();
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

  void _addOrUpdateTodo() {
    if (_titleController.text.isEmpty) {
      // You can add a validation message here
      return;
    }

    setState(() {
      if (_editingTodo == null) {
        // Adding a new task
        _todos.add(TodoItem(
          title: _titleController.text,
          description: _descController.text,
          group: _groupController.text,
          priority: _selectedPriority, // <--- Adding priority
          dueDate: _selectedDate, // <--- Adding date
        ));
      } else {
        // Updating an existing task
        _editingTodo!.title = _titleController.text;
        _editingTodo!.description = _descController.text;
        _editingTodo!.group = _groupController.text;
        _editingTodo!.priority = _selectedPriority; // <--- Updating priority
        _editingTodo!.dueDate = _selectedDate; // <--- Updating date
        _editingTodo = null; // Exit editing mode
      }
      _saveTodos(); // Save changes
    });
    _clearFields();
    Navigator.of(context).pop(); // Close dialog
  }

  void _clearFields() {
    _titleController.clear();
    _descController.clear();
    _groupController.clear();
    _selectedPriority = TodoPriority.medium; // <--- Reset priority
    _selectedDate = null; // <--- Reset date
  }

  void _editTodo(TodoItem todo) {
    _editingTodo = todo;
    _titleController.text = todo.title;
    _descController.text = todo.description;
    _groupController.text = todo.group;
    _selectedPriority = todo.priority; // <--- Set existing priority
    _selectedDate = todo.dueDate; // <--- Set existing date
    _showTodoDialog(); // Open dialog for editing
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

  // --- Date selection function ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(), // Initial date
      firstDate: DateTime(2000), // Earliest date
      lastDate: DateTime(2101), // Latest date
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.blueAccent, // Date picker header background
              onPrimary: Colors.white,   // Date picker header text
              surface: Colors.grey.shade900, // Date picker background
              onSurface: Colors.white,   // Date picker day/date text
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueAccent, // OK/Cancel button color
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
          backgroundColor: Colors.grey[900], // Dark background
          title: Text(_editingTodo == null ? 'ახალი დავალება' : 'დავალების რედაქტირება',
              style: const TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'სათაური',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descController,
                  decoration: InputDecoration(
                    labelText: 'აღწერა',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _groupController,
                  decoration: InputDecoration(
                    labelText: 'ჯგუფი',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                // --- პრიორიტეტის ამომრჩეველი ---
                DropdownButtonFormField<TodoPriority>(
                  value: _selectedPriority,
                  decoration: InputDecoration(
                    labelText: 'პრიორიტეტი',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                  dropdownColor: Colors.grey[850],
                  style: const TextStyle(color: Colors.white),
                  onChanged: (TodoPriority? newValue) {
                    setState(() {
                      _selectedPriority = newValue!;
                    });
                  },
                  items: TodoPriority.values.map((priority) {
                    return DropdownMenuItem<TodoPriority>(
                      value: priority,
                      child: Text(
                        priority.toGeorgianString(), // <--- აქ უკვე გასწორებულია!
                        style: TextStyle(color: priority.toColor),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                // --- თარიღის ამომრჩეველი ---
                ListTile(
                  title: Text(
                    _selectedDate == null
                        ? 'აირჩიეთ ვადა'
                        : 'ვადა: ${_formatDate(_selectedDate!)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: const Icon(Icons.calendar_today, color: Colors.blueAccent),
                  onTap: () => _selectDate(context),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('გაუქმება', style: TextStyle(color: Colors.white)),
              onPressed: () {
                _clearFields();
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: _addOrUpdateTodo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // ღილაკის ფონი
                foregroundColor: Colors.white, // ღილაკის ტექსტი
              ),
              child: Text(_editingTodo == null ? 'დამატება' : 'განახლება'),
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
        title: const Text(
          'SulisEnergetika',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            fontSize: 24.0,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[
          DropdownButton<String>(
            value: _filterGroup,
            dropdownColor: Colors.grey[850],
            style: const TextStyle(color: Colors.white),
            underline: Container(), // ხაზის მოსაშორებლად
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
          AnimatedBackground(animation: _fadeAnimation), // Fixed: Pass the animation parameter
          FadeTransition(
            opacity: _fadeAnimation,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: kToolbarHeight + 20), // აპლიკაციის ზოლის სიმაღლე + დამატებითი სივრცე
              itemCount: _filteredTodos.length,
              itemBuilder: (context, index) {
                final todo = _filteredTodos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  color: todo.isCompleted ? Colors.green.shade900 : Colors.grey.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: todo.priority.toColor.withOpacity(0.4)), // <--- ბორდერის ფერი
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Checkbox(
                      value: todo.isCompleted,
                      onChanged: (bool? newValue) {
                        _toggleTodoCompletion(todo);
                      },
                      activeColor: Colors.greenAccent,
                      checkColor: Colors.black,
                    ),
                    title: Text(
                      todo.title,
                      style: TextStyle(
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
                              style: TextStyle(color: Colors.grey[400], fontSize: 14),
                            ),
                          ),
                        if (todo.group.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'ჯგუფი: ${todo.group}',
                              style: TextStyle(color: Colors.grey[400], fontSize: 12),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'პრიორიტეტი: ${todo.priority.toGeorgianString()}', // <--- ქართული ტექსტი
                            style: TextStyle(
                              color: todo.priority.toColor, // <--- ფერი პრიორიტეტის მიხედვით
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (todo.dueDate != null) // <--- თარიღის ჩვენება
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'ვადა: ${_formatDate(todo.dueDate!)}', // Helper for date formatting
                              style: const TextStyle(color: Colors.blueAccent, fontSize: 12),
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
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _clearFields(); // დარწმუნდით, რომ ველები გასუფთავდება ახალი დავალების დამატებამდე
          _showTodoDialog();
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  // Helper function to format date
  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}