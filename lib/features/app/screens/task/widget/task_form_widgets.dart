import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prioro/colors.dart';

class TaskFormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  const TaskFormTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
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
    );
  }
}

class TaskPrioritySelector extends StatelessWidget {
  final String selectedPriority;
  final ValueChanged<String> onPriorityChanged;

  const TaskPrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _TaskPriorityChip(
            label: 'High',
            value: 'high',
            color: Colors.red,
            isSelected: selectedPriority == 'high',
            onTap: () => onPriorityChanged('high'),
          ),
          const SizedBox(width: 8),
          _TaskPriorityChip(
            label: 'Med',
            value: 'medium',
            color: Colors.orange,
            isSelected: selectedPriority == 'medium',
            onTap: () => onPriorityChanged('medium'),
          ),
          const SizedBox(width: 8),
          _TaskPriorityChip(
            label: 'Low',
            value: 'low',
            color: Colors.grey,
            isSelected: selectedPriority == 'low',
            onTap: () => onPriorityChanged('low'),
          ),
        ],
      ),
    );
  }
}

class _TaskPriorityChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TaskPriorityChip({
    required this.label,
    required this.value,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
}

class TaskDateRow extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const TaskDateRow({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
  });

  String _formatDate(DateTime? value) {
    if (value == null) return 'No date';
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  }

  @override
  Widget build(BuildContext context) {
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
}

class TaskProgressSlider extends StatelessWidget {
  final int progress;
  final ValueChanged<double> onChanged;
  final VoidCallback onReset;

  const TaskProgressSlider({
    super.key,
    required this.progress,
    required this.onChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
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
                  '$progress%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onReset,
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
            value: progress.toDouble(),
            min: 0,
            max: 100,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class TaskTagsInputField extends StatelessWidget {
  final List<String> tags;
  final int maxTags;
  final TextEditingController tagsController;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onRemoveTag;

  const TaskTagsInputField({
    super.key,
    required this.tags,
    required this.maxTags,
    required this.tagsController,
    required this.onSubmitted,
    required this.onChanged,
    required this.onRemoveTag,
  });

  @override
  Widget build(BuildContext context) {
    final isTagLimitReached = tags.length >= maxTags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tags.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags
                .map(
                  (tag) =>
                      _TaskTagChip(tag: tag, onRemove: () => onRemoveTag(tag)),
                )
                .toList(),
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
            controller: tagsController,
            enabled: !isTagLimitReached,
            textInputAction: TextInputAction.done,
            onSubmitted: onSubmitted,
            onChanged: onChanged,
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
}

class _TaskTagChip extends StatelessWidget {
  final String tag;
  final VoidCallback onRemove;

  const _TaskTagChip({required this.tag, required this.onRemove});

  @override
  Widget build(BuildContext context) {
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
            onTap: onRemove,
            child: Icon(Icons.close, size: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
