import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewModels/task_viewmodel.dart';
import '../../models/task_model.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF19485C);
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
        title: const Text('Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _profileCard(
              context,
              icon: Icons.history,
              title: 'Task History',
              color: Colors.teal,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TaskHistoryScreen()),
              ),
            ),
            const SizedBox(height: 24),
            _profileCard(
              context,
              icon: Icons.logout,
              title: 'Log Out',
              color: Colors.red,
              onTap: () async {
                final confirm = await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: themeColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    content: const Text('Are you sure you want to log out?', style: TextStyle(color: Colors.white70)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Log Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildFloatingNavBar(context, themeColor),
    )
    );
  }

  Widget _profileCard(BuildContext context, {required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withAlpha(31),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(20),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 18),
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  // Floating, rounded, animated bottom navigation bar
  Widget _buildFloatingNavBar(BuildContext context, Color themeColor) {
    final navItems = [
      {'icon': Icons.home_rounded, 'label': 'Home', 'route': '/home'},
      {'icon': Icons.task_rounded, 'label': 'Tasks', 'route': '/tasks'},
      {'icon': Icons.person_rounded, 'label': 'Profile', 'route': '/profile'},
    ];
    int selectedIndex = 2; // Profile screen is selected
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
              color: Colors.black.withAlpha(21),
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

class TaskHistoryScreen extends StatefulWidget {
  const TaskHistoryScreen({super.key});
  @override
  State<TaskHistoryScreen> createState() => _TaskHistoryScreenState();
}

class _TaskHistoryScreenState extends State<TaskHistoryScreen> {
  int _shownCount = 6;

  @override
  Widget build(BuildContext context) {
    final taskVM = Provider.of<TaskViewModel>(context);
    final completedTasks = List<Task>.from(taskVM.allTasks.where((t) => t.status == 'Completed'));
    completedTasks.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    final shownTasks = completedTasks.take(_shownCount).toList();
    final themeColor = const Color(0xFF19485C);
    return Scaffold(
      backgroundColor: themeColor,
      appBar: AppBar(
        title: const Text('Task History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tasks History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 18),
            Expanded(
              child: shownTasks.isEmpty
                  ? const Center(child: Text('No completed tasks yet.', style: TextStyle(color: Colors.white70)))
                  : ListView.builder(
                      itemCount: shownTasks.length,
                      itemBuilder: (context, index) {
                        final task = shownTasks[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(21),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.teal, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(31),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                              const SizedBox(height: 6),
                              Text(task.description, style: TextStyle(color: Colors.white.withAlpha(204), fontSize: 14)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, color: Colors.white.withAlpha(179), size: 16),
                                  const SizedBox(width: 4),
                                  Text('${task.dueDate.day.toString().padLeft(2, '0')}-${task.dueDate.month.toString().padLeft(2, '0')}-${task.dueDate.year}', style: TextStyle(color: Colors.white.withAlpha(179), fontSize: 13)),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text('Completed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            if (completedTasks.length > _shownCount)
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _shownCount += 6),
                  child: const Text('Load More', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 