import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prioro/colors.dart';
import 'package:prioro/features/app/screens/task/controller/task_controller.dart';
import 'package:prioro/features/app/screens/task/task_details_screen.dart';
import 'package:prioro/features/app/screens/task/task_screen.dart';
import 'package:prioro/features/app/screens/profile_screen.dart';
import 'package:prioro/features/app/widgets/bottom_nav_bar.dart';
import 'package:prioro/features/app/screens/home/widgets/home_gradient_card.dart';
import 'package:prioro/features/app/screens/home/widgets/home_high_priority_card.dart';
import 'package:prioro/features/app/screens/home/widgets/home_upcoming_task_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  String _taskScreenFilter = 'All';
  late final TaskController _taskController;
  late Future<List<Map<String, dynamic>>> _upcomingTasksFuture;
  late Future<List<Map<String, dynamic>>> _allTasksFuture;

  @override
  void initState() {
    super.initState();
    _taskController = TaskController();
    _upcomingTasksFuture = _loadUpcomingTasks();
    _allTasksFuture = _taskController.loadTasks();
  }

  Future<List<Map<String, dynamic>>> _loadUpcomingTasks() async {
    final tasks = await _taskController.loadTasks();
    final now = DateTime.now();

    final upcomingTasks = tasks.where((task) {
      final status = task['status']?.toString().toLowerCase() ?? '';
      if (status == 'completed') return false;

      final dueDate = DateTime.tryParse(task['dueDate']?.toString() ?? '');
      if (dueDate == null) return false;

      final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
      final todayOnly = DateTime(now.year, now.month, now.day);
      return !dueDateOnly.isBefore(todayOnly);
    }).toList();

    upcomingTasks.sort((a, b) {
      final aDate =
          DateTime.tryParse(a['dueDate']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bDate =
          DateTime.tryParse(b['dueDate']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return aDate.compareTo(bDate);
    });

    return upcomingTasks.take(5).toList();
  }

  String _formatDueDate(String? value) {
    if (value == null || value.isEmpty) return 'No date';

    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;

    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    return '$day-$month-${parsed.year}';
  }

  void _handleTaskMutation([String? deletedTaskId]) {
    if (deletedTaskId != null && deletedTaskId.isNotEmpty) {
      setState(() {
        _upcomingTasksFuture = _upcomingTasksFuture.then(
          (tasks) => tasks
              .where((task) => task['id']?.toString() != deletedTaskId)
              .toList(),
        );
        _allTasksFuture = _taskController.loadTasks();
      });

      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() {
          _upcomingTasksFuture = _loadUpcomingTasks();
          _allTasksFuture = _taskController.loadTasks();
        });
      });
      return;
    }

    setState(() {
      _upcomingTasksFuture = _loadUpcomingTasks();
      _allTasksFuture = _taskController.loadTasks();
    });
  }

  int _countOverdueTasks(List<Map<String, dynamic>> tasks) {
    return tasks.where(_isOverdue).length;
  }

  DateTime _parseCreatedAt(dynamic value) {
    if (value is DateTime) return value;

    return DateTime.tryParse(value?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  List<Map<String, dynamic>> _getRecentCreatedTasks(
    List<Map<String, dynamic>> tasks, {
    int limit = 3,
  }) {
    final recentTasks = [...tasks];
    recentTasks.sort(
      (a, b) => _parseCreatedAt(
        b['createdAt'],
      ).compareTo(_parseCreatedAt(a['createdAt'])),
    );

    return recentTasks.take(limit).toList();
  }

  void _openTaskScreenWithFilter(String filter) {
    setState(() {
      _taskScreenFilter = filter;
      currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return IndexedStack(
      index: currentIndex,
      children: [
        _buildHomeContent(user),
        TaskScreen(
          currentIndex: currentIndex,
          onTabChange: (index) => setState(() => currentIndex = index),
          onTaskMutation: _handleTaskMutation,
          selectedFilter: _taskScreenFilter,
        ),
        ProfileScreen(
          currentIndex: currentIndex,
          onTabChange: (index) => setState(() => currentIndex = index),
          user: user,
        ),
      ],
    );
  }

  Widget _buildHomeContent(User? user) {
    final String firstName = (user?.displayName ?? user?.email ?? 'User')
        .split(' ')
        .first;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '$firstName ',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const Text('🌟', style: TextStyle(fontSize: 22)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.orange.shade300,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: user?.photoURL != null
                          ? Image.network(user!.photoURL!, fit: BoxFit.cover)
                          : Container(
                              color: Colors.orange.shade100,
                              child: Icon(
                                Icons.person,
                                color: Colors.orange.shade400,
                                size: 26,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade100,
                                ),
                                child: user?.photoURL != null
                                    ? ClipOval(
                                        child: Image.network(
                                          user!.photoURL!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        color: Colors.grey.shade500,
                                        size: 32,
                                      ),
                              ),
                              const SizedBox(height: 4),
                              Icon(
                                Icons.layers_outlined,
                                size: 22,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FutureBuilder<List<Map<String, dynamic>>>(
                              future: _allTasksFuture,
                              builder: (context, snapshot) {
                                final tasks =
                                    snapshot.data ??
                                    const <Map<String, dynamic>>[];
                                final recentTasks = _getRecentCreatedTasks(
                                  tasks,
                                );

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Recent Activity',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 6),
                                        child: SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    else if (recentTasks.isEmpty)
                                      Text(
                                        'No tasks created yet',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    else
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: recentTasks.map((task) {
                                          final title = task['title']
                                              ?.toString()
                                              .trim();
                                          final displayTitle =
                                              title != null && title.isNotEmpty
                                              ? title
                                              : 'Untitled task';

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 3,
                                            ),
                                            child: Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: const Color(0xffEFEFEF),
                                              ),
                                              child: Text(
                                                displayTitle,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 8,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: _allTasksFuture,
                        builder: (context, snapshot) {
                          final tasks =
                              snapshot.data ?? const <Map<String, dynamic>>[];
                          final overdueCount = _countOverdueTasks(tasks);
                          final totalCount = tasks.length;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'App Dashboard',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                child: GestureDetector(
                                  onTap: () =>
                                      _openTaskScreenWithFilter('Overdue'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE4574F),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$overdueCount Overdue',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Total Tasks: $totalCount',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () =>
                                        _openTaskScreenWithFilter('All'),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF5B357),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Transform.translate(
                      offset: const Offset(0, -16),
                      child: HomeGradientCard(
                        title: 'View Task',
                        subtitle: '30 tasks in total',
                        count1: '12',
                        count2: '528',
                        icon: Icons.task_alt_rounded,
                        gradientColors: [const Color(0xFFF5A55A), appbarColor],
                        onTap: () => _openTaskScreenWithFilter('All'),
                        height: 125,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: HomeGradientCard(
                      title: 'Completed',
                      subtitle: '3.95 minutes avg',
                      count1: '19',
                      count2: '535',
                      icon: Icons.check_circle_rounded,
                      gradientColors: [
                        appbarColor,
                        const Color.fromARGB(255, 224, 135, 71),
                      ],
                      onTap: () => _openTaskScreenWithFilter('Completed'),
                      height: 156,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Transform.translate(
                      offset: const Offset(0, -36),
                      child: HomeGradientCard(
                        title: 'In Progress',
                        subtitle: 'Active tasks',
                        count1: '11',
                        count2: '523',
                        icon: Icons.pending_actions_rounded,
                        gradientColors: [
                          const Color(0xFFFFCF8B),
                          const Color(0xFFF5A55A),
                        ],
                        onTap: () {},
                        height: 132,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Transform.translate(
                      offset: const Offset(0, -9),
                      child: GestureDetector(
                        onTap: () => _openTaskScreenWithFilter('High priority'),
                        child: const HomeHighPriorityCard(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Upcoming Tasks',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: _upcomingTasksFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Failed to load tasks: ${snapshot.error}',
                              ),
                            );
                          }

                          final upcomingTasks = snapshot.data ?? [];
                          if (upcomingTasks.isEmpty) {
                            return Center(
                              child: Text(
                                'No upcoming tasks found',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            );
                          }

                          return ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: upcomingTasks.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final task = upcomingTasks[index];
                              return HomeUpcomingTaskCard(
                                task: task,
                                taskColor: _getTaskColor(task),
                                dueDateText: _formatDueDate(
                                  task['dueDate']?.toString(),
                                ),
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TaskDetailsScreen(task: task),
                                    ),
                                  );

                                  if (result is Map &&
                                      result['deletedTaskId'] != null) {
                                    final deletedId = result['deletedTaskId']
                                        .toString();
                                    setState(() {
                                      _upcomingTasksFuture =
                                          _loadUpcomingTasks().then(
                                            (tasks) => tasks
                                                .where(
                                                  (t) =>
                                                      t['id']?.toString() !=
                                                      deletedId,
                                                )
                                                .toList(),
                                          );
                                    });
                                    Future.delayed(
                                      const Duration(milliseconds: 700),
                                      () {
                                        if (!mounted) return;
                                        setState(() {
                                          _upcomingTasksFuture =
                                              _loadUpcomingTasks();
                                        });
                                      },
                                    );
                                    return;
                                  }

                                  if (result == true) {
                                    setState(() {
                                      _upcomingTasksFuture =
                                          _loadUpcomingTasks();
                                    });
                                  }
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
      ),
    );
  }

  bool _isOverdue(Map<String, dynamic> task) {
    final dueDate = DateTime.tryParse(task['dueDate']?.toString() ?? '');
    final status = task['status']?.toString().toLowerCase() ?? '';
    if (dueDate == null || status == 'completed') return false;
    return dueDate.isBefore(DateTime.now());
  }

  Color _getTaskColor(Map<String, dynamic> task) {
    if (_isOverdue(task)) return Colors.red;

    switch (task['status']?.toString().toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'blocked':
        return Colors.red;
    }

    switch (task['priority']?.toString().toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.grey;
    }

    return Colors.grey;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }
}
