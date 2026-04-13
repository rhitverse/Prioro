import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prioro/colors.dart';
import 'package:prioro/features/app/widgets/bottom_nav_bar.dart';
import 'package:prioro/features/app/screens/task/controller/task_controller.dart';
import 'package:prioro/features/app/screens/task/task_details_screen.dart';
import 'package:prioro/features/app/screens/task/create_task_screen.dart';

class TaskScreen extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabChange;
  final ValueChanged<String?>? onTaskMutation;
  final String selectedFilter;

  const TaskScreen({
    super.key,
    required this.currentIndex,
    required this.onTabChange,
    this.onTaskMutation,
    this.selectedFilter = 'All',
  });

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  String selectedFilter = 'All';
  late Future<List<Map<String, dynamic>>> _tasksFuture;
  late TextEditingController _searchController;
  late final TaskController _taskController;

  final List<String> filters = [
    'All',
    'Overdue',
    'High priority',
    'Medium',
    'Low',
    'Completed',
  ];

  @override
  void initState() {
    super.initState();
    _taskController = TaskController();
    _tasksFuture = _taskController.loadTasks();
    _searchController = TextEditingController();
    selectedFilter = filters.contains(widget.selectedFilter)
        ? widget.selectedFilter
        : 'All';
  }

  @override
  void didUpdateWidget(covariant TaskScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedFilter != widget.selectedFilter &&
        filters.contains(widget.selectedFilter) &&
        selectedFilter != widget.selectedFilter) {
      setState(() {
        selectedFilter = widget.selectedFilter;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _notifyTaskMutation([String? deletedTaskId]) {
    widget.onTaskMutation?.call(deletedTaskId);
  }

  bool _isCompletedTask(Map<String, dynamic> task) {
    final status = task['status']?.toString().toLowerCase() ?? '';
    final isCompleted = task['isCompleted'] == true;

    final rawProgress = task['progress'];
    int progress = 0;
    if (rawProgress is num) {
      progress = rawProgress.toInt();
    } else {
      progress = int.tryParse(rawProgress?.toString() ?? '') ?? 0;
    }

    return status == 'completed' || isCompleted || progress >= 100;
  }

  bool _hasPriority(Map<String, dynamic> task, String priority) {
    return task['priority']?.toString().toLowerCase() == priority;
  }

  bool _isOverdue(Map<String, dynamic> task) {
    try {
      final dueDateStr = task['dueDate']?.toString() ?? '';
      if (dueDateStr.isEmpty || _isCompletedTask(task)) return false;
      final dueDate = DateTime.tryParse(dueDateStr);
      if (dueDate == null) return false;

      final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
      final now = DateTime.now();
      final todayOnly = DateTime(now.year, now.month, now.day);
      return dueDateOnly.isBefore(todayOnly);
    } catch (e) {
      print('Error in _isOverdue: $e');
      return false;
    }
  }

  String _getCalendarSvg(Map<String, dynamic> task) {
    if (_isCompletedTask(task)) return 'assets/svg/greenCalendar.svg';

    if (_isOverdue(task)) return 'assets/svg/redCalendar.svg';

    if (_hasPriority(task, 'high')) return 'assets/svg/highCalendar.svg';
    if (_hasPriority(task, 'medium')) return 'assets/svg/orangeCalendar.svg';
    if (_hasPriority(task, 'low')) return 'assets/svg/greyCalendar.svg';

    return 'assets/svg/greyCalendar.svg';
  }

  String _formatDueDate(String? value) {
    if (value == null || value.isEmpty) return 'No date';

    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;

    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    return '$day-$month-${parsed.year}';
  }

  List<Map<String, dynamic>> _filterTasks(
    List<Map<String, dynamic>> tasks,
    String searchQuery,
  ) {
    try {
      var filtered = tasks;

      if (selectedFilter != 'All') {
        filtered = filtered.where((task) {
          try {
            switch (selectedFilter) {
              case 'Overdue':
                return _isOverdue(task);
              case 'High priority':
                return _hasPriority(task, 'high');
              case 'Medium':
                return _getCalendarSvg(task) == 'assets/svg/orangeCalendar.svg';
              case 'Low':
                return _hasPriority(task, 'low');
              case 'Completed':
                return _isCompletedTask(task);
              default:
                return true;
            }
          } catch (e) {
            print('Error filtering task: $e');
            return false;
          }
        }).toList();
      }

      if (searchQuery.isEmpty) {
        return filtered;
      }

      return filtered.where((task) {
        try {
          final title = task['title']?.toString().toLowerCase() ?? '';
          final description =
              task['description']?.toString().toLowerCase() ?? '';
          return title.contains(searchQuery.toLowerCase()) ||
              description.contains(searchQuery.toLowerCase());
        } catch (e) {
          print('Error in search: $e');
          return false;
        }
      }).toList();
    } catch (e) {
      print('Error in _filterTasks: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: appbarColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Tasks',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            hintText: 'Search Filters',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 8,
                              ),
                              child: SvgPicture.asset(
                                'assets/svg/search.svg',
                                colorFilter: ColorFilter.mode(
                                  Colors.black54,
                                  BlendMode.srcIn,
                                ),
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset(
                        'assets/svg/filter.svg',
                        colorFilter: ColorFilter.mode(
                          appbarColor,
                          BlendMode.srcIn,
                        ),
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: List.generate(
                filters.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => selectedFilter = filters[index]);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selectedFilter == filters[index]
                            ? appbarColor
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selectedFilter == filters[index]
                              ? Colors.white
                              : appbarColor,
                        ),
                      ),
                      child: Text(
                        filters[index],
                        style: TextStyle(
                          color: selectedFilter == filters[index]
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _tasksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error loading tasks: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _tasksFuture = _taskController.loadTasks();
                            });
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No tasks found'));
                }

                final tasks = snapshot.data!;
                final filteredTasks = _filterTasks(
                  tasks,
                  _searchController.text,
                );

                if (filteredTasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    final taskCalendar = _getCalendarSvg(task);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        child: Dismissible(
                          key: ValueKey(
                            task['id'] ?? '${task['title']}_$index',
                          ),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: SvgPicture.asset(
                              'assets/svg/delete.svg',
                              width: 28,
                              height: 28,
                              colorFilter: ColorFilter.mode(
                                Colors.red,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            final taskId = task['id']?.toString() ?? '';
                            if (taskId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Task id missing, cannot delete',
                                  ),
                                ),
                              );
                              return false;
                            }

                            try {
                              await _taskController.deleteTask(taskId);
                              if (!mounted) return false;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${task['title']} deleted'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              setState(() {
                                _tasksFuture = _taskController.loadTasks();
                              });
                              _notifyTaskMutation(taskId);
                              return true;
                            } catch (e) {
                              if (!mounted) return false;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Delete failed: $e')),
                              );
                              return false;
                            }
                          },
                          child: GestureDetector(
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
                                  _tasksFuture = _taskController
                                      .loadTasks()
                                      .then(
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
                                      _tasksFuture = _taskController
                                          .loadTasks();
                                    });
                                  },
                                );
                                _notifyTaskMutation(deletedId);
                                return;
                              }

                              if (result == true) {
                                setState(() {
                                  _tasksFuture = _taskController.loadTasks();
                                });
                                _notifyTaskMutation();
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: SvgPicture.asset(
                                      taskCalendar,
                                      width: 48,
                                      height: 48,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                task['title'] ?? 'No title',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _formatDueDate(
                                                task['dueDate']?.toString(),
                                              ),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          task['description']?.isNotEmpty ==
                                                  true
                                              ? task['description']
                                              : 'No description',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: appbarColor,
        elevation: 8,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
          );

          if (result == true) {
            setState(() {
              _tasksFuture = _taskController.loadTasks();
            });
            _notifyTaskMutation();
          }
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: widget.currentIndex,
        onTap: widget.onTabChange,
      ),
    );
  }
}
