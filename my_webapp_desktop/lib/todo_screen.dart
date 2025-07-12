import 'dart:convert';
import 'dart:math'; // Random-ისთვის
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/todo_item.dart'; // დარწმუნდით, რომ ეს გზა სწორია

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> with SingleTickerProviderStateMixin {
  final List<TodoItem> _todos = [];
  final _uuid = const Uuid();
  String _filterGroup = 'All';

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _groupController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadTodos();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // ანიმაციის ხანგრძლივობა
    )..repeat(reverse: true); // გაიმეორეთ წინ და უკან

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  void _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('todos');
    if (data != null) {
      final decoded = jsonDecode(data) as List;
      setState(() {
        _todos.addAll(decoded.map((e) => TodoItem.fromJson(e)));
      });
    }
  }

  void _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _todos.map((e) => e.toJson()).toList();
    prefs.setString('todos', jsonEncode(jsonList));
  }

  void _addOrEditTodo({TodoItem? existing}) {
    if (existing != null) {
      _titleController.text = existing.title;
      _descController.text = existing.description;
      _groupController.text = existing.group;
    } else {
      _titleController.clear();
      _descController.clear();
      _groupController.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9), // ოდნავ გამჭვირვალე ფონი
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.cyanAccent.withOpacity(0.5), width: 2), // ლამაზი ბორდერი
        ),
        title: Text(
          existing == null ? 'ახალი ენერგია (დავალება)' : 'დავალების განახლება',
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontFamily: 'Orbitron',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _styledField(_titleController, 'სათაური: ენერგიის წერტილი'),
              const SizedBox(height: 12),
              _styledField(_descController, 'აღწერა: დეტალური ნაკადი'),
              const SizedBox(height: 12),
              _styledField(_groupController, 'კატეგორია: სფერო'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_titleController.text.isEmpty) return; // სათაური აუცილებელია
              setState(() {
                if (existing == null) {
                  _todos.add(TodoItem(
                    id: _uuid.v4(),
                    title: _titleController.text,
                    description: _descController.text,
                    group: _groupController.text.isNotEmpty ? _groupController.text : 'General',
                  ));
                } else {
                  final int index = _todos.indexWhere((todo) => todo.id == existing.id);
                  if (index != -1) {
                    _todos[index] = TodoItem(
                      id: existing.id,
                      title: _titleController.text,
                      description: _descController.text,
                      group: _groupController.text.isNotEmpty ? _groupController.text : 'General',
                      isCompleted: existing.isCompleted,
                    );
                  }
                }
                _saveTodos();
              });
              Navigator.of(context).pop();
            },
            child: const Text('ჩართვა (შენახვა)', style: TextStyle(color: Colors.greenAccent, fontFamily: 'Orbitron')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('გამორთვა (გაუქმება)', style: TextStyle(color: Colors.redAccent, fontFamily: 'Orbitron')),
          ),
        ],
      ),
    );
  }

  Widget _styledField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontFamily: 'Orbitron'),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontFamily: 'Orbitron'),
        filled: true,
        fillColor: Colors.purple.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none, // უბრალო ბორდერი არ გვაქვს
        ),
        enabledBorder: OutlineInputBorder( // აქტიური ბორდერი
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.deepPurpleAccent.withOpacity(0.6), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder( // ფოკუსირებული ბორდერი
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.cyanAccent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((t) => t.id == id);
      _saveTodos();
    });
  }

  void _toggleTodoCompletion(TodoItem todo) {
    setState(() {
      todo.isCompleted = !todo.isCompleted;
      _saveTodos();
    });
  }

  List<TodoItem> get _filteredTodos {
    if (_filterGroup == 'All') return _todos;
    return _todos.where((t) => t.group == _filterGroup).toList();
  }

  @override
  Widget build(BuildContext context) {
    final uniqueGroups = {'All', ..._todos.map((e) => e.group).where((e) => e.isNotEmpty).toSet()};
    return Scaffold(
      backgroundColor: Colors.black, // შავი ფონი
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[900], // მუქი მეწამული AppBar
        elevation: 0, // ჩრდილის გარეშე
        title: const Text(
          'სულის ენერგეტიკა', // <=== სათაური შეიცვალა
          style: TextStyle(
            fontFamily: 'Orbitron',
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.5)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _filterGroup,
                  dropdownColor: Colors.deepPurple[900],
                  style: const TextStyle(color: Colors.cyanAccent, fontFamily: 'Orbitron', fontSize: 16),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.cyanAccent),
                  items: uniqueGroups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (val) => setState(() => _filterGroup = val!),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final scale = 1.0 + 0.2 * _pulseAnimation.value; // პულსირების ეფექტი
          return Transform.scale(
            scale: scale,
            child: FloatingActionButton(
              onPressed: () => _addOrEditTodo(),
              backgroundColor: Colors.cyanAccent,
              shape: const CircleBorder(
                side: BorderSide(color: Colors.purpleAccent, width: 3), // ორმაგი ბორდერი
              ),
              child: Icon(Icons.add, color: Colors.deepPurple[900]),
            ),
          );
        },
      ),
      body: Stack(
        children: [
          // ფონური ანიმაცია (პულსირებადი წრეები)
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: EnergyFlowPainter(_animationController.value),
                child: Container(),
              );
            },
          ),
          // Todo List
          _filteredTodos.isEmpty
              ? Center(
                  child: Text(
                    'ჯერ არ გაქვთ დავალებები.\nდაამატეთ ახალი ენერგიის ნაკადი!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 18, fontFamily: 'Orbitron'),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredTodos.length,
                  itemBuilder: (context, index) {
                    final todo = _filteredTodos[index];
                    return AnimatedBuilder(
                      animation: _animationController, // ანიმაცია კარტებისთვის
                      builder: (context, child) {
                        final glowStrength = 0.5 + 0.5 * sin(_animationController.value * pi * 2 + index * 0.5);
                        final glowColor = Colors.cyanAccent.withOpacity(glowStrength);
                        return Card(
                          color: Colors.deepPurple[800]!.withOpacity(0.8), // ოდნავ გამჭვირვალე მუქი მეწამული
                          elevation: 8, // უფრო მეტი ამაღლება
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: glowColor, width: 2), // მოციმციმე ბორდერი
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: InkWell( // Clickable effect
                            onTap: () => _toggleTodoCompletion(todo),
                            borderRadius: BorderRadius.circular(15),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          todo.title,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontFamily: 'Orbitron',
                                            fontWeight: FontWeight.bold,
                                            decoration: todo.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                            decorationColor: Colors.cyanAccent,
                                            decorationThickness: 2,
                                          ),
                                        ),
                                      ),
                                      if (todo.isCompleted)
                                        const Icon(Icons.check_circle, color: Colors.greenAccent),
                                    ],
                                  ),
                                  if (todo.description.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        todo.description,
                                        style: const TextStyle(color: Colors.white70, fontFamily: 'Orbitron', fontSize: 14),
                                      ),
                                    ),
                                  if (todo.group.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Chip(
                                        label: Text(
                                          todo.group,
                                          style: TextStyle(color: Colors.purpleAccent, fontFamily: 'Orbitron', fontSize: 12),
                                        ),
                                        backgroundColor: Colors.deepPurple[900]!.withOpacity(0.6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          side: BorderSide(color: Colors.purpleAccent.withOpacity(0.4)),
                                        ),
                                      ),
                                    ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.cyanAccent),
                                          onPressed: () => _addOrEditTodo(existing: todo),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                                          onPressed: () => _deleteTodo(todo.id),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }
}

// Custom Painter ფონური ანიმაციისთვის
class EnergyFlowPainter extends CustomPainter {
  final double animationValue;
  final Random _random = Random();

  EnergyFlowPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Glowing circles
    for (int i = 0; i < 5; i++) {
      final double x = size.width * (0.2 + 0.6 * _random.nextDouble());
      final double y = size.height * (0.2 + 0.6 * _random.nextDouble());
      final double radius = 50 + 100 * (0.5 + 0.5 * sin(animationValue * pi * 2 + i * 0.7));
      final double opacity = 0.1 + 0.1 * cos(animationValue * pi * 2 + i * 0.9);

      final paint = Paint()
        ..color = Colors.cyanAccent.withOpacity(opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.outer, radius / 8);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Flowing lines
    final linePaint = Paint()
      ..color = Colors.purpleAccent.withOpacity(0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i < size.width; i += 20) {
      final y = size.height * 0.5 + 50 * sin((i / 50.0) + animationValue * 2 * pi);
      if (i == 0) {
        path.moveTo(i.toDouble(), y);
      } else {
        path.lineTo(i.toDouble(), y);
      }
    }
    canvas.drawPath(path, linePaint);

    final path2 = Path();
    for (int i = 0; i < size.height; i += 20) {
      final x = size.width * 0.5 + 50 * cos((i / 50.0) + animationValue * 2 * pi);
      if (i == 0) {
        path2.moveTo(x, i.toDouble());
      } else {
        path2.lineTo(x, i.toDouble());
      }
    }
    canvas.drawPath(path2, linePaint);
  }

  @override
  bool shouldRepaint(covariant EnergyFlowPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
