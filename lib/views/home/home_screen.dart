import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:task_management_app/services/firebase_service.dart';
import '../../viewModels/task_viewmodel.dart';
import '../../viewModels/user_viewmodel.dart';
import '../../models/task_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
   DateTime? _lastBackPressed;

  DateTime selectedDate = DateTime.now();
  List<DateTime> daysList = [];

  bool _loaded = false;
  String selectedStatus = 'All';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _initializeDaysList();
      _listenToMidnight();
     
      _loaded = true;
    }
  }

  void _initializeDaysList() {
    final today = DateTime.now();
    setState(() {
      daysList = List.generate(7, (i) => DateTime(today.year, today.month, today.day).add(Duration(days: i)));
    });

    final taskVM = Provider.of<TaskViewModel>(context, listen: false);
    final userId = Provider.of<UserViewModel>(context, listen: false).currentUserId;
    if (userId != null) {
      taskVM.listenToTasks(userId);
    }
    taskVM.setSelectedDate(selectedDate);
  }

  void _listenToMidnight() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final duration = tomorrow.difference(now);

    Future.delayed(duration, () {
      setState(() {
        selectedDate = DateTime.now();
        daysList.removeAt(0);
        daysList.add(daysList.last.add(const Duration(days: 1)));
      });

      final taskVM = Provider.of<TaskViewModel>(context, listen: false);
      taskVM.setSelectedDate(selectedDate);
      _listenToMidnight();
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
    final taskVM = Provider.of<TaskViewModel>(context, listen: false);
    taskVM.setSelectedDate(date);
  }

  @override
  Widget build(BuildContext context) {
    final taskVM = Provider.of<TaskViewModel>(context);
    final dateFormat = DateFormat('dd MMM');
    final themeColor = const Color(0xFF19485C);
    final mutedColors = [
      const Color(0xFF7BC6A4),
      const Color(0xFFF7B267),
      const Color(0xFF6EC6FF),
      const Color(0xFFE57373),
    ];

    List<Task> displayTasks = [];
    if (selectedStatus == 'All') {
      displayTasks = taskVM.getTasksForDateAndStatus(selectedDate, 'Pending') +
          taskVM.getTasksForDateAndStatus(selectedDate, 'In Progress') +
          taskVM.getTasksForDateAndStatus(selectedDate, 'Overdue');
    } else {
      displayTasks = taskVM.getTasksForDateAndStatus(selectedDate, selectedStatus);
    }

    return  PopScope(
    canPop: false,
    onPopInvoked: (didPop) async {
      if (didPop) return;

      final now = DateTime.now();
      if (_lastBackPressed == null ||
          now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
        _lastBackPressed = now;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
               shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.all(
                Radius.circular(10)
               )),   
            backgroundColor: Color.fromARGB(255, 17, 52, 66),
            content: Text('Press back again to exit', style: TextStyle(fontWeight: FontWeight.bold,color: Color.fromARGB(253, 255, 255, 255))),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Exit the app
        SystemNavigator.pop();

      }
    },
    child:Scaffold(
      backgroundColor: themeColor,
      body: Column(
        children: [
          // Welcome & info
          Padding(
            padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<String?>(
                  future: _firebaseService.getCurrentUsername(),
                  builder: (context, snapshot) {
                    final username = snapshot.data ?? 'User';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 30),
                        Text(
                          'Welcome, $username!',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 29),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Taskify helps you manage your daily tasks with ease. Stay organized and productive!',
                          style: TextStyle(color: Colors.white70, fontSize: 19),
                        ),
                      
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // Date slider
          Container(
            height: 90,
            margin: const EdgeInsets.only(top: 0, bottom: 8),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              // color: const Color.fromARGB(255, 175, 175, 241),
               color: const Color.fromARGB(97, 84, 184, 228),

              borderRadius: BorderRadius.circular(18),
            ),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: daysList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final date = daysList[i];
                final isSelected = _isSameDate(date, selectedDate);
                final isToday = _isSameDate(date, DateTime.now());

                Color bgColor = Colors.transparent;
                Color textColor = Colors.black87;
                if (isSelected) {
                  bgColor= const Color.fromARGB(255, 17, 52, 66);
                  textColor = Colors.white;
                } else if (isToday) {
                  bgColor= const Color.fromARGB(137, 21, 62, 80);
                  textColor = Colors.white;
                }

                return GestureDetector(
                  onTap: () => _onDateSelected(date),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(date),
                          style: TextStyle(
                            color: textColor.withAlpha((isSelected || isToday) ? 255 : 179),

                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          date.day.toString().padLeft(2, '0'),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Content
          Expanded(
            child: selectedStatus == 'All'
                ? _buildOverviewContent(taskVM, dateFormat, mutedColors)
                : _buildTaskList(displayTasks),
          ),
        ],
      ),
      bottomNavigationBar: _buildFloatingNavBar(context, themeColor),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 0, 150, 135),
        onPressed: () => Navigator.pushNamed(context, '/addTask'),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    )
    );
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.day == b.day && a.month == b.month && a.year == b.year;

  // Floating, rounded, animated bottom navigation bar
  Widget _buildFloatingNavBar(BuildContext context, Color themeColor) {
    final navItems = [
      {'icon': Icons.home_rounded, 'label': 'Home', 'route': '/home'},
      {'icon': Icons.task_rounded, 'label': 'Tasks', 'route': '/tasks'},
      {'icon': Icons.person_rounded, 'label': 'Profile', 'route': '/profile'},
    ];
    int selectedIndex = 0;
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
              color: Colors.black.withAlpha(28),
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

  Widget _buildOverviewContent(TaskViewModel taskVM, DateFormat dateFormat, List<Color> mutedColors) {
    final dataMap = taskVM.pieChartData;
    return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
            _homeTile(
  title: "Tasks on ${dateFormat.format(selectedDate)}",
  count: taskVM.getTasksForDateAndStatus(selectedDate, 'Pending').length +
         taskVM.getTasksForDateAndStatus(selectedDate, 'In Progress').length,
  color: const Color(0xFF287191),
  onTap: () {
    Navigator.pushNamed(
      context,
      '/tasks',
      arguments: {
        'date': selectedDate,
        'status': 'dateOnly', // custom flag to show tasks only by date
      },
    );
  },
),
                    const SizedBox(width: 12),
            _homeTile(
  title: "Ongoing",
  count: taskVM.ongoingTasks.length,
  color: Colors.teal,
  onTap: () {
    Navigator.pushNamed(
      context,
      '/tasks',
      arguments: {
        'status': 'In Progress',
      },
    );
  },
),    ],
                ),
                const SizedBox(height: 20),
                Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF287191),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              const Text(
                'Task Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                        dataMap: dataMap,
                      colorList: mutedColors,
                        chartType: ChartType.ring,
                      ringStrokeWidth: 25,
                      chartRadius: MediaQuery.of(context).size.width / 4,
                      centerText: '', // Remove 'Tasks' text
                        baseChartColor: Colors.grey[300]!,
                        chartValuesOptions: const ChartValuesOptions(
                          showChartValuesInPercentage: true,
                        showChartValues: true,
                        showChartValueBackground: false,
                          decimalPlaces: 0,
                        chartValueStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        chartValueBackgroundColor: Colors.transparent,
                        ),
                        legendOptions: const LegendOptions(
                        showLegends: false,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        _buildLegendCircleItem("Completed", taskVM.completedTasks, mutedColors[0]),
                        const SizedBox(height: 12),
                        _buildLegendCircleItem("To do", taskVM.pendingTasks, mutedColors[1]),
                        const SizedBox(height: 12),
                        _buildLegendCircleItem("In Progress", taskVM.inProgressTasks, mutedColors[2]),
                        const SizedBox(height: 12),
                        
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendCircleItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 15,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Colors.white.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${selectedStatus.toLowerCase()} tasks for this date',
              style: TextStyle(
                color: Colors.white.withAlpha(179),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task);
      },
    );
  }

  Widget _buildTaskCard(Task task) {
    Color statusColor;
    IconData statusIcon;
    
    switch (task.status) {
      case 'Pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case 'In Progress':
        statusColor = Colors.blue;
        statusIcon = Icons.play_circle_outline;
        break;
      case 'completed':
        statusColor = const Color.fromARGB(255, 52, 170, 97);
        statusIcon = Icons.warning;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.circle;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF287191),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      task.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Text(
            task.description,
            style: TextStyle(
              color: Colors.white.withAlpha(204),
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.white.withAlpha(153),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('MMM dd, yyyy').format(task.dueDate),
                style: TextStyle(
                  color: Colors.white.withAlpha(153),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getPriorityColor(task.priority),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  task.priority,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _homeTile({required String title, required int count, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 130,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color, 
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title, 
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 18, 
                  fontWeight: FontWeight.bold
                ), 
                textAlign: TextAlign.center
              ),
              const SizedBox(height: 8),
              Text(
                '$count Tasks', 
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}



