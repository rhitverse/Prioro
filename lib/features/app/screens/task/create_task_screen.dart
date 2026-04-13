import 'package:flutter/material.dart';
import 'package:prioro/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prioro/features/app/screens/task/controller/task_controller.dart';
import 'package:prioro/features/app/screens/Login/widget/info_popup.dart';
import 'package:prioro/features/app/widgets/helpfulWidget/custom_messengeer.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
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
    _startDate = DateTime.now();
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'No date';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              setState(() => _tags.remove(tag));
            },
            child: Icon(Icons.close, size: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsInputField() {
    final isTagLimitReached = _tags.length >= _maxTags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_tags.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _tags.map(_buildTagChip).toList(),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: appbarColor, width: 1.2),
          ),
          child: TextField(
            controller: _tagsController,
            enabled: !isTagLimitReached,
            textInputAction: TextInputAction.done,
            onSubmitted: _addTagFromInput,
            onChanged: _handleTagTextChanged,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Add tags',
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleCreateTask() async {
    if (_titleController.text.isEmpty) {
      _showValidationPopup('Please fill Title');
      return;
    }

    if (_dueDate == null) {
      _showValidationPopup('Please fill Due Date');
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

      final newTask = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'priority': _selectedPriority,
        'status': 'todo',
        'progress': _progress,
        'isCompleted': false,
        'tags': payloadTags,
        'dueDate': _dueDate != null
            ? '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}'
            : '',
        'startDate': _startDate != null
            ? '${_startDate!.day.toString().padLeft(2, '0')}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.year}'
            : '',
        'endDate': '',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'assigneeId': '',
        'position': 0,
      };

      await _taskController.createTask(newTask);

      if (!mounted) return;
      CustomMessenger.show(context, 'Task created successfully!');

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
          'Create Task',
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
                _buildTextField(
                  controller: _titleController,
                  hintText: 'Title',
                  label: 'Title',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  hintText: 'Description.',
                  label: 'Description',
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
                _buildPrioritySelector(),
                const SizedBox(height: 28),
                _buildDateRow('Due Date', _dueDate, () => _selectDate(false)),
                const SizedBox(height: 28),
                _buildProgressSection(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleCreateTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appbarColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Create Task',
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
          firstChild: _buildProgressSlider(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: _buildTagsInputField(),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String label,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: appbarColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPriorityChip('High', 'high', Colors.red),
          const SizedBox(width: 8),
          _buildPriorityChip('Med', 'medium', Colors.orange),
          const SizedBox(width: 8),
          _buildPriorityChip('Low', 'low', Colors.grey),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(String label, String value, Color color) {
    final isSelected = _selectedPriority == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPriority = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          border: Border.all(color: color, width: isSelected ? 0 : 1.5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 19, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                'assets/svg/orangeCalendar.svg',
                width: 28,
                height: 28,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            Text(
              date != null
                  ? _formatDate(date)
                  : (label == 'Due Date' ? 'End Date' : 'No date'),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: date != null ? Colors.grey : appbarColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Completion',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            Row(
              children: [
                Text(
                  '$_progress%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => setState(() => _progress = 0),
                  child: Icon(
                    Icons.refresh,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: appbarColor,
            inactiveTrackColor: Colors.grey.shade300,
            thumbColor: appbarColor,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            trackHeight: 6,
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
          ),
          child: Slider(
            value: _progress.toDouble(),
            min: 0,
            max: 100,
            onChanged: (value) {
              setState(() => _progress = value.toInt());
            },
          ),
        ),
      ],
    );
  }
}
