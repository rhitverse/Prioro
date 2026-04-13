import 'package:flutter/material.dart';
import 'package:prioro/colors.dart';
import 'package:prioro/features/app/screens/Login/widget/info_popup.dart';
import 'package:prioro/features/app/screens/task/controller/task_controller.dart';
import 'package:prioro/features/app/screens/task/widget/task_form_widgets.dart';
import 'package:prioro/features/app/widgets/helpfulWidget/custom_messengeer.dart';

class EditTaskScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final TaskController _taskController = TaskController();

  String _selectedPriority = 'medium';
  DateTime? _startDate;
  DateTime? _dueDate;
  int _progress = 0;
  final List<String> _tags = [];
  static const int _maxTags = 5;

  bool _showTags = false;
  bool _showCompletion = true;

  @override
  void initState() {
    super.initState();
    _hydrateFromTask();
  }

  void _hydrateFromTask() {
    _titleController.text = widget.task['title']?.toString() ?? '';
    _descriptionController.text = widget.task['description']?.toString() ?? '';
    _selectedPriority =
        (widget.task['priority']?.toString().toLowerCase() ?? 'medium');

    final rawProgress = widget.task['progress'];
    if (rawProgress is num) {
      _progress = rawProgress.round().clamp(0, 100);
    } else {
      _progress =
          int.tryParse(rawProgress?.toString() ?? '')?.clamp(0, 100) ?? 0;
    }

    _startDate = _parseDate(widget.task['startDate']?.toString());
    _dueDate = _parseDate(widget.task['dueDate']?.toString());

    final rawTags = widget.task['tags'];
    if (rawTags is List) {
      _tags.addAll(
        rawTags
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .take(_maxTags),
      );
    } else if (rawTags is String) {
      _tags.addAll(
        rawTags
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .take(_maxTags),
      );
    }
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;

    final iso = DateTime.tryParse(value);
    if (iso != null) return iso;

    final parts = value.split('-');
    if (parts.length == 3) {
      final d = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      if (d != null && m != null && y != null) {
        return DateTime(y, m, d);
      }
    }
    return null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? _startDate ?? DateTime.now()
          : (_dueDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: appbarColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  void _showTagLimitMessage() {
    InfoPopup.show(
      context,
      'You can add up to 5 tags only',
      duration: const Duration(seconds: 2),
    );
  }

  void _showValidationPopup(String message) {
    InfoPopup.show(context, message, duration: const Duration(seconds: 2));
  }

  void _addTagFromInput(String rawValue) {
    final tag = rawValue.trim().replaceAll(',', '');
    if (tag.isEmpty) return;

    if (_tags.length >= _maxTags) {
      _tagsController.clear();
      _showTagLimitMessage();
      return;
    }

    final exists = _tags.any((t) => t.toLowerCase() == tag.toLowerCase());
    if (exists) {
      _tagsController.clear();
      return;
    }

    setState(() {
      _tags.add(tag);
      _tagsController.clear();
    });
  }

  void _handleTagTextChanged(String value) {
    if (!value.contains(',')) return;

    final parts = value.split(',');
    final completedTags = parts.take(parts.length - 1);
    var changed = false;

    for (final part in completedTags) {
      if (_tags.length >= _maxTags) {
        _showTagLimitMessage();
        break;
      }

      final candidate = part.trim();
      if (candidate.isEmpty) continue;
      final exists = _tags.any(
        (t) => t.toLowerCase() == candidate.toLowerCase(),
      );
      if (exists) continue;
      _tags.add(candidate);
      changed = true;
    }

    final remainder = parts.last.trimLeft();
    _tagsController.value = TextEditingValue(
      text: remainder,
      selection: TextSelection.collapsed(offset: remainder.length),
    );

    if (changed) {
      setState(() {});
    }
  }

  Future<void> _handleUpdateTask() async {
    if (_titleController.text.isEmpty) {
      _showValidationPopup('Please fill Title');
      return;
    }

    if (_dueDate == null) {
      _showValidationPopup('Please fill Due Date');
      return;
    }

    final taskId = widget.task['id']?.toString() ?? '';
    if (taskId.isEmpty) {
      _showValidationPopup('Task id missing, cannot update');
      return;
    }

    try {
      final pendingTag = _tagsController.text.trim();
      final payloadTags = [..._tags];
      if (pendingTag.isNotEmpty && payloadTags.length < _maxTags) {
        final exists = payloadTags.any(
          (t) => t.toLowerCase() == pendingTag.toLowerCase(),
        );
        if (!exists) payloadTags.add(pendingTag);
      } else if (pendingTag.isNotEmpty && payloadTags.length >= _maxTags) {
        _showTagLimitMessage();
      }

      final updates = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'priority': _selectedPriority,
        'progress': _progress,
        'tags': payloadTags,
        'dueDate':
            '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}',
        'startDate': _startDate != null
            ? '${_startDate!.day.toString().padLeft(2, '0')}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.year}'
            : '',
      };

      await _taskController.updateTask(taskId, updates);

      if (!mounted) return;
      CustomMessenger.show(context, 'Task updated successfully!');
      Navigator.pop(context, true);
    } catch (e) {
      InfoPopup.show(
        context,
        'Error: $e',
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFFE1AC63), appbarColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black87,
              size: 20,
            ),
          ),
        ),
        title: const Text(
          'Edit Task',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Basic Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                TaskFormTextField(
                  controller: _titleController,
                  hintText: 'Title',
                ),
                const SizedBox(height: 16),
                TaskFormTextField(
                  controller: _descriptionController,
                  hintText: 'Description.',
                  maxLines: 6,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Priority Date',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                TaskPrioritySelector(
                  selectedPriority: _selectedPriority,
                  onPriorityChanged: (value) {
                    setState(() => _selectedPriority = value);
                  },
                ),
                const SizedBox(height: 28),
                TaskDateRow(
                  label: 'Due Date',
                  date: _dueDate,
                  onTap: () => _selectDate(false),
                ),
                const SizedBox(height: 28),
                _buildProgressSection(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleUpdateTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appbarColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Update Task',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progress',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showCompletion = true;
                    _showTags = false;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _showCompletion ? appbarColor : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _showCompletion
                          ? appbarColor
                          : Colors.grey.shade300,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Completion',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _showCompletion ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showCompletion = false;
                    _showTags = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _showTags ? appbarColor : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _showTags ? appbarColor : Colors.grey.shade300,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Tags',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _showTags ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _showCompletion
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: TaskProgressSlider(
            progress: _progress,
            onChanged: (value) {
              setState(() => _progress = value.toInt());
            },
            onReset: () => setState(() => _progress = 0),
          ),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TaskTagsInputField(
              tags: _tags,
              maxTags: _maxTags,
              tagsController: _tagsController,
              onSubmitted: _addTagFromInput,
              onChanged: _handleTagTextChanged,
              onRemoveTag: (tag) {
                setState(() => _tags.remove(tag));
              },
            ),
          ),
        ),
      ],
    );
  }
}
