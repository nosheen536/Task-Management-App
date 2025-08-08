
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewModels/task_viewmodel.dart';
import '../../models/task_model.dart';
import '../../widgets/task_card.dart';
import 'package:intl/intl.dart';

class TasksScreen extends StatefulWidget {
  static const routeName = '/tasks';
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  int? _selectedCardIndex;
  bool _searchFocused = false;
  final List<String> _categories = [
    'All', 'Recent', 'In Progress', 'Pending'
  ];
  final Color _chipBg = const Color(0xFF19485C);

  String? _statusArg;
  DateTime? _dateArg;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      setState(() {
        _statusArg = args['status'];
        _dateArg = args['date'];
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskVM = Provider.of<TaskViewModel>(context);
    final themeColor = const Color(0xFF19485C);
    final tasks = _filteredTasks(taskVM.allTasks);

    return PopScope(
  canPop: false,
  onPopInvoked: (didPop) {
    if (!didPop) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  },
    child:Scaffold(
      backgroundColor: themeColor,
      appBar: AppBar(
        title: const Text('Tasks', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_statusArg == null && _dateArg == null) // Hide filters if showing custom filtered view
              Focus(
                onFocusChange: (hasFocus) => setState(() => _searchFocused = hasFocus),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(26),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _searchFocused ? Colors.white : Colors.transparent, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.search, color: Colors.white70),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search tasks by status, priority, date, and title…',
                            hintStyle: TextStyle(color: Colors.white54),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white70),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            if (_statusArg == null && _dateArg == null) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final cat = _categories[i];
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withAlpha(31) : _chipBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 2),
                          boxShadow: isSelected ? [BoxShadow(color: Colors.white24, blurRadius: 8, offset: const Offset(0, 2))] : [],
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 18),
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Text(
                        'No tasks found.',
                        style: TextStyle(color: Colors.white.withAlpha(179), fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCardIndex = index;
                            });
                          },
                          child: TaskCard(
                            task: tasks[index],
                            selected: _selectedCardIndex == index,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () => Navigator.pushNamed(context, '/addTask'),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildFloatingNavBar(context, themeColor),
    )
    );
  }

  List<Task> _filteredTasks(List<Task> allTasks) {
    // If filtering by in-progress only
    if (_statusArg == 'In Progress') {
      return allTasks.where((t) => t.status == 'In Progress').toList();
    }

    // If filtering by specific date
    if (_statusArg == 'dateOnly' && _dateArg != null) {
      return allTasks.where((t) {
        final tDate = DateFormat('yyyy-MM-dd').format(t.dueDate);
        final selectedDate = DateFormat('yyyy-MM-dd').format(_dateArg!);
        return tDate == selectedDate;
      }).toList();
    }

    // Normal filter by category + search
    List<Task> filtered = allTasks;
    switch (_selectedCategory) {
      case 'Recent':
        filtered = List.from(allTasks);
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        filtered = filtered.take(10).toList();
        break;
      case 'In Progress':
        filtered = allTasks.where((t) => t.status == 'In Progress').toList();
        break;
      case 'Pending':
        filtered = allTasks.where((t) => t.status == 'Pending').toList();
        break;
      default:
        break;
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) {
        final query = _searchQuery.toLowerCase();
        return t.title.toLowerCase().contains(query) ||
            t.status.toLowerCase().contains(query) ||
            t.priority.toLowerCase().contains(query) ||
            t.dueDate.toString().toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  Widget _buildFloatingNavBar(BuildContext context, Color themeColor) {
    final navItems = [
      {'icon': Icons.home_rounded, 'label': 'Home', 'route': '/home'},
      {'icon': Icons.task_rounded, 'label': 'Tasks', 'route': '/tasks'},
      {'icon': Icons.person_rounded, 'label': 'Profile', 'route': '/profile'},
    ];
    int selectedIndex = 1;
    for (int i = 0; i < navItems.length; i++) {
      if (ModalRoute.of(context)?.settings.name == navItems[i]['route']) {
        selectedIndex = i;
        break;
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(navItems.length, (i) {
            final isSelected = selectedIndex == i;
            final iconColor = isSelected ? Colors.white : themeColor;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.ease,
              padding: EdgeInsets.symmetric(horizontal: isSelected ? 18 : 0),
              child: GestureDetector(
                onTap: () {
                  if (ModalRoute.of(context)?.settings.name != navItems[i]['route']) {
                    Navigator.pushReplacementNamed(context, navItems[i]['route'] as String);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.ease,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? themeColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 0),
                  child: Row(
                    children: [
                      Icon(navItems[i]['icon'] as IconData, color: iconColor, size: isSelected ? 28 : 24),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Text(
                          navItems[i]['label'] as String,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

